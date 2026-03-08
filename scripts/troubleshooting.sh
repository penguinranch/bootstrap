#!/bin/bash
set -u

echo "🔍 Starting Devcontainer Troubleshooting..."
echo "----------------------------------------"

# Change to the repository root relative to the script's location
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit

ISSUE_FOUND=0

# 1. Check for .env file
echo "Checking for .env file..."
if [ ! -f .env ]; then
    echo "❌ Error: .env file is missing."
    if [ -f .env.example ]; then
        echo "   -> .env.example found. Creating .env from template..."
        cp .env.example .env
        echo "   ✅ .env created. Please run './scripts/setup-env.sh' to populate it."
    else
        echo "   ❌ Error: .env.example is also missing. Cannot create .env block automatically."
        ISSUE_FOUND=1
    fi
else
    # Basic check to see if .env has been filled out (checking for placeholder values or empty critical values)
    if grep -q "YOUR_GIT_NAME_HERE" .env || grep -q "YOUR_GIT_EMAIL_HERE" .env; then
        echo "⚠️  Warning: .env file contains placeholder values."
        echo "   -> Please run './scripts/setup-env.sh' to configure your environment variables."
        ISSUE_FOUND=1
    else
        echo "✅ .env file found and appears to be configured."
    fi
fi
echo "----------------------------------------"

# 2. Check script permissions
echo "Checking script permissions..."
PERM_ISSUE=0
for script in scripts/*.sh templates/scripts/*.sh; do
    if [ -f "$script" ]; then
        if [ ! -x "$script" ]; then
            echo "❌ Error: $script is missing execute permissions."
            PERM_ISSUE=1
        fi
    fi
done

if [ $PERM_ISSUE -eq 1 ]; then
    echo "   -> Attempting to fix permissions..."
    chmod +x scripts/*.sh templates/scripts/*.sh 2>/dev/null || true
    echo "   ✅ Added execute permissions to scripts."
else
    echo "✅ All scripts have correct execute permissions."
fi
echo "----------------------------------------"

# 3. Check for specific dependencies (e.g., Make, Git)
echo "Checking dependencies..."
if ! command -v make &> /dev/null; then
    echo "❌ Error: 'make' is not installed."
    echo "   -> Please ensure your Devcontainer has the necessary build tools."
    ISSUE_FOUND=1
else
    echo "✅ 'make' is installed."
fi

if ! command -v git &> /dev/null; then
    echo "❌ Error: 'git' is not installed."
    echo "   -> Git is required for this Devcontainer."
    ISSUE_FOUND=1
else
    echo "✅ 'git' is installed."
fi
echo "----------------------------------------"

# Final summary
if [ $ISSUE_FOUND -eq 1 ]; then
    echo "⚠️  Troubleshooting complete, but some issues require your attention."
    echo "   Please review the warnings and errors above."
    exit 1
else
    echo "🚀 Troubleshooting complete. Everything looks good!"
    exit 0
fi
