#!/bin/bash
set -euo pipefail

# new-adr.sh: Scaffold a new Architecture Decision Record.

ADR_DIR="docs/decisions"
mkdir -p "$ADR_DIR"

# Get current index
LATEST_ADR=$(find "$ADR_DIR" -maxdepth 1 -name "[0-9]*-*.md" | sort | tail -n 1)
if [ -z "$LATEST_ADR" ]; then
    NEXT_NUM="0001"
else
    # Extract leading number
    CURRENT_NUM=$(basename "$LATEST_ADR" | grep -o '^[0-9]\+')
    # Normalize to 4 digits for consistency in NEW files
    NEXT_NUM=$(printf "%04d" $((10#$CURRENT_NUM + 1)))
fi

read -rp "Enter the title for the new ADR: " ADR_TITLE
SLUG=$(echo "$ADR_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g')
FILENAME="${NEXT_NUM}-${SLUG}.md"
TARGET_FILE="${ADR_DIR}/${FILENAME}"

cat <<EOF > "$TARGET_FILE"
# ADR ${NEXT_NUM}: ${ADR_TITLE}

- **Date:** $(date +"%Y-%m-%d")
- **Status:** Proposed

## Context

Describe the background and the problem being addressed.

## Decision

Describe the proposed solution and why it was chosen.

## Consequences

What are the trade-offs or implications of this decision?
EOF

echo "✅ Created new ADR: $TARGET_FILE"
