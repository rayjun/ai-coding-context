# 决策 #30 · Round 5 P1 流程清理

**日期**: 2026-05-19
**状态**: Adopted

## 背景

Round 4 P0/P1 落地后做的架构臃肿评估，定位到 5 项细节债：

1. AGENTS.md §6 与 `workflow-management` skill 重复定义 9 步流程
2. `.claude/rules/*.md` 三个文件尾部都贴漏成重复段（合并 PR 遗物）
3. `monitoring-security` skill 在本项目从未被实际触发
4. `docs/plans/` 三份历史计划没标 `[DONE]`，违反 rules/docs-maintenance.md 自身规则
5. `install.sh` DIRECTORIES 数组里 `docs/decisions` 重复一行

这些不是 fundamental 问题，但累积起来损害维护质量与上下文质量。

## 决策

### #1 — `workflow-management` skill 改 thin shell

正文从 80 行缩到 56 行：删除 9 步列表正文、快速参考表、实施段、常见错误。
保留：frontmatter（外部触发器接口）+ 何时使用 + 关键纪律 + 6 条 EVAL（autoresearch 解析仍兼容）。
正文显式说明：「唯一 SSoT 在 AGENTS.md §6」。

### #2 — rules 删除尾部重复段

| 文件 | 原 bullets | 新 bullets |
|------|:-:|:-:|
| docs-maintenance.md | 11 | 7 |
| hooks-dev.md | 19 | 11 |
| skills-dev.md | 12 | 7 |

内容与上方完全重叠，是历史合并 PR 时的复制粘贴遗物。

### #3 — 移除 monitoring-security skill

`git rm -r .claude/skills/monitoring-security`；同步从 install.sh DIRECTORIES + CORE_FILES 移除。
该 skill 是给"部署 Prometheus/Grafana/Alertmanager"场景的，本项目作为 AI Coding Context 治理项目，**不部署任何监控基础设施**。任何需要它的 fork 用户可以从历史 commit 中找回。

### #4 — 旧 plans 标 [DONE]

`install-script.md`（决策 #15 已实施）、`integrate-coding-principles.md`（已并入 §3）、`workflow-v2.md`（即当前 §6）—— 三份首行加 `[DONE] + 完成日期`。

### #5 — install.sh 删 DIRECTORIES 重复行

`docs/decisions` 出现两次，删一行。

### 不做的事
- 不动 settings.json 中 large-file-warn / migration-safety 注册（用户没要求；它们对 fork 用户仍可能有价值）。
- 不删 monitoring-security 在历史文档（plans / tasks.json notes）中的提及，那是历史轨迹。

## 影响

收益：
- workflow-management 触发时节省 ~250 tokens
- rules 触发时净减 ~600 字符（约 200 tokens × 3 文件不会全部同时触发）
- docs/plans/ 100% 符合自身的 append-only + DONE 规则
- install.sh 和 skill 清单减少 1 个无用 skill 的维护面
- 未来维护 9 步流程只需改 AGENTS.md §6 一处

代价：
- workflow-management skill 内容大改，外部硬引用其内部章节的代码会失效。**缓解**：保留 frontmatter + 全部 EVAL，外部不该硬依赖正文。
- 移除 monitoring-security 后，安装本项目的新用户不会自动获得该 skill。**缓解**：从历史 commit 找回成本极低，且场景适配性问题（不是所有项目都做监控）。

## 验证

- 所有 plans 头部含 `[DONE]` 或 `[DEPRECATED]`
- `monitoring-security` 在 install.sh 中出现 0 次
- workflow-management 6 个 EVAL 通过 eval-runner.py 解析
- danger-patterns 测试 25/25 PASS

## 后续

- Round 6 评估是否真的废除 workflow-management skill（看一段时间外部使用情况）
- tasks.json archive 机制（防膨胀）
- AGENTS.md §0 是否抽到独立 profile（fork 友好性）
