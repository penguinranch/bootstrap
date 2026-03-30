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

log_info "Setting up environment variables (press Enter to keep current value)..."

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

echo ""
log_info "Optional: The Gemini API Key is used by the Gemini CLI inside this Devcontainer."
echo "You can get an API key from: https://aistudio.google.com/app/apikey"
if [ -n "$EXISTING_GEMINI_KEY" ]; then
    read -rp "Gemini API Key [****${EXISTING_GEMINI_KEY: -4}]: " GEMINI_API_KEY
else
    read -rp "Gemini API Key (press Enter to skip): " GEMINI_API_KEY
fi
GEMINI_API_KEY="${GEMINI_API_KEY:-$EXISTING_GEMINI_KEY}"

echo ""
log_info "Optional: The Anthropic API Key is used by the Claude CLI inside this Devcontainer."
echo "You can also authenticate interactively by running: claude"
if [ -n "$EXISTING_ANTHROPIC_KEY" ]; then
    read -rp "Anthropic API Key [****${EXISTING_ANTHROPIC_KEY: -4}]: " ANTHROPIC_API_KEY
else
    read -rp "Anthropic API Key (press Enter to skip): " ANTHROPIC_API_KEY
fi
ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-$EXISTING_ANTHROPIC_KEY}"

echo ""
log_info "Optional: Authenticate with GitHub CLI for automations inside the Devcontainer."
echo "To authenticate, run: gh auth login"

# Write values back (preserves existing if user pressed Enter)
update_env "GIT_NAME" "$GIT_NAME"
update_env "GIT_EMAIL" "$GIT_EMAIL"

if [ -n "$SSH_PUBLIC_KEY" ]; then
    update_env "SSH_PUBLIC_KEY" "$SSH_PUBLIC_KEY"
fi

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
    git config --global commit.gpgsign true
fi

if [ -n "$GEMINI_API_KEY" ]; then
    update_env "GEMINI_API_KEY" "$GEMINI_API_KEY"
fi

if [ -n "$ANTHROPIC_API_KEY" ]; then
    update_env "ANTHROPIC_API_KEY" "$ANTHROPIC_API_KEY"
fi

# Update the LICENSE file if it exists
if [ -f "LICENSE" ] && [ -n "$GIT_NAME" ]; then
    CURRENT_YEAR=$(date +"%Y")
    portable_sed "s|\[Year\]|${CURRENT_YEAR}|g" LICENSE
    portable_sed "s|\[Full Name\]|${GIT_NAME}|g" LICENSE
fi

log_success "Configuration complete. Restart your terminal or source the .env file."
