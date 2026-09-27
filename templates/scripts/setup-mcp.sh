#!/usr/bin/env bash
set -euo pipefail

# Installs the MCP servers pinned in .mcp/package.json, for 'make ai-mcp'.
#
# The pins live in a manifest rather than in the .mcp.json launch line so
# Dependabot opens PRs for them. .mcp.json then launches the installed binaries
# by path, which means a merged bump needs no other edit.

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

cd_repo_root

# CI runs the Make targets on the runner, the same exemption the Makefile's
# container guard makes.
if [ -z "${CI:-}" ]; then
    ensure_container
fi

if [ ! -f .mcp/package-lock.json ]; then
    log_warn "No .mcp/package-lock.json: no local MCP servers to install."
    exit 0
fi

if ! command -v npm > /dev/null 2>&1; then
    log_warn "npm is not on PATH: cannot install the local MCP servers."
    exit 0
fi

log_info "Installing the pinned MCP servers..."
npm ci --prefix .mcp --ignore-scripts --no-audit --no-fund

if [ ! -f .mcp.json ]; then
    log_success "MCP servers installed."
    exit 0
fi

missing=0
while IFS= read -r cmd; do
    [ -n "$cmd" ] || continue
    if [ ! -x "$cmd" ]; then
        log_error "$cmd is missing after install: does .mcp.json name a server .mcp/package.json does not pin?"
        missing=1
    fi
done <<< "$(local_mcp_commands)"

if [ "$missing" -eq 1 ]; then
    exit 1
fi

log_success "MCP servers installed."
