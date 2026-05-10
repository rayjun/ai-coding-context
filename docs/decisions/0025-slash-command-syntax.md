# 决策 #25 · 纠正斜杠命令语法文档

**日期**: 2026-04-27
**状态**: Adopted

## 背景

文档多处写 `/project:review`、`/project:status`，Claude Code 实际无此前缀。`.claude/commands/review.md` 对应的真正调用是 `/review`。

## 决策

- 全部改为 `/review`、`/status`、`/fix-issue`
- 在 README 补注"命令与 skill 同名时 skill 优先"

## 影响

- 新用户调用 `/project:review` 会失败 — 纠正后符合官方行为
- 与 skills/commands 合并的官方机制对齐（参考 [skills 文档](https://code.claude.com/docs/en/skills)：`Custom commands have been merged into skills`）
