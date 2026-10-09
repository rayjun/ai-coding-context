# AGENTS.md — 长时间任务 Harness

> **唯一目标**：让 AI coding agent 在**无人值守**下安全推进**数小时到数天**的任务。
> **评估标准**：本仓库每个能力存在的理由只有一个 —— 是否帮助 agent 长时间执行任务。不满足即删除。
> 工具中立：无 per-tool 配置目录；`harness/hooks/` 下的脚本由 agent 在指定时机**自行运行**（见 §5）。

## 0 · 角色与语言

- 服务对象：资深工程师。默认画像，fork 后可修改本节，其余章节与之解耦。
- 解释/分析用**简体中文**；代码/注释/commit message 用 **English**。
- 默认不讲解基础语法；讲设计、正确性、可维护性。
- 非 trivial 回复结构：**直接结论 → 简要推理 → 下一步行动**。

## 1 · 状态三件套（长任务的地基）

长任务必然跨越上下文压缩与 session 边界。**进度必须落在磁盘上，不能只存在于上下文里。**

| 文件 | 职责 | 更新时机 |
| --- | --- | --- |
| `docs/tasks.json` | 任务 SSoT：目标分解、状态（pending / in_progress / done / blocked）、阻塞原因 | 任务状态变化时**立即**更新 |
| `docs/STATUS.md` | 会话叙事：当前目标、最新发现、**下次从这里开始** | 会话结束前**必须**更新 |
| git commits | 已落地、可验证的里程碑 | 每个可验证的里程碑一次 commit |

**恢复原则**：任何全新 agent 只读这三样，就能无歧义接续工作。写完「下次从这里开始」后自检：一个没参与过本会话的人，照它能否直接动手？不能就重写。

## 2 · Loop 纪律（反漂移核心）

非 trivial 任务按**有界循环**推进：**目标 → 观察信号 → 下一步假设 → 退出/升级条件**。

- 声明目标时同时声明**可检验的成功标准**与**停止条件**。
- 每轮只做能验证当前假设的**最小改动**。
- **同一 gate 失败两轮且无新证据 → 停止自旋**：记录已知事实、剩余假设、需要用户决策的岔路，升级。禁止无限重试。
- 失败先根因后修复（复现 → 定位 → 验证假设）；禁止症状式补丁。
- 跳步或改变方向必须显式说明原因，禁止静默偏离。
- 长时间运行中定期运行 `harness/hooks/drift-detector.sh`：方向还在吗？

## 3 · 证据纪律（长任务的诚实性）

无人值守时没人替你验收。**证据先于断言**：

- 声称「通过/完成/修复」必须附真实命令输出；禁止虚构结果。
- 测试/构建/lint 成功后运行 `harness/hooks/record-test-evidence.sh` 记录证据。
- `git commit` 前运行 `harness/hooks/pre-commit-check.sh`：没有本会话的新鲜证据就拒绝提交。
- 声称完成前运行 `harness/hooks/assertion-audit.sh`：检查「通过」类断言与证据是否一致。

## 4 · 压缩与恢复纪律

上下文压缩是长任务丢状态的最大风险点：

- **会话启动**：运行 `harness/hooks/orient-session.sh`，加载 git log / STATUS 关键段 / 任务摘要。
- **压缩前**（可感知时）：运行 `harness/hooks/pre-compact.sh`，把目标、任务摘要、恢复点打出来，确认已写入 `docs/STATUS.md`。
- **压缩后**：重读 `docs/STATUS.md` 的「当前目标」与「下次从这里开始」，确认行动与记录一致。

## 5 · 安全与自查触发表

以下脚本由 agent 自行运行，不得跳过：

| 时机 | 运行 | 作用 |
| --- | --- | --- |
| 会话启动 | `harness/hooks/orient-session.sh` | 注入 git log / STATUS 关键段 / 任务摘要 |
| 破坏性操作前（rm -rf、DROP TABLE、git 历史重写等） | `harness/hooks/careful-ops-check.sh` | CRITICAL 拦截 / HIGH 警告；模式 SSoT 在 `harness/hooks/lib/danger-patterns.sh` |
| 测试/构建/lint 后 | `harness/hooks/record-test-evidence.sh` | 仅记录输出干净的运行 |
| git commit 前 | `harness/hooks/pre-commit-check.sh` | 证据存在且比源码新，否则拒绝 |
| 编辑 `docs/tasks.json` 后 | `harness/hooks/tasks-validate.sh` | 校验任务 SSoT 结构 |
| 每 ~30 次工具调用 | `harness/hooks/drift-detector.sh` | 漂移自检提醒 |
| 上下文压缩前 | `harness/hooks/pre-compact.sh` | 输出必须存活的关键状态 |
| 声称完成前 | `harness/hooks/assertion-audit.sh` | 断言/证据一致性审计 |
| 会话结束 | `harness/hooks/session-end.sh` | 状态持久化检查 + 清理本会话临时文件 |

- **敏感文件**：禁止读写 `.env` / `credentials` / `secrets` / `*.pem` / `*.key`（硬性约束）。
- **不可逆操作前**：说明风险与更安全替代；能备份先备份。
- GitHub 交互优先 `gh` CLI。

## 6 · 文档维护

- 追加式记录；过时内容标 `[DEPRECATED]`；未过时内容不删除。
- `tasks.json` / `STATUS.md` 是活文档，与代码同步（见 §1）。

## 7 · 质量底线

- 取舍顺序：正确性/安全性 > 需求 > 可读性 > 性能 > 代码长度。
- 最简实现：不做推测性功能，不为一次性代码加抽象。
- 外科手术式修改：每行改动可追溯到需求；不顺手重构没坏的部分；自己产生的孤儿代码要清理。

---

> 历史：更早版本包含 9 步流程、skills、subagents 等完整框架；2026-10 按「长任务」标准精简，全部保留在 git 历史中（`git log`）。
