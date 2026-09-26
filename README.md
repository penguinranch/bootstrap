# 🐧 Penguin Ranch Bootstrap

> **The "Gold Standard" repository template for launching new projects.**

> [!CAUTION]
> **AI AGENT INSTRUCTIONS:** If you have been directed to this repository to learn about or apply "best practices" to an existing project, start with **[BEST_PRACTICES.md](BEST_PRACTICES.md)**. It's a tiered tour of the standards with links to every canonical file. The canonical files all live in the `/templates` directory, which contains the actual scaffolding that becomes a new downstream project. Do NOT examine the root-level files (such as `install.sh`, `Makefile`, etc.) to learn about project setup, as those files are strictly for managing the bootstrap repository itself.

One command gets you a project with nothing to install on your host, secure defaults, and guardrails that keep habits honest. Built to work with IDE AI agents from day one.

---

## 🌟 The Philosophy & Features (The "Why")

When you bootstrap a project using this template, you are receiving an environment intentionally restricted to prevent common developer mistakes. Here is why we made these decisions:

### 1. Devcontainer Only (Zero-Host Dependency)

**The Problem:** "It works on my machine!"
**The Solution:** All work happens strictly inside a VS Code Dev Container. Whether you are on macOS, Linux, or Windows (WSL), once you reopen the project in its container, Docker builds the same pre-configured Linux environment for everyone. You never need to install Node, Python, or Go on your host computer again.

### 2. Secure by Default

**The Problem:** Accidentally committing API keys or unverified code.
**The Solution:** `.env` (and every `.env.*` except `.env.example`) is gitignored, and the pre-commit hook scans every staged change for secrets with **gitleaks** before the commit is allowed. VS Code also forwards your host's SSH agent into the devcontainer, so Git is set up for **SSH commit signing**. Signing turns on once you give `make setup` a public key and the SSH agent is reachable. If the agent wasn't reachable at setup time, unlock your key manager (1Password, say) and run `make doctor`.

### 3. AI-Optimized Workflows

**The Problem:** Generative AI tools (like GitHub Copilot or Gemini) get confused easily and burn through their context "tokens" doing repetitive tasks.
**The Solution:** This project includes an `AGENTS.md` file designed explicitly to be read by AI. It instructs the AI on our exact project constraints, architectural philosophy, and git branching strategies. The **Gemini CLI** (`@google/gemini-cli`) and **Claude Code CLI** (`@anthropic-ai/claude-code`) are installed globally inside the container. `make ai-context` bundles the README, AGENTS.md, CONTRIBUTING.md, the `docs/` files and a project tree into `context-for-ai.md` (gitignored), so a fresh AI session can start from one file. The CLIs' state (conversation history, logins, MCP (Model Context Protocol) server and trust approvals) lives on per-project Docker volumes, so it survives a container rebuild.

### 4. Structural Guardrails

A few checked-in files do the nagging for you:

