> **最后更新**: 2026-06-17 UTC
> **当前阶段**: [Round 11 P0 — Loop Engineering 完成]
> **整体进度**: 20 active 任务（含 16 archived）

## 当前目标
Round 11 P0：把 Loop Engineering 作为 9 步流程的横切纪律写入 `AGENTS.md` §6 和 `workflow-management` skill。定义非 trivial 任务的目标、观察信号、下一步假设、退出/升级条件；审查/验证/信息不足时按有界循环重跑同一 gate。同步更新 README、tasks、决策索引和 STATUS。
**参考**: `docs/plans/round11-loop-engineering.md`、`docs/decisions/0038-loop-engineering.md`

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
- **Loop Engineering 边界**：非 trivial 任务应声明目标、观察信号、下一步假设、退出/升级条件。信息不足、审查失败、验证失败时重跑同一 gate；同一失败两轮且无新证据时停止自旋并升级。
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
| 31 | [Round 6 P0 Context 二轮优化](./decisions/0031-round6-context-trim.md) | 2026-05-23 |
| 32 | [Round 6 P1 Context 三轮微调](./decisions/0032-round6-p1-microtrim.md) | 2026-05-24 |
| 33 | [Round 7 P0 跨 surface 去重](./decisions/0033-round7-p0-cross-surface-dedup.md) | 2026-05-25 |
| 34 | [Round 7 P1 §1 优先级表改名 + §6 规则 #2 缩短](./decisions/0034-round7-p1-priority-rename.md) | 2026-05-26 |
| 35 | [Round 8 P0 工作流健康度修复](./decisions/0035-round8-workflow-health.md) | 2026-05-29 |
| 36 | [Round 9 P0 运行时 surface 整理](./decisions/0036-round9-runtime-surface.md) | 2026-05-31 |
| 37 | [Round 10 P0 流程强制度提升](./decisions/0037-round10-flow-rigor.md) | 2026-06-02 |
| 38 | [Round 11 P0 — Loop Engineering](./decisions/0038-loop-engineering.md) | 2026-06-17 |

新决策**写到 `docs/decisions/NNNN-slug.md`**，本节只追加索引行（一行/决策）。

## 下次从这里开始

### 恢复上下文

```bash
python3 .claude/hooks/lib/task-summary.py full        # 任务进度 20/20
bash .claude/hooks/lib/danger-patterns.test.sh        # 25/25 PASS
bash .claude/hooks/plan-review-reminder.test.sh       # 6/6 PASS
ls docs/decisions/                                    # 决策档案 #22-#38
ls .claude/agents/                                    # plan-reviewer / retro-writer
```

### 继续工作

Round 11 P0 已完成。剩余待办（按优先级）：

- **P1（来自 Round 3 review 遗留）**：CLAUDE.md 精简 / AGENTS.md §0 去 Ray 化 / EVAL schema 文档化 / onboarding.md
- **P1（Round 4 中 ROI 项）**：statusline 脚本 / token 预算 hook / output-styles 分场景输出
- **P2（来自 Round 3 review 遗留）**：hooks 集成测试 / session metrics / install.sh 版本号
- **P3（Round 4 后续）**：MCP servers 显式管理 / lessons-extractor Stop hook 自动跑 retro-writer / eval 进 CI

---

## 历史记录（保留）

### 2026-06-17: Round 11 P0 — Loop Engineering
把 Loop Engineering 写入 context/workflow 层：`AGENTS.md` §6 新增目标→观察信号→下一步假设→退出/升级条件；流程规则要求信息不足、审查失败、验证失败时做最小修改并重跑同一 gate，无新证据的重复失败停止自旋。`workflow-management` skill 维持 thin shell，只新增 SSoT 指向和 EVAL；README、tasks、决策索引同步。决策 #38。

### 2026-06-02: Round 10 P0 — 流程强制度提升
2 项：(1) 新增 `plan-review-reminder.sh` 接到 `post-edit-dispatch.sh` 第 4 分支，匹配 `docs/plans/*.md` 编辑时输出软提醒（不阻断），让 §6 第 2 续步从「文档约定」进入 runtime；(2) `tasks-validate.sh` 校验可选 `spec_id` 字段（类型/前缀/目标存在），新 task T-035 携带 `spec_id` 指向本轮 plan。同步更新 `install.sh` CORE_FILES + `.gemini/settings.json`（按 `.claude/rules/hooks-dev.md`）。决策 #37。

### 2026-05-31: Round 9 P0 — 运行时 surface 整理
2 项：(1) settings.json 中 PostToolUse Edit|Write hook 链 4→1，移除 credential-sniff/large-file-warn/migration-safety（脚本保留，下游可启用）；(2) plan-reviewer/retro-writer/lessons.md/specs/README.md 顶部加「示例」blockquote（自 R4 P0 引入 33 天 0 触发，明确归类为 demo）。每次编辑省 3 fork-exec。决策 #36。

### 2026-05-29: Round 8 P0 — 工作流健康度修复
3 项：drift-counter 抽 lib/counter-path.sh 加 session_id 后缀（修计数失真，counter A/B 隔离）；tasks.json 归档机制（T-001..T-016 迁出到 tasks-archive.json，主文件 263→144 行省 45%）；AGENTS.md §6 加注「单人 main-only 可跳第 6/9 步」（与本仓库实际工作流诚实匹配）。决策 #35。

### 2026-05-26: Round 7 P1 — §1 优先级表改名 + §6 规则缩短
§1「约束优先级」→「决策过滤顺序」、「冲突处理优先级」→「取舍顺序（写代码时的冲突解决）」，避免 LLM 把两个不同维度当同一个「优先级」混用；§3 引用同步。§6 流程规则 #2「目标可验证」缩短，去掉冗余例子。AGENTS.md 4708 → 4679 chars。决策 #34。

### 2026-05-25: Round 7 P0 — 跨 surface 去重
4 项：§6 表头 superpowers 注解短化 + 表格加 ★；§6 表头删除重复的「禁止静默跳过」；§2 矩阵脚注的跳步规则下沉到 §6；§8 删除 Harness 提醒 3 行 bullet（与 hook 首注释重复）。AGENTS.md 节省 384 字符 / ~128 tokens。决策 #33。

### 2026-05-24: Round 6 P1 — Context 三轮微调
4 项：§6 流程规则 6→5（合并语义重复条目）；§9 合并到 §4 新增「输出风格」子段（章节 0-8）；obsidian-writer 标记为示例 skill；README skills count 同步为 5（修复 Round 5 删 monitoring-security 后的数字 drift）。决策 #32。

### 2026-05-23: Round 6 P0 — Context 二轮优化
4 项：§1 删历史脚注 / §3 优先级表述去重指向 §1；§6 加 superpowers skill 来源说明；CLAUDE.md 缩到 6 行；orient-session 删 ACTION REQUIRED 段。实测节省 ~120 tokens/session。决策 #31。

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
