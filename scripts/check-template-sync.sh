#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Guards invariants between the bootstrap repo's own copies and the shipped
# template payload. Some files diverge on purpose (.env.example, .gitignore,
# cspell.json, the Makefiles and Dockerfiles); everything in the manifest
# below MUST stay identical, because this repo dog-foods those files and a
# fix applied to only one copy is a bug shipped to the other. To diverge a
# pair on purpose, remove it here in the same commit and say why.

fail=0

IDENTICAL_PAIRS=(
    scripts/utils.sh
    scripts/setup-env.sh
    scripts/setup-ai-tools.sh
    scripts/doctor.sh
    scripts/create-container.sh
    scripts/start-container.sh
    .githooks/pre-commit
    .githooks/commit-msg
    .editorconfig
    .gitattributes
    .prettierrc
    .shellcheckrc
    .markdownlint-cli2.jsonc
)

for rel in "${IDENTICAL_PAIRS[@]}"; do
    if ! diff -q "$rel" "templates/$rel" >/dev/null; then
        echo "❌ $rel and templates/$rel have drifted:"
        diff "$rel" "templates/$rel" || true
        fail=1
    fi
done

# The VS Code extension list exists in four places (two devcontainer.json
# customizations blocks, two .vscode/extensions.json). The devcontainer and
# .vscode lists differ on purpose (remote-containers is meaningless inside a
# container), but each root/template pair must agree. Order-insensitive:
# entries are compared sorted.
extract_list() {
    sed -n "/\"$2\": \[/,/\]/p" "$1" | grep -oE '"[^"]+"' | grep -vx "\"$2\"" | sort
}

check_ext_pair() {
    local label=$1 file_a=$2 file_b=$3 key=$4
    local list_a list_b
    list_a=$(extract_list "$file_a" "$key")
    list_b=$(extract_list "$file_b" "$key")
    if [ -z "$list_a" ] || [ -z "$list_b" ]; then
        echo "❌ Could not extract the \"$key\" list from $file_a or $file_b."
        fail=1
    elif [ "$list_a" != "$list_b" ]; then
        echo "❌ The $label differ between $file_a and $file_b:"
        diff <(printf '%s\n' "$list_a") <(printf '%s\n' "$list_b") || true
        fail=1
    fi
}

check_ext_pair "devcontainer extension lists" \
    .devcontainer/devcontainer.json templates/.devcontainer/devcontainer.json extensions
check_ext_pair ".vscode extension recommendations" \
    .vscode/extensions.json templates/.vscode/extensions.json recommendations

# The AI kickoff prompt is quoted verbatim in both READMEs and has drifted
# before. Its lines are the only '> _' blockquote lines in either file.
prompt_root=$(grep '^> _' README.md || true)
prompt_tmpl=$(grep '^> _' templates/README.md || true)
if [ -z "$prompt_root" ] || [ -z "$prompt_tmpl" ]; then
    echo "❌ Could not find the '> _' kickoff prompt lines in one of the READMEs."
    fail=1
elif [ "$prompt_root" != "$prompt_tmpl" ]; then
    echo "❌ The kickoff prompt differs between README.md and templates/README.md:"
    diff <(printf '%s\n' "$prompt_root") <(printf '%s\n' "$prompt_tmpl") || true
    fail=1
fi

# The gitleaks version AND its checksums must match across both devcontainer
# Dockerfiles and the e2e workflow. Checking only the version let a stale
# checksum through: the Docker build then fails at 'sha256sum -c' in a
# downstream project instead of failing here, where it can be fixed.
# '|| true' keeps a missing pin from killing the script under set -e:
# the explicit empty-check below is the diagnostic we want in that case.
pin() { grep -oE "$2=[0-9a-f.]+" "$1" | head -n1 | cut -d= -f2 || true; }

# Compare one pin across a pair of files, reporting a missing or drifted value.
check_pin() {
    local label=$1 file_a=$2 key_a=$3 file_b=$4 key_b=$5
    local val_a val_b
    val_a=$(pin "$file_a" "$key_a")
    val_b=$(pin "$file_b" "$key_b")
    if [ -z "$val_a" ]; then
        echo "❌ no $key_a pin found in $file_a"
        fail=1
    fi
    if [ -z "$val_b" ]; then
        echo "❌ no $key_b pin found in $file_b"
        fail=1
    fi
    if [ -n "$val_a" ] && [ -n "$val_b" ] && [ "$val_a" != "$val_b" ]; then
        echo "❌ gitleaks $label differs: $file_a=$val_a $file_b=$val_b"
        fail=1
    fi
}

ROOT_DF=.devcontainer/Dockerfile
TMPL_DF=templates/.devcontainer/Dockerfile
E2E_WF=.github/workflows/e2e-install.yml

check_pin version "$ROOT_DF" GITLEAKS_VERSION "$TMPL_DF" GITLEAKS_VERSION
check_pin x64-checksum "$ROOT_DF" GITLEAKS_SHA256_X64 "$TMPL_DF" GITLEAKS_SHA256_X64
check_pin arm64-checksum "$ROOT_DF" GITLEAKS_SHA256_ARM64 "$TMPL_DF" GITLEAKS_SHA256_ARM64

# The e2e workflow installs its own gitleaks to test the pre-commit hook; it
# runs on an x64 runner, so it must match the x64 pin the devcontainers ship.
check_pin version "$ROOT_DF" GITLEAKS_VERSION "$E2E_WF" GITLEAKS_VERSION
check_pin x64-checksum "$ROOT_DF" GITLEAKS_SHA256_X64 "$E2E_WF" GITLEAKS_SHA256

# The two AGENTS.md files share two sections and drifted once already (2026-09).
# Engineering Philosophy must match verbatim. The Orchestrator sections carry
# repo-specific bodies, so only their bold rule labels are compared, in order.
section() { awk -v h="$2" '$0 ~ "^## .*" h {p=1; next} /^## /{p=0} p' "$1"; }
labels() { grep -oE '^ *([0-9]+\.|-) \*\*[^*]+\*\*' | sed -E 's/^[^*]*\*\*//; s/\*\*$//'; }

phil_root=$(section AGENTS.md "Engineering Philosophy")
phil_tmpl=$(section templates/AGENTS.md "Engineering Philosophy")
if [ -z "$phil_root" ] || [ -z "$phil_tmpl" ]; then
    echo "❌ Could not find the Engineering Philosophy section in one of the AGENTS.md files."
    fail=1
elif [ "$phil_root" != "$phil_tmpl" ]; then
    echo "❌ The Engineering Philosophy section differs between AGENTS.md and templates/AGENTS.md:"
    diff <(printf '%s\n' "$phil_root") <(printf '%s\n' "$phil_tmpl") || true
    fail=1
fi

orch_root=$(section AGENTS.md "Orchestrator" | labels)
orch_tmpl=$(section templates/AGENTS.md "Orchestrator" | labels)
if [ -z "$orch_root" ] || [ -z "$orch_tmpl" ]; then
    echo "❌ Could not find the Orchestrator rule labels in one of the AGENTS.md files."
    fail=1
elif [ "$orch_root" != "$orch_tmpl" ]; then
    echo "❌ The Orchestrator rule labels differ between AGENTS.md and templates/AGENTS.md:"
    diff <(printf '%s\n' "$orch_root") <(printf '%s\n' "$orch_tmpl") || true
    fail=1
fi

if [ "$fail" -eq 0 ]; then
    echo "✅ Bootstrap repo and template payload are in sync."
fi
exit "$fail"
