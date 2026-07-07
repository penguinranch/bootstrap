---
description: Test the install.sh script in an isolated temporary directory to verify extraction and structure
---

# Test Bootstrap Install

Run this workflow to verify that `install.sh` correctly extracts the `templates/` payload into a clean directory.

Without an override, `install.sh` downloads the upstream `main` tarball — it would silently ignore your local changes. Step 1 therefore packs the working tree's `templates/` into a local tarball and points `REPO_TAR_URL` at it, so the test exercises exactly what you are about to commit.

## Steps

1. Pack the working tree into a local tarball and run the installer against it (start from the bootstrap repo root):

```bash
BOOTSTRAP_REPO=$(git rev-parse --show-toplevel) && STAGE=$(mktemp -d) && PREFIX="penguinranch-bootstrap-$(git -C "$BOOTSTRAP_REPO" rev-parse --short HEAD)" && mkdir -p "$STAGE/$PREFIX" && cp -a "$BOOTSTRAP_REPO/templates" "$STAGE/$PREFIX/" && tar -czf /tmp/bootstrap-local.tgz -C "$STAGE" "$PREFIX" && rm -rf "$STAGE" && mkdir -p /tmp/test-bootstrap && cd /tmp/test-bootstrap && git init && REPO_TAR_URL="file:///tmp/bootstrap-local.tgz" bash "$BOOTSTRAP_REPO/install.sh"
```

// turbo

2. Verify the expected file structure exists:

```bash
ls -la /tmp/test-bootstrap/.devcontainer/ /tmp/test-bootstrap/scripts/ /tmp/test-bootstrap/docs/ && echo "✅ Structure intact" || echo "❌ Missing files"
```

// turbo

3. Verify key files are present:

```bash
for f in AGENTS.md Makefile .editorconfig .env.example .gitattributes .gitignore .prettierrc CHANGELOG.md LICENSE CODE_OF_CONDUCT.md README.md; do [ -f "/tmp/test-bootstrap/$f" ] && echo "✅ $f" || echo "❌ $f MISSING"; done
```

// turbo

4. Clean up:

```bash
rm -rf /tmp/test-bootstrap /tmp/bootstrap-local.tgz
```
