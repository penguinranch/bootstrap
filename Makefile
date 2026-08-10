# Universal task runner — the single entry point for every project command.
# Wrap ALL runnable commands in a target with a '## description' comment so it
# appears in 'make help'. Developers only ever need to remember 'make help'.
.PHONY: help setup doctor doctor-strict doctor-ci dev test build lint clean format check-docs ensure-toolchain ai-extensions

# Default variables
APP_NAME := bootstrap

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

ai-extensions: ## Install the optional third-party Gemini CLI extensions (interactive)
	@bash ./scripts/setup-ai-tools.sh --extensions

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

ensure-toolchain: # internal: install the pinned lint toolchain if absent
	@if [ ! -x node_modules/.bin/prettier ] && command -v npm >/dev/null 2>&1 && [ -f package-lock.json ]; then \
		echo "📦 Installing lint toolchain (npm ci)..."; \
		npm ci --no-audit --no-fund || echo "⚠️  npm ci failed — npm-based checks will be skipped (CI still enforces it)."; \
	fi

lint: ensure-toolchain ## Run code formatting & linting
	@echo "🔍 Linting shell scripts..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck install.sh scripts/*.sh templates/scripts/*.sh .githooks/* templates/.githooks/* || (echo "❌ Shellcheck failed. Fix errors above." && exit 1); \
	else \
		echo "⚠️  shellcheck not found — skipping (CI still enforces it)."; \
	fi
	@echo "🔍 Checking file formatting..."
	@if [ -x node_modules/.bin/prettier ]; then \
		npm run --silent format:check || (echo "❌ Formatting check failed. Run 'make format' to fix." && exit 1); \
	else \
		echo "⚠️  prettier unavailable (npm not found) — skipping (CI still enforces it)."; \
	fi
	@echo "🔍 Checking spelling..."
	@if [ -x node_modules/.bin/cspell ]; then \
		npm run --silent spell || (echo "❌ Spell check failed. Fix the typo, or add the term to cspell.json." && exit 1); \
	else \
		echo "⚠️  cspell unavailable (npm not found) — skipping (CI still enforces it)."; \
	fi
	@echo "🔍 Linting markdown..."
	@if [ -x node_modules/.bin/markdownlint-cli2 ]; then \
		npm run --silent lint:md || (echo "❌ Markdown lint failed. Fix the errors above." && exit 1); \
	else \
		echo "⚠️  markdownlint unavailable (npm not found) — skipping (CI still enforces it)."; \
	fi
	@echo "🔍 Checking BEST_PRACTICES.md ↔ templates/ sync..."
	@bash ./scripts/check-best-practices-sync.sh
	@echo "🔍 Checking bootstrap ↔ template payload sync..."
	@bash ./scripts/check-template-sync.sh
	@echo "✅ All lint checks passed."

check-docs: ## Verify BEST_PRACTICES.md links/coverage and repo ↔ template payload sync
	@bash ./scripts/check-best-practices-sync.sh
	@bash ./scripts/check-template-sync.sh

format: ensure-toolchain ## Format all files
	@echo "🧹 Formatting files..."
	@if [ -x node_modules/.bin/prettier ]; then \
		npm run --silent format; \
	else \
		echo "⚠️  prettier unavailable (npm not found) — skipping."; \
	fi
	@echo "✅ Formatting complete."

clean: ## Remove build artifacts
	@echo "Clean target not implemented yet — update after choosing your tech stack"
