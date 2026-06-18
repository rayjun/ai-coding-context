# 0038 · Round 11 P0 — Loop Engineering

**日期**: 2026-06-17
**状态**: accepted
**相关**: AGENTS.md §6, workflow-management skill, evidence gates

## 背景

当前 harness 已有 9 步流程、subagent 方案/代码审查、evidence 门禁和 STATUS/tasks SSoT，但缺少显式的「循环」操作模型。

缺口集中在三类场景：
- 信息不足时，agent 可能靠猜继续推进。
- 审查或验证失败时，agent 可能把失败当结论，过早结束。
- 多轮修复时，agent 可能无边界自旋，没有观察信号、退出条件或升级条件。

## 决策

**A · Loop Engineering 作为 context/workflow discipline，不新增 runtime hook。**

在 `AGENTS.md` §6 中新增 Loop Engineering 小节，定义非 trivial 任务的循环四要素：目标、观察信号、下一步假设、退出/升级条件。

**B · 将失败路径显式写入流程规则。**

信息不足、方案审查失败、代码审查失败、验证失败时，必须先记录观察信号，再更新假设，做最小修改并重跑同一 gate。同一 gate 失败两轮且没有新证据时停止自旋，汇报已知事实和需要外部决策的点。

**C · workflow-management skill 保持 thin shell。**

skill 不复制流程细节，只把 SSoT 指向 `AGENTS.md` §6 的 Loop Engineering，并新增 EVAL 检查 loop 是否具备边界。

## 后果

**正面**：
- 把「持续迭代直到绿灯」和「不要无界自旋」同时写进 harness。
- review/verification 从一次性步骤变成有明确收敛条件的工程循环。
- 不新增 hook，不增加 Claude/Gemini/Codex 配置和安装复杂度。

**负面 / 取舍**：
- 目前仍是文本约束，不能像 pre-commit evidence 那样硬拦截。
- 需要 agent 主动在计划/执行中声明 loop 边界；后续如果经常被忽略，再评估 soft reminder 或 hook。

## 不做

- 不新增 `.claude/hooks/*`。
- 不改变 `install.sh` CORE_FILES；本轮没有新增需要安装的核心文件。
- 不引入 `docs/specs/` 三件套，继续沿用 `docs/plans/*.md`。
