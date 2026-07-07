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

# Refuse to overwrite anything that already exists in the target directory.
# The .devcontainer check above fails fast before downloading; this is the
# real guard, comparing every payload file against the destination.
check_collisions() {
    local payload_dir="$1"
    local temp_dir="$2"
    if [ "${BOOTSTRAP_DEV:-0}" = "1" ]; then
        return 0
    fi
    local collisions=""
    local rel
    while IFS= read -r rel; do
        rel="${rel#./}"
        if [ -e "$rel" ]; then
            collisions="${collisions}   ${rel}
"
        fi
    done < <(cd "$payload_dir" && find . -type f)
    if [ -n "$collisions" ]; then
        log_error "These files already exist and would be overwritten:"
        printf '%s' "$collisions"
        echo "   Move them aside (or start from an empty directory) and re-run."
        rm -rf "$temp_dir"
        exit 1
    fi
}

extract_templates() {
    log_info "Downloading the latest templates..."
    # Create a temporary directory for safe extraction
    local temp_dir
    temp_dir=$(mktemp -d)

    if ! curl -sL "$REPO_TAR_URL" | tar -xz -C "$temp_dir" 2>/dev/null; then
        log_error "Failed to download or extract templates. Check your network connection."
        rm -rf "$temp_dir"
        exit 1
    fi

    # The tarball unpacks to a single 'user-repo-hash' directory; its name
    # carries the source commit, which we stamp for later upstream diffing
    local extracted_dir
    extracted_dir=$(find "$temp_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)

    # Move content from the templates directory to the current directory
    if [ -n "$extracted_dir" ] && [ -d "$extracted_dir/templates" ]; then
        check_collisions "$extracted_dir/templates" "$temp_dir"
        cp -af "$extracted_dir/templates/." .
        BOOTSTRAP_COMMIT="${extracted_dir##*-}"
    else
        log_error "Templates directory not found in the downloaded archive."
        rm -rf "$temp_dir"
        exit 1
    fi

    rm -rf "$temp_dir"
}

write_version_stamp() {
    {
        echo "# Written by the penguinranch/bootstrap installer."
        echo "# Records which template version this project was scaffolded from,"
        echo "# so agents can diff against upstream and propose updates."
        echo "commit=${BOOTSTRAP_COMMIT}"
        echo "installed=$(date +%Y-%m-%d)"
        echo "source=https://github.com/penguinranch/bootstrap"
    } > .bootstrap-version
}

finalize_setup() {
    # Ensure standard directory structure
    mkdir -p docs

    # Make scripts executable
    chmod +x scripts/*.sh 2>/dev/null || true
    chmod +x .githooks/* 2>/dev/null || true

    log_success "Bootstrap complete. Open in VS Code or Antigravity to start the Devcontainer."
}

# Main execution
check_environment
extract_templates
write_version_stamp
finalize_setup
