#!/bin/bash
set -uo pipefail

# Unified environment health check and troubleshooting.
# Runs non-interactively on every container start and can be invoked manually.
# Never prompts for input. Reports status, auto-fixes what it can,
# and directs to 'make setup' for the rest.

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

ensure_root

ISSUES=0

echo ""
echo "🔍 Environment Status"
echo "──────────────────────────────────────"

# --- Load .env and apply git config ---
if [ -f .env ]; then
    if grep -q "YOUR_GIT_NAME_HERE" .env || grep -q "YOUR_GIT_EMAIL_HERE" .env; then
        log_warn ".env file contains placeholder values. Run 'make setup' to configure."
        ISSUES=$((ISSUES + 1))
    else
        log_success ".env file found."
    fi
    safe_export_env

    # Apply git config from .env
    if [ -n "${GIT_NAME:-}" ]; then
        git config --global user.name "$GIT_NAME"
    fi
    if [ -n "${GIT_EMAIL:-}" ]; then
        git config --global user.email "$GIT_EMAIL"
    fi
    if [ -n "${SSH_PUBLIC_KEY:-}" ]; then
        git config --global gpg.format ssh
        git config --global user.signingkey "key::${SSH_PUBLIC_KEY}"
        if ssh_signing_available; then
            git config --global commit.gpgsign true
        else
            git config --global commit.gpgsign false
        fi
    fi
    if [ -n "${GITHUB_TOKEN:-}" ] && command -v gh &> /dev/null; then
        gh auth setup-git 2>/dev/null || true
    fi
else
    log_warn ".env file not found. Run 'make setup' to configure."
    ISSUES=$((ISSUES + 1))
fi

# --- Git identity ---
GIT_USER=$(git config --global user.name 2>/dev/null || echo "")
GIT_MAIL=$(git config --global user.email 2>/dev/null || echo "")
if [ -n "$GIT_USER" ] && [ -n "$GIT_MAIL" ]; then
    log_success "Git identity: $GIT_USER <$GIT_MAIL>"
else
    log_warn "Git identity not configured."
    ISSUES=$((ISSUES + 1))
fi

# --- SSH commit signing ---
SIGNING_KEY=$(git config --global user.signingkey 2>/dev/null || echo "")
if [ -n "$SIGNING_KEY" ]; then
    if ssh_signing_available; then
        log_success "SSH commit signing enabled (1Password / SSH agent detected)."
    else
        log_info "SSH signing key configured but agent not available — signing disabled."
    fi
else
    log_info "SSH commit signing not configured (optional)."
fi

# --- GitHub CLI ---
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        log_success "GitHub CLI authenticated."
    else
        log_warn "GitHub CLI installed but not authenticated. Run 'gh auth login'."
        ISSUES=$((ISSUES + 1))
    fi
else
    log_warn "GitHub CLI not installed."
    ISSUES=$((ISSUES + 1))
fi

# --- AI CLIs ---
if command -v gemini &> /dev/null; then
    log_success "Gemini CLI installed."
else
    log_warn "Gemini CLI not installed."
    ISSUES=$((ISSUES + 1))
fi

if command -v claude &> /dev/null; then
    log_success "Claude CLI installed."
else
    log_warn "Claude CLI not installed."
    ISSUES=$((ISSUES + 1))
fi

# --- Environment variables ---
echo ""
echo "📋 Environment Variables"
echo "──────────────────────────────────────"
for var in GEMINI_API_KEY ANTHROPIC_API_KEY GITHUB_TOKEN; do
    val="${!var:-}"
    if [ -n "$val" ]; then
        log_success "$var is set."
    else
        log_info "$var is not set (optional)."
    fi
done

# --- Script permissions ---
echo ""
echo "🔐 Script Permissions"
echo "──────────────────────────────────────"
PERM_ISSUE=0
for script in scripts/*.sh; do
    if [ -f "$script" ] && [ ! -x "$script" ]; then
        PERM_ISSUE=1
    fi
done
if [ $PERM_ISSUE -eq 1 ]; then
    chmod +x scripts/*.sh 2>/dev/null || true
    log_success "Fixed missing execute permissions on scripts."
else
    log_success "All scripts have correct permissions."
fi

# --- Git hooks ---
echo ""
echo "🔧 Git Hooks"
echo "──────────────────────────────────────"
if [ -d .githooks ]; then
    git config core.hooksPath .githooks
    chmod +x .githooks/* 2>/dev/null || true
    log_success "Git hooks configured."
else
    log_info "No .githooks directory found (configure after setup)."
fi

# --- Core tools ---
echo ""
echo "🛠  Core Tools"
echo "──────────────────────────────────────"
for tool in git node npm make; do
    if command -v "$tool" &> /dev/null; then
        log_success "$tool installed."
    else
        log_error "$tool missing."
        ISSUES=$((ISSUES + 1))
    fi
done

# --- Summary ---
echo ""
echo "──────────────────────────────────────"
if [ "$ISSUES" -gt 0 ]; then
    log_warn "$ISSUES issue(s) found. Run 'make setup' to configure."
else
    log_success "All checks passed."
fi
echo ""
