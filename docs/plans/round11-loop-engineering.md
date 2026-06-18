# Round 11 P0 — Loop Engineering

## 背景

当前 harness 已有 9 步流程、subagent plan/code review、evidence 门禁和 STATUS/tasks SSoT，但缺少一个显式的「循环」操作模型：当验证失败、审查失败或信息不足时，agent 应该如何组织下一轮尝试、何时收敛、何时停止升级。

这会导致两类漂移：
- 把一次失败当成结论，过早结束。
- 无边界地反复修改，没有明确观察信号、退出条件或升级条件。

## 目标

把 **Loop Engineering** 作为 9 步流程的横切纪律落到 context 层和 workflow skill 中，不新增 runtime hook，不增加安装复杂度。

## 成功标准

- `AGENTS.md` 明确定义 loop 的四要素：目标、观察信号、下一步假设、退出/升级条件。
- `AGENTS.md` 把 review/verification 失败后的行为写成有界循环，而不是一次性步骤。
- `workflow-management` skill 增加 loop discipline 和 EVAL，作为执行触发器。
- `README.md` 在核心规范中说明 harness 支持 loop engineering。
- `docs/tasks.json`、`docs/STATUS.md`、决策记录同步。
- 现有 shell hook 测试和 JSON 校验仍通过。

## 实施计划

1. 在 `AGENTS.md` §6 表格后新增「Loop Engineering」小节，保持短文案，避免重复 9 步流程。
2. 调整 §6 流程规则：把目标可验证扩展成 loop 的成功标准；新增审查失败、验证失败、信息不足时的有界循环规则。
3. 更新 `.claude/skills/workflow-management/SKILL.md`：只保留 loop 触发纪律和 EVAL，Loop 定义仍以 `AGENTS.md` 为 SSoT。
4. 更新 `README.md`：在 Context Engineering 描述中加入 loop engineering，避免改 hook 数量。
5. 新增决策 #0038，更新 `docs/decisions/README.md`、`docs/tasks.json`、`docs/STATUS.md` 决策索引与上下文。
6. 验证：运行 `tasks-validate.sh` 模拟 hook input、`status-format-check.sh`、全部 `*.test.sh`、`python3 -m json.tool docs/tasks.json`，展示真实输出。

## 不做

- 不新增 hook。loop engineering 先作为 reasoning/workflow discipline；runtime 强制可后续独立评估。
- 不改变 Claude/Gemini/Codex 配置。
- 不引入新的目录或 spec 三件套。
