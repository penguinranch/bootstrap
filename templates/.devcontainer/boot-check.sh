#!/bin/bash
set -euo pipefail

if [ ! -f .env ]; then
    echo "⚠️  WARNING: .env file not found."
    echo "Please run './scripts/setup-env.sh' in the terminal to initialize your environment variables."
else
    echo "✅ .env found. Exporting variables safely..."
    while IFS='=' read -r key value; do
        # Skip empty lines and comments
        if [[ -n "$key" && ! "$key" =~ ^# ]]; then
            # Trim leading/trailing whitespace from key and value
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs)
            export "$key=$value"
        fi
    done < ".env"

    # Configure Git if found in .env
    if [ -n "${GIT_NAME:-}" ]; then
        git config --global user.name "$GIT_NAME"
    fi
    if [ -n "${GIT_EMAIL:-}" ]; then
        git config --global user.email "$GIT_EMAIL"
    fi
    if [ -n "${SSH_PUBLIC_KEY:-}" ]; then
        git config --global gpg.format ssh
        git config --global user.signingkey "key::${SSH_PUBLIC_KEY}"
        git config --global commit.gpgsign true
    fi

    # Configure GitHub CLI as credential helper if token is present
    if [ -n "${GITHUB_TOKEN:-}" ] && command -v gh &> /dev/null; then
        gh auth setup-git
    fi
fi