#!/bin/bash
set -euo pipefail

# Orchestrator for postCreateCommand: runs once when the container is first created.
# Calls individual setup scripts in the correct order.

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

cd_repo_root
ensure_container

log_info "Running first-time container setup..."

# 1. Install AI CLI tools (Gemini, Claude, extensions)
bash ./scripts/setup-ai-tools.sh

# 2. Install the pinned npm toolchain when the project has a lockfile, so
#    make lint/format use the same versions CI enforces. A fresh scaffold
#    has no lockfile yet and skips this.
if [ -f package-lock.json ] && command -v npm >/dev/null 2>&1; then
    log_info "Installing npm toolchain (npm ci)..."
    npm ci --ignore-scripts --no-audit --no-fund
fi

# 3. Reinstall the .env shell loader. A rebuild resets $HOME, so this has to
#    run on create rather than only from 'make setup'.
install_env_loader

# 4. Install the pinned MCP servers. After the loader, so a registry failure
#    here cannot leave the container without it.
if [ -f ./scripts/setup-mcp.sh ]; then
    bash ./scripts/setup-mcp.sh
fi

log_success "Container creation setup complete."
