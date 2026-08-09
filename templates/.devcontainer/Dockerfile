FROM mcr.microsoft.com/devcontainers/base:trixie

# gitleaks release assets use x64/arm64, dpkg says amd64/arm64
ARG GITLEAKS_VERSION=8.30.1
RUN arch="$(dpkg --print-architecture)" \
    && case "$arch" in amd64) arch=x64 ;; esac \
    && curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${arch}.tar.gz" \
    | tar -xz -C /usr/local/bin gitleaks

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# Claude Code and Gemini CLI state each persist on a named volume (see
# devcontainer.json mounts; Claude's dir is additionally pointed here via
# CLAUDE_CONFIG_DIR). Pre-create the dirs owned by vscode so the fresh volumes
# inherit that ownership on first mount instead of coming up root-owned.
RUN mkdir -p /home/vscode/.claude /home/vscode/.gemini \
    && chown vscode:vscode /home/vscode/.claude /home/vscode/.gemini

# [Optional] Uncomment if you want to install an additional version of node using nvm
# ARG EXTRA_NODE_VERSION=10
# RUN su node -c "source /usr/local/share/nvm/nvm.sh && nvm install ${EXTRA_NODE_VERSION}"

# [Optional] Uncomment if you want to install more global node modules
# RUN su node -c "npm install -g <your-package-list-here>"
