---
description: Review the current branch diff for issues before merging
---

## Base Branch Detection

!`BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true); BASE=${BASE:-$(git config --get init.defaultBranch 2>/dev/null)}; BASE=${BASE:-main}; echo "Base: $BASE"; echo "Current: $(git rev-parse --abbrev-ref HEAD)"`

## Changes to Review

!`BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main); git diff --name-only "origin/$BASE...HEAD" 2>/dev/null || git diff --name-only "$BASE...HEAD" 2>/dev/null || git diff --name-only HEAD`

## Detailed Diff

!`BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main); git diff "origin/$BASE...HEAD" 2>/dev/null || git diff "$BASE...HEAD" 2>/dev/null || git diff HEAD`

Review the above changes for:
1. Code correctness and edge cases
2. Security vulnerabilities (injection, secrets exposure)
3. Missing test coverage
4. Performance concerns
5. Consistency with AGENTS.md conventions

Give specific, actionable feedback per file. Use 简体中文 for explanations.

**Fallback order**: `origin/HEAD` symref → `init.defaultBranch` config → `main`. Works on repos using master / develop / trunk without hard-coding.
