---
name: commit_atomic
description: 准备一个干净、原子的 git 提交。
---

**步骤:**
1. **状态检查:** 运行 `git status` 查看变更。
2. **Diff 检查:** 运行 `git diff` 审查确切的变更。
3. **Lint/测试:** 确保格式化和测试通过。
4. **构建信息:** 起草符合 Conventional Commit 的提交信息（英文）。
   - 格式: `<type>(<scope>): <subject>`
   - 正文: 解释 *为什么*，而不仅仅是 *什么*。
5. **执行:** 运行 `git add` 和 `git commit`。
