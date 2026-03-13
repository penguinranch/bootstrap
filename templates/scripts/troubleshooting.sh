#!/bin/bash
set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

ensure_root

log_info "Starting Devcontainer Troubleshooting..."
echo "----------------------------------------"

ISSUE_FOUND=0

# 1. Check for .env file
log_info "Checking for .env file..."
if [ ! -f .env ]; then
    log_error ".env file is missing."
    if [ -f .env.example ]; then
        log_info ".env.example found. Creating .env from template..."
        cp .env.example .env
        log_success ".env created. Please run './scripts/setup-env.sh' to populate it."
    else
        log_error ".env.example is also missing. Cannot create .env block automatically."
        ISSUE_FOUND=1
    fi
else
    # Basic check to see if .env has been filled out (checking for placeholder values)
    if grep -q "YOUR_GIT_NAME_HERE" .env || grep -q "YOUR_GIT_EMAIL_HERE" .env; then
        log_warn ".env file contains placeholder values."
        log_info "Please run './scripts/setup-env.sh' to configure your environment variables."
        ISSUE_FOUND=1
    else
        log_success ".env file found and appears to be configured."
    fi
fi
echo "----------------------------------------"

# 2. Check script permissions
log_info "Checking script permissions..."
PERM_ISSUE=0
# Check scripts in current scripts dir
for script in scripts/*.sh; do
    if [ -f "$script" ] && [ ! -x "$script" ]; then
        log_error "$script is missing execute permissions."
        PERM_ISSUE=1
    fi
done

if [ $PERM_ISSUE -eq 1 ]; then
    log_info "Attempting to fix permissions..."
    chmod +x scripts/*.sh 2>/dev/null || true
    log_success "Added execute permissions to scripts."
else
    log_success "All scripts have correct execute permissions."
fi
echo "----------------------------------------"

# 3. Check for specific dependencies
log_info "Checking dependencies..."
check_dep() {
    if ! command -v "$1" &> /dev/null; then
        log_error "'$1' is not installed."
        ISSUE_FOUND=1
    else
        log_success "'$1' is installed."
    fi
}

check_dep "make"
check_dep "git"
check_dep "gh"
echo "----------------------------------------"

# Final summary
if [ $ISSUE_FOUND -eq 1 ]; then
    log_warn "Troubleshooting complete, but some issues require your attention."
    exit 1
else
    log_success "Troubleshooting complete. Everything looks good!"
    exit 0
fi
