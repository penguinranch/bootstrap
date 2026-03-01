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
fi