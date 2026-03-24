# AI Coding Context

本项目的 AI 行为由以下文件共同定义，Claude Code 启动时会自动加载：

- **本文件 (CLAUDE.md)** — 入口，Claude Code 原生加载
- **AGENTS.md** — 完整的 AI 行为规范（推理框架、9 步流程、编码哲学、安全规则）
- **`.claude/rules/`** — 按路径作用域的模块化规则
- **`.claude/settings.json`** — 权限和 hooks 配置

## 快速参考

任务的 SSoT 是 `docs/tasks.json`，上下文记录在 `docs/STATUS.md`。

非 trivial 任务必须走 AGENTS.md §6 定义的 9 步流程，禁止静默跳步。

详细规则见 @AGENTS.md。
