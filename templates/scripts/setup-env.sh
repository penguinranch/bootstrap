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
echo "Optional: The Gemini API Key is used by the Gemini CLI inside this Devcontainer."
echo "You can get an API key from: https://aistudio.google.com/app/apikey"
read -p "Enter your Gemini API Key (press Enter to skip): " GEMINI_API_KEY

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

# Also configure git locally for the current environment
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

if [ -n "$GEMINI_API_KEY" ]; then
    update_env "GEMINI_API_KEY" "$GEMINI_API_KEY"
fi

# Update the LICENSE file if it exists
if [ -f "LICENSE" ] && [ -n "$GIT_NAME" ]; then
    CURRENT_YEAR=$(date +"%Y")
    portable_sed "s|\[Year\]|${CURRENT_YEAR}|g" LICENSE
    portable_sed "s|\[Full Name\]|${GIT_NAME}|g" LICENSE
fi

echo "✅ Configuration complete. Restart your terminal or source the .env file."