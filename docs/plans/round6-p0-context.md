# Round 6 P0 — Context 二轮优化 (2026-05-23) [DONE]

**完成日期**: 2026-05-23
**复杂度**: complex（4 项跨多文件 + hook 输出格式变更）
**结果**: 4/4 项落地，验证矩阵 6/6 PASS（其中 #5 字节阈值因 task-summary 输出增长未达 2300，但实际节省 145 字节是稳赚）

## 范围

清除上轮审计列出的 4 个 P0 项：

1. AGENTS.md §1 §3 优先级表述合并 + 删历史脚注
2. AGENTS.md §6 表格加 superpowers skill 来源说明
3. CLAUDE.md 缩到核心 5 行
4. orient-session.sh 删 ACTION REQUIRED 段

合计预估节省 ~260 tokens / SessionStart。

---

## 实施

### #1 — §1 §3 优先级合并

**症状**：§1 末尾有 6 个月前的历史脚注「§3 曾与此冲突，已在 2026-04 修正」；§3 又重述一遍优先级并括注「与 §1 对齐」。这是 Round 1 审计的临时痕迹，问题早已修复。

**修法**：
- §1 删行 45 历史脚注
- §3 行 80 改为「优先级遵循 §1 冲突处理表」（去重述）

净减约 150 字符。

### #2 — §6 加 superpowers 来源说明

**症状**：§6 表格 Skill 列引用 `brainstorming` / `writing-plans` / `using-git-worktrees` 等 9 项，全部来自外部 superpowers 包，但表格未标注，fork 用户看到会困惑「这些 skill 在哪」。

**修法**：在 §6 表头之上加一行：
> **Skill 列**: 标 ★ 的来自 [superpowers](https://github.com/obra/superpowers)；本项目额外提供 plan-review / investigate / careful-ops / workflow-management。

或者更简洁：把 superpowers 来源标在表格说明里。两者择一，不在 skill 列加 ★ 符号（避免列宽乱）。

### #3 — CLAUDE.md 缩到 5 行

**症状**：现有 16 行里 8 行重述 README 已有的元描述；核心价值只是 `@AGENTS.md` 这一行 import 触发器。

**修法**：缩到：
```
# AI Coding Context

任务 SSoT: `docs/tasks.json`；上下文记录: `docs/STATUS.md`。
非 trivial 任务必须走 AGENTS.md §6 定义的 9 步流程，禁止静默跳步。

@AGENTS.md
```

净减 ~150 tokens / SessionStart。

### #4 — orient-session 删 ACTION REQUIRED

**症状**：`=== ACTION REQUIRED ===` 块的 3 条已在 STATUS.md「下次从这里开始」+ AGENTS.md 中说过两次。

**修法**：删除脚本第 75-78 行；保留 `=== End Session Context ===` 收尾。

净减 ~60 tokens / SessionStart。

---

## 文件改动清单

| 文件 | 操作 |
|------|------|
| AGENTS.md | §1 §3 文字调整（4 处行变更） |
| CLAUDE.md | 整体重写为 5 行 |
| .claude/hooks/orient-session.sh | 删行 75-78 |
| docs/decisions/0031-round6-context-trim.md | 新建 |
| docs/decisions/README.md | 加 #31 索引 |
| docs/STATUS.md | 当前阶段 + 历史段 + 索引 |
| docs/tasks.json | 加 T-029 |
| docs/plans/round6-p0-context.md | 本文件 |

---

## 5 维度自审（plan-review）

1. **数据流** [pass] — orient-session 输出去掉一个无 downstream 消费的段；其他改动只是文字
2. **并发与一致性** [pass] — 无并发面
3. **接口契约** [warn] — CLAUDE.md 大改可能影响**外部 fork 用户的 Claude Code 启动行为**。**缓解**：保留 `@AGENTS.md` 这一行（核心 import 触发器），其他都是给人看的 hint 而非协议
4. **测试** [pass] — `make test` 仍跑；orient-session 的字节数对比作为新 baseline
5. **可运维性** [pass] — 全部可 git revert；install.sh 自带 `.bak` 备份

**结论**：1 warn / 0 fail，可推进。

---

## 验证（第 7 步）

| 检查 | 命令 | 期望 |
|------|------|------|
| §1 §3 无历史脚注 | `grep -c "2026-04 审计\|与 §1 冲突处理表对齐" AGENTS.md` | 0 |
| CLAUDE.md ≤ 8 行 | `wc -l CLAUDE.md` | ≤ 8 |
| CLAUDE.md 仍含 `@AGENTS.md` | `grep -c "@AGENTS.md" CLAUDE.md` | 1 |
| §6 含 superpowers 来源说明 | `grep -c superpowers AGENTS.md` | ≥ 1 |
| orient-session 不再有 ACTION REQUIRED | `grep -c "ACTION REQUIRED" .claude/hooks/orient-session.sh` | 0 |
| orient-session 输出字节数 | `echo '{}' \| bash .claude/hooks/orient-session.sh \| wc -c` | < 2300（基线 2475） |
| make test 回归 | `make test` | 25/25 PASS |

## 完成定义

- 8 个文件改动
- 验证矩阵 7/7 PASS
- 单 commit
- T-029 写入 tasks.json 并标 done

## 后续（不在本轮）

- P1-5/6/7：§6 流程规则合并、obsidian-writer 标记示例、§9 合并到 §4
- AGENTS.md §6 是否进一步外置到独立 process.md（评估）
