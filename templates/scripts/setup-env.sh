#!/bin/bash
# shellcheck shell=bash
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

log_info "Setting up environment variables..."
read -rp "Enter your Git Name: " GIT_NAME
read -rp "Enter your Git Email: " GIT_EMAIL

echo ""
log_info "Optional: SSH Public Key for commit signing."
echo "If you use 1Password as your SSH agent, you can copy the public key string directly."
echo "(e.g., ssh-ed25519 AAAAC3Nz...)"
read -rp "Enter your SSH Public Key (press Enter to skip): " SSH_PUBLIC_KEY

echo ""
log_info "Optional: The Gemini API Key is used by the Gemini CLI inside this Devcontainer."
echo "You can get an API key from: https://aistudio.google.com/app/apikey"
read -rp "Enter your Gemini API Key (press Enter to skip): " GEMINI_API_KEY

echo ""
log_info "Optional: Authenticate with GitHub CLI for automations inside the Devcontainer."
echo "To authenticate, you can run: gh auth login"

update_env "GIT_NAME" "$GIT_NAME"
update_env "GIT_EMAIL" "$GIT_EMAIL"

if [ -n "$SSH_PUBLIC_KEY" ]; then
    update_env "SSH_PUBLIC_KEY" "$SSH_PUBLIC_KEY"
fi

# Also configure git locally for the current environment
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

if [ -n "$SSH_PUBLIC_KEY" ]; then
    git config --global gpg.format ssh
    git config --global user.signingkey "key::${SSH_PUBLIC_KEY}"
    git config --global commit.gpgsign true
fi

if [ -n "$GEMINI_API_KEY" ]; then
    update_env "GEMINI_API_KEY" "$GEMINI_API_KEY"
fi

# Update the LICENSE file if it exists
if [ -f "LICENSE" ] && [ -n "$GIT_NAME" ]; then
    CURRENT_YEAR=$(date +"%Y")
    portable_sed "s|\[Year\]|${CURRENT_YEAR}|g" LICENSE
    portable_sed "s|\[Full Name\]|${GIT_NAME}|g" LICENSE
fi

log_success "Configuration complete. Restart your terminal or source the .env file."