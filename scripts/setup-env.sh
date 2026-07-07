#!/bin/bash
set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

ensure_root

# Re-runnable script to initialize or update .env
if [ ! -f .env.example ]; then
    log_error ".env.example not found. Please create it first."
    exit 1
fi

if [ ! -f .env ]; then
    cp .env.example .env
    log_success ".env created from template."
fi

# Load existing values as defaults
EXISTING_GIT_NAME=$(read_env "GIT_NAME")
EXISTING_GIT_EMAIL=$(read_env "GIT_EMAIL")
EXISTING_SSH_KEY=$(read_env "SSH_PUBLIC_KEY")
EXISTING_GEMINI_KEY=$(read_env "GEMINI_API_KEY")
EXISTING_ANTHROPIC_KEY=$(read_env "ANTHROPIC_API_KEY")

log_info "Setting up environment variables (Enter keeps the current value, '-' clears it)..."

# Values entered as '-' clear the saved value — otherwise a mistyped key
# or a retired SSH key could never be removed through the wizard.
clear_sentinel() {
    if [ "$1" = "-" ]; then echo ""; else echo "$1"; fi
}

if [ -n "$EXISTING_GIT_NAME" ]; then
    read -rp "Git Name [$EXISTING_GIT_NAME]: " GIT_NAME
else
    read -rp "Git Name: " GIT_NAME
fi
GIT_NAME="${GIT_NAME:-$EXISTING_GIT_NAME}"

if [ -n "$EXISTING_GIT_EMAIL" ]; then
    read -rp "Git Email [$EXISTING_GIT_EMAIL]: " GIT_EMAIL
else
    read -rp "Git Email: " GIT_EMAIL
fi
GIT_EMAIL="${GIT_EMAIL:-$EXISTING_GIT_EMAIL}"

echo ""
log_info "Optional: SSH Public Key for commit signing."
echo "If you use 1Password as your SSH agent, you can copy the public key string directly."
echo "(e.g., ssh-ed25519 AAAAC3Nz...)"
if [ -n "$EXISTING_SSH_KEY" ]; then
    read -rp "SSH Public Key [****${EXISTING_SSH_KEY: -12}]: " SSH_PUBLIC_KEY
else
    read -rp "SSH Public Key (press Enter to skip): " SSH_PUBLIC_KEY
fi
SSH_PUBLIC_KEY="${SSH_PUBLIC_KEY:-$EXISTING_SSH_KEY}"
SSH_PUBLIC_KEY=$(clear_sentinel "$SSH_PUBLIC_KEY")

# API keys are read with -s so they don't land in terminal scrollback.
echo ""
log_info "Optional: The Gemini API Key is used by the Gemini CLI inside this Devcontainer."
echo "You can get an API key from: https://aistudio.google.com/app/apikey"
if [ -n "$EXISTING_GEMINI_KEY" ]; then
    read -rsp "Gemini API Key [****${EXISTING_GEMINI_KEY: -4}] (hidden): " GEMINI_API_KEY
else
    read -rsp "Gemini API Key (hidden, press Enter to skip): " GEMINI_API_KEY
fi
echo ""
GEMINI_API_KEY="${GEMINI_API_KEY:-$EXISTING_GEMINI_KEY}"
GEMINI_API_KEY=$(clear_sentinel "$GEMINI_API_KEY")

echo ""
log_info "Optional: The Anthropic API Key is used by the Claude CLI inside this Devcontainer."
echo "You can also authenticate interactively by running: claude"
if [ -n "$EXISTING_ANTHROPIC_KEY" ]; then
    read -rsp "Anthropic API Key [****${EXISTING_ANTHROPIC_KEY: -4}] (hidden): " ANTHROPIC_API_KEY
else
    read -rsp "Anthropic API Key (hidden, press Enter to skip): " ANTHROPIC_API_KEY
fi
echo ""
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-$EXISTING_ANTHROPIC_KEY}"
ANTHROPIC_API_KEY=$(clear_sentinel "$ANTHROPIC_API_KEY")

echo ""
log_info "Optional: Authenticate with GitHub CLI for automations inside the Devcontainer."
echo "To authenticate, run: gh auth login"

# Write values back unconditionally so a '-' clear persists to .env
update_env "GIT_NAME" "$GIT_NAME"
update_env "GIT_EMAIL" "$GIT_EMAIL"
update_env "SSH_PUBLIC_KEY" "$SSH_PUBLIC_KEY"
update_env "GEMINI_API_KEY" "$GEMINI_API_KEY"
update_env "ANTHROPIC_API_KEY" "$ANTHROPIC_API_KEY"

# Configure git for the current environment
if [ -n "$GIT_NAME" ]; then
    git config --global user.name "$GIT_NAME"
fi
if [ -n "$GIT_EMAIL" ]; then
    git config --global user.email "$GIT_EMAIL"
fi

if [ -n "$SSH_PUBLIC_KEY" ]; then
    git config --global gpg.format ssh
    git config --global user.signingkey "key::${SSH_PUBLIC_KEY}"
    if ssh_signing_available; then
        git config --global commit.gpgsign true
        log_success "SSH commit signing enabled (agent available)."
    else
        git config --global commit.gpgsign false
        log_warn "SSH key saved but agent not available — signing disabled. Commits will proceed unsigned."
    fi
elif [ -n "$EXISTING_SSH_KEY" ]; then
    # Key was cleared with '-' — remove the signing config that pointed at it
    git config --global --unset user.signingkey 2>/dev/null || true
    git config --global commit.gpgsign false
    log_info "SSH signing key cleared — commit signing disabled."
fi

# Update the LICENSE file if it exists
if [ -f "LICENSE" ] && [ -n "$GIT_NAME" ]; then
    CURRENT_YEAR=$(date +"%Y")
    tmp_license=$(mktemp)
    awk -v year="$CURRENT_YEAR" -v name="$GIT_NAME" '
        BEGIN { gsub(/&/, "\\\\&", name) }
        { gsub(/\[Year\]/, year); gsub(/\[Full Name\]/, name); print }
    ' LICENSE > "$tmp_license"
    mv "$tmp_license" LICENSE
fi

# Make saved keys available to future interactive shells: source .env through
# the allowlisted parser from the container's shell profiles. Without this,
# keys saved here would never reach the gemini/claude CLIs — containerEnv only
# forwards host variables, and nothing else reads .env into a login shell.
if is_container; then
    PROJECT_ROOT="$(pwd)"
    RC_MARKER="# >>> project env: ${PROJECT_ROOT} >>>"
    for rc_file in "$HOME/.bashrc" "$HOME/.zshrc"; do
        touch "$rc_file"
        if ! grep -qF "$RC_MARKER" "$rc_file"; then
            {
                echo ""
                echo "$RC_MARKER"
                echo "# Added by 'make setup' — loads allowlisted keys from the project .env"
                echo "if [ -f '${PROJECT_ROOT}/scripts/utils.sh' ] && [ -f '${PROJECT_ROOT}/.env' ]; then"
                echo "    source '${PROJECT_ROOT}/scripts/utils.sh'"
                echo "    safe_export_env '${PROJECT_ROOT}/.env'"
                echo "fi"
                echo "# <<< project env: ${PROJECT_ROOT} <<<"
            } >> "$rc_file"
        fi
    done
    log_success "Shell profiles now load .env keys — open a new terminal to apply."
fi

log_success "Configuration complete."
