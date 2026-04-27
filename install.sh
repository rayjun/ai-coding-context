#!/bin/bash

# AI Coding Context Installer
# Purpose: Quickly set up or update AI Context standards in a project.
# Usage: curl -sSL https://.../install.sh | bash

set -e

# --- Configuration ---
# Priority: 1. Positional Argument ($1), 2. AI_CONTEXT_BASE_URL env, 3. DEFAULT_URL
DEFAULT_URL="https://raw.githubusercontent.com/rayjun/ai-coding-context/main"

# Parse flags. Accepts --dry-run and optional positional URL.
DRY_RUN=0
URL_ARG=""
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n) DRY_RUN=1 ;;
    --help|-h)
      cat <<'HLP'
Usage: install.sh [--dry-run] [BASE_URL]

  --dry-run   Show what would be downloaded/overwritten without touching the filesystem.
  BASE_URL    Override raw-content base (default: github main branch).

Existing files are backed up to <file>.bak before being overwritten (except on dry-run).
HLP
      exit 0
      ;;
    *) URL_ARG="$arg" ;;
  esac
done

BASE_URL="${URL_ARG:-${AI_CONTEXT_BASE_URL:-$DEFAULT_URL}}"

# Files and directories to sync
DIRECTORIES=(
  "docs/plans"
  "docs/reports"
  ".claude/skills/workflow-management"
  ".claude/skills/investigate"
  ".claude/skills/careful-ops"
  ".claude/skills/plan-review"
  ".claude/skills/monitoring-security"
  ".claude/skills/obsidian-vault"
  ".claude/skills/obsidian-writer"
  ".claude/skills/obsidian-writer/scripts"
  ".claude/skills/lib"
  ".claude/rules"
  ".claude/commands"
  ".claude/hooks"
  ".claude/hooks/lib"
)

CORE_FILES=(
  "CLAUDE.md"
  "AGENTS.md"
  ".claude/skills/workflow-management/SKILL.md"
  ".claude/skills/investigate/SKILL.md"
  ".claude/skills/careful-ops/SKILL.md"
  ".claude/skills/plan-review/SKILL.md"
  ".claude/skills/monitoring-security/SKILL.md"
  ".claude/skills/obsidian-vault/SKILL.md"
  ".claude/skills/obsidian-writer/SKILL.md"
  ".claude/skills/obsidian-writer/scripts/resolve-vault.sh"
  ".claude/skills/obsidian-writer/scripts/set-vault.sh"
  ".claude/settings.json"
  ".claude/rules/hooks-dev.md"
  ".claude/rules/skills-dev.md"
  ".claude/rules/docs-maintenance.md"
  ".claude/commands/review.md"
  ".claude/commands/status.md"
  ".claude/commands/fix-issue.md"
  ".claude/hooks/careful-ops-check.sh"
  ".claude/hooks/orient-session.sh"
  ".claude/hooks/status-reminder.sh"
  ".claude/hooks/pre-commit-check.sh"
  ".claude/hooks/record-test-evidence.sh"
  ".claude/hooks/post-edit-dispatch.sh"
  ".claude/hooks/status-format-check.sh"
  ".claude/hooks/tasks-validate.sh"
  ".claude/hooks/drift-detector.sh"
  ".claude/hooks/notify.sh"
  ".claude/hooks/credential-sniff.sh"
  ".claude/hooks/large-file-warn.sh"
  ".claude/hooks/migration-safety.sh"
  ".claude/hooks/lib/json-extract.sh"
  ".claude/hooks/lib/session-dir.sh"
  ".claude/hooks/lib/task-summary.py"
  ".claude/hooks/lib/danger-patterns.sh"
  ".claude/hooks/lib/danger-patterns.test.sh"
  ".claude/hooks/lib/pretool-response.sh"
  ".claude/skills/lib/eval-runner.py"
  ".claude/hooks/session-end.sh"
  ".claude/hooks/assertion-audit.sh"
  ".claude/hooks/prompt-context.sh"
  ".claude/hooks/pre-compact.sh"
  ".gemini/settings.json"
  ".codex/config.toml"
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

  if [ "$DRY_RUN" -eq 1 ]; then
    if [ -f "$file_path" ]; then
      info "[dry-run] would overwrite $file_path (backup → $file_path.bak)"
    else
      info "[dry-run] would create $file_path"
    fi
    return 0
  fi

  # Back up existing file before overwriting
  if [ -f "$file_path" ] && [ "$overwrite" = "true" ]; then
    cp "$file_path" "$file_path.bak" 2>/dev/null || true
  fi

  # Ensure parent directory exists
  local dir
  dir=$(dirname "$file_path")
  [ "$dir" != "." ] && mkdir -p "$dir"

  info "Downloading $file_path..."
  # Use -f to fail on HTTP error, and cleanup if a zero-sized file is created
  if curl -fsSL "$url" -o "$file_path"; then
    return 0
  else
    warn "Failed to download $file_path (URL: $url)"
    [ -f "$file_path" ] && [ ! -s "$file_path" ] && rm "$file_path"
    # Restore from backup if download failed
    if [ -f "$file_path.bak" ]; then
      mv "$file_path.bak" "$file_path"
      warn "Restored $file_path from backup"
    fi
    return 1
  fi
}

# --- Main Execution ---

# 1. Safety Checks
if [ ! -d ".git" ]; then
  warn "This directory is not a Git repository. Proceeding anyway..."
fi

# 2. Create Directory Structure
if [ "$DRY_RUN" -eq 1 ]; then
  info "[dry-run] would create directories: ${DIRECTORIES[*]}"
else
  info "Creating directory structure..."
  for dir in "${DIRECTORIES[@]}"; do
    mkdir -p "$dir"
  done
fi

# 3. Download Core Files (Always Overwrite)
info "Syncing core standards..."
for file in "${CORE_FILES[@]}"; do
  download_file "$file" "true"
done

# 4. Initialize Project-Specific Files (Do Not Overwrite)
info "Initializing project-specific files..."
download_file "docs/STATUS.template.md" "true"
download_file "docs/status-writing-guide.md" "true"
download_file ".gitignore" "false"
download_file "docs/STATUS.md" "false"
download_file "docs/tasks.example.json" "false"
download_file "README.md" "false"

# 5. Make Hook Scripts Executable
if [ "$DRY_RUN" -eq 0 ]; then
  info "Setting hook scripts as executable..."
  chmod +x .claude/hooks/*.sh .claude/hooks/lib/*.sh .claude/skills/lib/*.py .claude/skills/obsidian-writer/scripts/*.sh 2>/dev/null || true
fi

# 6. Clean up deprecated files
if [ -f "DEV.md" ]; then
  warn "DEV.md is deprecated (merged into AGENTS.md). Consider removing it."
fi
if [ -f "DOCS.md" ]; then
  warn "DOCS.md is deprecated (merged into AGENTS.md). Consider removing it."
fi
if [ -d "hooks" ] && [ ! -d ".claude/hooks" ]; then
  warn "hooks/ at project root is deprecated. Hooks now live in .claude/hooks/."
fi

# 7. Success Message
echo -e "\n\033[0;32m✅ AI Coding Context has been successfully initialized!\033[0m"
echo -e "--------------------------------------------------------"
echo -e "Next steps:"
echo -e "1. Read \033[1mCLAUDE.md\033[0m and \033[1mAGENTS.md\033[0m to understand AI behavior."
echo -e "2. Use \033[1m/status\033[0m to check project health."
echo -e "3. Happy coding!\n"
