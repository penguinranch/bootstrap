#!/bin/bash
# shellcheck shell=bash
# utils.sh: Shared utility functions for Penguin Ranch scripts.
# NOTE: This file must stay identical to its counterpart in the bootstrap
# repository (scripts/utils.sh <-> templates/scripts/utils.sh) — CI enforces this.

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}ℹ️  [INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}✅ [SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠️  [WARN]${NC} $1"; }
log_error() { echo -e "${RED}❌ [ERROR]${NC} $1"; }

# Safely update or append a key=value pair inside an env file.
# Uses awk instead of sed to avoid injection via special characters in values.
update_env() {
    local key=$1
    local value=$2
    local env_file=${3:-.env}

    if [ ! -f "$env_file" ]; then
        touch "$env_file"
    fi

    if grep -q "^${key}=" "$env_file"; then
        local tmp_file
        tmp_file=$(mktemp)
        # The value goes in via ENVIRON, not -v: awk -v interprets C escapes,
        # so a value containing \n or \t would corrupt the file.
        V="$value" awk -v k="$key" 'BEGIN{FS=OFS="="} $1==k{$0=k"="ENVIRON["V"]} {print}' "$env_file" > "$tmp_file"
        mv "$tmp_file" "$env_file"
    else
        # A hand-edited file may lack a trailing newline — appending straight
        # onto the last line would fuse two entries together.
        if [ -s "$env_file" ] && [ -n "$(tail -c1 "$env_file")" ]; then
            echo >> "$env_file"
        fi
        printf '%s=%s\n' "$key" "$value" >> "$env_file"
    fi
}

# Keys allowed to cross from an env file into the environment. Anything else in
# the file is ignored, so a hostile key name (e.g. LD_PRELOAD, PATH) cannot be
# injected by editing .env.
ENV_ALLOWED_KEYS=(
    GIT_NAME GIT_EMAIL SSH_PUBLIC_KEY
    GEMINI_API_KEY ANTHROPIC_API_KEY GITHUB_TOKEN
    CONTEXT7_API_KEY
)

# Safely export variables from .env, restricted to the allowlist above.
# Accepts an optional path so callers can read a specific project's .env.
safe_export_env() {
    local env_file=${1:-.env}
    local -a ALLOWED_KEYS=("${ENV_ALLOWED_KEYS[@]}")
    if [ ! -f "$env_file" ]; then
        return
    fi
    # '|| [ -n "$key" ]' keeps the final line when the file has no trailing
    # newline — read returns non-zero at EOF and would silently drop it.
    while IFS='=' read -r key value || [ -n "$key" ]; do
        if [[ -n "$key" && ! "$key" =~ ^# ]]; then
            key="${key#"${key%%[![:space:]]*}"}"
            key="${key%"${key##*[![:space:]]}"}"
            value="${value#"${value%%[![:space:]]*}"}"
            value="${value%"${value##*[![:space:]]}"}"
            value=$(strip_matched_quotes "$value")
            # An empty value would clobber a key the host already provided
            # via containerEnv — skip it.
            [ -n "$value" ] || continue
            # Only export if key is in the allowlist
            for allowed in "${ALLOWED_KEYS[@]}"; do
                if [[ "$key" == "$allowed" ]]; then
                    export "$key=$value"
                    break
                fi
            done
        fi
    done < "$env_file"
}

# Emit 'export KEY=VALUE' lines for the allowlisted keys in an env file, with
# values shell-quoted for eval. Lets a shell profile pick up the keys without
# sourcing this library into the user's interactive namespace.
# The body is a subshell, so the parse never leaks into the caller.
print_env_exports() (
    local env_file=${1:-.env}
    local key
    safe_export_env "$env_file"
    for key in "${ENV_ALLOWED_KEYS[@]}"; do
        if [ -n "${!key:-}" ]; then
            printf 'export %s=%q\n' "$key" "${!key}"
        fi
    done
)

# Strip one pair of matched surrounding quotes, dotenv-style, so
# GIT_NAME="Jane Doe" doesn't produce a git identity with literal quotes.
strip_matched_quotes() {
    local value=$1
    if [ "${#value}" -ge 2 ]; then
        case "$value" in
            \"*\") value="${value#\"}"; value="${value%\"}" ;;
            \'*\') value="${value#\'}"; value="${value%\'}" ;;
        esac
    fi
    printf '%s' "$value"
}

# Read a value from .env by key (returns empty string if not found).
# Trims whitespace and strips matched quotes, same as safe_export_env.
read_env() {
    local key=$1
    local env_file=${2:-.env}
    local value
    if [ -f "$env_file" ]; then
        value=$(grep -m1 "^${key}=" "$env_file" 2>/dev/null | cut -d'=' -f2- || true)
        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"
        strip_matched_quotes "$value"
    fi
}

# Check if the SSH agent is available for commit signing.
# Returns 0 if SSH_AUTH_SOCK is set and the agent responds.
ssh_signing_available() {
    [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "${SSH_AUTH_SOCK}" ] && ssh-add -L &>/dev/null
}

# Install a block in the container's shell profiles that loads the project's
# allowlisted .env keys into future interactive shells. containerEnv only
# forwards host variables, and nothing else reads .env into a login shell, so
# without this the saved keys never reach the gemini/claude CLIs.
#
# Called from 'make setup' AND from postCreateCommand: $HOME is not on a named
# volume (only ~/.claude and ~/.gemini are), so a container rebuild wipes the
# profiles. Re-running it on create keeps a rebuild from silently unplugging
# the keys until someone thinks to run 'make setup' again.
# Idempotent — keyed on a per-project marker.
install_env_loader() {
    is_container || return 0
    local project_root rc_root rc_marker rc_file
    project_root="$(pwd)"
    # a single quote in the path would unbalance the quoting in the emitted
    # shell code and break every future shell in the container
    rc_root="${project_root//\'/\'\\\'\'}"
    rc_marker="# >>> project env: ${project_root} >>>"
    for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
        touch "$rc_file"
        if ! grep -qF "$rc_marker" "$rc_file"; then
            # Run through 'bash -c' and eval only the export lines, rather than
            # sourcing this file: it is a bash library (${!var}, [[ ]]) and one
            # of the two profiles is .zshrc, and sourcing would also define the
            # log helpers and color names (RED, NC, ...) in every session.
            # The root goes in as $1 so the bash snippet needs no interpolation.
            cat >> "$rc_file" <<RC_BLOCK

${rc_marker}
# Added by the bootstrap scripts — loads allowlisted keys from the project .env
if [ -f '${rc_root}/scripts/utils.sh' ] && [ -f '${rc_root}/.env' ]; then
    eval "\$(bash -c '. "\$1/scripts/utils.sh"; print_env_exports "\$1/.env"' _ '${rc_root}')"
fi
# <<< project env: ${project_root} <<<
RC_BLOCK
        fi
    done
}

# Ensure we are at the repository root
cd_repo_root() {
    local script_dir
    script_dir=$(dirname "${BASH_SOURCE[0]}")
    cd "$script_dir/.." || exit 1
}

# Check if we are running inside a container
is_container() {
    [ -f /.dockerenv ] || [ -n "${REMOTE_CONTAINERS:-}" ] || [ -n "${CODESPACES:-}" ]
}

# Ensure the script is running in a devcontainer
ensure_container() {
    if ! is_container; then
        log_error "This script must be run inside a devcontainer."
        log_warn "Please reopen this project in a container to continue."
        exit 1
    fi
}
