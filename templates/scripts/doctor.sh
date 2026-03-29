#!/bin/bash
set -uo pipefail

# Non-interactive health check — runs on every container start.
# Never prompts for input. Reports status and directs to 'make setup' if needed.

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
    log_success ".env file found."
    while IFS='=' read -r key value; do
        if [[ -n "$key" && ! "$key" =~ ^# ]]; then
            key="${key#"${key%%[![:space:]]*}"}"
            key="${key%"${key##*[![:space:]]}"}"
            value="${value#"${value%%[![:space:]]*}"}"
            value="${value%"${value##*[![:space:]]}"}"
            export "$key=$value"
        fi
    done < ".env"

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
        git config --global commit.gpgsign true
    fi
    if [ -n "${GITHUB_TOKEN:-}" ] && command -v gh &> /dev/null; then
        gh auth setup-git 2>/dev/null || true
    fi
else
    log_warn ".env file not found."
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
SIGNING=$(git config --global commit.gpgsign 2>/dev/null || echo "")
if [ "$SIGNING" = "true" ]; then
    log_success "SSH commit signing enabled."
else
    log_info "SSH commit signing not configured (optional)."
fi

# --- GitHub CLI ---
if command -v gh &> /dev/null; then
    if gh auth status &> /dev/null; then
        log_success "GitHub CLI authenticated."
    else
        log_warn "GitHub CLI installed but not authenticated."
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
