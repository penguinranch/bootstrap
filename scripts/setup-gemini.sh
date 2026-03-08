#!/bin/bash
set -euo pipefail

# Install Gemini CLI globally
if command -v gemini &> /dev/null; then
    echo "Gemini CLI is already installed."
else
    echo "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
fi

echo "✅ Gemini CLI setup complete! Run 'gemini' to start."
