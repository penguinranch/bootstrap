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
    # Create a temporary directory for safe extraction
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Extract everything, but strip the root 'user-repo-hash' directory
    if ! curl -sL "$REPO_TAR_URL" | tar -xz -C "$temp_dir" --strip-components=1 2>/dev/null; then
        log_error "Failed to download or extract templates. Check your network connection."
        rm -rf "$temp_dir"
        exit 1
    fi

    # Move content from the templates directory to the current directory
    if [ -d "$temp_dir/templates" ]; then
        cp -af "$temp_dir/templates/." .
    else
        log_error "Templates directory not found in the downloaded archive."
        rm -rf "$temp_dir"
        exit 1
    fi

    rm -rf "$temp_dir"
}

finalize_setup() {
    # Ensure standard directory structure
    mkdir -p docs/decisions

    # Make scripts executable
    chmod +x scripts/*.sh 2>/dev/null || true
    chmod +x .githooks/* 2>/dev/null || true

    log_success "Bootstrap complete. Open in VS Code or Antigravity to start the Devcontainer."
}

# Main execution
check_environment
extract_templates
finalize_setup
