# 决策 #31 · Round 6 P0 Context 二轮优化

**日期**: 2026-05-23
**状态**: Adopted

## 背景

Round 5 P1 清理 5 项细节债之后，再做一次 context audit，发现 4 个 P0 项：
1. AGENTS.md §1 §3 都列了「正确性 > 可读性 > 性能」优先级，§1 末尾还挂着 6 个月前的历史脚注「§3 曾与此冲突」——审计修正早已落地，注释成为历史包袱。
2. AGENTS.md §6 表格 Skill 列引用 `brainstorming` / `writing-plans` 等 9 项 superpowers skill，但表格没标注来源，fork 用户看到会困惑「这些 skill 在哪」。
3. CLAUDE.md 16 行里 8 行重述 README 已有的元描述，核心价值只是 `@AGENTS.md` 一行 import 触发器。
4. orient-session.sh 末尾的 `=== ACTION REQUIRED ===` 块的 3 条已在 STATUS.md「下次从这里开始」+ AGENTS.md 中各说过一次，第三次重复纯属浪费。

合计预估节省 ~260 tokens / SessionStart。

## 决策

### #1 — §1 §3 优先级合并

- 删除 §1 行 45 历史脚注「§3 的排序曾与此冲突，已在 2026-04 审计中修正」
- §3 行 80「优先级：**正确性与安全性 > 可读性 > 性能 > 代码长度**（与 §1 冲突处理表对齐）」改为「优先级遵循 §1「冲突处理优先级」表，不再重述」

### #2 — §6 表头加 superpowers 来源说明

在 §6 表格之上加一行 blockquote：

> **Skill 列**：8 项 superpowers skill 名 + plan-review（本项目自有）。未安装 superpowers 时，行为约束仍生效，只是缺少对应的可执行 skill 触发器。

### #3 — CLAUDE.md 缩到 6 行

```markdown
# AI Coding Context

任务 SSoT: `docs/tasks.json`；上下文记录: `docs/STATUS.md`。
非 trivial 任务必须走 AGENTS.md §6 定义的 9 步流程，禁止静默跳步。

@AGENTS.md
```

保留 `@AGENTS.md` 作为 Claude Code 原生 import 触发器。

### #4 — orient-session 删 ACTION REQUIRED

脚本第 75-78 行删除，保留 `=== End Session Context ===` 收尾。注释里说明为什么删（避免和 STATUS.md / AGENTS.md 三重复）。

## 影响

实测节省：
- CLAUDE.md：374 → 138 chars（-78 tokens）
- orient-session 输出：2475 → 2330 字节（-48 tokens）
- AGENTS.md：净增 ~5 tokens（superpowers 说明行抵消 §1/§3 去重）
- **合计 ~120 tokens / SessionStart**

预估目标是 ~260 tokens，实际 ~120，差额来自 superpowers 说明行 + task-summary 输出对 next pending 的展示（取代了被删的 ACTION REQUIRED 段的部分作用）。后者是良性，前者是新增的正确性收益。

正确性收益（不算 token）：
- §6 fork 用户不再困惑 superpowers skill 来源
- §1 §3 表述统一，去除审计期临时痕迹

代价：
- CLAUDE.md 大改可能影响**外部 fork 用户**，但 `@AGENTS.md` 这一行 import 触发器保留，核心协议不变。

## 验证

- §1 §3 历史脚注 grep 计数 = 0
- CLAUDE.md = 6 行，含 1 处 @AGENTS.md
- §6 含 1 处 superpowers
- orient-session ACTION REQUIRED grep 计数 = 0
- danger-patterns 25/25 PASS

## 后续

- Round 6 P1：§6 流程规则合并 #1 #6（duplicates）+ obsidian-writer 标记示例 + §9 合并到 §4
- Round 7：是否进一步把 §6 外置到独立 process.md（评估）
