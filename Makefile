# Universal task runner — the single entry point for every project command.
# Wrap ALL runnable commands in a target with a '## description' comment so it
# appears in 'make help'. Developers only ever need to remember 'make help'.
.PHONY: help setup doctor dev test build lint clean format check-docs

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

dev: ## Start the development server
	@echo "Dev target not implemented yet — update after choosing your tech stack"

test: ## Run the test suite
	@echo "Test target not implemented yet — update after choosing your tech stack"

build: ## Create a production build
	@echo "Build target not implemented yet — update after choosing your tech stack"

lint: ## Run code formatting & linting
	@echo "🔍 Linting shell scripts..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck install.sh scripts/*.sh templates/scripts/*.sh .githooks/* templates/.githooks/* || (echo "❌ Shellcheck failed. Fix errors above." && exit 1); \
	else \
		echo "⚠️  shellcheck not found — skipping (CI still enforces it)."; \
	fi
	@echo "🔍 Checking file formatting..."
	@if command -v npx >/dev/null 2>&1; then \
		npx -y prettier@3.9.4 --check "**/*.{md,json,yml}" || (echo "❌ Formatting check failed. Run 'make format' to fix." && exit 1); \
	else \
		echo "⚠️  npx not found — skipping prettier (CI still enforces it)."; \
	fi
	@echo "🔍 Checking BEST_PRACTICES.md ↔ templates/ sync..."
	@bash ./scripts/check-best-practices-sync.sh
	@echo "✅ All lint checks passed."

check-docs: ## Verify BEST_PRACTICES.md and templates/ are in sync
	@bash ./scripts/check-best-practices-sync.sh

format: ## Format all files
	@echo "🧹 Formatting files..."
	@npx -y prettier@3.9.4 --write "**/*.{md,json,yml}"
	@echo "✅ Formatting complete."

clean: ## Remove build artifacts
	@echo "Clean target not implemented yet — update after choosing your tech stack"
