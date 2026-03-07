---
description: Test the install.sh script in an isolated temporary directory to verify extraction and structure
---

# Test Bootstrap Install

Run this workflow to verify that `install.sh` correctly extracts the `templates/` payload into a clean directory.

## Steps

1. Create and enter a temporary test directory:
```bash
mkdir -p /tmp/test-bootstrap && cd /tmp/test-bootstrap && git init
```

// turbo
2. Run the install script from the bootstrap repo (using local copy, not remote):
```bash
BOOTSTRAP_DEV=1 bash /Users/lynnwallenstein/workspace/penguinranch/bootstrap/install.sh
```

// turbo
3. Verify the expected file structure exists:
```bash
ls -la /tmp/test-bootstrap/.devcontainer/ /tmp/test-bootstrap/scripts/ /tmp/test-bootstrap/docs/decisions/ && echo "✅ Structure intact" || echo "❌ Missing files"
```

// turbo
4. Verify key files are present:
```bash
for f in AGENTS.md Makefile .editorconfig .env.example .gitattributes .gitignore .prettierrc CHANGELOG.md LICENSE CODE_OF_CONDUCT.md README.md; do [ -f "/tmp/test-bootstrap/$f" ] && echo "✅ $f" || echo "❌ $f MISSING"; done
```

// turbo
5. Clean up:
```bash
rm -rf /tmp/test-bootstrap
```
