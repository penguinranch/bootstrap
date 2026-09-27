#!/bin/bash
set -euo pipefail

# End-to-end test of install.sh against the working tree's payload.
# Run via 'make test'. The e2e-install CI workflow runs this same script,
# so local and CI verification can't drift apart.

cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

fail() {
    echo "❌ $1"
    exit 1
}

# Without an override, install.sh downloads the upstream main tarball and
# silently ignores local changes, so default to packing the working tree.
# CI exports REPO_TAR_URL to the pushed commit's GitHub tarball instead,
# which also exercises the real download path.
if [ -z "${REPO_TAR_URL:-}" ]; then
    PREFIX="penguinranch-bootstrap-$(git rev-parse --short HEAD)"
    mkdir -p "$WORK_DIR/stage/$PREFIX"
    cp -a "$REPO_ROOT/templates" "$WORK_DIR/stage/$PREFIX/"
    tar -czf "$WORK_DIR/payload.tgz" -C "$WORK_DIR/stage" "$PREFIX"
    export REPO_TAR_URL="file://$WORK_DIR/payload.tgz"
    echo "📦 Packed working tree payload: $REPO_TAR_URL"
else
    echo "📦 Using provided REPO_TAR_URL: $REPO_TAR_URL"
fi

echo ""
echo "🧪 Fresh install into an empty directory"
PROJECT="$WORK_DIR/test-project"
mkdir -p "$PROJECT"
cd "$PROJECT"
git init -q
bash "$REPO_ROOT/install.sh"

for f in AGENTS.md Makefile README.md CHANGELOG.md LICENSE CODE_OF_CONDUCT.md \
    .editorconfig .env.example .gitattributes .gitignore .prettierrc; do
    test -f "$f" || fail "$f missing after install"
done
for d in .devcontainer scripts docs .githooks .github; do
    test -d "$d" || fail "$d/ missing after install"
done
for f in docs/VISION.md docs/ARCHITECTURE.md docs/MEMORY.md; do
    test -f "$f" || fail "$f missing after install"
done
for s in scripts/setup-env.sh scripts/start-container.sh scripts/doctor.sh; do
    test -x "$s" || fail "$s not executable"
done
test -f .bootstrap-version || fail ".bootstrap-version not written"
grep -q '^commit=..*' .bootstrap-version || fail ".bootstrap-version has no commit"
[ ! -f install.sh ] || fail "install.sh leaked into the project root"
echo "✅ Structure, permissions, and version stamp verified."

echo ""
echo "🧪 Installer refuses a non-empty directory"
if bash "$REPO_ROOT/install.sh"; then
    fail "installer should abort when .devcontainer already exists"
fi
echo "✅ Existing-project guard refused to overwrite."

echo ""
echo "🧪 Installer refuses to overwrite conflicting files"
COLLISION="$WORK_DIR/collision-project"
mkdir -p "$COLLISION"
cd "$COLLISION"
echo "precious" > Makefile
if bash "$REPO_ROOT/install.sh"; then
    fail "installer should abort when payload files already exist"
fi
test "$(cat Makefile)" = "precious" || fail "existing Makefile was clobbered"
echo "✅ Collision guard preserved the existing file."

echo ""
echo "🧪 Git hooks enforce the guardrails"
cd "$PROJECT"
git config user.name "E2E Bot"
git config user.email "e2e@example.com"
# fixture commits only: the developer's own signing setup isn't under test
# and a missing agent must not fail the suite
git config commit.gpgsign false
git config core.hooksPath .githooks
test -x .githooks/commit-msg || fail "commit-msg hook not executable"
test -x .githooks/pre-commit || fail "pre-commit hook not executable"

git add -A
# The shipped VS Code config must survive the first commit: guards against
# a '.vscode/' ignore pattern whose negations git can't honor.
git ls-files --cached --others --exclude-standard | grep -qx '.vscode/extensions.json' \
    || fail ".vscode/extensions.json was not staged (gitignore is eating it)"
if git commit -q -m "not a conventional message"; then
    fail "commit-msg hook should reject non-conventional messages"
fi
echo "✅ Non-conventional commit message rejected."
git commit -q -m "chore: initial scaffold from bootstrap"
echo "✅ Conventional commit accepted."

echo ""
echo "🧪 Pre-commit blocks a staged secret"
if command -v gitleaks >/dev/null 2>&1; then
    # Fake GitHub PAT: matches gitleaks' default rules (the canonical AWS
    # example key is allowlisted upstream, so it can't be used here).
    printf 'github_token = "ghp_abcd1234efgh5678ijkl9012mnop3456qrst"\n' > leaky.conf # gitleaks:allow
    git add leaky.conf
    if git commit -q -m "feat: add config"; then
        fail "pre-commit should reject a staged secret"
    fi
    git rm -q --cached leaky.conf
    rm leaky.conf
    echo "✅ Staged secret rejected by gitleaks."
