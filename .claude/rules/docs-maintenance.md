---
paths:
  - "docs/**"
---

# 文档维护规则

> 本文件由 Claude Code 的 `.claude/rules/` 原生机制加载。

- `docs/tasks.json` 是任务的 SSoT，格式由 `.claude/hooks/tasks-validate.sh` 校验。
- `docs/STATUS.md` 格式参照 `docs/STATUS.template.md`，必须包含：当前目标、任务进度、下次从这里开始。
- `docs/status-writing-guide.md` 是 STATUS 的书写规范（原位于根 `STATUS.md`）。
- 文档追加记录（Append-Only），禁止删除未过时内容，过时内容标记 `[DEPRECATED]`。
- 新增内容必须包含更新日期 (YYYY-MM-DD)。
- 计划文件放在 `docs/plans/`，完成后在文件顶部标记 `[DONE]` + 完成日期，但不删除。

- `docs/tasks.json` 是任务的 SSoT，格式由 `hooks/tasks-validate.sh` 校验。
- `docs/STATUS.md` 格式参照 `docs/STATUS.template.md`，必须包含：当前目标、任务进度、下次从这里开始。
- 文档追加记录（Append-Only），禁止删除未过时内容，过时内容标记 `[DEPRECATED]`。
- 新增内容必须包含更新日期 (YYYY-MM-DD)。
