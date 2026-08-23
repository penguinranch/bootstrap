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
# silently ignores local changes — so default to packing the working tree.
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
# fixture commits only — the developer's own signing setup isn't under test
# and a missing agent must not fail the suite
git config commit.gpgsign false
git config core.hooksPath .githooks
test -x .githooks/commit-msg || fail "commit-msg hook not executable"
test -x .githooks/pre-commit || fail "pre-commit hook not executable"

git add -A
# The shipped VS Code config must survive the first commit — guards against
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
    # Fake GitHub PAT — matches gitleaks' default rules (the canonical AWS
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
    echo "⚠️  gitleaks not installed — skipping the secret-block test."
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
echo "🧪 Scaffold lint gate fails on a broken script"
# shellcheck disable=SC2016 # the unexpanded $UNCLOSED is the point
printf '#!/bin/bash\nif [ "$UNCLOSED = 1 ]; then :; fi\n' > scripts/broken.sh
if make lint; then
    fail "make lint should fail on a script shellcheck rejects"
fi
rm scripts/broken.sh
echo "✅ Scaffold lint gate rejects a broken shell script."

echo ""
echo "✅ Install e2e passed."
