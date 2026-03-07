# Contributing

Thank you for considering contributing to this project! This guide will help you get started.

## Development Setup

1. **Open in a Devcontainer** — All development happens inside the container. Never install dependencies on your host machine.
2. **Run the setup script** — `./scripts/setup-env.sh` configures Git identity and API keys.
3. **Activate git hooks** — `make setup` installs pre-commit linting and commit message validation.

## Workflow

### 1. Create an Issue

Before starting work, create or find a GitHub issue describing the change. Use the provided issue templates:
- **🐛 Bug Report** for bugs
- **🚀 Feature Request** for new features

### 2. Write an ADR (for significant changes)

If the change affects architecture, dependencies, or infrastructure, propose an Architecture Decision Record first:

```
docs/decisions/NNN-description.md
```

Use `docs/decisions/000-template.md` as a starting point.

### 3. Create a Branch

Use scoped branch naming:

| Prefix       | Use Case                    |
| ------------ | --------------------------- |
| `feat/...`   | New features                |
| `fix/...`    | Bug fixes                   |
| `task/...`   | Chores, refactors, cleanup  |
| `docs/...`   | Documentation-only changes  |

### 4. Write Code

- Follow the coding standards in `AGENTS.md`
- Run `make lint` before committing (the pre-commit hook does this automatically)
- Write tests — `make test` should pass before submitting a PR

### 5. Commit with Conventional Commits

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>[optional scope]: <description>
```

**Valid types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

The `commit-msg` hook enforces this automatically.

### 6. Submit a Pull Request

- Fill out the PR template completely
- Ensure CI passes
- Update `CHANGELOG.md` with a summary of what changed
- Request review from the appropriate `CODEOWNERS`

## Standards

| Tool              | Purpose                          |
| ----------------- | -------------------------------- |
| **EditorConfig**  | Consistent whitespace & encoding |
| **Prettier**      | Code formatting                  |
| **Makefile**      | Universal task runner            |
| **Git hooks**     | Automated quality gates          |

## Need Help?

Check the `AGENTS.md` file for detailed architectural philosophy, environmental constraints, and coding standards.
