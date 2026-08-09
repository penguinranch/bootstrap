FROM mcr.microsoft.com/devcontainers/base:trixie

# a broken curl in the download pipe below must fail the build, not get
# masked by tar's exit status
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# shellcheck backs 'make lint' — not optional in this image
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends shellcheck \
    && rm -rf /var/lib/apt/lists/*

# gitleaks powers the pre-commit secret scan — same version as the template
# payload. Release assets use x64/arm64, dpkg says amd64/arm64.
ARG GITLEAKS_VERSION=8.30.1
RUN arch="$(dpkg --print-architecture)" \
    && case "$arch" in amd64) arch=x64 ;; esac \
    && curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${arch}.tar.gz" \
    | tar -xz -C /usr/local/bin gitleaks

# Claude Code and Gemini CLI state each persist on a named volume (see
# devcontainer.json mounts; Claude's dir is additionally pointed here via
# CLAUDE_CONFIG_DIR). Pre-create the dirs owned by vscode so the fresh volumes
# inherit that ownership on first mount instead of coming up root-owned.
RUN mkdir -p /home/vscode/.claude /home/vscode/.gemini \
    && chown vscode:vscode /home/vscode/.claude /home/vscode/.gemini

# Node comes from the devcontainer node feature AFTER this image builds, so
# node/npm are not usable in RUN layers. Install global node modules in
# scripts/setup-ai-tools.sh (postCreateCommand) instead.
