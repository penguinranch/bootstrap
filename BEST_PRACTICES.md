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
5. **Replace placeholders** as you copy: `{{PROJECT_NAME}}` (devcontainer.json and the Makefile's `APP_NAME`), `[SECURITY_EMAIL]` (SECURITY.md), `[Year]` / `[Full Name]` ([LICENSE](templates/LICENSE)), and the `@core-maintainers` / `@tech-leads` / `@devops` team slugs (CODEOWNERS).
6. **Record the source commit.** Note the bootstrap commit you adopted from — in the adoption PR body, or in a `.bootstrap-version` file like the installer writes — so a future standards sync can diff upstream from that point instead of re-auditing everything.

---

## Tier 1 — Universal Guardrails (adopt everywhere)

These are drop-in files that prevent entire categories of mistakes and require no changes to how the project is built or run.

| Practice                    | Source                                                                                              | Notes                                                                                                                            |
| --------------------------- | --------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Consistent editor behavior  | [`templates/.editorconfig`](templates/.editorconfig)                                                | Enforces indentation, charset, final newlines in every IDE.                                                                      |
| LF line endings for scripts | [`templates/.gitattributes`](templates/.gitattributes)                                              | Prevents CRLF from breaking bash scripts checked out on Windows.                                                                 |
| Secrets never committed     | [`templates/.env.example`](templates/.env.example) + [`templates/.gitignore`](templates/.gitignore) | Real values live in `.env` (gitignored); `.env.example` documents every variable. Add new variables to `.env.example` first.     |
| Conventional Commits        | [`templates/.githooks/commit-msg`](templates/.githooks/commit-msg)                                  | Enforces `<type>[scope]: <description>` on every commit.                                                                         |
| Pre-commit secrets + lint   | [`templates/.githooks/pre-commit`](templates/.githooks/pre-commit)                                  | Scans staged changes for secrets (gitleaks), then runs `make lint`; each step skips gracefully if its tool isn't available yet.  |
| Consistent formatting       | [`templates/.prettierrc`](templates/.prettierrc)                                                    | Keep whatever formatter the project already uses — the practice is _a_ shared formatter config in the repo, not Prettier per se. |

**Activate the hooks** after copying `.githooks/`:

```bash
git config core.hooksPath .githooks && chmod +x .githooks/*
```

## Tier 2 — Workflow & Automation

| Practice                     | Source                                                                                                                                             | Notes                                                                                                                                                                                                                                                |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Universal task interface     | [`templates/Makefile`](templates/Makefile)                                                                                                         | Wrap _every_ runnable command in a Make target with a `## description` comment (that comment is what `make help` prints). Start with the standard targets — `dev`, `test`, `build`, `lint`, `format`, `clean`, `help` — and keep their names stable. |
| Automated dependency updates | [`templates/.github/dependabot.yml`](templates/.github/dependabot.yml)                                                                             | Include one entry per package ecosystem the project actually uses (`npm`, `pip`, `gomod`, `docker`, `github-actions`, `devcontainers`).                                                                                                              |
| CI on every PR               | [`templates/.github/workflows/ci.yml`](templates/.github/workflows/ci.yml)                                                                         | The Node section is a placeholder — swap in the project's stack, but keep the shape: checkout → setup → install → lint → test, with concurrency.                                                                                                     |
| Security scanning            | [`templates/.github/workflows/security.yml`](templates/.github/workflows/security.yml)                                                             | Trivy filesystem scan failing on CRITICAL/HIGH; usable as-is.                                                                                                                                                                                        |
| PR & issue hygiene           | [`templates/.github/PULL_REQUEST_TEMPLATE.md`](templates/.github/PULL_REQUEST_TEMPLATE.md), [`ISSUE_TEMPLATE/`](templates/.github/ISSUE_TEMPLATE/) | Checklists that make reviews and reports consistent.                                                                                                                                                                                                 |
| Required reviewers           | [`templates/.github/CODEOWNERS`](templates/.github/CODEOWNERS)                                                                                     | Route `docs/` (architecture & project docs) to tech leads and CI/infra changes to DevOps. Update the team slugs.                                                                                                                                     |
| Vulnerability disclosure     | [`templates/SECURITY.md`](templates/SECURITY.md)                                                                                                   | Fill in a real contact address.                                                                                                                                                                                                                      |
| Changelog discipline         | [`templates/CHANGELOG.md`](templates/CHANGELOG.md)                                                                                                 | Keep a Changelog format; record _decisions_, not just diffs.                                                                                                                                                                                         |
| Contributor onboarding       | [`templates/CONTRIBUTING.md`](templates/CONTRIBUTING.md)                                                                                           | Branch naming (`feat/`, `fix/`, `task/`, `docs/`), commit format, living-docs workflow, PR process.                                                                                                                                                  |

## Tier 3 — AI-Native & Environment

| Practice                       | Source                                                                                                                                                   | Notes                                                                                                                                                                                                                                                                |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Agent instructions in the repo | [`templates/AGENTS.md`](templates/AGENTS.md)                                                                                                             | The single most impactful AI-native practice: one file stating working judgment, constraints, philosophy, lifecycle rules, and branching strategy. Adapt, don't copy.                                                                                                |
| Living project documentation   | [`templates/docs/VISION.md`](templates/docs/VISION.md), [`ARCHITECTURE.md`](templates/docs/ARCHITECTURE.md), [`MEMORY.md`](templates/docs/MEMORY.md)     | Three agent-maintained docs: vision (goals, non-goals, roadmap), architecture (stack, Mermaid diagrams, runbook, append-only decision log), and agent memory (preferences, gotchas, lessons — never secrets). See the maintenance triggers in `templates/AGENTS.md`. |
| AI context bundling            | [`templates/scripts/ai-context.sh`](templates/scripts/ai-context.sh)                                                                                     | `make ai-context` bundles README, AGENTS.md, and the `docs/` living documents into one file to prime a fresh AI session cheaply.                                                                                                                                     |
| Devcontainer isolation         | [`templates/.devcontainer/`](templates/.devcontainer/)                                                                                                   | The heaviest item: all development inside a container, zero host dependencies. High value, but retrofitting an existing team's workflow is a judgment call.                                                                                                          |
| Environment setup & health     | [`templates/scripts/setup-env.sh`](templates/scripts/setup-env.sh), [`doctor.sh`](templates/scripts/doctor.sh), [`utils.sh`](templates/scripts/utils.sh) | Interactive `.env` wizard, idempotent health check (`make doctor`), and safe allowlisted `.env` parsing.                                                                                                                                                             |
| SSH commit signing             | see `setup-env.sh` above                                                                                                                                 | Configure `gpg.format ssh` + `user.signingkey`; enable signing only when an agent is actually available so commits never silently fail.                                                                                                                              |

---

## Principles to Enforce Regardless of Files Copied

Even where none of the files above fit, hold the project to the underlying rules:

- **Host isolation:** never install project tooling on the host when a container is the declared environment; wait until you are inside it.
- **Secrets in `.env` only**, documented in `.env.example`, never committed. Parse `.env` against an allowlist of known keys — never blindly `source` it.
- **Decision-first workflow:** significant changes get a one-line entry in the `docs/ARCHITECTURE.md` Decision Log before code, and a CHANGELOG entry after.
- **Evidence over claims:** "done" means verified against actual command output, quoted in the report; anything unverified is reported as unverified, never rounded up to working.
- **Idempotency:** setup and lifecycle scripts must be safe to re-run; interactive prompts never belong in automated lifecycle hooks.
- **Pragmatism (YAGNI & KISS):** build for current requirements; no premature abstraction.
- **One task interface:** contributors and agents run `make test`, not stack-specific incantations. Every new command — migrations, generators, seed scripts, one-offs — gets wrapped in a Make target with a `## description` so it shows up in `make help`, even if it's a one-line passthrough. Developers should never have to remember whether something is an npm command or a python command: `make help` is the only command anyone must remember, in any project.

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
- [ ] docs/ living documents (VISION.md, ARCHITECTURE.md, MEMORY.md); record the adoption itself in the Decision Log
- [ ] Devcontainer (optional — see Tier 3)
```
