#!/bin/bash
# Re-runnable script to initialize or update .env
if [ ! -f .env.example ]; then
    echo "Error: .env.example not found. Please create it first."
    exit 1
fi

if [ ! -f .env ]; then
    cp .env.example .env
    echo ".env created from template."
fi

echo "Setting up environment variables..."
read -p "Enter your Git Name: " GIT_NAME
read -p "Enter your Git Email: " GIT_EMAIL

echo ""
echo "Optional: The Gemini API Key is used by the CLI tools inside this Devcontainer."
echo "You can get an API key from: https://aistudio.google.com/app/apikey"
read -p "Enter your Gemini API Key (press Enter to skip): " GEMINI_API_KEY

# Function to securely update or append inside .env
update_env() {
    local key=$1
    local value=$2
    if grep -q "^${key}=" .env; then
        # Replace existing key ensuring value is quoted safely if necessary, though basic alphanumeric is fine here
        sed -i '' "s|^${key}=.*|${key}=${value}|" .env 2>/dev/null || sed -i "s|^${key}=.*|${key}=${value}|" .env
    else
        echo "${key}=${value}" >> .env
    fi
}

update_env "GIT_NAME" "$GIT_NAME"
update_env "GIT_EMAIL" "$GIT_EMAIL"

# Also configure git locally for the current environment
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

if [ -n "$GEMINI_API_KEY" ]; then
    update_env "GEMINI_API_KEY" "$GEMINI_API_KEY"
fi

# Update the LICENSE file if it exists
if [ -f "LICENSE" ] && [ -n "$GIT_NAME" ]; then
    CURRENT_YEAR=$(date +"%Y")
    # Use cross-platform sed (Mac vs Linux syntax differences)
    sed -i '' "s/\[Year\]/$CURRENT_YEAR/g" LICENSE 2>/dev/null || sed -i "s/\[Year\]/$CURRENT_YEAR/g" LICENSE
    sed -i '' "s/\[Full Name\]/$GIT_NAME/g" LICENSE 2>/dev/null || sed -i "s/\[Full Name\]/$GIT_NAME/g" LICENSE
fi

echo "Configuration complete. Restart your terminal or source the .env file."