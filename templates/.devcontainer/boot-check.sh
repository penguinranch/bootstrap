#!/bin/bash
if [ ! -f .env ]; then
    echo "⚠️  WARNING: .env file not found."
    echo "Please run './scripts/setup-env.sh' in the terminal to initialize your environment variables."
else
    echo "✅ .env found. Exporting variables safely..."
    while IFS='=' read -r key value; do
        if [[ ! -z "$key" && ! "$key" =~ ^# ]]; then
            export "$key=$value"
        fi
    done < ".env"

    # Configure Git if found in .env
    if [ ! -z "$GIT_NAME" ]; then
        git config --global user.name "$GIT_NAME"
    fi
    if [ ! -z "$GIT_EMAIL" ]; then
        git config --global user.email "$GIT_EMAIL"
    fi
fi