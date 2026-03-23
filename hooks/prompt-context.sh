#!/bin/bash
# Hook: UserPromptSubmit
# Purpose: Before AI processes each user message, inject current task context.
# Lightweight — uses mtime cache to avoid spawning python3 on every prompt.

set -euo pipefail

if [ ! -f "docs/tasks.json" ]; then
  exit 0
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SESSION_DIR=$("$SCRIPT_DIR/lib/session-dir.sh" 2>/dev/null || true)
CACHE_FILE="${SESSION_DIR}/task-cache"

# Get tasks.json mtime (macOS: stat -f %m, Linux: stat -c %Y)
TASKS_MTIME=$(stat -f %m docs/tasks.json 2>/dev/null || stat -c %Y docs/tasks.json 2>/dev/null || echo "0")

# Check cache: first line is mtime, rest is content
if [ -f "$CACHE_FILE" ]; then
  CACHED_MTIME=$(head -1 "$CACHE_FILE" 2>/dev/null || echo "")
  if [ "$CACHED_MTIME" = "$TASKS_MTIME" ]; then
    tail -n +2 "$CACHE_FILE"
    exit 0
  fi
fi

# Cache miss — parse and store
CONTEXT=$(python3 hooks/lib/task-summary.py brief 2>/dev/null || true)
if [ -n "$CONTEXT" ] && [ -n "$SESSION_DIR" ]; then
  printf '%s\n%s' "$TASKS_MTIME" "$CONTEXT" > "$CACHE_FILE"
  echo "$CONTEXT"
fi

exit 0
