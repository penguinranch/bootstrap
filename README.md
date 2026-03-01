# Bootstrap

This repository contains the Gold Standard for spinning up new projects. It enforces containerization, signed commits, automated documentation, and LLM-friendly workflows.

## Features

Zero-Host Dependency: Everything runs in a Devcontainer.

Security First: Pre-configured for SSH commit signing and .env protection.

AI-Ready: Includes AGENTS.md to guide LLMs through ADRs and branch management.

Standardized Ports: Pre-mapped for Antigravity (9222) and web frameworks.

## How to Use

To start a brand-new project with these standards:

Create your new project directory and move into it:

Bash
mkdir my-new-idea && cd my-new-idea
git init
Run the bootstrap installer:

Bash
curl -sSL https://raw.githubusercontent.com/penguinranch/bootstrap/main/install.sh | bash
Open in VS Code: When prompted, click "Reopen in Container."

Run Setup: Inside the container terminal, run:

Bash
./scripts/setup-env.sh

"I am starting a new project. Please read AGENTS.md for our workflow standards. Let's begin Phase 1: Discovery by discussing the goals and tech stack for this idea."

## Developing the Bootstrap Template

If you are looking to contribute to or modify the `bootstrap` repository itself, please consult the root **`AGENTS.md`** file for architectural constraints, goals, and modification rules.
