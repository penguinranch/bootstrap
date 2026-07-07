#!/bin/bash
set -euo pipefail

# ai-context.sh: Gather project context for AI assistants.
# This script bundles key documentation and file structure into a single output.

OUTPUT_FILE="context-for-ai.md"

echo "🔍 Gathering project context..."

{
    echo "# Project Context for AI Assistant"
    echo "Generated on: $(date)"
    echo ""
    echo "## Project Structure"
    echo "\`\`\`"
    if command -v tree >/dev/null 2>&1; then
        tree -I "node_modules|.git|dist|.tmp"
    else
        find . -maxdepth 2 -not -path '*/.*'
    fi
    echo "\`\`\`"
    echo ""

    for file in README.md AGENTS.md CONTRIBUTING.md docs/VISION.md docs/ARCHITECTURE.md docs/MEMORY.md; do
        if [ -f "$file" ] && [ ! -L "$file" ]; then
            echo "## $file"
            echo "\`\`\`markdown"
            cat "$file"
            echo "\`\`\`"
            echo ""
        fi
    done

} > "$OUTPUT_FILE"

echo "✅ Context gathered in: $OUTPUT_FILE"
