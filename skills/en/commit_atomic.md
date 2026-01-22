---
name: commit_atomic
description: Prepare a clean, atomic git commit.
---

**Steps:**
1. **Status Check:** Run `git status` to see changes.
2. **Diff Check:** Run `git diff` to review exact changes.
3. **Lint/Test:** Ensure formatting and tests pass.
4. **Message Construction:** Draft a Conventional Commit message (English).
   - Format: `<type>(<scope>): <subject>`
   - Body: Explain *why*, not just *what*.
5. **Execute:** Run `git add` and `git commit`.
