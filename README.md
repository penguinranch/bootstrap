# 🐧 Penguin Ranch Bootstrap

> **The "Gold Standard" repository template for launching new projects.**

> [!CAUTION]
> **AI AGENT INSTRUCTIONS:** If you have been directed to this repository to learn about "best practices", you MUST examine the contents of the `/templates` directory. The `/templates` directory contains the actual scaffolding and files that become a new downstream project. Do NOT examine the root-level files (such as `install.sh`, `Makefile`, etc.) to learn about project setup, as those files are strictly for managing the bootstrap repository itself.

This repository is designed to instantly bootstrap a fully configured project environment characterized by zero-host dependencies, secure-by-default workflows, and structural guardrails that enforce elite engineering practices. It is explicitly designed to be heavily supported by IDE-based AI Agents.

---

## 🌟 The Philosophy & Features (The "Why")

When you bootstrap a project using this template, you are receiving an environment intentionally restricted to prevent common developer mistakes. Here is why we made these decisions:

### 1. Devcontainer Only (Zero-Host Dependency)

**The Problem:** "It works on my machine!"
**The Solution:** All work happens strictly inside a VS Code Devcontainer. Whether you are on macOS, Linux, or Windows (WSL), the moment you open this project, Docker spins up an identical, pre-configured Linux container. You never need to install Node, Python, or Go on your host computer again.

### 2. Secure by Default

**The Problem:** Accidentally committing API keys or unverified code.
**The Solution:** The `.env` file is heavily `.gitignore`d. Additionally, the Devcontainer is mapped to your host's `~/.ssh` directory, and Git is pre-configured to strictly require **SSH Commit Signing**.

### 3. AI-Optimized Workflows

**The Problem:** Generative AI tools (like GitHub Copilot or Gemini) get confused easily and burn through their context "tokens" doing repetitive tasks.
**The Solution:** This project includes an `AGENTS.md` file designed explicitly to be read by AI. It instructs the AI on our exact project constraints, architectural philosophy, and git branching strategies. Furthermore, the **Gemini CLI** (`@google/gemini-cli`) is installed globally inside the container, providing the AI with native tooling for code review and analysis—saving precious IDE tokens.

### 4. Structural Guardrails

We have implemented physical files that prevent bad habits:

- **`.editorconfig`**: Forces every IDE (even Vim) to use the exact same tab sizes, line endings, and whitespace rules.
- **`Makefile`**: A universal task runner. Whether the underlying project is `npm`, `go`, or `pytest`, developers only ever need to run `make test` or `make run`.
- **`CODEOWNERS`**: Automatically requires Tech Lead PR reviews for architecture decisions (ADRs) and DevOps reviews for CI/CD changes.
- **`dependabot.yml`**: Automatically configured to continuously scan dependencies for vulnerabilities.

---

## 🚀 How to Use (Step-by-Step)

### Prerequisites (On your Host Machine)

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/).
2. Install [Antigravity](https://antigravity.google/).

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

### Step 2: The AI Architecture Kickoff

Before opening the Devcontainer, decide on your tech stack. The language and framework you choose will determine how the container is configured. Open your AI IDE Assistant chat panel and prompt it with exactly this text:

> _"I am starting a new project. Please completely read `AGENTS.md` for our workflow standards. Let's begin Phase 1: Discovery by discussing the goals and tech stack for this idea. Once we decide, please proceed with the following setup checklist:_
> _1. Fill out the `001-initial-tech-stack.md` ADR._
> _2. Update the `.devcontainer/` configuration (Dockerfile and devcontainer.json) for our chosen stack, and replace the `{{PROJECT_NAME}}` placeholder in `devcontainer.json` with the project name._
> _3. Configure the universal `Makefile` and setup `dependabot.yml`._
> _4. Rewrite `README.md` to describe this new project and how to run it."_

### Step 3: Open the Devcontainer

1. Open the folder in **Antigravity**.
2. An alert will appear prompting you to reopen the project in a Dev Container.
3. Click to **Reopen in Container**.

_Wait a few minutes while Docker builds the Linux environment for your chosen stack._

### Step 4: Initial Setup Scripts

Once Antigravity reloads inside the container, open a new **Terminal** and run:

```bash
./scripts/setup-env.sh
```

_This will prompt you for your Git credentials and your Gemini API Key so the CLI tooling works._

---

## 🚑 Troubleshooting

- **The IDE Window is hung / The Gemini CLI didn't install:**
  Sometimes the automatic `postCreateCommand` hangs. Open a terminal inside the container and manually run `bash ./scripts/setup-gemini.sh` to finish the installation.
- **Git complains about missing user name and email:**
  If the Devcontainer hangs after building, the `boot-check.sh` script might not have run to configure your Git profile from `.env`. You can fix this by explicitly running `./.devcontainer/boot-check.sh` or by running `./scripts/setup-env.sh` again.
- **Windows / WSL line-ending errors (bash scripts crashing):**
  Windows uses `CRLF` format for new lines, which crashes Linux bash scripts. We have a `.gitattributes` file to prevent this, but if you still see `\r` errors, ensure your global git config is set: `git config --global core.autocrlf false`.

---

## 🛠 Developing the Bootstrap Template

If you are looking to contribute to or modify the `bootstrap` repository itself, please consult the root **`AGENTS.md`** file for architectural constraints, goals, and modification rules.
