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

# Update or append
sed -i "s/^GIT_NAME=.*/GIT_NAME=$GIT_NAME/" .env || echo "GIT_NAME=$GIT_NAME" >> .env
sed -i "s/^GIT_EMAIL=.*/GIT_EMAIL=$GIT_EMAIL/" .env || echo "GIT_EMAIL=$GIT_EMAIL" >> .env

echo "Configuration complete. Restart your terminal or source the .env file."