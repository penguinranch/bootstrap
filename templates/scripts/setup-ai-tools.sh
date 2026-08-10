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

# Pinned so a container build installs a known version instead of whatever npm
# resolves that day — the same reason the GitHub Actions carry commit SHAs and
# the gitleaks download carries a checksum. Nothing watches these for updates
# (Dependabot does not read this file), so bump them here deliberately.
GEMINI_CLI_VERSION=0.54.4
CLAUDE_CLI_VERSION=2.1.226
NPM_VERSION=12.0.2

# Optional, third-party, and NOT installed by default — see
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
    log_warn "Approve each prompt yourself — nothing here consents on your behalf."
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
    log_info "Fresh bootstrap detected — installing pinned versions."
else
    log_info "Existing environment detected — ensuring tools match the pinned versions."
fi

# Installed unconditionally rather than only when the binary is missing: a
# container holding an older pin would otherwise never move to a new one.
log_info "Installing Gemini CLI ${GEMINI_CLI_VERSION}..."
npm install -g "@google/gemini-cli@${GEMINI_CLI_VERSION}"
log_success "Gemini CLI installed."

log_info "Installing Claude CLI ${CLAUDE_CLI_VERSION}..."
npm install -g "@anthropic-ai/claude-code@${CLAUDE_CLI_VERSION}"
log_success "Claude CLI installed."

log_info "Optional Gemini extensions are not installed automatically — run 'make ai-extensions'."

# Pin npm itself on fresh bootstrap
if $FRESH; then
    log_info "Installing npm ${NPM_VERSION}..."
    npm install -g "npm@${NPM_VERSION}" 2>/dev/null || log_warn "npm self-upgrade failed (non-critical)."
fi

# Write sentinel on fresh bootstrap
if $FRESH; then
    mkdir -p "$(dirname "$SENTINEL")"
    date -u '+%Y-%m-%dT%H:%M:%SZ' > "$SENTINEL"
    log_success "Bootstrap complete — sentinel written."
fi
