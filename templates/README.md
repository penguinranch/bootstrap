# 🐧 Your New Project

> **Bootstrapped with [Penguin Ranch Bootstrap](https://github.com/penguinranch/bootstrap).**

Welcome to your new project! This repository has been scaffolded with a ready-to-go developer environment. Everything you need to get started is already here. Just open it in a Devcontainer and go.

---

## 📂 Project Structure

Here's what was installed and why:

```text
.
├── .devcontainer/            # 🐳 Containerized dev environment
│   ├── Dockerfile            #    Base image & system dependencies
│   ├── devcontainer.json     #    VS Code / IDE container config
│   └── devcontainer-lock.json #   Pins devcontainer feature versions
│
├── .gemini/                  # ♊ Gemini CLI project settings
│   └── settings.json         #    MCP (Model Context Protocol) servers (mirrors .mcp.json)
│
├── .github/                  # 🤖 GitHub automation
│   ├── ISSUE_TEMPLATE/       #    Standardized issue forms
│   │   ├── bug_report.md     #    Bug report template
│   │   ├── config.yml        #    Issue chooser config
│   │   └── feature_request.md #   Feature request template
│   ├── CODEOWNERS            #    Auto-assigns reviewers for critical paths
│   ├── PULL_REQUEST_TEMPLATE.md  # Standardized PR checklist
│   ├── dependabot.yml        #    Automated dependency version updates
│   └── workflows/
│       ├── ci.yml            #    CI pipeline (runs on PRs and pushes to main)
│       └── security.yml      #    Trivy security scanning
│
├── .githooks/                # 🪝 Git hooks (installed via make setup)
│   ├── pre-commit            #    Scans staged changes for secrets (gitleaks), then runs make lint
│   └── commit-msg            #    Enforces Conventional Commits format
│
├── .vscode/                  # 🧩 Editor defaults
│   └── extensions.json       #    Recommended VS Code extensions
│
├── scripts/                  # ⚙️  Setup & automation scripts
│   ├── create-container.sh   #    [postCreateCommand] One-time container setup
│   ├── start-container.sh    #    [postStartCommand] Fast, idempotent checks
│   ├── setup-env.sh          #    [Manual] Interactive setup for credentials
│   ├── doctor.sh             #    [Manual/Auto] Environment health check & troubleshooting
│   ├── setup-ai-tools.sh     #    [postCreateCommand/Manual] Global AI CLI installations
│   ├── ai-context.sh         #    [Manual] Bundle metadata for AI assistants
│   ├── bootstrap-sync.sh     #    [Manual] Diff this project against upstream bootstrap standards
│   └── utils.sh              #    Shared logging & env helpers (sourced by the other scripts, except ai-context.sh)
│
├── docs/                     # 📝 Living project documentation (AI-maintained)
│   ├── VISION.md             #    Goals, non-goals, and Now/Next/Later roadmap
│   ├── ARCHITECTURE.md       #    Tech stack, diagrams, runbook & decision log
│   └── MEMORY.md             #    Long-lived context for AI agents
│
├── .bootstrap-version        # Which template commit this project was scaffolded from
├── .editorconfig             # Consistent formatting across all editors
├── .env.example              # Template for environment variables (most optional)
├── .gitattributes            # Line-ending normalization (LF for scripts)
├── .mcp.json                 # MCP servers for AI agents (Notion, Context7, GitHub, Playwright, Chrome DevTools)
├── .gitignore                # Sensible defaults (node_modules, .env, etc.)
├── .markdownlint-cli2.jsonc  # Markdown lint rules (used by make lint)
├── .nvmrc                    # Pins Node.js version (matches CI)
├── .prettierrc               # Code formatter configuration
├── .shellcheckrc             # Shell lint rules (used by make lint)
├── AGENTS.md                 # AI agent instructions & project context
├── cspell.json               # Spell-checker dictionary (shared word list)
├── CHANGELOG.md              # Project changelog (Keep a Changelog format)
├── CODE_OF_CONDUCT.md        # Contributor code of conduct
├── CONTRIBUTING.md           # How to contribute to this project
├── LICENSE                   # Project license (MIT)
├── SECURITY.md               # Vulnerability disclosure policy
└── Makefile                  # Universal task runner (make dev, make test, etc.)
```

---

## 🚀 Getting Started

### 1. Define Your Architecture

Before opening the Devcontainer, define your tech stack. The language and framework you choose will determine how the container is configured. Open your AI assistant and prompt it with:

> _"I am starting a new project. Please completely read `AGENTS.md` for our workflow standards. Let's begin Phase 1: Discovery by discussing the goals and tech stack for this idea. Once we decide, please proceed with the following setup checklist:_
> _1. Fill out `docs/VISION.md` (goals, non-goals, roadmap) and the Tech Stack section of `docs/ARCHITECTURE.md`._
> _2. Update the `.devcontainer/` configuration (Dockerfile and devcontainer.json) for our chosen stack, and replace the `{{PROJECT_NAME}}` placeholders in `devcontainer.json` and the `Makefile` (`APP_NAME`) with the project name._
> _3. Configure the universal `Makefile` and setup `dependabot.yml`._
> _4. Replace the `[SECURITY_EMAIL]` placeholder in `SECURITY.md` and `CODE_OF_CONDUCT.md` with a real contact address._
> _5. Replace the `[Year]` / `[Full Name]` placeholders in `LICENSE`, and update the `@core-maintainers` / `@tech-leads` / `@devops` team slugs in `.github/CODEOWNERS` to teams or usernames that exist in our org._
> _6. Rewrite `README.md` to describe this new project and how to run it."_

> [!CAUTION]
> **Host Isolation:** Do NOT allow your AI assistant to run `npm install`, `pip install`, or any other tool installation commands until you have officially **Reopened in Container**. All project logic must stay isolated.

### 2. Open in a Devcontainer

Once the Devcontainer has been configured for your stack, open this folder in **VS Code** and accept the prompt to **Reopen in Container**. Docker will build your isolated development environment automatically.

> **AI state persists across rebuilds.** Claude Code (`~/.claude`) and Gemini CLI (`~/.gemini`) each store their conversation history, logins, and MCP/trust approvals on a per-project named Docker volume, so rebuilding the container won't wipe them. To start fresh, remove the volumes on your host: `docker volume rm claude-code-config-<id> gemini-cli-config-<id>` (find the exact names with `docker volume ls`).

### 3. Run the Setup Wizard

Once the container is ready, open a terminal and run:

```bash
make setup
```

This walks the interactive setup wizard (Git identity, optional SSH signing key, optional Gemini/Anthropic API keys), installs the AI CLI tools, and activates the git hooks. For GitHub operations, run `gh auth login` inside the container to authenticate over HTTPS.

> **Note:** If your devcontainer seems to hang after building, or if `git` complains about missing user name and email, run `make doctor` to apply your `.env` values and verify the git hooks.

### 4. Build Something Great

Start developing! Use the universal `Makefile` targets:

| Command               | Purpose                                                           |
| --------------------- | ----------------------------------------------------------------- |
| `make help`           | Show available make targets                                       |
| `make setup`          | Interactive first-time setup wizard                               |
| `make doctor`         | Check environment health and status                               |
| `make dev`            | Start the development server                                      |
| `make test`           | Run the test suite                                                |
| `make build`          | Create a production build                                         |
| `make lint`           | Run code formatting & linting                                     |
| `make format`         | Format all files                                                  |
| `make ai-context`     | Gather project context for AI                                     |
| `make ai-tools`       | (Re)install the AI CLI tools                                      |
| `make bootstrap-sync` | Diff this project against the latest upstream bootstrap standards |
| `make clean`          | Remove build artifacts                                            |

Run `make help` for the full list.

---

## 📚 Key Files to Know

| File                  | What It Does                                                                                                                                                                                              |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`AGENTS.md`**       | Instructions for AI assistants: coding standards, workflow rules, and architectural philosophy.                                                                                                           |
| **`Makefile`**        | Maps your stack-specific commands to universal targets. Update this once you choose your tech stack.                                                                                                      |
| **`.env.example`**    | Lists the environment variables the project can use (most are optional). Copy to `.env` and fill in your values.                                                                                          |
| **`docs/`**           | The three living documents (`VISION.md`, `ARCHITECTURE.md`, `MEMORY.md`) that agents keep current.                                                                                                        |
| **`CODEOWNERS`**      | Routes `docs/` changes to tech leads, and `.github/workflows/` and `.devcontainer/` changes to DevOps. Reviews only become required if branch protection has "Require review from Code Owners" turned on. |
| **`CONTRIBUTING.md`** | How to contribute: branch naming, conventional commits, living-docs workflow, and PR process.                                                                                                             |
| **`SECURITY.md`**     | How to report vulnerabilities. Replace `[SECURITY_EMAIL]` with your contact.                                                                                                                              |

---

## 🛟 Need Help?

- **Container not building?** Check that Docker Desktop is running and you have enough disk space.
- **AI CLIs (Gemini / Claude) missing?** Run `make ai-tools` inside the container.
- **Line-ending errors on Windows?** Run `git config --global core.autocrlf false` and re-clone.
- **Something else?** Check the [bootstrap repo](https://github.com/penguinranch/bootstrap) for the latest docs and troubleshooting tips.
