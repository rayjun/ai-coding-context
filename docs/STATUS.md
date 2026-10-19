> **最后更新**: 2026-10-19
> **当前阶段**: 精简重构完成 — 长任务 harness

## 当前目标
把仓库收敛为「长时间任务 harness」。评估标准：**能否支持 agent 数小时～数天无人值守执行任务**。
已删除所有不服务该目标的内容（9 步流程 / skills / subagents / commands / rules / 历史 docs 等），git 历史保留旧内容。

## 任务进度
详见 `docs/tasks.json`。

## 最新发现
- 保留核心：状态三件套、Loop 纪律、证据纪律、安全门（9 个自查脚本 + danger-patterns 库）。
- 覆盖率门槛整体移除（跨平台不可靠且非长任务核心）；相关测试同步删除。
- 命名中性化：`/tmp/claude-hooks` → `/tmp/ai-context`；`HERMES_HOOK_EVIDENCE_DIR` → `AI_CONTEXT_EVIDENCE_DIR`。
- 新增 §8 跨 agent review：请求必须自包含（目标 / 范围 / 证据 / 原则 / 输出格式），8 条 review 原则（证据先于判断、发现可落地、blocker / should-fix / nit 三档、已证实与推测分离），评审结论落盘到 tasks.json / STATUS.md。
- 已知遗留：`pre-commit-check.sh` 与 `assertion-audit.sh` 提示文本仍引用「AGENTS.md §6 Step 7」，精简后应为 §3 证据纪律，待修。

## 下次从这里开始
- 无未完成任务。被删除内容的完整历史：`git log` / `git show <commit>^:path`。
- 新增任何内容前先回答：是否帮助 agent 长时间执行任务？否则不加。
