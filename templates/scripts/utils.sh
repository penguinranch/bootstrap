#!/bin/bash
# shellcheck shell=bash
# utils.sh: Shared utility functions for Penguin Ranch scripts.

# Colors for logging
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}ℹ️  [INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}✅ [SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠️  [WARN]${NC} $1"; }
log_error() { echo -e "${RED}❌ [ERROR]${NC} $1"; }

# Portable sed: works on both macOS (BSD sed) and Linux (GNU sed)
portable_sed() {
    if sed --version 2>/dev/null | grep -q GNU; then
        sed -i "$@"
    else
        sed -i '' "$@"
    fi
}

# Safely update or append a key=value pair inside an env file.
# Uses awk instead of sed to avoid injection via special characters in values.
update_env() {
    local key=$1
    local value=$2
    local env_file=${3:-.env}

    if [ ! -f "$env_file" ]; then
        touch "$env_file"
    fi

    if grep -q "^${key}=" "$env_file"; then
        local tmp_file
        tmp_file=$(mktemp)
        awk -v k="$key" -v v="$value" 'BEGIN{FS=OFS="="} $1==k{$0=k"="v} {print}' "$env_file" > "$tmp_file"
        mv "$tmp_file" "$env_file"
    else
        printf '%s=%s\n' "$key" "$value" >> "$env_file"
    fi
}

# Read a value from .env by key (returns empty string if not found)
read_env() {
    local key=$1
    local env_file=${2:-.env}
    if [ -f "$env_file" ]; then
        grep -m1 "^${key}=" "$env_file" 2>/dev/null | cut -d'=' -f2- || true
    fi
}

# Ensure we are at the repository root
ensure_root() {
    local script_dir
    script_dir=$(dirname "${BASH_SOURCE[0]}")
    cd "$script_dir/.." || exit 1
}

# Check if we are running inside a container
is_container() {
    [ -f /.dockerenv ] || [ -n "$REMOTE_CONTAINERS" ] || [ -n "$CODESPACES" ]
}

# Ensure the script is running in a devcontainer
ensure_container() {
    if ! is_container; then
        log_error "This script must be run inside a devcontainer."
        log_warn "Please reopen this project in a container to continue."
        exit 1
    fi
}
