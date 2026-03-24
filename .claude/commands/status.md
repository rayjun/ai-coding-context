---
description: Check project health — STATUS.md freshness, tasks.json consistency, uncommitted files
---

## Project Status

!`cat docs/STATUS.md 2>/dev/null || echo "docs/STATUS.md not found"`

## Task Progress

!`python3 .claude/hooks/lib/task-summary.py full 2>/dev/null || echo "No tasks.json or python3 unavailable"`

## Git State

!`git status --short`

!`git log --oneline -5`

## Health Check

Based on the above:
1. Is STATUS.md up to date (updated within last session)?
2. Are there tasks stuck in `in_progress`?
3. Are there uncommitted changes that should be committed?
4. Does the "下次从这里开始" section have actionable content?

Report issues and suggest next actions. Use 简体中文.
