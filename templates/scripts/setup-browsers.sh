#!/usr/bin/env bash
set -euo pipefail

# Installs the browser the pinned @playwright/mcp server expects, for 'make browsers'.
#
# The version is derived, never typed. Every @playwright/mcp release pins an
# exact alpha of playwright, so a bare 'npx playwright install' pulls the latest
# stable instead and downloads a browser revision the pinned playwright-core
# refuses to launch.

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

cd_repo_root
ensure_container

if ! command -v node > /dev/null 2>&1 || ! command -v npm > /dev/null 2>&1; then
    log_warn "node and npm are not on PATH: nothing to install against."
    exit 0
fi

if [ ! -f .mcp.json ]; then
    log_warn "No .mcp.json: nothing to match a browser against."
    exit 0
fi

if [ ! -f .mcp/package.json ]; then
    log_warn "No .mcp/package.json: nothing pins the playwright MCP server."
    exit 0
fi

# The pin lives in the manifest, not in the .mcp.json launch line, because that
# is the file Dependabot bumps.
mcp_pin="$(node -e '
const pkg = require("./.mcp/package.json");
const deps = Object.assign({}, pkg.dependencies, pkg.devDependencies);
const version = deps["@playwright/mcp"];
process.stdout.write(version ? "@playwright/mcp@" + version : "");
')"

if [ -z "$mcp_pin" ]; then
    log_warn "No @playwright/mcp pin in .mcp/package.json: nothing to do."
    exit 0
fi

# The --browser value in .mcp.json decides which browser has to be present.
# Default to chromium, which is what the shipped config asks for.
browser="$(node -e '
const cfg = require("./.mcp.json");
const args = ((cfg.mcpServers || {}).playwright || {}).args || [];
const i = args.indexOf("--browser");
process.stdout.write(i !== -1 && args[i + 1] ? args[i + 1] : "chromium");
')"

log_info "Resolving the playwright version ${mcp_pin} depends on..."
if ! playwright_version="$(npm view "$mcp_pin" dependencies.playwright 2> /dev/null)" || [ -z "$playwright_version" ]; then
    log_warn "Could not resolve the playwright dependency of ${mcp_pin}: skipping."
    exit 0
fi

playwright_pkg="playwright@${playwright_version}"

log_info "Installing ${browser} for ${playwright_pkg}..."

# --with-deps re-runs apt for the OS libraries the browser needs and escalates
# through sudo on its own. If that half fails (an unreachable apt mirror, say)
# the browser binary alone is still worth having.
if npx --yes "$playwright_pkg" install --with-deps "$browser"; then
    log_success "${browser} ready for ${mcp_pin}."
elif npx --yes "$playwright_pkg" install "$browser"; then
    log_warn "${browser} installed without OS dependencies. If it fails to launch, run 'make browsers' again with apt reachable."
else
    log_warn "${browser} install failed. The playwright MCP server will not start until 'make browsers' succeeds."
fi
