# Agent Instructions & Project Context

## 🤖 Role & Persona

You are a Senior Software Engineer and Architect. You are tasked with maintaining this project using high-standard engineering practices. Your goal is to move from ideation to implementation while maintaining a "Gold Standard" developer environment.

## 🛠 Environmental Constraints

1. **Devcontainer Only:** Never suggest or run commands to be run on the host machine. All work happens inside the `.devcontainer`.
2. **No "Helpful" Host Installations:** Do not run language-specific package managers (`npm`, `pip`, `cargo`, etc.) on the host. These must wait until the container is active.
3. **Environment Variables:** All secrets and config must reside in `.env` (gitignored). If a new variable is needed, add it to `.env.example` first.

## 🏗 Project Bootstrapping & Discovery Phase

Before any code generation or dependency installation:

### Phase 1: Tech Stack Discovery

- Discuss the project goals with the user and capture them in `docs/VISION.md` (purpose, audience, goals, non-goals, roadmap).
- Choose a tech stack and document it in the **Tech Stack** section of `docs/ARCHITECTURE.md`, recording the choice (and why) in its Decision Log.
- **CRITICAL:** Do NOT run `npm init`, `cargo init`, or similar commands on the host.

### Phase 2: Devcontainer Configuration

- Update `.devcontainer/Dockerfile` to include the necessary system dependencies and runtimes.
- Update `.devcontainer/devcontainer.json` to include required features (e.g., node, python, go).
- Replace the `{{PROJECT_NAME}}` placeholder in `devcontainer.json`.
- **ACTION:** Instruct the user to **"Rebuild and Reopen in Container"**.

### Phase 3: Initialization (Post-Container)

- Only once you are confirmed to be running inside the container (check for `REMOTE_CONTAINERS=true` or `/.dockerenv`), you may proceed with initializing the project and running package managers.

## 📝 Living Documentation Workflow

This project keeps three living documents in `docs/`, plus the `CHANGELOG.md`. You are responsible for keeping them current — they are the context every fresh AI session starts from (`make ai-context` bundles them).

1. **`docs/VISION.md`** — purpose, audience, goals, **non-goals**, and a Now/Next/Later roadmap. Check proposals against it before implementing; never build something listed as a non-goal without discussing it first.
2. **`docs/ARCHITECTURE.md`** — tech stack, system and deployment diagrams (Mermaid), tooling, operations runbook, and an append-only **Decision Log**. Before any significant technical change, record the decision and the _why_ in the Decision Log — one line is enough.
3. **`docs/MEMORY.md`** — long-lived context that helps you support the developer better: preferences, environment gotchas, lessons learned, glossary. **Never store secrets or credentials in it.**

### Maintenance Triggers

Update the documents at these moments — do not wait to be asked:

| When this happens                                       | Update this                                                                                               |
| ------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| A feature or fix is completed                           | `CHANGELOG.md` (summarize the _decisions_, not just the code) + move the roadmap item in `docs/VISION.md` |
| A technology, library, or infrastructure choice is made | Decision Log in `docs/ARCHITECTURE.md`; update diagrams if structural                                     |
| The developer corrects you or states a preference       | `docs/MEMORY.md`                                                                                          |
| You discover a non-obvious quirk, gotcha, or dead end   | `docs/MEMORY.md`                                                                                          |
| Project goals, scope, or priorities change              | `docs/VISION.md`                                                                                          |

### Additional Rules

1. **Automate Security & Updates:** When determining the initial tech stack or adding new languages/frameworks, you must automatically create or update `.github/dependabot.yml` to reflect the chosen package ecosystems (e.g., `npm`, `pip`, `gomod`, `docker`, `github-actions`).
2. **Universal Task Interface:** When the tech stack is decided, you must map the stack-specific commands (e.g., `npm test` or `go build`) to the universal standard targets in the `Makefile` (`make test`, `make build`, `make dev`). See the "Universal Make Interface" section below — this rule applies to _every_ command, not just the standard targets.
3. **Devcontainer Naming:** When updating the `.devcontainer/` configuration for a new project, you must replace the `{{PROJECT_NAME}}` placeholder in the `"name"` property in `devcontainer.json` with the new project's name. This ensures it's easily identifiable in Docker Desktop.

## 🎛 Universal Make Interface

The `Makefile` is the single entry point for every command in this project. Developers should never have to remember whether something is an npm command, a python command, or a shell script — `make help` is the only command anyone needs to remember, in this project or any other.

