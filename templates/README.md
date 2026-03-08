# 🐧 Your New Project

> **Bootstrapped with [Penguin Ranch Bootstrap](https://github.com/penguinranch/bootstrap).**

Welcome to your new project! This repository has been scaffolded with a "Gold Standard" developer environment. Everything you need to get started is already here — just open it in a Devcontainer and go.

---

## 📂 Project Structure

Here's what was installed and why:

```
.
├── .devcontainer/            # 🐳 Containerized dev environment
│   ├── Dockerfile            #    Base image & system dependencies
│   ├── devcontainer.json     #    VS Code / IDE container config
│   └── boot-check.sh         #    Post-create health check script
│
├── .github/                  # 🤖 GitHub automation
│   ├── ISSUE_TEMPLATE/       #    Standardized issue forms
│   │   ├── bug_report.md     #    Bug report template
│   │   └── feature_request.md #   Feature request template
│   ├── CODEOWNERS            #    Auto-assigns reviewers for critical paths
│   ├── PULL_REQUEST_TEMPLATE.md  # Standardized PR checklist
│   ├── dependabot.yml        #    Automated dependency vulnerability scanning
│   └── workflows/
│       ├── ci.yml            #    CI pipeline (runs on every PR)
│       └── security.yml      #    Trivy security scanning
│
├── .githooks/                # 🪝 Git hooks (installed via make setup)
│   ├── pre-commit            #    Runs make lint before each commit
│   └── commit-msg            #    Enforces Conventional Commits format
│
├── scripts/                  # ⚙️  Setup & automation scripts
│   ├── start-container.sh    #    [postStartCommand] Fast, idempotent checks
│   ├── setup-env.sh          #    [Manual] Interactive setup for credentials
│   ├── troubleshooting.sh    #    [Manual] Diagnose common environment issues
│   └── setup-gemini.sh       #    [postCreateCommand] Global tool installations
│
├── docs/
│   └── decisions/            # 📝 Architecture Decision Records (ADRs)
│       ├── 000-template.md           # ADR template — copy for new decisions
│       └── 001-initial-tech-stack.md  # Your first ADR — fill this out!
│
├── .editorconfig             # Consistent formatting across all editors
├── .env.example              # Template for required environment variables
├── .gitattributes            # Line-ending normalization (LF for scripts)
├── .gitignore                # Sensible defaults (node_modules, .env, etc.)
├── .nvmrc                    # Pins Node.js version (matches CI)
├── .prettierrc               # Code formatter configuration
├── AGENTS.md                 # AI agent instructions & project context
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
> _1. Fill out the `001-initial-tech-stack.md` ADR._
> _2. Update the `.devcontainer/` configuration (Dockerfile and devcontainer.json) for our chosen stack, and replace the `{{PROJECT_NAME}}` placeholder in `devcontainer.json` with the project name._
> _3. Configure the universal `Makefile` and setup `dependabot.yml`._
> _4. Update `SECURITY.md` with your contact details._
> _5. Rewrite `README.md` to describe this new project and how to run it."_

### 2. Open in a Devcontainer

Once the Devcontainer has been configured for your stack, open this folder in **VS Code** or **Antigravity** and accept the prompt to **Reopen in Container**. Docker will build your isolated development environment automatically.

### 3. Run the Setup Script

Once the container is ready, open a terminal and run:

```bash
./scripts/setup-env.sh
```

This will configure your Git identity and prompt for any required API keys (Gemini). For GitHub operations, run `gh auth login` inside the container for seamless HTTPS authentication.

Then activate the git hooks and project setup:

```bash
make setup
```

> **Note:** If your devcontainer seems to hang after building, or if `git` complains about missing user name and email, you can manually run `./scripts/start-container.sh` to apply `.env` variables and verify hooks.

### 4. Build Something Great

Start developing! Use the universal `Makefile` targets:

| Command      | Purpose                        |
| ------------ | ------------------------------ |
| `make help`  | Show all available targets     |
| `make setup` | Install deps & configure hooks |
| `make dev`   | Start the development server   |
| `make test`  | Run the test suite             |
| `make build` | Create a production build      |
| `make lint`  | Run code formatting & linting  |
| `make clean` | Remove build artifacts         |

---

## 📚 Key Files to Know

| File                  | What It Does                                                                                         |
| --------------------- | ---------------------------------------------------------------------------------------------------- |
| **`AGENTS.md`**       | Instructions for AI assistants — coding standards, workflow rules, and architectural philosophy.     |
| **`Makefile`**        | Maps your stack-specific commands to universal targets. Update this once you choose your tech stack. |
| **`.env.example`**    | Lists all required environment variables. Copy to `.env` and fill in your values.                    |
| **`CODEOWNERS`**      | Defines who must approve PRs for critical paths (CI, ADRs, Devcontainer).                            |
| **`CONTRIBUTING.md`** | How to contribute: branch naming, conventional commits, ADR workflow, and PR process.                |
| **`SECURITY.md`**     | How to report vulnerabilities. Replace `[SECURITY_EMAIL]` with your contact.                         |

---

## 🛟 Need Help?

- **Container not building?** Check that Docker Desktop is running and you have enough disk space.
- **Gemini CLI missing?** Run `bash ./scripts/setup-gemini.sh` manually inside the container.
- **Line-ending errors on Windows?** Run `git config --global core.autocrlf false` and re-clone.
- **Something else?** Check the [bootstrap repo](https://github.com/penguinranch/bootstrap) for the latest docs and troubleshooting tips.
