# AI Coding Context

> AI Coding 的本质是 **上下文管理**。本项目在 LLM 的概率性与软件工程的确定性之间，通过规范、Harness 和 Skills 建立平衡。

一套完整的 AI 行为治理框架，四层协同：

1. **上下文工程** — `AGENTS.md` 定义推理框架、9 步流程、编码哲学、安全规则
2. **Harness 层** — 19 个 hook 脚本将关键规则从"文字约束"升级为"代码强制"
3. **Skills 层** — 按需加载的可复用能力包（工作流 / 调试 / 安全 / 架构审查）
4. **SSoT 文档** — `docs/STATUS.md` 记录上下文、`docs/tasks.json` 追踪进度

跨工具可用：Claude Code（一等公民）、Gemini CLI（hooks 兼容）、Codex CLI（sandbox 兜底）。

---

## 快速安装

```bash
# 前置依赖
# 1. Claude Code: https://docs.claude.com/en/docs/claude-code
# 2. superpowers: https://github.com/obra/superpowers

# 在项目根目录执行
curl -sSL https://raw.githubusercontent.com/rayjun/ai-coding-context/main/install.sh | bash

# 预览将要写入的文件（不落盘）
curl -sSL .../install.sh | bash -s -- --dry-run
```

覆盖前自动写 `.bak` 备份；下载失败自动回滚。

---

## 项目结构

```
your-project/
├── CLAUDE.md                     # Claude Code 原生入口（@AGENTS.md import）
├── AGENTS.md                     # AI 行为规范（~150 行）
│
├── .claude/
│   ├── settings.json             # 7 个 hook 事件 + permissions
│   ├── rules/                    # paths frontmatter 作用域规则（原生）
│   │   ├── hooks-dev.md          #   → 编辑 .claude/hooks/** 时加载
│   │   ├── skills-dev.md         #   → 编辑 .claude/skills/**/*.md 时加载
│   │   └── docs-maintenance.md   #   → 编辑 docs/** 时加载
│   ├── commands/                 # 斜杠命令（/review /status /fix-issue）
│   ├── skills/                   # 按需加载的 Skills
│   │   ├── workflow-management/  #   9 步开发流程
│   │   ├── investigate/          #   根因调试
│   │   ├── careful-ops/          #   破坏性操作防护
│   │   ├── plan-review/          #   架构审查（5 维 pass/warn/fail）
│   │   ├── monitoring-security/  #   监控安全加固
│   │   ├── obsidian-vault/       #   Obsidian 笔记整理（内置规则）
│   │   ├── obsidian-writer/      #   Obsidian 写入（读 vault 根 AGENTS.md）
│   │   └── lib/eval-runner.py    #   从 SKILL.md EVAL 块打分
│   └── hooks/                    # Harness 层
│       ├── careful-ops-check.sh  # PreToolUse 危险命令拦截
│       ├── pre-commit-check.sh   # PreToolUse commit 门禁
│       ├── record-test-evidence  # PostToolUse 测试证据记录
│       ├── credential-sniff.sh   # 扫 inline 凭据
│       ├── migration-safety.sh   # DB migration 可回滚性
│       ├── assertion-audit.sh    # Stop 时审计虚假断言
│       └── lib/                  # danger-patterns + 测试套件
│
├── docs/
│   ├── STATUS.md                 # 项目状态 SSoT（跨会话上下文）
│   ├── tasks.json                # 任务 SSoT（结构化）
│   ├── status-writing-guide.md   # STATUS 书写规范
│   └── plans/                    # 计划存档
│
├── .gemini/settings.json         # Gemini CLI hooks（适配 Claude 的 hook 脚本）
└── .codex/config.toml            # Codex CLI sandbox + approval
```

---

## 核心规范

### `CLAUDE.md` — Claude Code 入口
Claude Code 启动时自动加载。通过 `@AGENTS.md` import 引用 AGENTS.md 主规范。

### `AGENTS.md` — AI 行为准则
推理框架、任务复杂度分级、编码哲学、9 步开发流程、安全规则、文档维护。**流程按 trivial/moderate/complex × 9 步矩阵裁量**，避免一刀切。

### `.claude/rules/` — 路径作用域规则（官方 paths 原生机制）
```yaml
---
paths:
  - ".claude/hooks/**/*.sh"
---
# Hook 开发规则
- 所有 hook 脚本必须以 `set -euo pipefail` 开头
- ...
```
Claude Code 在编辑匹配文件时自动注入内容。

### `.claude/commands/` — 自定义斜杠命令
- `/review` — 审查当前分支 diff（动态检测 base 分支）
- `/status` — 项目健康检查（STATUS.md 新鲜度 + tasks 一致性 + git 状态）
- `/fix-issue <n>` — 从 GitHub issue 号系统性修复

> Claude Code 的斜杠命令**无 `project:` 前缀**。同名时 skill 优先。

### `.claude/skills/` — 按需 Skills
6 个项目级 skill + 1 个 eval-runner 工具。每个 SKILL.md 含 `EVAL 1..N` 质量评估块，可用 `eval-runner.py` 自动打分。

---

## Harness 层（19 个 hook）