- **`.editorconfig`**: One indent and whitespace standard for every editor that reads it (VS Code gets the extension from the recommended list). Line endings are pinned separately in `.gitattributes`.
- **`Makefile`**: A universal task runner. Whether the project runs on npm, Go or pytest under the hood, developers run `make test` or `make dev` (once they're wired to your stack during the kickoff). `make help` lists every target, and `make doctor` runs an environment health check.
- **`CODEOWNERS`**: Routes `docs/` changes to tech leads, and `.github/workflows/` and `.devcontainer/` changes to DevOps. Swap the placeholder team slugs for real teams. Reviews only become required if branch protection has "Require review from Code Owners" turned on.
- **`dependabot.yml`**: Pre-configured to open PRs that keep dependencies (GitHub Actions, Docker images, devcontainer features) up to date. For vulnerability alerts, turn on Dependabot alerts in the repo settings. The shipped Trivy workflow also scans the repo filesystem for CRITICAL/HIGH vulnerabilities on pushes and PRs to `main`.

---

## 🧭 Already Have a Project?

Have an existing codebase? Or pointing an AI agent at this repo with _"use the best practices set by this repo"_? Use **[BEST_PRACTICES.md](BEST_PRACTICES.md)** instead. It organizes everything here into three adoption tiers (drop-in guardrails → workflow automation → AI-native environment) so you can take exactly as much as you want, without the installer.

---

## 🚀 How to Use (Step-by-Step)

### Prerequisites (On your Host Machine)

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
2. Install [Visual Studio Code](https://code.visualstudio.com/).
3. Install the [Claude Code extension](https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code) (`anthropic.claude-code`) and the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) (`ms-vscode-remote.remote-containers`).

### Step 1: Scaffold the Project

Open a standard terminal on your host machine (**Mac/Linux**) or **Git Bash / WSL** (**Windows**) and run:

```bash
# Create and move into your new project folder
mkdir my-new-idea && cd my-new-idea

# Initialize git
git init

# Run the bootstrap installer
curl -sSL https://raw.githubusercontent.com/penguinranch/bootstrap/main/install.sh | bash
```

> **Note for Windows Users:** Command Prompt and PowerShell do not natively support running `.sh` bash scripts. You must execute the above `curl` command using [Git Bash](https://gitforwindows.org/) or [WSL](https://learn.microsoft.com/en-us/windows/wsl/install).

### Step 2: Open the Project in VS Code

1. Open the folder in **VS Code**. When prompted to install the workspace's recommended extensions, accept (the scaffold's `.vscode/extensions.json` includes the Claude Code extension).
2. An alert will appear prompting you to reopen the project in a Dev Container. **Hold off for now**... the container needs configuring for your stack first (next step).

### Step 3: The AI Architecture Kickoff

Decide on your tech stack first, since the language and framework decide how the container gets configured. Open the **Claude Code** panel in VS Code and prompt it with exactly this text:

> _"I am starting a new project. Please completely read `AGENTS.md` for our workflow standards. Let's begin Phase 1: Discovery by discussing the goals and tech stack for this idea. Once we decide, please proceed with the following setup checklist:_
> _1. Fill out `docs/VISION.md` (goals, non-goals, roadmap) and the Tech Stack section of `docs/ARCHITECTURE.md`._
> _2. Update the `.devcontainer/` configuration (Dockerfile and devcontainer.json) for our chosen stack, and replace the `{{PROJECT_NAME}}` placeholders in `devcontainer.json` and the `Makefile` (`APP_NAME`) with the project name._
> _3. Configure the universal `Makefile` and setup `dependabot.yml`._
> _4. Replace the `[SECURITY_EMAIL]` placeholder in `SECURITY.md` and `CODE_OF_CONDUCT.md` with a real contact address._
> _5. Replace the `[Year]` / `[Full Name]` placeholders in `LICENSE`, and update the `@core-maintainers` / `@tech-leads` / `@devops` team slugs in `.github/CODEOWNERS` to teams or usernames that exist in our org._
> _6. Rewrite `README.md` to describe this new project and how to run it."_

### Step 4: Open the Devcontainer

Once the AI has configured `.devcontainer/`, click **Reopen in Container** (or run **Dev Containers: Reopen in Container** from the command palette).

_Wait a few minutes while Docker builds the Linux environment for your chosen stack._

### Step 5: Initial Setup Scripts

Once VS Code reloads inside the container, open a new **Terminal** and run:

```bash
make setup
```

_This asks for your Git name and email, an optional SSH public key for commit signing, and optional Gemini and Anthropic API keys. Then it makes sure the AI CLIs are installed and turns on the git hooks._

---

## 🚑 Troubleshooting

- **The IDE Window is hung / The AI CLIs didn't install:**
  Sometimes the automatic `postCreateCommand` hangs. Open a terminal inside your generated project's container and run `make ai-tools` to finish the installation.
- **Git complains about missing user name and email:**
  If the devcontainer hangs after building, the startup health check might not have run to configure your Git profile from `.env`. You can fix this by running `make doctor` (which re-applies `.env` settings) or by running `make setup` again.
- **Windows / WSL line-ending errors (bash scripts crashing):**
  Windows uses `CRLF` (Windows-style) line endings, which crash Linux bash scripts expecting `LF` (Unix-style). We have a `.gitattributes` file to prevent this, but if you still see `\r` errors, set your global git config: `git config --global core.autocrlf false`.

---

## 🛠 Developing the Bootstrap Template

Working on the bootstrap repo itself? Open it in its own devcontainer (root `.devcontainer/`, not the template's), run `make help`, and read the root **`AGENTS.md`** for the rules. After touching `install.sh` or `templates/`, run `make test`, and run `make lint` before committing.
