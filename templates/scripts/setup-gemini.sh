#!/bin/bash
# Source shared utilities
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

ensure_root

# Install Gemini CLI globally
if command -v gemini &> /dev/null; then
    log_success "Gemini CLI is already installed."
else
    log_info "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
    log_success "Gemini CLI setup complete! Run 'gemini' to start."
fi
