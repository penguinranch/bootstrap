.PHONY: help setup dev test build lint clean

# Default variables
APP_NAME := {{PROJECT_NAME}}

help: ## Show available make targets
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Install dependencies and configure git hooks
	@git config core.hooksPath .githooks
	@chmod +x .githooks/*
	@echo "✅ Git hooks configured."
	@echo "⚠️  Run your package manager's install command to finish setup."

dev: ## Start the development server
	@echo "Dev target not implemented yet — update after choosing your tech stack"

test: ## Run the test suite
	@echo "Test target not implemented yet — update after choosing your tech stack"

build: ## Create a production build
	@echo "Build target not implemented yet — update after choosing your tech stack"

lint: ## Run code formatting & linting
	@echo "🔍 Linting shell scripts..."
	@shellcheck install.sh .devcontainer/*.sh scripts/*.sh templates/scripts/*.sh || (echo "❌ Shellcheck failed. Fix errors above." && exit 1)
	@echo "✅ Shell scripts linted."

clean: ## Remove build artifacts
	@echo "Clean target not implemented yet — update after choosing your tech stack"
