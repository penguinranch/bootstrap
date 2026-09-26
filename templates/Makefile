# Universal task runner — the single entry point for every project command.
# Wrap ALL runnable commands (npm, pip, cargo, scripts, ...) in a target here,
# even one-line passthroughs, and give each a '## description' comment so it
# appears in 'make help'. Developers only ever need to remember 'make help'.
.PHONY: help setup doctor doctor-strict doctor-ci dev test build lint clean format ai-context ai-tools ai-extensions bootstrap-sync

# Container enforcement check. Skipped under CI, where ci.yml runs make on the runner.
ifndef CI
ifndef REMOTE_CONTAINERS
ifndef CODESPACES
ifneq ($(wildcard /.dockerenv),/.dockerenv)
$(warning ⚠️  WARNING: You are NOT running inside a devcontainer.)
$(warning This project is designed to be developed in an isolated environment.)
$(warning Future AI assistants may jump the gun and install tools on your host.)
$(warning Please open in a container before proceeding with setup.)
endif
endif
endif
endif

# Default variables
APP_NAME := {{PROJECT_NAME}}

help: ## Show available make targets
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Interactive first-time setup wizard
	@bash ./scripts/setup-env.sh
	@bash ./scripts/setup-ai-tools.sh
	@if [ -d .githooks ]; then \
		if git rev-parse --git-dir >/dev/null 2>&1; then \
			git config core.hooksPath .githooks; \
			chmod +x .githooks/*; \
			echo "✅ Git hooks configured."; \
		else \
			echo "⚠️  Not a git repository — run 'git init', then 'make setup' again to enable hooks."; \
		fi; \
	fi
	@chmod +x scripts/*.sh 2>/dev/null || true
	@echo ""
	@echo "────────────────────────────────────────"
	@echo "  Next steps:"
	@echo "    gh auth login     — Authenticate GitHub CLI"
	@echo "    claude            — Start Claude CLI"
	@echo "    gemini            — Start Gemini CLI"
	@echo "────────────────────────────────────────"
	@echo ""
	@echo "✅ Setup complete. Run 'make' to see all available commands."

doctor: ## Check environment health and status
	@bash ./scripts/doctor.sh

doctor-strict: ## Doctor that exits non-zero on any issue
	@bash ./scripts/doctor.sh --strict

doctor-ci: ## Doctor that exits non-zero only on core toolchain issues (for CI gating)
	@bash ./scripts/doctor.sh --ci

dev: ## Start the development server
	@echo "Dev target not implemented yet — update after choosing your tech stack"

test: ## Run the test suite
	@echo "Test target not implemented yet — update after choosing your tech stack"

build: ## Create a production build
	@echo "Build target not implemented yet — update after choosing your tech stack"

# The pre-commit hook runs this target, so a step that finds no tool must not
# report success — an inert gate that still reports a pass is worse than no
# gate at all. shellcheck ships in the devcontainer image and is therefore
# mandatory; the node-based checks stay advisory until the project picks a
# stack and installs them, and they light up automatically once it does.
lint: ## Run code formatting & linting
	@echo "🔍 Linting shell scripts..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck scripts/*.sh .githooks/* || (echo "❌ Shellcheck failed. Fix the errors above." && exit 1); \
	else \
		echo "❌ shellcheck missing — it ships in the devcontainer image, so rebuild the container." && exit 1; \
	fi
	@echo "🔍 Checking file formatting..."
	@if [ -x node_modules/.bin/prettier ]; then \
		./node_modules/.bin/prettier --check . || (echo "❌ Formatting check failed. Run 'make format' to fix." && exit 1); \
	else \
		echo "⚠️  No formatter installed — .prettierrc is editor-only until you add prettier (or swap in your stack's formatter)."; \
	fi
	@echo "🔍 Checking spelling..."
	@if [ -x node_modules/.bin/cspell ]; then \
		./node_modules/.bin/cspell lint --no-progress --dot "**/*" || (echo "❌ Spell check failed. Fix the typo, or add the term to cspell.json." && exit 1); \
	else \
		echo "⚠️  cspell not installed — cspell.json is editor-only until you add it."; \
	fi
	@echo "🔍 Linting markdown..."
	@if [ -x node_modules/.bin/markdownlint-cli2 ]; then \
		./node_modules/.bin/markdownlint-cli2 || (echo "❌ Markdown lint failed. Fix the errors above." && exit 1); \
	else \
		echo "⚠️  markdownlint not installed — .markdownlint-cli2.jsonc is editor-only until you add it."; \
	fi
	@echo "✅ Lint checks passed."

format: ## Format all files
	@if [ -x node_modules/.bin/prettier ]; then \
		./node_modules/.bin/prettier --write .; \
	else \
		echo "⚠️  No formatter installed — add prettier, or point this target at your stack's formatter."; \
	fi

ai-context: ## Gather project context for AI
	@bash ./scripts/ai-context.sh

ai-tools: ## (Re)install the AI CLI tools
	@bash ./scripts/setup-ai-tools.sh

ai-extensions: ## Install the optional third-party Gemini CLI extensions (interactive)
	@bash ./scripts/setup-ai-tools.sh --extensions

bootstrap-sync: ## Diff this project against the latest upstream bootstrap standards
	@bash ./scripts/bootstrap-sync.sh

clean: ## Remove build artifacts
	@echo "Clean target not implemented yet — update after choosing your tech stack"
