> **最后更新**: 2026-05-19 UTC
> **当前阶段**: [Round 5 P1 — 流程清理完成]
> **整体进度**: 28/28 任务

## 当前目标
Round 5 P1：清除 5 项架构臃尾（workflow skill thin shell / rules 去重 / 删 monitoring-security / 旧 plans 标 DONE / install.sh 重复行）。
**参考**: `docs/plans/round5-p1-cleanup.md`、`docs/decisions/0030-round5-cleanup.md`

## 任务进度

任务 SSoT 见 `docs/tasks.json`。本节只记录上下文。

| Round | 范围 | 状态 |
|-------|------|------|
| Round 1 (T-001~T-016) | 优先级统一 / harness 重构 / 流程分级 / 4 新 hook | ✓ |
| Round 2 (T-017~T-020) | Claude Code 官方 API 合规性 | ✓ |
| Round 3 P0 | Stop 顺序 + evidence 隔离 + 决策外置 | ✓ |
| Round 4 P0 (T-021~T-027) | Subagents + Spec-Driven 模板 | ✓ |

## 最新发现

- **Skill vs Subagent 边界**：skill 是「规则 + EVAL SSoT」，agent 是「执行 surface」。agent 通过 `Read` 引用 skill 文件，不复制内容，DRY。
- **Subagent 工具白名单要显式收紧**：plan-reviewer 只读 (Read/Glob/Grep/Bash)，retro-writer 唯一写入 `docs/lessons.md`。避免 agent 越权。
- **EARS 格式（WHEN/IF/WHILE + SHALL）适合作为 spec 的需求语言**：每条需求强制有触发条件 + 系统行为 + 验收标准，规避「make it work」式模糊需求。
- **install.sh 区分覆盖策略**：模板（specs/_template/、specs/README.md）每次覆盖；用户内容（lessons.md、STATUS.md、tasks.example.json）首次创建后不覆盖。Round 4 同时新增了这两类资源。

## 决策记录

详见 [`docs/decisions/`](./decisions/)。每决策一文件。STATUS.md 不再复制决策正文。

| # | 标题 | 日期 |
|---|------|------|
| 22 | [record-test-evidence 改用 stdout 启发式](./decisions/0022-record-evidence-heuristic.md) | 2026-04-27 |
| 23 | [PreToolUse deny 格式全面升级](./decisions/0023-pretool-deny-format.md) | 2026-04-27 |
| 24 | [回归 rules/*.md 原生 paths 机制](./decisions/0024-rules-native-paths.md) | 2026-04-27 |
| 25 | [纠正斜杠命令语法文档](./decisions/0025-slash-command-syntax.md) | 2026-04-27 |
| 26 | [引入 .claude/agents/ subagents](./decisions/0026-introduce-subagents.md) | 2026-05-14 |
| 27 | [docs/specs/ 作为可选 Spec-Driven 增强](./decisions/0027-optional-spec-driven.md) | 2026-05-14 |
| 28 | [orient-session 改用 awk 截取 STATUS.md 关键段](./decisions/0028-orient-session-trim.md) | 2026-05-15 |
| 29 | [AGENTS.md §0 去 Ray 化](./decisions/0029-agents-deray.md) | 2026-05-15 |
| 30 | [Round 5 P1 流程清理](./decisions/0030-round5-cleanup.md) | 2026-05-19 |

新决策**写到 `docs/decisions/NNNN-slug.md`**，本节只追加索引行（一行/决策）。

## 下次从这里开始

### 恢复上下文

```bash
python3 .claude/hooks/lib/task-summary.py full        # 任务进度 27/27
bash .claude/hooks/lib/danger-patterns.test.sh        # 25/25 PASS
ls docs/decisions/                                    # 决策档案 #22-#27
ls .claude/agents/                                    # plan-reviewer / retro-writer
ls docs/specs/_template/                              # requirements / design / tasks
```

### 继续工作

Round 4 P0 已完成。剩余待办（按优先级）：

- **P1（来自 Round 3 review 遗留）**：CLAUDE.md 精简 / AGENTS.md §0 去 Ray 化 / EVAL schema 文档化 / onboarding.md
- **P1（Round 4 中 ROI 项）**：statusline 脚本 / token 预算 hook / output-styles 分场景输出
- **P2（来自 Round 3 review 遗留）**：hooks 集成测试 / session metrics / install.sh 版本号
- **P2（Round 4 后续）**：plan-reviewer 接入 §6 第 2 续步强制触发 / tasks.json 加 `spec_id` 字段
- **P3（Round 4 后续）**：MCP servers 显式管理 / lessons-extractor Stop hook 自动跑 retro-writer / eval 进 CI

---

## 历史记录（保留）

### 2026-05-19: Round 5 P1 — 流程清理
5 项细节债清除：workflow-management skill 改 thin shell（指向 §6）；rules/*.md 三个文件删尾部重复段；删除 monitoring-security skill；docs/plans/ 三份历史计划标 [DONE]；install.sh DIRECTORIES 重复行删除。决策 #30。

### 2026-05-15: Round 4 P1 — AGENTS.md §0 去 Ray 化
§0「关于用户与你的角色」主语 `Ray` → `资深工程师 / 用户`，加 fork 提示行。§1 第一人称统一为第三人称。决策 #29。

### 2026-05-15: Round 4 P1 — orient-session token 瘦身
`orient-session.sh` 第 3 步从 `cat docs/STATUS.md` 改为 awk 截取「当前目标」+「下次从这里开始」两段。SessionStart 注入从 ~1587 tokens 降到 ~818 tokens（节省 ~1180）。决策 #28。

### 2026-05-14: Round 4 P0 — Subagents + Spec-Driven 模板
新增 `.claude/agents/{plan-reviewer, retro-writer}.md`、`docs/specs/_template/{requirements,design,tasks}.md`、`docs/specs/README.md`、`docs/lessons.md`。AGENTS.md §6 第 2 续步加注 subagent 推荐。决策 #26 #27 见 `docs/decisions/`。

### 2026-05-10: Round 3 P0 — Stop 顺序 + evidence 隔离 + 决策外置
3 项修正：assertion-audit 排到 session-end 之前；evidence 文件加 session_id 后缀；STATUS.md 决策迁出到 `docs/decisions/`。详见 `docs/plans/round3-p0-fixes.md`。

### 2026-04-27: Round 2 — Claude Code 官方 API 合规性
4 项修正：record-test-evidence stdout 启发式、PreToolUse hookSpecificOutput、rules paths 原生机制、slash 命令前缀纠正。决策 #22-#25 见 [`docs/decisions/`](./decisions/)。

### 2026-04-27: Round 1 — 16 项规范审计
P0 优先级统一 / STATUS bootstrap / EVAL 补齐；P1 pre-commit mtime 判据 / danger-patterns SSoT / review 动态分支 / post-edit 合并 / 流程分级；P2 TDD 限定 / 4 个新 hook / eval-runner / 工具兼容矩阵 / install.sh .bak。

### 2026-04-21: 融入 4 条编码原则
将 Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution 融入 AGENTS.md。

### 2026-03-11: Skill 国际化
将 skills 目录下所有 SKILL.md 翻译为中文，保留 YAML `name` 为英文标识符。
