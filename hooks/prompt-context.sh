#!/bin/bash
# Hook: UserPromptSubmit
# Purpose: Before AI processes each user message, inject current task context.
# Lightweight — only outputs if tasks.json exists with pending tasks.

set -euo pipefail

# Quick task context injection
if [ -f "docs/tasks.json" ]; then
  CONTEXT=$(python3 -c "
import json
try:
    with open('docs/tasks.json') as f:
        data = json.load(f)
    tasks = data.get('tasks', [])
    total = len(tasks)
    done = sum(1 for t in tasks if t.get('done', False))
    in_prog = [t for t in tasks if t.get('status') == 'in_progress']
    pending = [t for t in tasks if not t.get('done', False) and t.get('status') != 'in_progress']
    parts = [f'[Tasks: {done}/{total}]']
    if in_prog:
        parts.append(f'Active: [{in_prog[0][\"id\"]}] {in_prog[0][\"title\"]}')
    elif pending:
        parts.append(f'Next: [{pending[0][\"id\"]}] {pending[0][\"title\"]}')
    print(' | '.join(parts))
except:
    pass
" 2>/dev/null || true)
  if [ -n "$CONTEXT" ]; then
    echo "$CONTEXT"
  fi
fi

exit 0
