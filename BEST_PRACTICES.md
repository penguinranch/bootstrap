# 🧭 Adopting These Standards in an Existing Project

> **Audience:** AI agents and developers who were pointed at this repository with an instruction like _"use the best practices and standards set by this repo"_ — but who already have a project underway and do **not** want to run the full bootstrap installer.

If you are starting a brand-new project, stop here and follow the [README](README.md) instead — the installer gives you everything below in one step.

## How to Use This Guide

1. **Do not run `install.sh`** — it is designed for empty directories and will refuse to overwrite an existing project.
2. **The [`/templates`](templates/) directory is the canonical source.** Every file referenced below lives there, exactly as it would land in a new project. Root-level files (like `install.sh` and the root `Makefile`) manage this repository itself — ignore them.
3. **Fetch files directly** when working remotely:

   ```text
   https://raw.githubusercontent.com/penguinranch/bootstrap/main/templates/<path>
   ```

4. **Adopt in tier order.** Tier 1 fits any project with zero restructuring. Stop at whatever tier matches the project's appetite.
5. **Replace placeholders** as you copy: `{{PROJECT_NAME}}` (devcontainer), `[SECURITY_EMAIL]` (SECURITY.md), `[Year]` / `[Full Name]` (LICENSE), and the `@core-maintainers` / `@tech-leads` / `@devops` team slugs (CODEOWNERS).

---

## Tier 1 — Universal Guardrails (adopt everywhere)

These are drop-in files that prevent entire categories of mistakes and require no changes to how the project is built or run.

| Practice                    | Source                                                                                              | Notes                                                                                                                            |
| --------------------------- | --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Consistent editor behavior  | [`templates/.editorconfig`](templates/.editorconfig)                                                | Enforces indentation, charset, final newlines in every IDE.                                                                      |
| LF line endings for scripts | [`templates/.gitattributes`](templates/.gitattributes)                                              | Prevents CRLF from breaking bash scripts checked out on Windows.                                                                 |
| Secrets never committed     | [`templates/.env.example`](templates/.env.example) + [`templates/.gitignore`](templates/.gitignore) | Real values live in `.env` (gitignored); `.env.example` documents every variable. Add new variables to `.env.example` first.     |
| Conventional Commits        | [`templates/.githooks/commit-msg`](templates/.githooks/commit-msg)                                  | Enforces `<type>[scope]: <description>` on every commit.                                                                         |
| Pre-commit linting          | [`templates/.githooks/pre-commit`](templates/.githooks/pre-commit)                                  | Runs `make lint` before each commit; blocks on real failures, skips gracefully if lint isn't configured yet.                     |
| Consistent formatting       | [`templates/.prettierrc`](templates/.prettierrc)                                                    | Keep whatever formatter the project already uses — the practice is _a_ shared formatter config in the repo, not Prettier per se. |

**Activate the hooks** after copying `.githooks/`:

```bash
git config core.hooksPath .githooks && chmod +x .githooks/*
```

## Tier 2 — Workflow & Automation

| Practice                     | Source                                                                                                                                             | Notes                                                                                                                                            |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Universal task interface     | [`templates/Makefile`](templates/Makefile)                                                                                                         | Map the stack's real commands to the standard targets: `dev`, `test`, `build`, `lint`, `format`, `clean`, `help`. Keep the target names stable.  |
| Automated dependency updates | [`templates/.github/dependabot.yml`](templates/.github/dependabot.yml)                                                                             | Include one entry per package ecosystem the project actually uses (`npm`, `pip`, `gomod`, `docker`, `github-actions`, `devcontainers`).          |
| CI on every PR               | [`templates/.github/workflows/ci.yml`](templates/.github/workflows/ci.yml)                                                                         | The Node section is a placeholder — swap in the project's stack, but keep the shape: checkout → setup → install → lint → test, with concurrency. |
| Security scanning            | [`templates/.github/workflows/security.yml`](templates/.github/workflows/security.yml)                                                             | Trivy filesystem scan failing on CRITICAL/HIGH; usable as-is.                                                                                    |
| PR & issue hygiene           | [`templates/.github/PULL_REQUEST_TEMPLATE.md`](templates/.github/PULL_REQUEST_TEMPLATE.md), [`ISSUE_TEMPLATE/`](templates/.github/ISSUE_TEMPLATE/) | Checklists that make reviews and reports consistent.                                                                                             |
| Required reviewers           | [`templates/.github/CODEOWNERS`](templates/.github/CODEOWNERS)                                                                                     | Route ADRs to tech leads and CI/infra changes to DevOps. Update the team slugs.                                                                  |
| Vulnerability disclosure     | [`templates/SECURITY.md`](templates/SECURITY.md)                                                                                                   | Fill in a real contact address.                                                                                                                  |
| Changelog discipline         | [`templates/CHANGELOG.md`](templates/CHANGELOG.md)                                                                                                 | Keep a Changelog format; record _decisions_, not just diffs.                                                                                     |
| Contributor onboarding       | [`templates/CONTRIBUTING.md`](templates/CONTRIBUTING.md)                                                                                           | Branch naming (`feat/`, `fix/`, `task/`, `docs/`), commit format, ADR workflow, PR process.                                                      |

