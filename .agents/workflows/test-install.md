---
description: Test the install.sh script in an isolated temporary directory to verify extraction and structure
---

# Test Bootstrap Install

Run this workflow to verify that `install.sh` correctly extracts the `templates/` payload into a clean directory.

## Steps

1. Create a temporary test directory and run the local install script (start from the bootstrap repo root):

```bash
BOOTSTRAP_REPO=$(git rev-parse --show-toplevel) && mkdir -p /tmp/test-bootstrap && cd /tmp/test-bootstrap && git init && BOOTSTRAP_DEV=1 bash "$BOOTSTRAP_REPO/install.sh"
```

// turbo 2. Verify the expected file structure exists:

```bash
ls -la /tmp/test-bootstrap/.devcontainer/ /tmp/test-bootstrap/scripts/ /tmp/test-bootstrap/docs/ && echo "✅ Structure intact" || echo "❌ Missing files"
```

// turbo 3. Verify key files are present:

```bash
for f in AGENTS.md Makefile .editorconfig .env.example .gitattributes .gitignore .prettierrc CHANGELOG.md LICENSE CODE_OF_CONDUCT.md README.md; do [ -f "/tmp/test-bootstrap/$f" ] && echo "✅ $f" || echo "❌ $f MISSING"; done
```

// turbo 4. Clean up:

```bash
rm -rf /tmp/test-bootstrap
```