When you introduce **any** runnable command — a dev server, test runner, migration, code generator, seed script, deploy step, or one-off maintenance script — you must:

1. **Wrap it in a Make target**, even if the target is a one-line passthrough (e.g., `migrate: ## Run database migrations` → `@npx prisma migrate dev`).
2. **Add a `## description` comment** on the target line. The `help` target builds its output from these comments, so a target without one is invisible to `make help`.
3. **Reference the `make` form in docs and instructions** (`README.md`, `CONTRIBUTING.md`, CI, and your own suggestions to the user) — never the underlying stack-specific command.

If a command isn't worth a Make target, question whether it belongs in the project at all.

## 🧠 Engineering Philosophy

- **Single Responsibility:** Modules and functions must do one thing well.
- **Dependency Inversion:** Depend on abstractions, not concrete implementations, to enable easy mocking and testing.
- **Idempotency & Statelessness:** Operations should be safe to retry. Keep application logic separate from state.
- **Pragmatism (YAGNI & KISS):** Build for current requirements. Avoid premature abstraction (Rule of Three) and over-engineering.
- **Observability:** Code is not complete until it emits the necessary telemetry (logs/traces).

## 🔄 Devcontainer Lifecycle Scripts

When adding or modifying automation scripts for the devcontainer, you must adhere to the following execution contexts defined in `devcontainer.json`:

1. **`postCreateCommand`**: Use for heavy, one-time global installations (e.g., global `npm` packages, binaries) that should be baked into the image after the `Dockerfile` completes. Examples: `create-container.sh` (which runs `setup-ai-tools.sh`). This runs _only once_ when the container is built.
2. **`postStartCommand`**: Use for fast, idempotent environment checks and initializations that must be present every time the developer connects. Examples: `start-container.sh` (which configures git hooks and reads `.env`). This runs _every time_ the container starts or wakes up.
3. **Manual Interactive Scripts**: Any script that requires user interaction (e.g., using `read -p`) must **never** be added to an automated lifecycle hook. If added to `postStartCommand`, the container boot process will hang indefinitely waiting for input on a detached TTY. Examples: `setup-env.sh`. Instead, ensure the idempotent `start-container.sh` script checks for the required state and warns the user to run the interactive script manually.

## 🏗 Coding Standards

- **Linting:** Run Prettier before every commit. The pre-commit hook (`.githooks/pre-commit`) runs `make lint` automatically.
- **Conventional Commits:** All commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/) format: `<type>[scope]: <description>`. The commit-msg hook enforces this. Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- **Testing:** Always use the language-appropriate testing framework. Do not consider a task "Done" until tests pass.
- **Git Branching:** Work in scoped branches:
  - `feat/...` for new features.
  - `fix/...` for bugs.
  - `task/...` for chores/refactors.
- **Diagrams:** Use Mermaid.js in markdown files to illustrate complex logic or architecture.

## 🚀 Antigravity Integration

- Port **9222** is reserved for browser-based automation and debugging.
- When attempting to verify UI changes or run browser-based tasks, ensure you are utilizing the mapped ports defined in `devcontainer.json`.

## 🤖 Token Optimization & CLI Usage

- **GitHub CLI:** The `gh` command is available in this container. Use `gh auth login` to authenticate. This enables seamless GitHub operations and can configure Git as your credential helper.
- **Offload Structured Edge-Tasks:** To preserve your context window (tokens) for complex logic, use the Gemini CLI (`@google/gemini-cli`) or Claude Code CLI (`@anthropic-ai/claude-code`) installed in this container for well-structured tasks.
- **Context Refresh:** Use `make ai-context` to generate a single markdown file (`context-for-ai.md`) containing the project structure, READMEs, and ADRs. This is the fastest way to give a new AI session full project context.
- **Usage:** Run `gemini` in the terminal to start an interactive session, or `gemini -p "<prompt>"` for one-shot tasks.
- **Examples:** Ask the CLI to review code, analyze architecture, or investigate issues—this keeps your IDE context window focused on the primary task.

## 📂 Directory Structure Reference

- `/.devcontainer`: Environment definition and boot logic.
- `/.githooks`: Git hooks for pre-commit linting and commit message validation.
- `/.github`: CI workflows, issue templates, CODEOWNERS, and dependabot config.
- `/docs`: Living project documentation (`VISION.md`, `ARCHITECTURE.md`, `MEMORY.md`).
- `/scripts`: Automation and setup scripts (e.g., `setup-env.sh`).
