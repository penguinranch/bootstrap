---
description: Test the install.sh script in an isolated temporary directory to verify extraction and structure
---

# Test Bootstrap Install

Run this workflow to verify that `install.sh` correctly extracts the `templates/` payload into a clean directory and that the shipped guardrails (collision guard, git hooks, lint gate) work in the scaffold.

The whole e2e lives in `scripts/test-install.sh`, shared with the E2E Install CI workflow. It packs the working tree's `templates/` into a local tarball and points `REPO_TAR_URL` at it — running a bare `bash install.sh` instead would download the upstream `main` tarball and silently ignore your local changes.

## Steps

1. Run the install e2e from the bootstrap repo root:

```bash
make test
```

// turbo
