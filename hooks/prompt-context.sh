#!/bin/bash
# Hook: UserPromptSubmit
# Purpose: Before AI processes each user message, inject current task context.
# Lightweight — only outputs if tasks.json exists with pending tasks.

set -euo pipefail

if [ -f "docs/tasks.json" ]; then
  CONTEXT=$(python3 hooks/lib/task-summary.py brief 2>/dev/null || true)
  if [ -n "$CONTEXT" ]; then
    echo "$CONTEXT"
  fi
fi

exit 0
