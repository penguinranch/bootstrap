.PHONY: help setup doctor dev test build lint clean format new-adr ai-context

# Container enforcement check
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

# Default variables
APP_NAME := {{PROJECT_NAME}}

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
