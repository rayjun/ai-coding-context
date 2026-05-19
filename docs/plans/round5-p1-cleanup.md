# Round 5 P1 — 流程清理 (2026-05-19) [DONE]

**完成日期**: 2026-05-19
**复杂度**: complex（5 项跨多文件 + skill 改写）
**结果**: 5/5 项落地，验证矩阵 8/8 PASS

## 范围

清除前次评估列出的 5 项臃尾：

1. AGENTS.md §6 vs `workflow-management` skill 双 SSoT
2. `.claude/rules/*.md` 三个文件的尾部重复段
3. `monitoring-security` skill 在本项目从未使用
4. `docs/plans/` 三份未标 [DONE] 的旧计划
5. `install.sh` DIRECTORIES 重复的 `docs/decisions` 行

`#5` 中**不**移除 `large-file-warn` / `migration-safety`（用户没要求；这两个对 fork 用户仍可能有价值，留作可选 hook 是合理默认）。

---

## 实施步骤

### 步骤 1 · `workflow-management` skill 改为 thin shell

保留：frontmatter + "何时使用" + 指向 `AGENTS.md §6` 的链接 + EVAL 1-6（评估仍需要可解析的 EVAL 块）。
删除：9 步列表正文、快速参考表、实施段、常见错误（这些已在 §6 中）。

预期净减：~30 行（80 → ~50），节省 ~250 tokens（skill 触发时）。

### 步骤 2 · 删除 rules/*.md 尾部重复段

| 文件 | 行号 | 删除目标 |
|------|------|---------|
| docs-maintenance.md | 18-21 行 | 末尾 4 条重复 bullet |
| hooks-dev.md | 23-29 行 | 末尾 7 条重复 bullet |
| skills-dev.md | 18-22 行 | 末尾 5 条重复 bullet |

这些是当年合并 PR 时的复制粘贴遗物，与上方完全重叠。

### 步骤 3 · 移除 monitoring-security skill

- 删除 `.claude/skills/monitoring-security/` 目录
- install.sh 删除：DIRECTORIES 里的 `monitoring-security` 行 + CORE_FILES 里的 SKILL.md 行
- 不动历史文档（docs/plans/audit-fixes-2026-04.md / docs/tasks.json 中的提及，那是历史记录）

### 步骤 4 · 标记旧 plans 为 [DONE]

| 文件 | 完成证据 |
|------|---------|
| `docs/plans/install-script.md` | install.sh 已实施，决策 #15 |
| `docs/plans/integrate-coding-principles.md` | 4 条原则已合并到 AGENTS.md §3 |
| `docs/plans/workflow-v2.md` | 当前 §6 9 步流程即此计划落地 |

每份首行加 `[DONE] (实际完成日期)` 即可，正文不动。

### 步骤 5 · install.sh 删 `docs/decisions` 重复行

DIRECTORIES 第 41 行删除（与第 40 行重复）。

---

## 文件改动清单

| 文件 | 操作 | 备注 |
|------|------|------|
| `.claude/skills/workflow-management/SKILL.md` | 改写为 thin shell | 步骤 1 |
| `.claude/rules/docs-maintenance.md` | 删尾段 | 步骤 2 |
| `.claude/rules/hooks-dev.md` | 删尾段 | 步骤 2 |
| `.claude/rules/skills-dev.md` | 删尾段 | 步骤 2 |
| `.claude/skills/monitoring-security/SKILL.md` | 删除 | 步骤 3 |
| `install.sh` | 删 monitoring-security 行 + decisions 重复行 | 步骤 3 + 5 |
| `docs/plans/install-script.md` | 首行加 [DONE] | 步骤 4 |
| `docs/plans/integrate-coding-principles.md` | 首行加 [DONE] | 步骤 4 |
| `docs/plans/workflow-v2.md` | 首行加 [DONE] | 步骤 4 |
| `docs/decisions/0030-cleanup-bloat.md` | 新建 | 决策记录 |
| `docs/decisions/README.md` | 加 #30 索引 | — |
| `docs/STATUS.md` | 当前阶段 + 历史段 + 索引 | 第 8 步 |
| `docs/tasks.json` | 加 T-028 完成项 | 第 8 步 |

---

## 5 维度自审（plan-review skill）

1. **数据流** [pass] — 都是文件改动，无运行时数据流变化
2. **并发与一致性** [pass] — 单次 commit，串行执行；rules 删除后 paths 触发量减少
3. **接口契约** [warn] — `workflow-management` skill 内容大改可能影响**外部引用**。**缓解**：保留 frontmatter name+description 不变 + 保留全部 EVAL（autoresearch 解析仍兼容）；正文是给人看的，外部不该硬依赖。
4. **测试** [pass] — `make test` (danger-patterns 25 用例) 仍跑；删 monitoring-security 不影响测试
5. **可运维性** [pass] — 回滚 = `git revert`；install.sh `.bak` 自动备份；用户已运行的 monitoring-security 文件不会被自动删除（install.sh 不删文件，只覆盖）

**结论**：1 warn / 0 fail，可推进。

---

## 验证（第 7 步）

| 检查 | 命令 | 期望 |
|------|------|------|
| rules 不再有重复段 | `grep -c "^- " .claude/rules/*.md` | 与去重后 bullet 数一致 |
| monitoring-security 已删 | `ls .claude/skills/monitoring-security 2>&1` | "No such file" |
| install.sh 无重复 decisions | `grep -c '"docs/decisions"' install.sh` | 1（DIRECTORIES）+ 1（download）= 2 |
| install.sh 无 monitoring-security | `grep -c monitoring-security install.sh` | 0 |
| workflow-management skill EVAL 仍可解析 | `python3 .claude/skills/lib/eval-runner.py parse .claude/skills/workflow-management/SKILL.md` | 6 个 EVAL |
| docs/plans 无未完成 | `for p in docs/plans/*.md; do head -1 "$p" \| grep -q "DONE\|DEPRECATED" \|\| echo unfinished:$p; done` | 全部输出 DONE |
| make test 回归 | `make test` | 25/25 PASS |

---

## 完成定义

- 13 个文件改动（含 1 删除目录、1 新增决策、若干编辑）
- 验证矩阵 7 项全过
- 单 commit，commit message 提完整范围
- T-028 ~ T-029 写入 tasks.json

## 后续（不在本轮范围）

- 是否真的删 large-file-warn / migration-safety hook 注册（用户暂不要求）
- workflow-management skill 是否完全废除（依赖外部引用情况评估后定）
- tasks.json archive 机制（防 Round 8+ 膨胀）
