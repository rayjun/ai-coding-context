#!/bin/bash
# Hook: PreCompact (fires before context window compaction)
# Purpose: Inject critical state that MUST survive compaction.
# Without this, AI loses track of what it was doing after compaction.

set -euo pipefail

echo "=== CRITICAL CONTEXT (preserve through compaction) ==="

# 1. Current task
if [ -f "docs/tasks.json" ]; then
  python3 hooks/lib/task-summary.py full 2>/dev/null || true
fi

# 2. Resume point from STATUS.md
if [ -f "docs/STATUS.md" ]; then
  RESUME_LINE=$(grep -n '## 下次从这里开始' "docs/STATUS.md" 2>/dev/null | head -1 | cut -d: -f1 || true)
  if [ -n "$RESUME_LINE" ]; then
    echo "RESUME POINT (from STATUS.md):"
    tail -n +"$((RESUME_LINE + 1))" "docs/STATUS.md" | sed '/^## /,$d' | head -5
  fi

  # Current goal
  GOAL_LINE=$(grep -n '## 当前目标' "docs/STATUS.md" 2>/dev/null | head -1 | cut -d: -f1 || true)
  if [ -n "$GOAL_LINE" ]; then
    echo "CURRENT GOAL:"
    tail -n +"$((GOAL_LINE + 1))" "docs/STATUS.md" | sed '/^## /,$d' | head -3
  fi
fi

# 3. Active plan
if [ -d "docs/plans" ]; then
  LATEST_PLAN=$(ls -t docs/plans/ 2>/dev/null | head -1)
  if [ -n "$LATEST_PLAN" ]; then
    echo "ACTIVE PLAN: docs/plans/${LATEST_PLAN}"
  fi
fi

echo "=== END CRITICAL CONTEXT ==="

exit 0
