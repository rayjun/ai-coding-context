# Round 12 P2 — 工具中立化：harness/ 迁移 + 彻底移除 .claude/.gemini/.codex

**日期**: 2026-06-18
**状态**: done ✅（全部验收项通过，2026-06-18）
**决策参考**: `docs/decisions/0041-tool-agnostic-harness.md`（第 8 步落盘）

## 目标

去掉 `.claude` / `.codex` / `.gemini` / `CLAUDE.md` 的工具分类，让 AGENTS.md 上下文直接适配所有 agent：

1. **资源层中立化**：hooks / skills / agents / rules / commands 迁移到 `harness/`，AGENTS.md 及全部活跃引用归零 `.claude/` 前缀。
2. **彻底删除工具目录**：`.claude/`（含 settings.json）、`.gemini/settings.json`、`.codex/config.toml`、`CLAUDE.md` 全部删除。
3. **hooks 改为「Agent 自觉执行」**：不依赖任何平台的 hooks 注册机制；AGENTS.md 定义触发时机（破坏性操作前、commit 前、编辑后等），由 agent 自行运行 `harness/hooks/*.sh`。平台 hooks 的"硬强制"降级为"文本约定"（用户明确接受的取舍）。

## 迁移拓扑

```
.claude/hooks      → harness/hooks
.claude/skills     → harness/skills
.claude/agents     → harness/agents
.claude/rules      → harness/rules
.claude/commands   → harness/commands
.claude/settings.json / .gemini/ / .codex/ / CLAUDE.md → git rm
```

## 执行步骤

| # | 动作 |
|---|------|
| 1 | `git mv` 5 个子目录到 `harness/`；`git rm` settings.json / .gemini / .codex / CLAUDE.md |
| 2 | 全局引用更新：AGENTS.md（6 处）、hooks 内部（task-summary.py 等）、skills（careful-ops SSoT、obsidian-writer 用户路径、eval-runner）、agents（SKILL 引用）、rules（paths frontmatter + 加载说明）、commands（python3 路径） |
| 3 | AGENTS.md §7 改写：hooks 从"平台硬拦截"改为"agent 自觉执行清单"（触发时机 × 对应 hook） |
| 4 | install.sh 全面更新：DIRECTORIES/CORE_FILES 全部 harness/ 路径、chmod、清理逻辑、不再安装工具配置 |
| 5 | .gitignore 删除 .claude/.gemini/.codex 规则；README 更新 Cross-tool 描述 + 安装说明 |
| 6 | 测试迁移后全绿；`grep -r "\.claude"` 活跃文件归零（仅历史 docs 保留） |
| 7 | 文档维护：决策 0041、tasks.json T-039、STATUS.md、install.sh dry-run 验证 |

## 引用更新细节

- **AGENTS.md**：§6 表格第 2续/6 步、subagent 执行方式、会话复盘、§7 安全、§8 → `harness/...`
- **hooks 内部**：`orient-session.sh` / `pre-compact.sh` / `prompt-context.sh` / `session-end.sh` 的 `python3 .claude/hooks/lib/task-summary.py` → `harness/hooks/lib/`
- **obsidian-writer**：`~/.claude/obsidian-vault.path` → `~/.config/ai-context/obsidian-vault.path`（中性用户路径）；`~/.claude/settings.json` env 建议删除
- **rules**：frontmatter `paths` 更新为 harness 路径；加载说明从"Claude Code 原生机制"改为"由 AGENTS.md §8 文档引用"
- **commands**：保留为参考实现（slash 命令仅 Claude 特定），README 标注

## 风险与对策

| 风险 | 对策 |
|------|------|
| hooks 不再被平台自动触发 → 门禁变软约束 | AGENTS.md §7 明确定义触发时机清单；README 说明取舍；用户确认接受 |
| 敏感文件 deny 失效（原 settings.json permissions） | AGENTS.md §7 保留敏感文件说明；credential-sniff hook 纳入自觉执行清单 |
| 存量引用遗漏（docs 历史） | 活跃文件 grep 归零为目标；历史 docs 存量保护不改 |
| rules paths 机制失效 | rules 文档化，AGENTS.md §8 引用 |

## Loop 信号

- 观察信号：git mv 无冲突；测试全绿；活跃文件 `.claude` 引用归零；install.sh dry-run 输出全部 harness/ 路径。
- 退出条件：验收项全过 + 全量测试 PASS。
- 升级条件：路径引用遗漏导致 hook 运行失败时，按 grep 结果逐个修正后重跑测试。
