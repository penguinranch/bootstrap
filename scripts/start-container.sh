#!/bin/bash
set -euo pipefail

# Source shared utilities
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

ensure_root

log_info "Starting devcontainer environment..."

# Run non-interactive health check and apply .env config
bash ./scripts/doctor.sh

log_success "Container startup complete. Run 'make' for available commands."
