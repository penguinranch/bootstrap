#!/bin/bash
set -u

# Source shared utilities
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

ensure_root

log_info "Starting Devcontainer Troubleshooting..."
echo "────────────────────────────────────────"

ISSUE_FOUND=0

# 1. Check for .env file
log_info "Checking for .env file..."
if [ ! -f .env ]; then
    log_error ".env file is missing."
    if [ -f .env.example ]; then
        log_info ".env.example found. Run 'make setup' to configure your environment."
    else
        log_error ".env.example is also missing. Cannot create .env automatically."
        ISSUE_FOUND=1
    fi
else
    if grep -q "YOUR_GIT_NAME_HERE" .env || grep -q "YOUR_GIT_EMAIL_HERE" .env; then
        log_warn ".env file contains placeholder values."
        log_info "Run 'make setup' to configure your environment variables."
        ISSUE_FOUND=1
    else
        log_success ".env file found and appears to be configured."
    fi
fi
echo "────────────────────────────────────────"

# 2. Check script permissions
log_info "Checking script permissions..."
PERM_ISSUE=0
for script in scripts/*.sh templates/scripts/*.sh; do
    if [ -f "$script" ]; then
        if [ ! -x "$script" ]; then
            log_error "$script is missing execute permissions."
            PERM_ISSUE=1
        fi
    fi
done

if [ $PERM_ISSUE -eq 1 ]; then
    log_info "Attempting to fix permissions..."
    chmod +x scripts/*.sh templates/scripts/*.sh 2>/dev/null || true
    log_success "Added execute permissions to scripts."
else
    log_success "All scripts have correct execute permissions."
fi
echo "────────────────────────────────────────"

# 3. Check for dependencies
log_info "Checking dependencies..."
for tool in make git node npm; do
    if command -v "$tool" &> /dev/null; then
        log_success "'$tool' is installed."
    else
        log_error "'$tool' is not installed."
        ISSUE_FOUND=1
    fi
done

# 4. Check AI CLIs
log_info "Checking AI tools..."
if command -v gemini &> /dev/null; then
    log_success "Gemini CLI is installed."
else
    log_warn "Gemini CLI is not installed. Run 'make setup' to install."
    ISSUE_FOUND=1
fi

if command -v claude &> /dev/null; then
    log_success "Claude CLI is installed."
else
    log_warn "Claude CLI is not installed. Run 'make setup' to install."
    ISSUE_FOUND=1
fi

# 5. Check GitHub CLI auth
log_info "Checking GitHub CLI..."
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        log_success "GitHub CLI is authenticated."
    else
        log_warn "GitHub CLI is installed but not authenticated. Run 'gh auth login'."
        ISSUE_FOUND=1
    fi
else
    log_warn "GitHub CLI is not installed."
    ISSUE_FOUND=1
fi
echo "────────────────────────────────────────"

# Final summary
if [ $ISSUE_FOUND -eq 1 ]; then
    log_warn "Troubleshooting complete, but some issues require your attention."
    log_info "Run 'make setup' to resolve most issues, or 'make doctor' for a status check."
    exit 1
else
    log_success "Troubleshooting complete. Everything looks good!"
    exit 0
fi
