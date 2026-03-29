#!/bin/bash
set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

ensure_root
ensure_container

# Install Gemini CLI
if command -v gemini &> /dev/null; then
    log_success "Gemini CLI is already installed."
else
    log_info "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
    log_success "Gemini CLI installed. Run 'gemini' to start."
fi

# Install Claude CLI
if command -v claude &> /dev/null; then
    log_success "Claude CLI is already installed."
else
    log_info "Installing Claude CLI..."
    npm install -g @anthropic-ai/claude-code
    log_success "Claude CLI installed. Run 'claude' to start."
fi
