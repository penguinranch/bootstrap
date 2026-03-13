#!/bin/bash
# Source shared utilities
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

ensure_root

log_info "Starting Antigravity Devcontainer environment..."

# 1. Check existing environment variables and apply Git configuration
log_info "Checking environment variables and Git configuration..."
bash ./.devcontainer/boot-check.sh

# 2. Configure Git hooks via Makefile
log_info "Ensuring Git hooks are configured..."
make setup

log_success "Container startup complete."
