# 决策 #26 · 引入 .claude/agents/ subagents

**日期**: 2026-05-14
**状态**: Adopted

## 背景

Round 1-3 把硬约束（hooks）、官方 API 合规性、SSoT 文档三条主线打通后，下一步天花板在「主上下文外的能力」。
当前 `plan-review` 这类「长报告」型任务跑在主上下文里，会消耗大量 token 并污染后续对话。
Claude Code 原生支持 `.claude/agents/` 子代理（独立上下文窗口、独立工具白名单），本项目此前未使用。

## 决策

新增 `.claude/agents/` 目录与两个核心 subagent：

1. **`plan-reviewer`** — 执行 5 维度架构审查
   - 工具：Read / Glob / Grep / Bash（只读）
   - 规则源：`.claude/skills/plan-review/SKILL.md`（**不复制**，agent 引用）
   - 触发：complex 级任务第 2 续步推荐使用
2. **`retro-writer`** — 会话复盘
   - 工具：Read / Edit / Write / Glob / Grep / Bash
   - 唯一写入目标：`docs/lessons.md`（追加式）
   - 触发：用户主动调用或会话结束

设计原则：
- **Skill 是规则 SSoT，agent 是执行 surface**，二者不重复内容。
- agent 名称与 skill 名称区分（`plan-reviewer` vs `plan-review`），避免混淆。
- 工具白名单显式收紧，避免 agent 越权。
- AGENTS.md §6 加注推荐用法，但不强制（保持 trivial / moderate 用 skill 的轻量路径）。

## 影响

收益：
- complex 任务的审查输出不再污染主上下文，节省 token 并保持主线程清爽。
- 经验沉淀机制（lessons.md）首次落地，未来 SessionStart 可注入历史教训。
- 与 Claude Code 官方设计范式对齐。

代价：
- subagents 是 Claude Code 独有，Gemini / Codex 不支持。兼容矩阵已说明此情况。
- agent 名称 vs skill 名称容易记混 — 通过 README 和 AGENTS.md §6 注解显式区分。
- install.sh 多了 1 个 DIRECTORIES + 2 个 CORE_FILES，维护面扩大。

后续：
- Round 5 评估是否把 plan-reviewer 接入第 2 续步的强制触发。
- 按需追加 evidence-auditor / migration-reviewer 等专用 agent。
