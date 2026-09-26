# Contributing

Thank you for considering contributing to this project! This guide will help you get started.

## Development Setup

1. **Open in a Devcontainer:** All development happens inside the container. Never install dependencies on your host machine.
2. **Run `make setup`:** The interactive wizard configures your Git identity, optional SSH signing key and API keys. It also installs the AI CLI tools and activates the git hooks (pre-commit secret scanning + linting, and commit message validation).

## Workflow

### 1. Create an Issue

Before starting work, create or find a GitHub issue describing the change. Use the provided issue templates:

- **🐛 Bug Report** for bugs
- **🚀 Feature Request** for new features

### 2. Update the Living Docs (for significant changes)

If the change affects architecture, dependencies, or infrastructure, record the decision (and why) in the **Decision Log** in `docs/ARCHITECTURE.md` before writing code. If it changes goals or scope, update `docs/VISION.md` too.

### 3. Create a Branch

Use scoped branch naming:

| Prefix     | Use Case                   |
| ---------- | -------------------------- |
| `feat/...` | New features               |
| `fix/...`  | Bug fixes                  |
| `task/...` | Chores, refactors, cleanup |
| `docs/...` | Documentation-only changes |

### 4. Write Code

- Follow the coding standards in `AGENTS.md`
- Run `make lint` before committing (the pre-commit hook does this automatically)
- Write tests. `make test` should pass before submitting a PR

### 5. Commit with Conventional Commits

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```text
<type>[optional scope]: <description>
```

**Valid types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

Add `!` after the type or scope to mark a breaking change (for example `feat(api)!: drop the v1 endpoints`).

The `commit-msg` hook enforces this automatically.

### 6. Submit a Pull Request

- Fill out the PR template completely
- Make sure CI passes
- Update `CHANGELOG.md` with a summary of what changed
- Request review from the appropriate `CODEOWNERS`

## Standards

| Tool             | Purpose                          |
| ---------------- | -------------------------------- |
| **EditorConfig** | Consistent whitespace & encoding |
| **Prettier**     | Code formatting (`make format`)  |
| **Makefile**     | Universal task runner            |
| **Git hooks**    | Automated quality gates          |

See `AGENTS.md` for the detailed architectural philosophy, environment constraints, and coding standards.
