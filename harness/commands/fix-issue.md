---
description: Investigate and fix a GitHub issue by number
argument-hint: "[issue-number]"
---

## Issue Details

!`gh issue view $ARGUMENTS 2>/dev/null || echo "Failed to fetch issue #$ARGUMENTS. Is gh CLI authenticated?"`

## Related Code Context

!`gh issue view $ARGUMENTS --json body,labels,assignees 2>/dev/null | python3 -c "import json,sys; d=json.load(sys.stdin); [print(l['name']) for l in d.get('labels',[])]" 2>/dev/null || true`

## Instructions

Based on the issue above:
1. Understand the bug or feature request
2. Trace it to the root cause in the codebase
3. Implement the fix following AGENTS.md conventions
4. Write a test that would have caught this issue
5. Verify the fix with actual test output

Use 简体中文 for explanations. Follow the investigate skill for debugging if needed.
