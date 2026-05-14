# Round 4 P0 (2026-05-14) [DONE]

**完成日期**: 2026-05-14
**复杂度**: complex
**结果**: 2/2 P0 落地，T-021..T-027 全 done。
**范围**: Round 4 review 提出的两个 P0 — Subagents 引入 + Spec-Driven 模板

## 背景

Round 1-3 已经把硬约束（Hooks 19 个 + danger-patterns 25 测试）、官方 API 合规性、SSoT（tasks/STATUS/decisions）三条主线落地。
本轮天花板在「**主上下文外**的能力」：

1. **Subagents（独立上下文窗口）** — 把 plan-review 这种长报告类任务搬出主线程，避免污染。
2. **Spec-Driven 三件套（结构化输入产物）** — 给 plan-review 提供稳定的审查 surface（requirements + design + tasks），也对齐 Kiro / spec-kit 业界范式。

## 用户决策（已确认）

- **Subagent 选型**：先落地 `plan-reviewer` + `retro-writer` 两个（覆盖流程入口 + 流程出口）
- **Spec-Driven 集成方式**：只交付模板和写作指南，**不改 §6**，用户按需选用

---

## P0-1 · 引入 .claude/agents/ 与 2 个核心 subagent

### 设计

**`.claude/agents/plan-reviewer.md`**
- 角色：独立上下文里跑 plan-review 5 维度审查（数据流/并发/接口/测试/运维）
- 输入：plan 文件路径或当前 plan 内容
- 输出：pass/warn/fail 报告（沿用 plan-review skill 已有的 EVAL 1-5）
- 工具：Read / Glob / Grep / Bash(只读)
- 触发：complex 级任务第 2 步后，主 agent `Agent(subagent_type="plan-reviewer")` 调用

**`.claude/agents/retro-writer.md`**
- 角色：会话结束或用户主动调用，从 transcript 提取「我以为 X 实际 Y」类自我修正
- 输入：transcript 路径（Stop hook 提供）或最近 N 轮对话
- 输出：追加到 `docs/lessons.md`（按主题分类、含日期）
- 工具：Read / Edit / Bash(grep)
- 触发：用户显式调用 `Agent(subagent_type="retro-writer")`，或会话结束后用户主动跑

### 与现有 plan-review skill 的关系

- Skill 保留为**人类可读的检查清单 + EVAL SSoT**
- Agent **引用** skill 文件（"参考 `.claude/skills/plan-review/SKILL.md` 的 5 维度"），不复制内容
- DRY：维度清单只在 skill 一处维护

### 文件改动

1. 新建 `.claude/agents/plan-reviewer.md`
2. 新建 `.claude/agents/retro-writer.md`
3. 新建 `docs/lessons.md`（首次空模板，含写作指南）
4. `AGENTS.md` §6 第 2 续步加注：「complex 级建议通过 `plan-reviewer` subagent 跑，避免污染主线程」
5. `install.sh` DIRECTORIES 增加 `.claude/agents`，CORE_FILES 增加 2 个 agent
6. `README.md` 在 Skills 章节后新增 "Subagents" 段（注明 Claude Code 独有）
7. `docs/decisions/0026-introduce-subagents.md`

### 风险

- **跨工具兼容**：subagents 是 Claude Code 独有，Gemini/Codex 不支持 → README 兼容矩阵已经在 Round 1 加过，更新一行即可
- **命名冲突**：skill 叫 `plan-review`，agent 叫 `plan-reviewer`，避免相同名（Claude Code 文档建议）
- **install.sh 同步遗漏**：通过 `--dry-run` 验证新文件出现在输出列表

---

## P0-2 · docs/specs/ 模板与写作指南（可选增强）

### 设计

不改 §6 流程定义，作为 **可选增量**：

```
docs/specs/
  ├── README.md              # 何时用 spec vs plan + 写作指南
  └── _template/
      ├── requirements.md    # EARS 格式骨架（WHEN/IF/WHILE + SHALL）
      ├── design.md          # 架构/数据流/风险骨架
      └── tasks.md           # 可执行步骤骨架（与 tasks.json 关系说明）
```

### `docs/specs/README.md` 要点

- **何时用 spec**：跨多个 PR 的 feature、有外部利益相关方、需要长期回查决策上下文
- **何时用 plan**：单次任务、单 PR 范围、纯重构 — 现有 `docs/plans/` 不变
- **生命周期**：spec 创建 → tasks 拆到 `docs/tasks.json`（带 `spec_id` 字段标注，但 tasks.json schema 暂不强制）
- **与 plan-review 的关系**：spec 提供更结构化的审查输入，但 skill 输入契约本轮不绑定（Round 5 再说）

### 文件改动

1. 新建 `docs/specs/README.md`
2. 新建 `docs/specs/_template/requirements.md`
3. 新建 `docs/specs/_template/design.md`
4. 新建 `docs/specs/_template/tasks.md`
5. `install.sh` DIRECTORIES 增加 `docs/specs/_template`，CORE_FILES 增加 4 个模板
6. `README.md` 在 SSoT 段落后新增 "Spec-Driven (Optional)" 一段
7. `docs/decisions/0027-optional-spec-driven.md`

### 风险

- 极低，纯增量。已显式选择「不改 §6」，避免破坏现有流程。
- `tasks.json` schema 暂不加 `spec_id` 字段，避免 tasks-validate.sh 同步改动 — 留到 Round 5。

---

## 验证（第 7 步证据）

| 检查 | 命令 | 期望 |
|------|------|------|
| subagent 文件存在且 frontmatter 合法 | `head -5 .claude/agents/*.md` | 每个文件首行 `---`，含 `name`/`description` |
| install.sh dry-run 包含新文件 | `bash install.sh --dry-run 2>&1 \| grep -E "(agents/\|specs/)"` | 4 specs + 2 agents 出现 |
| README 兼容矩阵反映 subagents | `grep -i subagent README.md` | 至少 1 行 |
| 决策文件落地 | `ls docs/decisions/0026-* docs/decisions/0027-*` | 两文件存在 |
| tasks.json 新增 T-021..T-027 | `python3 .claude/hooks/lib/task-summary.py full` | 27 项任务 |
| danger-patterns 回归 | `bash .claude/hooks/lib/danger-patterns.test.sh` | 25/25 PASS |

---

## 任务拆解（写入 tasks.json）

| ID | 任务 | 依赖 |
|----|------|------|
| T-021 | 新建 `.claude/agents/plan-reviewer.md` | — |
| T-022 | 新建 `.claude/agents/retro-writer.md` | — |
| T-023 | 新建 `docs/lessons.md` 初始骨架 | T-022 |
| T-024 | AGENTS.md §6 第 2 续步加注 subagent 推荐 | T-021 |
| T-025 | 新建 `docs/specs/_template/{requirements,design,tasks}.md` | — |
| T-026 | 新建 `docs/specs/README.md` 写作指南 | T-025 |
| T-027 | install.sh / README.md / decisions #26 #27 同步 | T-021..T-026 |

## 完成定义

- 7 个新文件 + 2 个修改文件（AGENTS.md / README.md / install.sh / tasks.json）
- 2 个决策记录
- 验证表 6 项全 PASS
- 提交一个 commit（不分批，因为是同一轮规划）

## 后续（不在本轮范围）

- spec_id 字段进 tasks.json schema（Round 5）
- plan-reviewer subagent 实际接入 §6 第 2 续步的强制触发（Round 5）
- 其他 subagent（evidence-auditor / migration-reviewer）按需追加
- Round 3 遗留 P1：CLAUDE.md 精简 / AGENTS.md §0 去 Ray 化 / EVAL schema / onboarding