else
    echo "⚠️  gitleaks not installed: skipping the secret-block test."
fi

echo ""
echo "🧪 Make targets work in the scaffold"
# capture instead of piping into grep -q: under 'make test' this is a
# sub-make whose trailing "Leaving directory" line lands after grep exits,
# and pipefail would turn that SIGPIPE into a failure
HELP_OUTPUT=$(make help)
echo "$HELP_OUTPUT" | grep -q "setup" || fail "make help lists no setup target"
make doctor-ci
make lint | tee "$WORK_DIR/lint.log"
# 'make lint' is what the pre-commit hook runs, so leaving it unchecked is
# how the scaffold's lint target once regressed to a no-op that still passed
grep -q "Linting shell scripts" "$WORK_DIR/lint.log" || fail "scaffold lint skipped shellcheck"
echo "✅ make help, make doctor-ci and make lint run in a fresh scaffold."

echo ""
echo "🧪 Local MCP servers install from the pinned manifest"
test -f .mcp/package.json || fail ".mcp/package.json missing after install"
test -f .mcp/package-lock.json || fail ".mcp/package-lock.json missing after install"

# Before the install the configs name binaries that are not there yet, and
# doctor is the only thing that tells a developer so.
DOCTOR_BEFORE=$(make doctor 2>&1 || true)
echo "$DOCTOR_BEFORE" | grep -q "run 'make ai-mcp'" || fail "doctor did not report the MCP servers as missing before install"

make ai-mcp

