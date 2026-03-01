#!/bin/bash
# Usage: curl -sSL https://raw.githubusercontent.com/penguinranch/bootstrap/main/install.sh | bash

REPO_TAR_URL="https://github.com/penguinranch/bootstrap/tarball/main"

echo "🚀 Initializing Gold Standard Environment..."

# Download and extract the templates directory
echo "Downloading the latest templates..."
curl -sL "$REPO_TAR_URL" | tar -xz --strip-components=2 "*/templates/"

# Ensure standard directory structure
mkdir -p docs/decisions

# Make scripts executable
chmod +x .devcontainer/boot-check.sh scripts/setup-env.sh

echo "✅ Bootstrap complete. Open in VS Code to start the Devcontainer."