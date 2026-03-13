#!/bin/bash
set -euo pipefail

# Usage: curl -sSL https://raw.githubusercontent.com/penguinranch/bootstrap/main/install.sh | bash

# Basic logging for the installer (no external dependencies)
log_info() { echo -e "\033[0;34mℹ️  [INFO]\033[0m $1"; }
log_success() { echo -e "\033[0;32m✅ [SUCCESS]\033[0m $1"; }
log_error() { echo -e "\033[0;31m❌ [ERROR]\033[0m $1"; }

REPO_TAR_URL="${REPO_TAR_URL:-https://github.com/penguinranch/bootstrap/tarball/main}"

check_environment() {
    log_info "Initializing Gold Standard Environment..."
    # Guard: prevent overwriting an existing project (bypass with BOOTSTRAP_DEV=1 for local testing)
    if [ -d ".devcontainer" ] && [ "${BOOTSTRAP_DEV:-0}" != "1" ]; then
        log_error "Existing project structure detected. Aborting bootstrap to prevent overwriting files."
        echo "   (Set BOOTSTRAP_DEV=1 to bypass this check for local development.)"
        exit 1
    fi
}

extract_templates() {
    log_info "Downloading the latest templates..."
    # Try GNU tar (with --wildcards) first, then fallback to BSD tar (macOS)
    if ! curl -sL "$REPO_TAR_URL" | tar -xz --wildcards --strip-components=2 "*/templates/" 2>/dev/null; then
        if ! curl -sL "$REPO_TAR_URL" | tar -xz --strip-components=2 2>/dev/null; then
            log_error "Failed to download or extract templates. Check your network connection."
            exit 1
        fi
    fi
}

finalize_setup() {
    # Ensure standard directory structure
    mkdir -p docs/decisions

    # Make scripts executable
    chmod +x .devcontainer/boot-check.sh scripts/*.sh 2>/dev/null || true
    chmod +x .githooks/* 2>/dev/null || true

    log_success "Bootstrap complete. Open in VS Code or Antigravity to start the Devcontainer."
}

# Main execution
check_environment
extract_templates
finalize_setup
table
chmod +x .devcontainer/boot-check.sh scripts/*.sh
chmod +x .githooks/*

echo "✅ Bootstrap complete. Open in VS Code or Antigravity to start the Devcontainer."