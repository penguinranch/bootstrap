#!/bin/bash
set -euo pipefail

# Read-only standards refresh: diffs this project's files against the latest
# upstream bootstrap payload and prints a compare link from the commit in the
# .bootstrap-version stamp. Writes nothing. Applying changes is left to the
# developer (or their agent), who should update the stamp and Decision Log
# afterward (see AGENTS.md, "Staying Current with Upstream Standards").

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
# shellcheck source=scripts/utils.sh
source "$SCRIPT_DIR/utils.sh"

cd_repo_root

STAMP=".bootstrap-version"
UPSTREAM_REPO="https://github.com/penguinranch/bootstrap"
REPO_TAR_URL="${REPO_TAR_URL:-${UPSTREAM_REPO}/tarball/main}"

if [ ! -f "$STAMP" ]; then
    log_error "No $STAMP found: was this project scaffolded by penguinranch/bootstrap?"
    exit 1
fi

OLD_COMMIT=$(grep -m1 '^commit=' "$STAMP" | cut -d= -f2- || true)
if [ -z "$OLD_COMMIT" ]; then
    log_error "$STAMP has no commit= line: cannot determine the baseline."
    exit 1
fi

log_info "Project was scaffolded from upstream commit: $OLD_COMMIT"
log_info "Downloading the latest upstream payload..."

temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT

if ! curl -fsSL "$REPO_TAR_URL" | tar -xz -C "$temp_dir"; then
    log_error "Failed to download or extract the upstream tarball."
    exit 1
fi

extracted_dir=$(find "$temp_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)
if [ -z "$extracted_dir" ] || [ ! -d "$extracted_dir/templates" ]; then
    log_error "Templates directory not found in the downloaded archive."
    exit 1
fi

NEW_COMMIT="${extracted_dir##*-}"
if [ "$NEW_COMMIT" = "$OLD_COMMIT" ]; then
    log_success "Already up to date with upstream ($OLD_COMMIT)."
    exit 0
fi

log_info "Latest upstream commit: $NEW_COMMIT"
echo ""

payload="$extracted_dir/templates"
changed=0
added=0

while IFS= read -r rel; do
    rel="${rel#./}"
    if [ ! -e "$rel" ]; then
        echo "🆕 New upstream file (not in this project): $rel"
        added=$((added + 1))
    elif ! diff -q "$payload/$rel" "$rel" >/dev/null; then
        echo ""
        echo "📝 $rel differs from upstream:"
        # project first, upstream second, so '+' lines read as what upstream adds
        diff -u "$rel" "$payload/$rel" || true
        changed=$((changed + 1))
    fi
done < <(cd "$payload" && find . -type f | sort)

echo ""
echo "──────────────────────────────────────"
if [ "$changed" -eq 0 ] && [ "$added" -eq 0 ]; then
    log_success "No file-level differences against upstream $NEW_COMMIT."
    log_info "The stamp is behind, though. Update commit= in $STAMP to $NEW_COMMIT."
    exit 0
fi

log_info "$changed file(s) differ, $added new upstream file(s)."
log_info "Full upstream history: ${UPSTREAM_REPO}/compare/${OLD_COMMIT}...${NEW_COMMIT}"
log_warn "Local diffs can be intentional adaptations: apply upstream changes with judgment, never wholesale."
log_info "After syncing: update commit= and installed= in $STAMP to $NEW_COMMIT and record the sync in docs/ARCHITECTURE.md's Decision Log."
