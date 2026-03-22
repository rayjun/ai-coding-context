#!/bin/bash
# Hook: SessionStart
# Purpose: Auto-inject project context at the start of every session.
# Replaces the "AI should remember to read STATUS.md" text constraint
# with code-enforced context injection.

set -euo pipefail

echo "=== Session Context ==="
echo ""

# 1. Current working directory
echo "Working directory: $(pwd)"
echo ""

# 2. Recent git history (last 5 commits)
if git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "--- Recent Commits ---"
  git log --oneline -5 2>/dev/null || echo "(no commits yet)"
  echo ""
fi

# 3. STATUS.md content + format validation
if [ -f "docs/STATUS.md" ]; then
  echo "--- docs/STATUS.md ---"
  cat "docs/STATUS.md"
  echo ""

  # Validate required sections exist
  MISSING_SECTIONS=""
  grep -q '## 当前目标' "docs/STATUS.md" || MISSING_SECTIONS="${MISSING_SECTIONS} [当前目标]"
  grep -q '## 任务进度' "docs/STATUS.md" || MISSING_SECTIONS="${MISSING_SECTIONS} [任务进度]"
  grep -q '## 下次从这里开始' "docs/STATUS.md" || MISSING_SECTIONS="${MISSING_SECTIONS} [下次从这里开始]"

  if [ -n "$MISSING_SECTIONS" ]; then
    echo "WARNING: docs/STATUS.md is missing required sections:${MISSING_SECTIONS}"
    echo "Update STATUS.md to include these sections before proceeding."
    echo ""
  fi
else
  echo "WARNING: docs/STATUS.md does not exist. Create it before starting work."
  echo ""
fi

# 4. Structured task progress (docs/tasks.json)
if [ -f "docs/tasks.json" ]; then
  echo "--- Task Progress ---"
  TASK_SUMMARY=$(python3 hooks/lib/task-summary.py full 2>/dev/null || echo "(python3 not available for task parsing)")
  echo "$TASK_SUMMARY"
  echo ""
fi

# 5. Recent plans
if [ -d "docs/plans" ]; then
  PLANS=$(ls -t docs/plans/ 2>/dev/null | head -5)
  if [ -n "$PLANS" ]; then
    echo "--- Recent Plans ---"
    echo "$PLANS"
    echo ""
  fi
fi

# 6. Explicit resume instruction
echo "=== ACTION REQUIRED ==="
echo "1. docs/tasks.json is the task SSoT. Work on the next pending task shown above."
echo "2. docs/STATUS.md has context and decisions. Read '下次从这里开始' for resume instructions."
echo "3. Do NOT restart from scratch. Continue from where the last session left off."
echo "=== End Session Context ==="
