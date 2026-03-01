#!/bin/bash
if [ ! -f .env ]; then
    echo "⚠️  WARNING: .env file not found."
    echo "Please run './scripts/setup-env.sh' in the terminal to initialize your environment variables."
else
    echo "✅ .env found. Exporting variables..."
    export $(grep -v '^#' .env | xargs)
fi