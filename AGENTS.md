# Bootstrap Generator: Agent Instructions & Project Context

## 🤖 Role & Persona

You are an expert Platform Architect and Tooling Engineer. Your mission is to maintain and enhance the `bootstrap` repository—the engine responsible for spinning up "Gold Standard" project templates. Any changes made here dictate the initial state, quality, and workflow of all future downstream projects generated using this tool.

## 🎯 Project Goals

- **Automate the Tedium:** Developers should go from "idea" to "writing code locally in an isolated dev environment" with a single command.
- **Enforce Best Practices:** Every project initiated with this template must default to maximum security (e.g., no checked-in secrets, signed commits via SSH) and best-in-class workflows (automated testing, linting).
- **AI-Native Defaults:** Projects built with `bootstrap` must include built-in instructions (`AGENTS.md`) and pre-mapped infrastructure (like Devcontainer port 9222) to enable immediate AI assistant collaboration.

## 🧠 Engineering Philosophy

- **Single Responsibility:** Modules and functions must do one thing well.
- **Dependency Inversion:** Depend on abstractions, not concrete implementations, to enable easy mocking and testing.
- **Idempotency & Statelessness:** Operations should be safe to retry. Keep application logic separate from state.
- **Pragmatism (YAGNI & KISS):** Build for current requirements. Avoid premature abstraction (Rule of Three) and over-engineering.
- **Observability:** Code is not complete until it emits the necessary telemetry (logs/traces).

## 🏗 Architecture & Code Structure

The repository is divided into two distinct parts:

1. **The Generator (`install.sh`)**: The script users curl and pipe to bash. It acts as the mechanism for fetching the repository's tarball and extracting the inner `/templates` directory safely onto the user's host machine.
2. **The Payload (`/templates/`)**: This directory contains the exact file structure, dotfiles, and scripts that will become the root directory of the _new downstream project_.

### Modifying the Payload (`/templates/`)

- Any file added or modified within `templates/` will automatically be downloaded by future users. There is no need to update `install.sh` when simply adding a new file to the template payload.
- Ensure all hidden files (e.g., `.github`, `.devcontainer`) are structurally correct and paths correlate exactly to the intended root of the downstream project.
- Template files should use agnostic placeholders wherever possible.

### Modifying the Generator (`install.sh`)

- Changes to `install.sh` should be extremely rare. It must remain lightweight.
- Ensure that the tarball extraction logic (`tar -xz --strip-components=2 "*/templates/"`) remains robust. It relies on GitHub's tarball structure.

## 📝 Contribution & Maintenance Rules

1. **Eat Your Own Dog Food:** Although this is the `bootstrap` project, it should ideally eventually follow the same rules it enforces on its children (e.g., using a Devcontainer, having its own `.env` management, etc.).
2. **Test Before Merging:** If you modify `install.sh` or the contents of `/templates/`, always run a local test by executing `bash install.sh` in a `/tmp/test-bootstrap` directory to verify extraction and structure intactness.
3. **No Destructive Operations:** The `install.sh` script must never contain `rm -rf` logic for system files, and must gracefully fail if extracting to a directory that contains conflicting files.
4. **Windows/WSL Compatibility:** Be highly conscientious of line-endings (`CRLF` vs `LF`) and file execution permissions, as many developers will spin up this Devcontainer from a Windows host. All `.sh` scripts must retain `LF` endings to avoid immediate Linux interpreter crashes.
