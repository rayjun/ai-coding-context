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
#    Token-budget: inject only "当前目标" and "下次从这里开始" sections (the
#    actionable parts). History / 决策记录 / 任务进度 大表 are skipped here —
#    they are still on disk and can be Read on demand. This typically saves
#    ~900 tokens per SessionStart on a mature project.
if [ -f "docs/STATUS.md" ]; then
  echo "--- docs/STATUS.md (key sections) ---"
  awk '
    /^## (当前目标|下次从这里开始)/ { in_block=1; print; next }
    /^## / && in_block { in_block=0 }
    /^---[[:space:]]*$/ && in_block { in_block=0 }
    in_block { print }
  ' "docs/STATUS.md"
  echo ""
  echo "(full STATUS.md including 历史/决策记录/最新发现 is on disk — Read on demand.)"
  echo ""

  # Validate required sections exist (full file, not just the snippet)
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
  TASK_SUMMARY=$(python3 .claude/hooks/lib/task-summary.py full 2>/dev/null || echo "(python3 not available for task parsing)")
  echo "$TASK_SUMMARY"
  echo ""
fi

# 5. Recent plans (files only, exclude dotfiles and directories)
if [ -d "docs/plans" ]; then
  PLANS=$(ls -tp docs/plans/ 2>/dev/null | grep -v '/$' | grep -v '^\.' | head -5)
  if [ -n "$PLANS" ]; then
    echo "--- Recent Plans ---"
    echo "$PLANS"
    echo ""
  fi
fi

# 6. End marker
#    The actionable resume instructions live in docs/STATUS.md "下次从这里开始"
#    (already injected above) and AGENTS.md — no need to repeat them here.
echo "=== End Session Context ==="
