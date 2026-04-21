# Plan: 将 4 条编码原则融入 AGENTS.md

**日期**: 2026-04-21
**作者**: Claude (与 Ray 讨论)
**目标**: 将 Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution 四条行为原则融入现有 AGENTS.md 章节，不新增顶层章节。

## 背景

用户提供的 4 条原则用于减少 LLM 编码常见错误。现有 AGENTS.md 已覆盖推理、简洁、风格等部分，需将新原则就近融入以避免重复与分散。

## 原则映射

| 原则 | 目标章节 | 插入点 |
|------|---------|--------|
| Think Before Coding | §1 推理框架 | "假设与溯因推理"之后，新增"显式化与澄清" |
| Simplicity First | §3 编程哲学 | 列表末尾新增"最简实现"要点 |
| Surgical Changes | §3 编程哲学 | 新增"外科手术式修改"要点 |
| Goal-Driven Execution | §6 流程规则 | 规则 1 之后新增"每步需有可验证成功标准" |
| Tradeoff 声明 | §2 任务复杂度 | 段落末尾追加提示 |

## 成功标准

1. AGENTS.md 4 处改动全部落地，无章节结构破坏。
2. 中文表述，术语与现有风格一致（可读性/正确性/简洁）。
3. `git diff` 只动 AGENTS.md，行数控制在 ~25 行以内。
4. 不新建 `.claude/rules/` 文件，不改 CLAUDE.md。

## 步骤

1. 编辑 AGENTS.md §1、§2、§3、§6 四处。
2. 更新 `docs/tasks.json` 追加 T-034。
3. 更新 `docs/STATUS.md`。

## 验证

- `rg -n "最简实现|外科手术|显式化|成功标准" AGENTS.md` 应匹配 4 处新增关键词。
- 无多余新增文件（除本计划与 tasks/STATUS 更新）。

## 风险

- 低风险：纯文档改动，不影响 hooks / 代码。
