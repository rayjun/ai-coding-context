# 0041 · Round 12 P2 — 工具中立化：harness/ 迁移 + 移除 .claude/.gemini/.codex

**日期**: 2026-06-18
**状态**: accepted
**相关**: AGENTS.md §7, harness/, install.sh, README.md

## 背景

harness 资源（hooks / skills / agents / rules / commands）物理上全部位于 `.claude/` 下，配置按工具分三个目录（`.claude/settings.json`、`.gemini/settings.json`、`.codex/config.toml`），入口是 Claude 专属的 `CLAUDE.md`。AGENTS.md 有 6 处 `.claude/` 路径引用。这带来三个问题：

1. **工具耦合**：AGENTS.md 引用 `.claude/` 前缀，非 Claude 的 agent（Gemini CLI、Codex、pi、Cursor 等）拿到上下文会困惑——路径指向一个工具专属目录。
2. **三份配置漂移**：hooks 注册需要同时维护 `.claude/settings.json` 和 `.gemini/settings.json` 两份清单（hooks-dev.md 规则第 21 条强制要求同步），任何新增 hook 都要改两个文件。
3. **分类思维**：README 以「Claude Code (First-class) / Gemini (Hooks compatible) / Codex (Sandbox fallback)」定义能力边界，实际是同一套资源的不同适配方式。

## 决策

**A · 资源层中立化：迁移到 `harness/`。**

```
.claude/hooks    → harness/hooks
.claude/skills   → harness/skills
.claude/agents   → harness/agents
.claude/rules    → harness/rules
.claude/commands → harness/commands
```

AGENTS.md 及全部活跃引用（hooks 内部 python3 路径、skills SSoT 引用、agents 规则引用、rules paths、commands、install.sh、Makefile、.gitignore、README、STATUS 恢复上下文）统一为 `harness/`。

**B · 彻底删除工具目录与专属入口。**

`git rm .claude/settings.json .gemini/settings.json .codex/config.toml CLAUDE.md`。`.claude/`、`.gemini/` 目录不再保留（连同其注册文件）；`.codex/` 的 sandbox/approval 建议不再单独配置（由各 agent 平台的默认策略承担）。

**C · hooks 改为「Agent 自觉执行」模式。**

不依赖任何平台的 hooks 注册机制。AGENTS.md §7 改为触发时机清单表：会话启动 / 破坏性操作前 / 测试命令后 / commit 前 / 编辑 plans / tasks / STATUS 后 / 会话结束，各登记对应 `harness/hooks/*.sh`，由 agent 自行运行。平台 hooks 的「硬强制」降级为「文本约定」。

**D · 用户级路径中性化。**

`~/.claude/obsidian-vault.path` → `~/.config/ai-context/obsidian-vault.path`；`CLAUDE_LARGE_FILE_THRESHOLD` → `LARGE_FILE_THRESHOLD`。

## 后果

**正面**：
- AGENTS.md 零工具引用，任何 agent 拿到即用——上下文从「Claude Code 的配置」变成「中立的 AI 行为标准」。
- 消除三份配置漂移：hooks 只登记在 install.sh CORE_FILES + AGENTS.md §7 表，一处改动。
- 删除 2 个注册文件 + 1 个入口文件，安装更简单（install.sh 不再装工具配置）。

**负面 / 取舍（用户明确接受）**：
- hooks 不再被平台自动触发：pre-commit 门禁、破坏性操作拦截、敏感文件 deny 从「硬拦截」降级为「agent 自觉执行」。可靠性依赖 agent 遵守 AGENTS.md §7，而非平台强制。
- `.claude/rules/` 的 paths 自动注入机制失效：rules 变纯文档，由 AGENTS.md §8 引用。
- slash commands（/review /status /fix-issue）失去自动注册：保留为参考实现。
- 原 `.claude/settings.json` 的 `permissions.deny`（敏感文件拦截）失效：改为 AGENTS.md 文本约束 + credential-sniff 自觉检查。

## 不做

- 不自动删除已安装项目的 `.claude/.gemini/.codex`（install.sh 只警告，由用户决定）。
- 不改 docs/plans、docs/decisions 历史文件中的 `.claude` 引用（存量保护）。
- 不引入新的工具适配层（如 XDG 配置文件）——保持「无注册」的纯粹性，等真实工具需求出现再说。
