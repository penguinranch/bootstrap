#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

DOC="BEST_PRACTICES.md"
fail=0

mapfile -t refs < <(grep -oE '\]\(templates/[^)]*\)' "$DOC" | sed -E 's/^\]\(//; s/\)$//' | sort -u)

for ref in "${refs[@]}"; do
    if [ ! -e "$ref" ]; then
        echo "❌ $DOC links to a path that no longer exists: $ref"
        fail=1
    fi
done

# project skeleton files, not documented practices — when adding a template
# file, either reference it in BEST_PRACTICES.md or consciously list it here
allowlist=(
    "templates/README.md"
    "templates/CODE_OF_CONDUCT.md"
    "templates/.nvmrc"
    "templates/.vscode/extensions.json"
    "templates/scripts/create-container.sh"
    "templates/scripts/start-container.sh"
    "templates/scripts/setup-ai-tools.sh"
)

covered() {
    local file="$1"
    local ref
    for ref in "${refs[@]}"; do
        ref="${ref%/}"
        # a link to the payload root documents nothing specific
        if [ "$ref" = "templates" ]; then
            continue
        fi
        if [ "$file" = "$ref" ]; then
            return 0
        fi
        case "$file" in
            "$ref"/*) return 0 ;;
        esac
    done
    local allowed
    for allowed in "${allowlist[@]}"; do
        if [ "$file" = "$allowed" ]; then
            return 0
        fi
    done
    return 1
}

while IFS= read -r file; do
    if ! covered "$file"; then
        echo "❌ Template file not referenced in $DOC (add a reference or allowlist it): $file"
        fail=1
    fi
done < <(git ls-files templates/)

if [ "$fail" -eq 0 ]; then
    echo "✅ $DOC and templates/ are in sync."
fi
exit "$fail"
