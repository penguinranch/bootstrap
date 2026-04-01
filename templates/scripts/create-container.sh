#!/bin/bash
set -euo pipefail

# Orchestrator for postCreateCommand — runs once when the container is first created.
# Calls individual setup scripts in the correct order.

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

ensure_root
ensure_container

log_info "Running first-time container setup..."

# 1. Install AI CLI tools (Gemini, Claude, extensions)
bash ./scripts/setup-ai-tools.sh

log_success "Container creation setup complete."
