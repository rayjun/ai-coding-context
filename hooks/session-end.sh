#!/bin/bash
# Hook: Stop (fires when the AI agent stops / session ends)
# Purpose: Validate that persistent state has been updated before session ends.
# Non-blocking (exit 0) — outputs warnings for anything that looks stale.

set -euo pipefail

WARNINGS=""

# 1. Check STATUS.md was updated recently (within last 2 hours)
if [ -f "docs/STATUS.md" ]; then
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    # Check if STATUS.md has uncommitted changes (good — means it was updated)
    if ! git diff --name-only 2>/dev/null | grep -q 'docs/STATUS.md' && \
       ! git diff --cached --name-only 2>/dev/null | grep -q 'docs/STATUS.md'; then
      # Not modified in working tree. Check if it was committed recently.
      LAST_COMMIT_TIME=$(git log -1 --format=%ct -- docs/STATUS.md 2>/dev/null || echo "0")
      CURRENT_TIME=$(date +%s)
      HOURS_AGO=$(( (CURRENT_TIME - LAST_COMMIT_TIME) / 3600 ))
      if [ "$HOURS_AGO" -gt 2 ]; then
        WARNINGS="${WARNINGS}\n  - docs/STATUS.md was not updated in this session (last change: ${HOURS_AGO}h ago)"
      fi
    fi
  fi
else
  WARNINGS="${WARNINGS}\n  - docs/STATUS.md does not exist"
fi

# 2. Check tasks.json consistency if it exists
if [ -f "docs/tasks.json" ]; then
  TASK_CHECK=$(python3 hooks/lib/task-summary.py check 2>/dev/null || true)
  if [ -n "$TASK_CHECK" ]; then
    WARNINGS="${WARNINGS}\n  - ${TASK_CHECK}"
  fi
fi

# 3. Check for unstaged changes that should be committed
if git rev-parse --is-inside-work-tree &>/dev/null; then
  UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$UNCOMMITTED" -gt 0 ]; then
    WARNINGS="${WARNINGS}\n  - ${UNCOMMITTED} uncommitted file(s) in working tree"
  fi
fi

# Output warnings if any
if [ -n "$WARNINGS" ]; then
  echo ""
  echo "=== SESSION END CHECK ==="
  echo -e "Before ending, please address:${WARNINGS}"
  echo "=== END CHECK ==="
  echo ""
fi

# Clean up session temp files
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -x "$SCRIPT_DIR/lib/session-dir.sh" ]; then
  SESSION_DIR=$("$SCRIPT_DIR/lib/session-dir.sh" 2>/dev/null || true)
  if [ -n "$SESSION_DIR" ] && [ -d "$SESSION_DIR" ]; then
    rm -rf "$SESSION_DIR"
  fi
fi

exit 0