# Read the commands out of .mcp.json rather than repeating them, so this test
# cannot pass while the shipped config points somewhere else.
MCP_COMMANDS=$(node -e '
const cfg = require("./.mcp.json");
const out = [];
for (const server of Object.values(cfg.mcpServers || {})) {
    if (server && typeof server.command === "string" && server.command.startsWith(".mcp/")) {
        out.push(server.command);
    }
}
process.stdout.write(out.join("\n"));
')
[ -n "$MCP_COMMANDS" ] || fail ".mcp.json names no local MCP server commands"
while IFS= read -r mcp_cmd; do
    [ -n "$mcp_cmd" ] || continue
    test -x "$mcp_cmd" || fail "$mcp_cmd is not executable after 'make ai-mcp'"
done <<< "$MCP_COMMANDS"

# The launched server must report the version the manifest pins. A stale
# install or a shadowing global copy passes the executable check and fails here.
# shellcheck disable=SC2016 # the ${...} below are JS template literals, not shell
node -e '
const { execFileSync } = require("child_process");
const cfg = require("./.mcp.json");
const pkg = require("./.mcp/package.json");
const pins = Object.assign({}, pkg.dependencies, pkg.devDependencies);
const expected = {
    "playwright": pins["@playwright/mcp"],
    "chrome-devtools": pins["chrome-devtools-mcp"],
};
for (const [name, want] of Object.entries(expected)) {
    const server = (cfg.mcpServers || {})[name];
    if (!server || !String(server.command || "").startsWith(".mcp/")) continue;
    const reported = execFileSync(server.command, ["--version"], { encoding: "utf8" }).trim();
    if (!want || !reported.includes(want)) {
        console.error(`${name}: reported "${reported}" but .mcp/package.json pins ${want}`);
        process.exit(1);
    }
}
' || fail "a launched MCP server does not match the pin in .mcp/package.json"

# A real MCP handshake, with the exact command and args the shipped config
# carries, so a flag the server stops accepting fails the build here.
cat > "$WORK_DIR/mcp-probe.cjs" <<'PROBE'
const { spawn } = require("child_process");
const name = process.argv[2];
const cfg = require(process.cwd() + "/.mcp.json");
const server = (cfg.mcpServers || {})[name];
if (!server || !server.command) {
    console.error(`no server named ${name} in .mcp.json`);
    process.exit(1);
}
const child = spawn(server.command, server.args || [], { stdio: ["pipe", "pipe", "pipe"] });
let stdout = "";
let stderr = "";
let settled = false;
const finish = (code, message) => {
    if (settled) return;
    settled = true;
    child.kill();
    if (message) console.error(message);
    process.exit(code);
};
child.stdout.on("data", (chunk) => {
    stdout += chunk;
    for (const line of stdout.split("\n")) {
        try {
            const msg = JSON.parse(line);
            if (msg.id === 1 && msg.result && msg.result.serverInfo) {
                console.log(`${name} answered initialize as ${msg.result.serverInfo.name}`);
                finish(0);
            }
        } catch (err) {
            /* partial line */
        }
    }
});
child.stderr.on("data", (chunk) => {
    stderr += chunk;
});
child.on("error", (err) => finish(1, `${name} failed to spawn: ${err.message}`));
setTimeout(() => finish(1, `${name} never answered initialize. stderr: ${stderr.slice(0, 400)}`), 30000);
child.stdin.write(JSON.stringify({
    jsonrpc: "2.0",
    id: 1,
    method: "initialize",
    params: { protocolVersion: "2025-06-18", capabilities: {}, clientInfo: { name: "e2e", version: "0" } },
}) + "\n");
child.stdin.write(JSON.stringify({ jsonrpc: "2.0", method: "notifications/initialized" }) + "\n");
PROBE
for mcp_server in playwright chrome-devtools; do
    node "$WORK_DIR/mcp-probe.cjs" "$mcp_server" || fail "$mcp_server did not complete an MCP initialize with its shipped args"
done

# Both agent configs launch the same local servers, which AGENTS.md asks for in
# prose and nothing else checks.
# shellcheck disable=SC2016 # the ${...} below are JS template literals, not shell
node -e '
const claude = require("./.mcp.json").mcpServers || {};
const gemini = require("./.gemini/settings.json").mcpServers || {};
const local = (servers) => Object.entries(servers)
    .filter(([, s]) => s && typeof s.command === "string")
    .map(([name, s]) => `${name} ${s.command} ${(s.args || []).join(" ")}`)
    .sort()
    .join("\n");
if (local(claude) !== local(gemini)) {
    console.error("local server entries differ\n--- .mcp.json ---\n" + local(claude) + "\n--- .gemini/settings.json ---\n" + local(gemini));
    process.exit(1);
}
' || fail ".mcp.json and .gemini/settings.json disagree on the local MCP servers"

DOCTOR_AFTER=$(make doctor 2>&1 || true)
echo "$DOCTOR_AFTER" | grep -q "Local MCP servers installed" || fail "doctor did not report the MCP servers as installed"
echo "✅ MCP servers install from the manifest, match their pins, and answer initialize."

echo ""
echo "🧪 bootstrap-sync recognizes its own payload as current"
# REPO_TAR_URL still points at the tarball this scaffold came from, so the
# stamped commit and the "latest" commit must match
SYNC_OUTPUT=$(make bootstrap-sync)
echo "$SYNC_OUTPUT" | grep -q "Already up to date" || fail "bootstrap-sync did not report up to date against its own payload"
echo "✅ bootstrap-sync compares against the version stamp."

echo ""
echo "🧪 bootstrap-sync reports files removed upstream since the stamped commit"
# Baseline payload = the current one plus a file that "upstream later removed".
# The project still has that file, so the sync must flag it and print the
# compare link even though nothing else differs.
BASELINE_PREFIX="penguinranch-bootstrap-0ldc0de"
mkdir -p "$WORK_DIR/baseline-stage/$BASELINE_PREFIX"
cp -a "$REPO_ROOT/templates" "$WORK_DIR/baseline-stage/$BASELINE_PREFIX/"
echo "gone upstream" > "$WORK_DIR/baseline-stage/$BASELINE_PREFIX/templates/docs/RETIRED.md"
tar -czf "$WORK_DIR/baseline.tgz" -C "$WORK_DIR/baseline-stage" "$BASELINE_PREFIX"
echo "gone upstream" > docs/RETIRED.md
# not 'sed -i': GNU takes no suffix argument and BSD requires one, so an
# in-place edit that works in the devcontainer fails on a macOS host, which
# is where 'make test' gets run before a commit
stamp_rewrite="$(mktemp)"
sed 's/^commit=.*/commit=0ldc0de/' .bootstrap-version > "$stamp_rewrite"
mv "$stamp_rewrite" .bootstrap-version
SYNC_OUTPUT=$(BASELINE_TAR_URL="file://$WORK_DIR/baseline.tgz" make bootstrap-sync)
echo "$SYNC_OUTPUT" | grep -q "Removed upstream since 0ldc0de (still in this project): docs/RETIRED.md" || fail "bootstrap-sync did not flag the file removed upstream"
echo "$SYNC_OUTPUT" | grep -q "compare/0ldc0de\.\.\." || fail "bootstrap-sync did not print the compare link"
rm docs/RETIRED.md
echo "✅ bootstrap-sync flags upstream-removed files and links the compare view."

echo ""
echo "🧪 Scaffold lint gate fails on a broken script"
# shellcheck disable=SC2016 # the unexpanded $UNCLOSED is the point
printf '#!/bin/bash\nif [ "$UNCLOSED = 1 ]; then :; fi\n' > scripts/broken.sh
# capture the lint output: the planted script's shellcheck errors read like
# a real failure when they print mid-run, so show them only if the gate
# wrongly passes
if LINT_OUTPUT=$(make lint 2>&1); then
    echo "$LINT_OUTPUT"
    fail "make lint should fail on a script shellcheck rejects"
fi
rm scripts/broken.sh
echo "✅ Scaffold lint gate rejects a broken shell script."

echo ""
echo "✅ Install e2e passed."
