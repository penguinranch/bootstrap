#!/bin/bash
set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

ensure_root
ensure_container

# Export .env values so API keys are available for CLI tools
safe_export_env

SENTINEL=".devcontainer/.bootstrapped"
FRESH=false

if [ ! -f "$SENTINEL" ]; then
    FRESH=true
    log_info "Fresh bootstrap detected — installing latest versions."
else
    log_info "Existing environment detected — ensuring tools are present."
fi

# Install or upgrade Gemini CLI
if $FRESH; then
    log_info "Installing Gemini CLI (latest)..."
    npm install -g @google/gemini-cli@latest
    log_success "Gemini CLI installed."
elif ! command -v gemini &> /dev/null; then
    log_info "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
    log_success "Gemini CLI installed."
else
    log_success "Gemini CLI is already installed."
fi

# Install or upgrade Claude CLI
if $FRESH; then
    log_info "Installing Claude CLI (latest)..."
    npm install -g @anthropic-ai/claude-code@latest
    log_success "Claude CLI installed."
elif ! command -v claude &> /dev/null; then
    log_info "Installing Claude CLI..."
    npm install -g @anthropic-ai/claude-code
    log_success "Claude CLI installed."
else
    log_success "Claude CLI is already installed."
fi

# Install Gemini CLI extensions (security & code quality)
if command -v gemini &> /dev/null; then
    GEMINI_EXTENSIONS=(
        "https://github.com/gemini-cli-extensions/security"
        "https://github.com/gemini-cli-extensions/code-review"
        "https://github.com/endorlabs/gemini-extension"
    )
    for ext in "${GEMINI_EXTENSIONS[@]}"; do
        ext_name=$(basename "$ext")
        log_info "Installing Gemini extension: $ext_name..."
        echo "Y" | gemini extensions install "$ext" 2>/dev/null || log_warn "Failed to install $ext_name (non-critical)."
    done
    log_success "Gemini CLI extensions configured."
fi

# Upgrade npm itself on fresh bootstrap
if $FRESH; then
    log_info "Upgrading npm to latest..."
    npm install -g npm@latest 2>/dev/null || log_warn "npm self-upgrade failed (non-critical)."
fi

# Write sentinel on fresh bootstrap
if $FRESH; then
    mkdir -p "$(dirname "$SENTINEL")"
    date -u '+%Y-%m-%dT%H:%M:%SZ' > "$SENTINEL"
    log_success "Bootstrap complete — sentinel written."
fi