## Tier 3 — AI-Native & Environment

| Practice                       | Source                                                                                                                                                   | Notes                                                                                                                                                       |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Agent instructions in the repo | [`templates/AGENTS.md`](templates/AGENTS.md)                                                                                                             | The single most impactful AI-native practice: one file stating constraints, philosophy, lifecycle rules, and branching strategy. Adapt, don't copy.         |
| Architecture Decision Records  | [`templates/docs/decisions/000-template.md`](templates/docs/decisions/000-template.md) + [`new-adr.sh`](templates/scripts/new-adr.sh)                    | Propose an ADR _before_ significant changes; number them sequentially in `docs/decisions/`.                                                                 |
| AI context bundling            | [`templates/scripts/ai-context.sh`](templates/scripts/ai-context.sh)                                                                                     | `make ai-context` bundles README, AGENTS.md, and ADRs into one file to prime a fresh AI session cheaply.                                                    |
| Devcontainer isolation         | [`templates/.devcontainer/`](templates/.devcontainer/)                                                                                                   | The heaviest item: all development inside a container, zero host dependencies. High value, but retrofitting an existing team's workflow is a judgment call. |
| Environment setup & health     | [`templates/scripts/setup-env.sh`](templates/scripts/setup-env.sh), [`doctor.sh`](templates/scripts/doctor.sh), [`utils.sh`](templates/scripts/utils.sh) | Interactive `.env` wizard, idempotent health check (`make doctor`), and safe allowlisted `.env` parsing.                                                    |
| SSH commit signing             | see `setup-env.sh` above                                                                                                                                 | Configure `gpg.format ssh` + `user.signingkey`; enable signing only when an agent is actually available so commits never silently fail.                     |

---

## Principles to Enforce Regardless of Files Copied

Even where none of the files above fit, hold the project to the underlying rules:

- **Host isolation:** never install project tooling on the host when a container is the declared environment; wait until you are inside it.
- **Secrets in `.env` only**, documented in `.env.example`, never committed. Parse `.env` against an allowlist of known keys — never blindly `source` it.
- **Decision-first workflow:** significant changes get an ADR before code, and a CHANGELOG entry after.
- **Idempotency:** setup and lifecycle scripts must be safe to re-run; interactive prompts never belong in automated lifecycle hooks.
- **Pragmatism (YAGNI & KISS):** build for current requirements; no premature abstraction.
- **One task interface:** contributors and agents run `make test`, not stack-specific incantations.

## Adoption Checklist

Copy this into the PR that introduces the standards and check off what was adopted:

```markdown
- [ ] .editorconfig, .gitattributes, .prettierrc (or equivalent formatter config)
- [ ] .env / .env.example secret hygiene, .gitignore covers .env
- [ ] .githooks (commit-msg + pre-commit) activated via core.hooksPath
- [ ] Makefile with standard targets mapped to the real stack
- [ ] dependabot.yml covering all package ecosystems in use
- [ ] CI workflow (lint + test on every PR)
- [ ] Security scan workflow (Trivy)
- [ ] PR template, issue templates, CODEOWNERS (slugs updated)
- [ ] SECURITY.md (contact filled in), CONTRIBUTING.md, CHANGELOG.md
- [ ] AGENTS.md adapted to this project
- [ ] docs/decisions/ with ADR template; first ADR records the adoption itself
- [ ] Devcontainer (optional — see Tier 3)
```
