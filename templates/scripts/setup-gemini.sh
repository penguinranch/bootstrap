#!/bin/bash
set -euo pipefail

# Install Gemini CLI globally
echo "Installing Gemini CLI..."
npm install -g @google/gemini-cli

echo "✅ Gemini CLI setup complete! Run 'gemini' to start."
