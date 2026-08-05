# 0039 · Round 12 P0 — §2/§6 矩阵合并去重 + 移除 superpowers 依赖

**日期**: 2026-06-18
**状态**: accepted
**相关**: AGENTS.md §2 §6, README.md, investigate skill

## 背景

AGENTS.md 经多轮增量编辑（Round 6/7/10/11）后累积了结构性重复：

1. **§2 流程分级矩阵 与 §6 9 步表** 信息完全重合（步骤 1-9 含"2续"的必做/可跳逐字重复），§6 表只多 Skill 列和审查方式列。
2. **subagent 评审规则出现 3 次**：§6 表格行、§6 引用块（"第 2 续步/第 6 步执行方式"）、§6 流程规则第 6/7 条，且细节又与 `plan-review/SKILL.md` 重复。
3. **"证据先于断言"出现 4 次**：§2 矩阵行、§2 规则行、§6 表格行、§6 流程规则第 4 条。
4. **TDD 判据出现 3 次**：§2 矩阵、§6 表、§4（§4 是权威版）。
5. **Loop Engineering 与流程规则互斥重复**：规则第 9 条 ≈ Loop Engineering 第三点；规则第 2 条 ≈ Loop Engineering 第一点。
6. **superpowers 外部依赖**：§6 表格 Skill 列引用 7 个外部 skill（brainstorming / writing-plans / using-git-worktrees / test-driven-development / executing-plans / verification-before-completion / finishing-a-development-branch），表头依赖 [obra/superpowers](https://github.com/obra/superpowers) 包；引用块还引用了 `requesting-code-review` skill（同样来自 superpowers）。fork 用户不装该包时会产生困惑。

## 决策

**A · 删 §2 矩阵，合并为 §6 单一分级矩阵。**

§2 只保留 trivial / moderate / complex 定义和取舍提示；§6 矩阵扩展为「步骤 × trivial/moderate/complex × 审查方式与要点」单表，成为分级 + 审查方式的唯一 SSoT。

**B · 引用块与流程规则合并精简。**

删「第 2 续步 / 第 6 步执行方式」两个引用块，合并为一条「subagent 执行方式」引用 `.claude/skills/plan-review/SKILL.md`；流程规则从 9 条压到 4 条（删与表格/Loop Engineering 重复的 #2/#4/#6/#7/#9，合并 #8 进 #6/#7 的独立审查要求）。

**C · 移除 superpowers 依赖。**

删 §6 表格 Skill 列和表头来源说明；`requesting-code-review` 引用改为指向本仓库 `.claude/skills/plan-review/SKILL.md`；README 删 superpowers 前置依赖和 Skills Framework 引用；investigate skill 删「与 systematic-debugging 的关系」节（其存在目的即解释外部依赖）。流程所需 skills 全部由本仓库自带（plan-review / investigate / careful-ops / workflow-management）。

## 后果

**正面**：
- AGENTS.md 从 184 行降至 ~150 行（估算省 ~30 行 / ~35% 重复内容），后续改流程只动一处。
- 单一矩阵消除「§2 与 §6 说法漂移」的长期风险（本轮就发现引用块 5 维度与 SKILL.md 维度不一致）。
- fork 用户零外部依赖，安装即用。
- 消除 `requesting-code-review` 悬空引用（该 skill 来自 superpowers，未安装时引用失效）。

**负面 / 取舍**：
- §6 矩阵行宽增加（含 5 列），token 密度更高。
- 流程规则 #2「目标可验证」并入 Loop Engineering 后，对 trivial 任务的显式提醒弱化（语义未丢，仍在 Loop Engineering 段）。

## 不做

- 不新增/删除任何 hook，不改 install.sh。
- 不改 `docs/plans/`、`docs/decisions/` 历史文件（存量保护）。
- 不引入 spec 三件套，继续沿用 `docs/plans/*.md`。
- 保留 §6 表格第 7 行与规则行的「证据先于断言」各一处（执行方式 vs 适用范围，语义分工，非重复）。
