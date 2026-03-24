# AI Coding Context

AI Coding 的本质是 **上下文管理**，旨在 LLM 的概率性与软件工程的确定性之间通过精细的规范、工具和 Skill 寻找平衡。

本项目提供一套完整的 AI 行为治理框架：harness 层（代码强制）+ 上下文工程（AGENTS.md）+ 工作流（9 步流程）+ Skills。

---

## 快速安装

需要提前安装 [superpowers](https://github.com/obra/superpowers)，然后在项目根目录下执行：

```bash
curl -sSL https://raw.githubusercontent.com/rayjun/ai-coding-context/main/install.sh | bash
```

---

## 项目结构

```
your-project/
├── CLAUDE.md                  # Claude Code 原生入口（自动加载）
├── AGENTS.md                  # AI 行为规范（推理 + 流程 + 风格 + 安全 + 文档）
│
├── .claude/
│   ├── settings.json          # 权限 + hooks 配置
│   ├── rules/                 # 按路径作用域的模块化规则
│   │   ├── hooks-dev.md       # hooks/ 目录下的开发规则
│   │   ├── skills-dev.md      # skills/ 目录下的开发规则
│   │   └── docs-maintenance.md # docs/ 目录下的文档规则
│   └── commands/              # 自定义斜杠命令
│       ├── review.md          # /project:review — 代码审查
│       └── status.md          # /project:status — 项目状态检查
│
├── hooks/                     # Harness 层（13 个脚本，覆盖 7 个生命周期事件）
│   ├── careful-ops-check.sh   # 破坏性操作拦截
│   ├── pre-commit-check.sh    # commit 前测试门禁
│   ├── orient-session.sh      # 会话启动上下文注入
│   ├── prompt-context.sh      # 每条消息注入任务进度
│   ├── drift-detector.sh      # 每 30 次调用轨道修正
│   ├── pre-compact.sh         # compaction 前保存关键状态
│   ├── session-end.sh         # 会话结束检查
│   └── lib/                   # 共享库
│
├── skills/                    # 可复用 Skills
│   ├── workflow-management/   # 9 步流程管理
│   ├── investigate/           # 系统性调试
│   ├── careful-ops/           # 破坏性操作防护
│   ├── plan-review/           # 架构审查
│   ├── monitoring-security/   # 监控安全加固
│   └── obsidian-vault/        # Obsidian 笔记整理
│
├── docs/
│   ├── STATUS.md              # 项目状态（上下文记录）
│   ├── tasks.json             # 任务 SSoT（结构化跟踪）
│   └── plans/                 # 计划存档
│
├── .gemini/settings.json      # Gemini CLI hooks 配置
└── .codex/config.toml         # Codex CLI 安全配置
```

---

## 核心规范

### `CLAUDE.md` — Claude Code 入口
Claude Code 启动时第一个加载的文件。指向 AGENTS.md。

### `AGENTS.md` — AI 行为准则（126 行）
定义 AI 的推理框架、9 步强制开发流程、编码风格、安全规则和文档维护原则。一个文件包含所有行为规范。

### `.claude/rules/` — 路径作用域规则
按工作目录自动加载的模块化规则。编辑 `hooks/` 时加载 hook 开发规则，编辑 `skills/` 时加载 skill 开发规则。

### `.claude/commands/` — 自定义命令
- `/project:review` — 审查当前分支 diff
- `/project:status` — 检查项目健康状态

---

## Harness 层

13 个 hook 脚本覆盖 Claude Code 的 7 个生命周期事件，将关键规则从"文字约束"升级为"代码强制"。同时适配 Gemini CLI 和 Codex CLI。

详见 `AGENTS.md` §7。

---

## 相关依赖
- **Harness 理念**: 基于 [12 Factor Agents](https://github.com/humanlayer/12-factor-agents) 准则
- **Skills 扩展**: 利用 [superpowers](https://github.com/obra/superpowers) 框架
- **规范起源**: `AGENTS.md` 改编自 [Xuanwo 的 AI Context Gist](https://gist.github.com/Xuanwo/fa5162ed3548ae4f962dcc8b8e256bed)
