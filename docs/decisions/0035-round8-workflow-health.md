# 决策 #35 · Round 8 P0 工作流健康度修复

**日期**: 2026-05-29
**状态**: Adopted

## 背景

Round 7 完成静态资产去重后，做第一次「**流程在实际跑动中的健康度**」审计，发现三个跨 Round 累积的债：

1. **drift-counter 跨会话累积** —— `/tmp/claude-hooks/<md5(pwd)>/drift-counter` 在多个会话之间共享，截至本审计已累积到 225。设计意图是「每会话每 30 次提醒一次」，实际行为是「全局每 30 次概率性提醒」。Round 3 P0 已用 `evidence-path.sh` 解决 evidence 文件的同类问题，drift-counter 没跟着改。

2. **tasks.json 无归档机制** —— 32 任务 / 263 行；按当前 4-5 天/Round 节奏，Round 12 → 50 任务，Round 20 → 失控。95%+ 是已 done 的历史任务，每次 hook 解析全文。

3. **§6 第 9 步「完成分支」与本仓库实际工作流 mismatch** —— 近 8 个 commit 全在 `main` 上线性推进，第 9 步 `finishing-a-development-branch` 从未触发；第 6 步「代码审查」同理。这两步对单人 main-only 项目没意义。

## 决策

### #1 — drift-counter 加 session_id 后缀

抽通用 helper `lib/counter-path.sh`（与 `evidence-path.sh` 同模式），drift-detector.sh 改用 `counter_path_for_input INPUT drift-counter` 解析路径。新会话 → 新 counter，从 0 开始。

文件路径形如 `${SESSION_DIR}/drift-counter.<session_id:0:12>`，与 evidence 文件并列。无 session_id 时 fallback 到无后缀路径（兼容旧调用）。

### #2 — tasks.json 归档机制

- 新建 `docs/tasks-archive.json`（同 schema + `archived_at` + `note` 字段）
- T-001 ~ T-016（Round 1，2026-04-27 完成）整体迁出
- `tasks.json` 加 `archive` 字段说明归档去向
- archive 不参与 task-summary 统计、不被 tasks-validate 校验，只作历史记录
- 不进 install.sh CORE_FILES（用户的归档不该被覆盖）

实测：tasks.json 263 → 144 行（**省 45%**）。

### #3 — §6 加注「单人 main-only 工作流可跳第 6/9 步」

§6 表格下方增 1 行 blockquote：

> **第 9 步适配**：单人 main-only / 文档迭代项目可跳过第 9 步——直接 commit + push 到 main 即合规；feature branch + PR 工作流的项目应当执行。第 6 步「代码审查」同理：单人项目可跳，多人协作项目必做。

让 §6 与实际工作流保持诚实，避免 LLM 在 main-only 项目里继续提醒「未走第 9 步」。

## 影响

实测：
- tasks.json：263 行 → 144 行（**-45%**）
- drift-counter 跨会话隔离：counter A、B 独立递增，互不污染
- §6 与本仓库工作流诚实匹配

正确性收益：
- drift-detector 提醒概率回归设计意图
- tasks.json 不再线性膨胀（归档为冷文件）
- §6 不再演「未触发的第 9 步」的戏

代价：
- 极小。`lib/counter-path.sh` 是新文件（38 行），增维护面但与 evidence-path.sh 同模式，理解成本低。
- archive 文件不被 tasks-validate 校验，理论上可能漂移；但归档为冷文件，预期不会修改。

## 验证

- counter session A=2, B=1（隔离生效）
- tasks.json 16 done + 1 pending；tasks-archive.json 16 项
- §6 含「main-only」注解
- danger-patterns 25/25 PASS

## 后续

- P1-4：文档显式标注未触发 surface（plan-reviewer / retro-writer / lessons / specs）的「示例性质」
- Round 9 候选：drift-detector 改成项目计划/STATUS 检查（更有意义）
- Round 9 候选：assertion-audit 是否在本仓库需要（无人嘴里说"测试通过"）
