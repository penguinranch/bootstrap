#!/bin/bash
set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

cd_repo_root
ensure_container

# Export .env values so API keys are available for CLI tools
safe_export_env .env

# The AI CLIs deliberately track @latest, unlike the local MCP servers, which
# carry exact pins in .mcp/package.json. Dependabot watches that manifest and
# opens bump PRs for it, so those pins stay current. Nothing watches a pin for
# these two CLIs: they ship several releases a week, so a pin here would rot
# silently and hand out a stale CLI. The MCP servers are pinned because an agent
# launches them on every session with the host Docker socket in reach. These two
# are installed once, into the container, by a developer running setup.

# Optional, third-party, and NOT installed by default: see
# install_gemini_extensions below.
GEMINI_EXTENSIONS=(
    "https://github.com/gemini-cli-extensions/security"
    "https://github.com/gemini-cli-extensions/code-review"
    "https://github.com/endorlabs/gemini-extension"
)

# These pull code from repositories outside this project into a container that
# has the host Docker socket mounted, so the trust prompt is the only thing
# standing between a compromised extension and the host. It is left for a human
# to answer: '--consent' used to auto-grant it from postCreateCommand, where
# nobody was watching.
install_gemini_extensions() {
    if ! command -v gemini &> /dev/null; then
        log_error "Gemini CLI not installed. Run 'make setup' first."
        exit 1
    fi
    log_warn "These extensions are third-party code from outside this project."
    log_warn "Approve each prompt yourself: nothing here consents on your behalf."
    local ext ext_name
    for ext in "${GEMINI_EXTENSIONS[@]}"; do
        ext_name=$(basename "$ext")
        log_info "Installing Gemini extension: $ext_name..."
        gemini extensions install "$ext" || log_warn "Failed to install $ext_name (non-critical)."
    done
}

if [ "${1:-}" = "--extensions" ]; then
    install_gemini_extensions
    exit 0
fi

SENTINEL=".devcontainer/.bootstrapped"
FRESH=false

if [ ! -f "$SENTINEL" ]; then
    FRESH=true
    log_info "Fresh bootstrap detected: installing latest versions."
else
    log_info "Existing environment detected: ensuring tools are present."
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

log_info "Optional Gemini extensions are not installed automatically: run 'make ai-extensions'."

# Upgrade npm itself on fresh bootstrap
if $FRESH; then
    log_info "Upgrading npm to latest..."
    npm install -g npm@latest 2>/dev/null || log_warn "npm self-upgrade failed (non-critical)."
fi

# Write sentinel on fresh bootstrap
if $FRESH; then
    mkdir -p "$(dirname "$SENTINEL")"
    date -u '+%Y-%m-%dT%H:%M:%SZ' > "$SENTINEL"
    log_success "Bootstrap complete: sentinel written."
fi
