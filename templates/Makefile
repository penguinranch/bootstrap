.PHONY: help setup dev test build lint clean format doctor new-adr ai-context

# Default variables
APP_NAME := {{PROJECT_NAME}}

help: ## Show available make targets
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Install dependencies and configure git hooks
	@git config core.hooksPath .githooks
	@chmod +x .githooks/* scripts/*.sh
	@echo "✅ Git hooks and scripts configured."
	@echo "⚠️  Run your package manager's install command to finish setup."

doctor: ## Check environment health
	@echo "🔍 Checking environment..."
	@command -v git >/dev/null 2>&1 && echo "✅ Git installed" || echo "❌ Git missing"
	@command -v node >/dev/null 2>&1 && echo "✅ Node.js installed ($(shell node -v))" || echo "❌ Node.js missing"
	@command -v npm >/dev/null 2>&1 && echo "✅ npm installed" || echo "❌ npm missing"
	@command -v prettier >/dev/null 2>&1 && echo "✅ Prettier installed" || echo "⚠️  Prettier missing (run npm install -g prettier)"
	@command -v gh >/dev/null 2>&1 && echo "✅ GitHub CLI installed" || echo "⚠️  GitHub CLI missing"
	@echo "✅ Environment check complete."

dev: ## Start the development server
	@echo "Dev target not implemented yet — update after choosing your tech stack"

test: ## Run the test suite
	@echo "Test target not implemented yet — update after choosing your tech stack"

build: ## Create a production build
	@echo "Build target not implemented yet — update after choosing your tech stack"

lint: ## Run code formatting & linting
	@if command -v prettier >/dev/null 2>&1; then \
		prettier --check "."; \
	else \
		echo "⚠️  Prettier not found. Update this target with your preferred linter."; \
	fi

format: ## Format all files
	@if command -v prettier >/dev/null 2>&1; then \
		prettier --write "."; \
	else \
		echo "⚠️  Prettier not found. Update this target with your preferred formatter."; \
	fi

new-adr: ## Create a new Architecture Decision Record
	@bash ./scripts/new-adr.sh

ai-context: ## Gather project context for AI
	@bash ./scripts/ai-context.sh

clean: ## Remove build artifacts
	@echo "Clean target not implemented yet — update after choosing your tech stack"
