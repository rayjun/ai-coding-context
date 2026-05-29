# Round 8 P0 — 工作流健康度修复 (2026-05-29) [DONE]

**完成日期**: 2026-05-29
**复杂度**: complex
**结果**: 3/3 项落地，验证矩阵 7/7 PASS

## 范围

### P0-1 — drift-counter 加 session_id 后缀

**症状**：`/tmp/claude-hooks/<md5(pwd)>/drift-counter` 跨会话累积，当前已 225。设计意图是「每会话每 30 次提醒」，实际行为是「全局每 30 次概率性提醒」。Round 3 P0 已用 `evidence-path.sh` 解决 evidence 文件的同类问题，drift-counter 没跟着改。

**修法**：drift-detector.sh 改用 `session_id` 后缀（与 evidence 文件并列，路径形如 `drift-counter.<short-id>`）。新会话 → 新 counter，从 0 开始。

可以复用 `lib/evidence-path.sh` 的 session_id 提取逻辑，或单独抽 `lib/counter-path.sh`。**选用前者**：抽通用 helper 避免重复。

### P0-2 — tasks.json 归档机制

**症状**：32 任务 / 263 行，按 4-5 天/Round 节奏，Round 12 → 50 任务，Round 20 → 失控。

**修法**：
- 新建 `docs/tasks-archive.json`（同 schema）
- 把 T-001 ~ T-016（Round 1，2026-04 完成）整体搬到 archive
- `tasks.json` 保留 T-017 起的 16 项 + 「归档说明」字段指向 archive
- `task-summary.py` 不动（只读 tasks.json，archive 不参与统计）
- `tasks-validate.sh` 不动（schema 一致）

### P0-3 — §6 第 9 步加注「单人 main-only 工作流可跳」

**症状**：本仓库近 8 个 commit 全在 `main` 上线性推进，第 9 步「完成分支 — 合并 / PR / 清理」从未触发。`§6 第 9 步` 适用于 fork 用户的 feature 项目工作流，本仓库这种文档迭代场景不适用。

**修法**：在 §6 表格下方加一行注释，明确「单人 main-only / 文档迭代项目可跳过第 9 步」。

---

## 实施顺序

1. P0-1（drift-counter）：抽 `counter-path.sh` 或复用 evidence-path.sh，改 drift-detector
2. P0-2（tasks 归档）：创建 archive、迁移 T-001..T-016、tasks.json 留索引
3. P0-3（AGENTS.md §6 注解）：单点编辑

---

## 5 维度自审（plan-review）

1. **数据流** [pass]：drift-counter 路径变更但读写流程不变；tasks.json 拆分但消费者只读 tasks.json，archive 是冷文件
2. **并发与一致性** [pass]：drift-counter 写入仍走 `tmp + mv` 原子；tasks 归档是一次性迁移
3. **接口契约** [warn]：tasks-validate.sh 仅校验 tasks.json，archive 同 schema 但**不被校验**——决策放任，archive 是冷归档不期望被频繁修改
4. **测试** [pass]：danger-patterns 25/25 + 手测 drift-counter 新会话从 0 + tasks.json 仍可解析
5. **可运维性** [pass]：tasks-archive.json 可 git mv 回 tasks.json 任意时刻；drift-counter 路径 fallback 到无后缀（兼容旧 hook 调用）

**结论**：1 warn / 0 fail，可推进。

---

## 验证矩阵

| 检查 | 命令 | 期望 |
|------|------|------|
| drift-counter 含 session_id 后缀 | `ls $(.claude/hooks/lib/session-dir.sh)/drift-counter*` | `drift-counter.<short-id>` |
| 新会话 counter 从 0 | mock 一次 PostToolUse 调用 | counter 文件值 = 1 |
| tasks.json 任务数 | `python3 .claude/hooks/lib/task-summary.py full` | 16 个任务（T-017..T-032） |
| tasks-archive.json 任务数 | `jq '.tasks \| length' docs/tasks-archive.json` | 16（T-001..T-016） |
| tasks.json 仍 valid | tasks-validate hook 模拟跑 | exit 0 |
| §6 含 main-only 注解 | `grep -c "main-only" AGENTS.md` | ≥ 1 |
| make test | — | 25/25 PASS |

## 完成定义

- 5 个新/改文件 + 1 新 lib helper + 1 决策记录
- 验证矩阵 7/7 PASS
- 单 commit
- T-033 写入 tasks.json 并标 done

## 后续（不在本轮）

- P1-4：文档显式标注未触发 surface 的「示例性质」
- Round 9：drift-detector 改成项目计划/STATUS 检查（更有意义）
