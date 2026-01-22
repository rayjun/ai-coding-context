---
name: refactor_safe
description: Safely restructure code without changing behavior.
---

**Steps:**
1. **Verify Baseline:** Ensure all existing tests pass. If no tests, create a "snapshot test" or characterization test first.
2. **Plan Changes:** Identify code smells (Long Method, Large Class, Duplication).
3. **Atomic Moves:** Apply changes in small steps (e.g., Rename, Extract Method, Move Class).
4. **Verify Step-by-Step:** Run tests after *every* atomic change.
5. **Cleanup:** Remove old unused code/comments.
