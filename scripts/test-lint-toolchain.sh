#!/bin/bash
set -euo pipefail
# cspell:ignore misspeled

cd "$(dirname "$0")/.."

# a green 'make lint' can't tell a clean repo from a tool that ignored our config

BIN=node_modules/.bin
for tool in prettier cspell markdownlint-cli2; do
    [ -x "$BIN/$tool" ] || {
        echo "❌ $BIN/$tool is missing: run 'npm ci' first."
        exit 1
    }
done

# inside the repo so each tool discovers the root config the way 'make lint' does
FIXTURES=$(mktemp -d "$PWD/toolchain-probe.XXXXXX")
trap 'rm -rf "$FIXTURES"' EXIT

failures=0

expect_pass() {
    local label=$1
    shift
    if "$@" >"$FIXTURES/out" 2>&1; then
        echo "✅ $label"
    else
        echo "❌ $label"
        sed 's/^/    /' "$FIXTURES/out"
        failures=$((failures + 1))
    fi
}

expect_fail() {
    local label=$1 needle=$2
    shift 2
    if "$@" >"$FIXTURES/out" 2>&1; then
        echo "❌ $label: the command passed"
        failures=$((failures + 1))
    elif ! grep -q -- "$needle" "$FIXTURES/out"; then
        echo "❌ $label: failed without reporting '$needle'"
        sed 's/^/    /' "$FIXTURES/out"
        failures=$((failures + 1))
    else
        echo "✅ $label"
    fi
}

printf "key: 'single'\n" >"$FIXTURES/quotes-ok.yml"
printf 'key: "double"\n' >"$FIXTURES/quotes-bad.yml"
expect_pass "prettier accepts single quotes, which only .prettierrc allows" \
    "$BIN/prettier" --check "$FIXTURES/quotes-ok.yml"
expect_fail "prettier rejects double quotes" "quotes-bad.yml" \
    "$BIN/prettier" --check "$FIXTURES/quotes-bad.yml"

printf 'The penguinranch repo.\n' >"$FIXTURES/words-ok.md"
printf 'The repo has a misspeled word.\n' >"$FIXTURES/words-bad.md"
expect_pass "cspell accepts a word only cspell.json knows" \
    "$BIN/cspell" lint --no-progress --no-summary "$FIXTURES/words-ok.md"
expect_fail "cspell rejects a misspelling" "misspeled" \
    "$BIN/cspell" lint --no-progress --no-summary "$FIXTURES/words-bad.md"

printf '# Title\n\n%s\n' "$(printf 'word%.0s ' $(seq 1 40))end" >"$FIXTURES/long-line-ok.md"
printf '# Title\n\n#Missing space\n' >"$FIXTURES/heading-bad.md"
expect_pass "markdownlint accepts a long line, which only the MD013 override allows" \
    "$BIN/markdownlint-cli2" --no-globs "$FIXTURES/long-line-ok.md"
expect_fail "markdownlint rejects a heading with no space" "MD018" \
    "$BIN/markdownlint-cli2" --no-globs "$FIXTURES/heading-bad.md"

if [ "$failures" -ne 0 ]; then
    echo "❌ $failures lint toolchain check(s) failed."
    exit 1
fi
echo "✅ Lint toolchain reads its config and still reports errors."
