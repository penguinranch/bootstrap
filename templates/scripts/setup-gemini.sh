#!/bin/bash
# Install Gemini CLI and useful extensions globally

echo "Installing Gemini CLI..."
npm install -g geminicli

echo "Installing Gemini CLI Extensions..."
geminicli extension install gemini-cli-security code-review github Endor-Labs-Code-Security Snyk

echo "Gemini CLI setup complete!"
