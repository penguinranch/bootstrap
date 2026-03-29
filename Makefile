.PHONY: help setup doctor dev test build lint clean format

# Default variables
APP_NAME := bootstrap

help: ## Show available make targets
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Interactive first-time setup wizard
	@bash ./scripts/setup-env.sh
	@bash ./scripts/setup-ai-tools.sh
	@if [ -d .githooks ]; then \
		git config core.hooksPath .githooks; \
		chmod +x .githooks/*; \
		echo "✅ Git hooks configured."; \
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
	@shellcheck scripts/*.sh templates/scripts/*.sh || (echo "❌ Shellcheck failed. Fix errors above." && exit 1)
	@echo "🔍 Checking file formatting..."
	@npx -y prettier --check "**/*.{md,json,yml}" || (echo "❌ Formatting check failed. Run 'make format' to fix." && exit 1)
	@echo "✅ All lint checks passed."

format: ## Format all files
	@echo "🧹 Formatting files..."
	@npx -y prettier --write "**/*.{md,json,yml}"
	@echo "✅ Formatting complete."

clean: ## Remove build artifacts
	@echo "Clean target not implemented yet — update after choosing your tech stack"
