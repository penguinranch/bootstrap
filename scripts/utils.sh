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

# Function to securely update or append inside .env
update_env() {
    local key=$1
    local value=$2
    local env_file=${3:-.env}

    if [ ! -f "$env_file" ]; then
        touch "$env_file"
    fi

    if grep -q "^${key}=" "$env_file"; then
        portable_sed "s|^${key}=.*|${key}=${value}|" "$env_file"
    else
        echo "${key}=${value}" >> "$env_file"
    fi
}

# Ensure we are at the repository root
ensure_root() {
    local script_dir
    script_dir=$(dirname "${BASH_SOURCE[1]:-${BASH_SOURCE[0]}}")
    cd "$script_dir/.." || exit 1
}
