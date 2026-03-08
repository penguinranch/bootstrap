#!/bin/bash
set -euo pipefail

# Re-runnable script to initialize or update .env
if [ ! -f .env.example ]; then
    echo "Error: .env.example not found. Please create it first."
    exit 1
fi

if [ ! -f .env ]; then
    cp .env.example .env
    echo ".env created from template."
fi

echo "Setting up environment variables..."
read -p "Enter your Git Name: " GIT_NAME
read -p "Enter your Git Email: " GIT_EMAIL

echo ""
echo "Optional: SSH Public Key for commit signing."
echo "If you use 1Password as your SSH agent, you can copy the public key string directly."
echo "(e.g., ssh-ed25519 AAAAC3Nz...)"
read -p "Enter your SSH Public Key (press Enter to skip): " SSH_PUBLIC_KEY

echo ""
echo "Optional: The Gemini API Key is used by the Gemini CLI inside this Devcontainer."
echo "You can get an API key from: https://aistudio.google.com/app/apikey"
read -p "Enter your Gemini API Key (press Enter to skip): " GEMINI_API_KEY

echo ""
echo "Optional: The GitHub Token is used by the GitHub CLI and automations inside the Devcontainer."
echo "You can get a Fine-grained PAT from: https://github.com/settings/tokens?type=beta"
echo "It needs 'Pull Requests: Read-only' and 'Contents: Read-only' access to relevant repositories."
read -p "Enter your GitHub Token (press Enter to skip): " GITHUB_TOKEN

if [ -n "$GITHUB_TOKEN" ]; then
    echo "To authenticate the GitHub CLI, run: echo \$GITHUB_TOKEN | gh auth login --with-token"
fi

# Portable sed: works on both macOS (BSD sed) and Linux (GNU sed)
portable_sed() {
    if sed --version 2>/dev/null | grep -q GNU; then
        sed -i "$@"
    else
        sed -i '' "$@"
    fi
}

# Function to securely update or append inside .env
update_env() {
    local key=$1
    local value=$2
    if grep -q "^${key}=" .env; then
        portable_sed "s|^${key}=.*|${key}=${value}|" .env
    else
        echo "${key}=${value}" >> .env
    fi
}

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

if [ -n "$GITHUB_TOKEN" ]; then
    update_env "GITHUB_TOKEN" "$GITHUB_TOKEN"
    # Authenticate GitHub CLI if we are in an environment where gh is available
    if command -v gh &> /dev/null; then
        echo "$GITHUB_TOKEN" | gh auth login --with-token
        gh auth setup-git
        echo "GitHub CLI authenticated and configured as Git credential helper."
    fi
fi

# Update the LICENSE file if it exists
if [ -f "LICENSE" ] && [ -n "$GIT_NAME" ]; then
    CURRENT_YEAR=$(date +"%Y")
    portable_sed "s|\[Year\]|${CURRENT_YEAR}|g" LICENSE
    portable_sed "s|\[Full Name\]|${GIT_NAME}|g" LICENSE
fi

echo "✅ Configuration complete. Restart your terminal or source the .env file."