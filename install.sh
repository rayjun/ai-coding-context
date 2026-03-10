#!/bin/bash

# AI Coding Context Installer
# Purpose: Quickly set up or update AI Context standards in a project.
# Usage: curl -sSL https://.../install.sh | bash

set -e

# --- Configuration ---
# Priority: 1. Positional Argument ($1), 2. AI_CONTEXT_BASE_URL env, 3. DEFAULT_URL
DEFAULT_URL="https://raw.githubusercontent.com/rayjun/ai-coding-context/main"
BASE_URL="${1:-${AI_CONTEXT_BASE_URL:-$DEFAULT_URL}}"

# Files and directories to sync
DIRECTORIES=(
  "docs/plans"
  "docs/reports"
  "skills/workflow-management"
)

CORE_FILES=(
  "AGENTS.md"
  "DEV.md"
  "DOCS.md"
  "skills/workflow-management/SKILL.md"
)

# --- Functions ---

# Print with color
info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
warn() { echo -e "\033[0;33m[WARN]\033[0m $1"; }
error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; exit 1; }

# Download a file from the repository
download_file() {
  local file_path=$1
  local overwrite=$2
  local url="${BASE_URL}/${file_path}"
  
  if [ -f "$file_path" ] && [ "$overwrite" != "true" ]; then
    info "Skipping $file_path (already exists)"
    return
  fi

  info "Downloading $file_path..."
  # Use -f to fail on HTTP error, and cleanup if a zero-sized file is created
  if curl -fsSL "$url" -o "$file_path"; then
    return 0
  else
    warn "Failed to download $file_path (URL: $url)"
    [ -f "$file_path" ] && [ ! -s "$file_path" ] && rm "$file_path"
    return 1
  fi
}

# --- Main Execution ---

# 1. Safety Checks
if [ ! -d ".git" ]; then
  warn "This directory is not a Git repository. Proceeding anyway..."
fi

# 2. Create Directory Structure
info "Creating directory structure..."
for dir in "${DIRECTORIES[@]}"; do
  mkdir -p "$dir"
done

# 3. Download Core Files (Always Overwrite)
info "Syncing core standards..."
for file in "${CORE_FILES[@]}"; do
  download_file "$file" "true"
done

# 4. Initialize Project-Specific Files (Do Not Overwrite)
info "Initializing project-specific files..."
download_file "docs/STATUS.md" "false"
download_file "README.md" "false"

# 5. Success Message
echo -e "\n\033[0;32m✅ AI Coding Context has been successfully initialized!\033[0m"
echo -e "--------------------------------------------------------"
echo -e "Next steps:"
echo -e "1. Read \033[1mAGENTS.md\033[0m to understand AI behavior."
echo -e "2. Start your first task and let AI update \033[1mdocs/STATUS.md\033[0m."
echo -e "3. Happy coding!\n"
