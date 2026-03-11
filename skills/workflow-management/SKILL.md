---
name: workflow-management
description: Use when executing non-trivial development tasks to ensure a standardized 9-step workflow from requirements analysis to final documentation.
---

# Workflow Management

## Overview
A standardized implementation process that bridges the gap between LLM probability and software engineering certainty through a strict 9-step lifecycle.

## When to Use
- Implementing new features or refactoring code.
- Fixing bugs or resolving architectural issues.
- Any development task that requires a formal plan and verification.

## Core Pattern
The 9-step development cycle:
1. Brainstorming (Intention exploration)
2. Plan Writing (docs/plans/)
3. Git Worktree (Isolation)
4. TDD (Test-first)
5. Execution (Implementation)
6. Code Review (Validation)
7. Verification (docs/reports/)
8. Document Maintenance (DOCS.md synchronization)
9. Finishing Branch (Integration)

## Quick Reference
| Step | Action | Output / Goal |
|------|--------|---------------|
| 1-2 | Initialization | Update docs/STATUS.md, create plan |
| 4-5 | Red-Green | TDD cycle and code implementation |
| 7 | Validation | Run tests and generate report |
| 8 | Maintenance | Update DOCS.md (Append-Only) |
| 9 | Completion | Final merge and methodology extraction |

## Implementation
AI must update `docs/STATUS.md` at the beginning and end of each session. All technical decisions and architectural changes must be appended to `DOCS.md`.

## Common Mistakes
- Skipping Step 8 (Documentation): Results in knowledge rot.
- Silently bypassing steps: Violates the DEV.md guidelines.
- Missing verification evidence: Claims "tests passed" without showing output.
- Using emojis: Violates the project's formatting standard for skills.
