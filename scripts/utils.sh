#!/bin/bash
# shellcheck shell=bash
# utils.sh: Shared utility functions for Penguin Ranch scripts.

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

# Portable sed: works on both macOS (BSD sed) and Linux (GNU sed)
portable_sed() {
    if sed --version 2>/dev/null | grep -q GNU; then
        sed -i "$@"
    else
        sed -i '' "$@"
    fi
}

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
        awk -v k="$key" -v v="$value" 'BEGIN{FS=OFS="="} $1==k{$0=k"="v} {print}' "$env_file" > "$tmp_file"
        mv "$tmp_file" "$env_file"
    else
        printf '%s=%s\n' "$key" "$value" >> "$env_file"
    fi
}

# Safely export variables from .env, restricted to an allowlist of known keys.
# Prevents hostile key names (e.g. LD_PRELOAD, PATH) from being injected.
safe_export_env() {
    local env_file=${1:-.env}
    local -a ALLOWED_KEYS=(
        GIT_NAME GIT_EMAIL SSH_PUBLIC_KEY
        GEMINI_API_KEY ANTHROPIC_API_KEY GITHUB_TOKEN
    )
    if [ ! -f "$env_file" ]; then
        return
    fi
    while IFS='=' read -r key value; do
        if [[ -n "$key" && ! "$key" =~ ^# ]]; then
            key="${key#"${key%%[![:space:]]*}"}"
            key="${key%"${key##*[![:space:]]}"}"
            value="${value#"${value%%[![:space:]]*}"}"
            value="${value%"${value##*[![:space:]]}"}"
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

# Read a value from .env by key (returns empty string if not found)
read_env() {
    local key=$1
    local env_file=${2:-.env}
    if [ -f "$env_file" ]; then
        grep -m1 "^${key}=" "$env_file" 2>/dev/null | cut -d'=' -f2- || true
    fi
}

# Check if the SSH agent is available for commit signing.
# Returns 0 if SSH_AUTH_SOCK is set and the agent responds.
ssh_signing_available() {
    [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "${SSH_AUTH_SOCK}" ] && ssh-add -L &>/dev/null
}

# Ensure we are at the repository root
ensure_root() {
    local script_dir
    script_dir=$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")
    cd "$script_dir/.." || exit 1
}
