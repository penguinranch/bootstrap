#!/bin/bash
set -euo pipefail

# Change to the repository root relative to the script's location
cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "🚀 Starting Antigravity Devcontainer environment..."

# 1. Check existing environment variables and apply Git configuration
echo "Checking environment variables..."
bash ./.devcontainer/boot-check.sh

# 2. Configure Git hooks via Makefile
echo "Ensuring Git hooks are configured..."
make setup

echo "✅ Container startup complete."
