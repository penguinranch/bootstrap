#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Guards invariants between the bootstrap repo's own copies and the shipped
# template payload. Some files diverge on purpose (doctor.sh scans both trees,
# lifecycle scripts guard differently); the checks below are only the pairs
# that MUST stay identical. Add a pair here when a new shared invariant appears.

fail=0

# utils.sh is the shared helper library — it must be identical in both trees.
if ! diff -q scripts/utils.sh templates/scripts/utils.sh >/dev/null; then
    echo "❌ scripts/utils.sh and templates/scripts/utils.sh have drifted:"
    diff scripts/utils.sh templates/scripts/utils.sh || true
    fail=1
fi

# The gitleaks pin must match across both devcontainer Dockerfiles.
# '|| true' keeps a missing pin from killing the script under set -e —
# the explicit empty-check below is the diagnostic we want in that case.
gitleaks_ver() { grep -oE 'GITLEAKS_VERSION=[0-9.]+' "$1" | head -n1 | cut -d= -f2 || true; }
root_gl=$(gitleaks_ver .devcontainer/Dockerfile)
tmpl_gl=$(gitleaks_ver templates/.devcontainer/Dockerfile)
if [ -z "$root_gl" ]; then
    echo "❌ no GITLEAKS_VERSION pin found in .devcontainer/Dockerfile"
    fail=1
fi
if [ -z "$tmpl_gl" ]; then
    echo "❌ no GITLEAKS_VERSION pin found in templates/.devcontainer/Dockerfile"
    fail=1
fi
if [ -n "$root_gl" ] && [ -n "$tmpl_gl" ] && [ "$root_gl" != "$tmpl_gl" ]; then
    echo "❌ gitleaks pin differs: .devcontainer=$root_gl templates/.devcontainer=$tmpl_gl"
    fail=1
fi

if [ "$fail" -eq 0 ]; then
    echo "✅ Bootstrap repo and template payload are in sync."
fi
exit "$fail"
