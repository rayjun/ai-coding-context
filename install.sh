#!/bin/bash
set -euo pipefail

# AI Coding Context Installer — long-running task harness
# Usage: curl -sSL https://raw.githubusercontent.com/rayjun/ai-coding-context/main/install.sh | bash
#
# Syncs the harness into the current project:
#   - harness files: always synced (backed up to .bak)
#   - project-specific files: created only if missing
#   - a failed sync rolls back everything this run touched

DEFAULT_URL="https://raw.githubusercontent.com/rayjun/ai-coding-context/main"

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

DIRECTORIES=(
  "docs"
  "harness/hooks"
  "harness/hooks/lib"
)

CORE_FILES=(
  "AGENTS.md"
  "harness/hooks/assertion-audit.sh"
  "harness/hooks/careful-ops-check.sh"
  "harness/hooks/drift-detector.sh"
  "harness/hooks/orient-session.sh"
  "harness/hooks/pre-commit-check.sh"
  "harness/hooks/pre-compact.sh"
  "harness/hooks/record-test-evidence.sh"
  "harness/hooks/session-end.sh"
  "harness/hooks/tasks-validate.sh"
  "harness/hooks/pre-commit-check.test.sh"
  "harness/hooks/record-test-evidence.test.sh"
  "harness/hooks/lib/counter-path.sh"
  "harness/hooks/lib/danger-patterns.sh"
  "harness/hooks/lib/danger-patterns.test.sh"
  "harness/hooks/lib/evidence-path.sh"
  "harness/hooks/lib/json-extract.sh"
  "harness/hooks/lib/pretool-response.sh"
  "harness/hooks/lib/session-dir.sh"
  "harness/hooks/lib/task-summary.py"
  "docs/STATUS.template.md"
  "docs/tasks.example.json"
)

SYNCED=()
rollback() {
  printf '\033[0;31m[ERROR]\033[0m install failed — rolling back files synced this run\n' >&2
  if [ "${#SYNCED[@]}" -gt 0 ]; then
    for f in "${SYNCED[@]}"; do
      if [ -f "${f}.bak" ]; then mv "${f}.bak" "$f"; else rm -f "$f"; fi
    done
  fi
}
trap rollback ERR

info()  { printf '\033[0;34m[INFO]\033[0m %s\n' "$*"; }
warn()  { printf '\033[0;33m[WARN]\033[0m %s\n' "$*"; }

download_file() {
  local rel_path="$1"
  local overwrite="${2:-true}"
  local url="${BASE_URL}/${rel_path}"

  if [ -f "$rel_path" ] && [ "$overwrite" != "true" ]; then
    info "exists, skipping: $rel_path"
    return 0
  fi

  if [ "$DRY_RUN" -eq 1 ]; then
    if [ -f "$rel_path" ]; then
      info "[dry-run] would overwrite: $rel_path (backup -> ${rel_path}.bak)"
    else
      info "[dry-run] would create: $rel_path"
    fi
    return 0
  fi

  mkdir -p "$(dirname "$rel_path")"
  local tmp
  tmp="$(mktemp)"
  if ! curl -fsSL "$url" -o "$tmp"; then
    printf '\033[0;31m[ERROR]\033[0m download failed: %s\n' "$url" >&2
    rm -f "$tmp"
    return 1
  fi

  if [ -f "$rel_path" ]; then cp "$rel_path" "${rel_path}.bak"; fi
  mv "$tmp" "$rel_path"
  SYNCED+=("$rel_path")
  info "synced: $rel_path"
}

# --- Main ---
info "AI Coding Context installer (long-running task harness)"
info "Base URL: $BASE_URL"
echo

if [ ! -d ".git" ]; then
  warn "Not a git repository — you lose diff/rollback safety. Consider 'git init' first."
fi

if [ "$DRY_RUN" -eq 1 ]; then
  info "[dry-run] would create dirs: ${DIRECTORIES[*]}"
else
  for d in "${DIRECTORIES[@]}"; do mkdir -p "$d"; done
fi

echo
info "Syncing harness files..."
for f in "${CORE_FILES[@]}"; do
  download_file "$f" "true"
done

echo
info "Project-specific files (created only if missing)..."
download_file ".gitignore" "false"

if [ "$DRY_RUN" -eq 0 ]; then
  if [ ! -f "docs/STATUS.md" ]; then
    cp docs/STATUS.template.md docs/STATUS.md
    info "created: docs/STATUS.md (from template)"
  fi
  if [ ! -f "docs/tasks.json" ]; then
    cp docs/tasks.example.json docs/tasks.json
    info "created: docs/tasks.json (from example)"
  fi
  chmod +x harness/hooks/*.sh harness/hooks/lib/*.sh 2>/dev/null || true
else
  info "[dry-run] would seed docs/STATUS.md and docs/tasks.json if missing"
fi

echo
if [ -d ".claude" ] || [ -d ".gemini" ] || [ -d ".codex" ] || [ -f "CLAUDE.md" ]; then
  warn "Found tool-specific dirs (.claude/.gemini/.codex) or CLAUDE.md from an old layout."
  warn "This harness is tool-agnostic now — remove them if they only held the old setup."
fi
if [ -f "DEV.md" ] || [ -f "DOCS.md" ]; then
  warn "Found DEV.md/DOCS.md from an old layout — the harness uses AGENTS.md only."
fi

echo
if [ "$DRY_RUN" -eq 1 ]; then
  info "Dry run complete — nothing was written."
else
  info "Done. Next steps:"
  echo "  1. Read AGENTS.md — the long-task protocol (state files, loop discipline, safety triggers)."
  echo "  2. At session start, run: harness/hooks/orient-session.sh"
  echo "  3. Keep docs/tasks.json + docs/STATUS.md updated — that is what survives compaction."
fi
