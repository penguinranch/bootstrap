#!/bin/bash
set -euo pipefail

# Usage: curl -sSL https://raw.githubusercontent.com/penguinranch/bootstrap/main/install.sh | bash

REPO_TAR_URL="${REPO_TAR_URL:-https://github.com/penguinranch/bootstrap/tarball/main}"

echo "🚀 Initializing Gold Standard Environment..."

# Guard: prevent overwriting an existing project (bypass with BOOTSTRAP_DEV=1 for local testing)
if [ -d ".devcontainer" ] && [ "${BOOTSTRAP_DEV:-0}" != "1" ]; then
  echo "⚠️  Existing project structure detected. Aborting bootstrap to prevent overwriting files."
  echo "   (Set BOOTSTRAP_DEV=1 to bypass this check for local development.)"
  exit 1
fi

# Download and extract the templates directory
echo "Downloading the latest templates..."
if ! curl -sL "$REPO_TAR_URL" | tar -xz --wildcards --strip-components=2 "*/templates/"; then
  echo "❌ Failed to download or extract templates. Check your network connection."
  exit 1
fi

# Ensure standard directory structure
mkdir -p docs/decisions

# Make scripts executable
chmod +x .devcontainer/boot-check.sh scripts/setup-env.sh scripts/setup-gemini.sh scripts/start-container.sh scripts/troubleshooting.sh
chmod +x .githooks/*

echo "✅ Bootstrap complete. Open in VS Code or Antigravity to start the Devcontainer."