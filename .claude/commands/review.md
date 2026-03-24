---
description: Review the current branch diff for issues before merging
---

## Changes to Review

!`git diff --name-only main...HEAD 2>/dev/null || git diff --name-only HEAD~5...HEAD`

## Detailed Diff

!`git diff main...HEAD 2>/dev/null || git diff HEAD~5...HEAD`

Review the above changes for:
1. Code correctness and edge cases
2. Security vulnerabilities (injection, secrets exposure)
3. Missing test coverage
4. Performance concerns
5. Consistency with AGENTS.md conventions

Give specific, actionable feedback per file. Use 简体中文 for explanations.
