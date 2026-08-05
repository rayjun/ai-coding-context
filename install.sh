#!/bin/bash
set -euo pipefail

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
  "docs/decisions"
  "docs/specs/_template"
  "harness/agents"
  "harness/skills/workflow-management"
  "harness/skills/investigate"
  "harness/skills/careful-ops"
  "harness/skills/plan-review"
  "harness/skills/code-review"
  "harness/skills/obsidian-writer"
  "harness/skills/obsidian-writer/scripts"
  "harness/skills/lib"
  "harness/rules"
  "harness/commands"
  "harness/hooks"
  "harness/hooks/lib"
)

CORE_FILES=(
  "AGENTS.md"
  "harness/agents/plan-reviewer.md"
  "harness/agents/code-reviewer.md"
  "harness/agents/retro-writer.md"
  "harness/skills/workflow-management/SKILL.md"
  "harness/skills/investigate/SKILL.md"
  "harness/skills/careful-ops/SKILL.md"
  "harness/skills/plan-review/SKILL.md"
  "harness/skills/code-review/SKILL.md"
  "harness/skills/obsidian-writer/SKILL.md"
  "harness/skills/obsidian-writer/scripts/resolve-vault.sh"
  "harness/skills/obsidian-writer/scripts/set-vault.sh"
  "harness/rules/hooks-dev.md"
  "harness/rules/skills-dev.md"
  "harness/rules/docs-maintenance.md"
  "harness/commands/review.md"
  "harness/commands/status.md"
  "harness/commands/fix-issue.md"
  "harness/hooks/careful-ops-check.sh"
  "harness/hooks/orient-session.sh"
  "harness/hooks/status-reminder.sh"
  "harness/hooks/pre-commit-check.sh"
  "harness/hooks/record-test-evidence.sh"
  "harness/hooks/post-edit-dispatch.sh"
  "harness/hooks/status-format-check.sh"
  "harness/hooks/tasks-validate.sh"
  "harness/hooks/plan-review-reminder.sh"
  "harness/hooks/plan-review-reminder.test.sh"
  "harness/hooks/drift-detector.sh"
  "harness/hooks/notify.sh"
  "harness/hooks/credential-sniff.sh"
  "harness/hooks/large-file-warn.sh"
  "harness/hooks/migration-safety.sh"
  "harness/hooks/lib/json-extract.sh"
  "harness/hooks/lib/session-dir.sh"
  "harness/hooks/lib/task-summary.py"
  "harness/hooks/lib/danger-patterns.sh"
  "harness/hooks/lib/danger-patterns.test.sh"
  "harness/hooks/lib/pretool-response.sh"
  "harness/hooks/lib/evidence-path.sh"
  "harness/hooks/lib/counter-path.sh"
  "harness/skills/lib/eval-runner.py"
  "harness/hooks/session-end.sh"
  "harness/hooks/assertion-audit.sh"
  "harness/hooks/prompt-context.sh"
  "harness/hooks/pre-compact.sh"
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
download_file "docs/decisions/README.md" "true"
download_file "docs/specs/README.md" "true"
download_file "docs/specs/_template/requirements.md" "true"
download_file "docs/specs/_template/design.md" "true"
download_file "docs/specs/_template/tasks.md" "true"
download_file ".gitignore" "false"
download_file "docs/STATUS.md" "false"
download_file "docs/lessons.md" "false"
download_file "docs/tasks.example.json" "false"
download_file "README.md" "false"

# 5. Make Hook Scripts Executable
if [ "$DRY_RUN" -eq 0 ]; then
  info "Setting hook scripts as executable..."
  chmod +x harness/hooks/*.sh harness/hooks/lib/*.sh harness/skills/lib/*.py harness/skills/obsidian-writer/scripts/*.sh 2>/dev/null || true
fi

# 6. Clean up deprecated files
if [ -f "DEV.md" ]; then
  warn "DEV.md is deprecated (merged into AGENTS.md). Consider removing it."
fi
if [ -f "DOCS.md" ]; then
  warn "DOCS.md is deprecated (merged into AGENTS.md). Consider removing it."
fi
if [ -d "hooks" ] && [ ! -d "harness/hooks" ]; then
  warn "hooks/ at project root is deprecated. Hooks now live in harness/hooks/."
fi
if [ -d ".claude" ] || [ -d ".gemini" ] || [ -d ".codex" ] || [ -f "CLAUDE.md" ]; then
  warn "Tool-specific dirs (.claude/.gemini/.codex) and CLAUDE.md are removed in favor of the tool-agnostic harness/ + AGENTS.md. Remove them if they still exist."
fi

# 7. Success Message
echo -e "\n\033[0;32m✅ AI Coding Context has been successfully initialized!\033[0m"
echo -e "--------------------------------------------------------"
echo -e "Next steps:"
echo -e "1. Read \033[1mAGENTS.md\033[0m to understand AI behavior."
echo -e "2. Use \033[1m/status\033[0m to check project health."
echo -e "3. Happy coding!\n"