| 事件 | 脚本 | 作用 |
|------|------|------|
| SessionStart | `orient-session.sh` | 注入 git log / STATUS.md / tasks 摘要 |
| UserPromptSubmit | `prompt-context.sh` | 每次对话前注入 tasks 简报（带 mtime 缓存） |
| PreToolUse Bash | `careful-ops-check.sh` | 危险命令阻断（hookSpecificOutput 格式）|
| PreToolUse Bash | `pre-commit-check.sh` | 无测试证据或源码被动后过禁止 commit |
| PostToolUse Bash | `record-test-evidence.sh` | 仅在测试/构建输出看起来成功时记录 |
| PostToolUse Edit\|Write | `post-edit-dispatch.sh` | 合并分发 status-reminder / format-check / tasks-validate |
| PostToolUse Edit\|Write | `credential-sniff.sh` | 扫 AKIA / sk- / ghp_ / PEM / JWT |
| PostToolUse Edit\|Write | `large-file-warn.sh` | >1500 行提醒拆分 |
| PostToolUse Edit\|Write | `migration-safety.sh` | 检测 NOT NULL 无默认 / DROP / 非 CONCURRENTLY |
| PreCompact | `pre-compact.sh` | 压缩前保留当前目标 / 计划 / resume point |
| Notification | `notify.sh` | macOS / Linux 桌面通知 |
| Stop | `session-end.sh` | 会话结束检查 STATUS / tasks / 未提交 |
| Stop | `assertion-audit.sh` | 扫 "测试通过" 断言，对比 evidence 文件 |

共享库：`lib/json-extract.sh`、`lib/session-dir.sh`、`lib/task-summary.py`、`lib/danger-patterns.sh`（+ 25 条单元测试）、`lib/pretool-response.sh`。

### 官方合规
- PreToolUse deny 使用 **`hookSpecificOutput.permissionDecision`**（非 deprecated 的 `{decision:"deny"}` + exit 2）
- PostToolUse Bash 的 JSON schema 无 `exit_code`，使用 `tool_response.{stdout,stderr,interrupted}` 启发式判定
- `.claude/rules/*.md` 的 `paths` frontmatter 是官方原生加载机制

---

## 跨工具兼容矩阵

| 能力 | Claude Code | Gemini CLI | Codex CLI |
|------|:-:|:-:|:-:|
| 路径作用域 Rules (`.claude/rules/`) | ✅ 原生 | ⚠️ 参考 AGENTS.md | ❌ |
| SessionStart / PreCompact | ✅ | ✅ | ❌ |
| PreToolUse Bash 拦截 | ✅ | ✅ (`matcher=shell`) | ⚠️ sandbox + approval_policy |
| PostToolUse Edit 合并分发 | ✅ | ✅ (`matcher=write_file\|edit`) | ❌ |
| Stop / SessionEnd | ✅ Stop | ✅ SessionEnd | ❌ |
| `permissions.allow/deny` | ✅ | ❌ | ❌ (用 `sandbox_mode`) |
| Skills (`SKILL.md` 原生发现) | ✅ | ❌ 需人工 @引用 | ❌ |
| 斜杠命令 | ✅ | ❌ | ❌ |

**结论**：Claude Code 一等公民；Gemini CLI 跑 hook 但无 Skills；Codex CLI 主要靠 sandbox + approval 兜底。跨工具使用以 `AGENTS.md` 为共通规范面。

---

## 工作流：9 步流程（按复杂度裁量）

| 步骤 | trivial | moderate | complex |
|------|:-:|:-:|:-:|
| 1. 头脑风暴 | ➖ | ◯ | ✅ |
| 2. 制定计划 + 审查 | ➖ | ✅ | ✅ |
| 3. Git worktree | ➖ | ➖ | ◯ |
| 4. TDD（生产业务逻辑） | ➖ | ✅ | ✅ |
| 5. 执行（可并行 agent） | 直接 | ✅ | ✅ |
| 6. 代码审查 | ➖ | ◯ | ✅ |
| 7. **验证（证据先于断言）** | ✅ | ✅ | ✅ |
| 8. 文档维护 | ➖ | ✅ | ✅ |
| 9. 完成分支 | ➖ | ◯ | ✅ |

✅ 必做 · ◯ 可选 · ➖ 可跳

详见 `AGENTS.md` §2 §6。

---

## 相关依赖

- **Harness 理念**: [12 Factor Agents](https://github.com/humanlayer/12-factor-agents)
- **Skills 框架**: [superpowers](https://github.com/obra/superpowers)
- **规范起源**: `AGENTS.md` 改编自 [Xuanwo 的 AI Context Gist](https://gist.github.com/Xuanwo/fa5162ed3548ae4f962dcc8b8e256bed)
- **官方文档**: [Claude Code Hooks](https://code.claude.com/docs/en/hooks) · [Skills](https://code.claude.com/docs/en/skills) · [Memory](https://code.claude.com/docs/en/memory)

---

## 审计历史

| 日期 | 动作 | 产出 |
|------|------|------|
| 2026-04-27 | Round 2 · 对齐 Claude Code 官方文档 | hookSpecificOutput 升级、rules 回归原生 paths、命令前缀纠正 |
| 2026-04-27 | Round 1 · 16 项规范审计 | 优先级统一、EVAL 补齐、pre-commit mtime 判据、3 个新 hook |
| 2026-04-21 | 融入 4 条编码原则 | Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven |
| 2026-03-11 | Skill 国际化（中文） | name 保留英文标识符，内容 / description 中文 |

详见 `docs/STATUS.md` 决策记录（#1 ~ #25）。
