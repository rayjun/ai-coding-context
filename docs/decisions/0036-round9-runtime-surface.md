# 决策 #36 · Round 9 P0 运行时 surface 整理

**日期**: 2026-05-31
**状态**: Adopted

## 背景

Round 8 P0 修完工作流跨会话累积问题后，做第二次「实际跑动」审计，发现两类未被 Round 1-8 触及的问题：

1. **本仓库 `.claude/settings.json` 的 PostToolUse Edit|Write hook 链有 4 个 hook，其中 3 个对本仓库永远静默**：
   - `credential-sniff.sh`：扫 API key / JWT，本仓库是 docs 项目无 secrets
   - `large-file-warn.sh`：阈值 1500 行，本仓库最大文件 ~250 行
   - `migration-safety.sh`：检测 SQL migration，本仓库无数据库
   
   每次 Edit/Write 串行 fork-exec 4 个 hook 进程，本会话约 30 次编辑 → 90 次进程启动 0 输出。
   
2. **Round 4 P0 引入的 4 个未触发 surface（plan-reviewer / retro-writer / lessons.md / specs/）距今 33 天 0 实际触发**：
   - 不再是「等等看」阶段
   - fork 用户看到这些 surface 会以为是项目核心组件
   - 与 R6 P1 给 obsidian-writer 的处理（标记为示例）保持一致原则

## 决策

### #1 — settings.json 移除 3 个对本仓库永远静默的 hook 注册

`.claude/settings.json` PostToolUse Edit|Write 链从 4 个 hook 缩为 1 个（仅保留 `post-edit-dispatch.sh`，它会动态分发 status-reminder / format-check / tasks-validate）。

**脚本文件保留**（仍在 install.sh CORE_FILES）。fork 用户的项目（含 secrets / 大文件 / DB migration）可手动加回 settings.json。

### #2 — 4 个 demo surface 加「示例」blockquote 标注

| 文件 | 标注内容 |
|------|---------|
| `.claude/agents/plan-reviewer.md` | 「示例 agent」+ 0 触发说明 |
| `.claude/agents/retro-writer.md` | 同上 + lessons.md 0 追加说明 |
| `docs/lessons.md` | 「示例文件」+ 0 追加事实 |
| `docs/specs/README.md` | 「示例性质」+ 本仓库未使用 spec 模式 |

参考 R6 P1 给 obsidian-writer 的同模式处理。

### 不做
- **不删** plan-reviewer / retro-writer / specs：对 fork 用户仍有价值
- **不删** assertion-audit hook：它是 fail-safe 防 LLM 自夸，删了主架构变化太大
- **不删** 3 个静默 hook 脚本：保留作 opt-in 工具

## 影响

实测：
- PostToolUse Edit|Write hook 链：4 → **1**（每次编辑省 3 fork-exec）
- 4 个 demo surface 顶部都有「示例」声明，fork 用户读 SKILL/agent 文件第一眼就知道定位

正确性收益：
- 本仓库 settings.json 现在反映本仓库的真实需求，不再演「永远静默的 3 个 hook」
- demo surface 的设计意图明确：示范模式而非核心组件

代价：
- 极小。3 个 hook 脚本仍随 install.sh 分发，fork 用户启用方式：复制 `.claude/settings.json` 中相应 hook 配置回去。**未来可考虑** `.claude/settings.example.json` 提供完整版供参考。

## 验证

- PostToolUse Edit|Write hook 注册数 = 1
- 3 个静默 hook 在 settings.json 引用 = 0
- 4 个 demo surface 各含 1 处「示例」标注
- danger-patterns 25/25 PASS

## 后续

- 可选：`.claude/settings.example.json` 完整模板（含 3 个静默 hook + 注释「适用场景」）
- 后续审计可关注：assertion-audit 在多次 Round 后是否仍属于 fail-safe 还是死代码
- Round 10 候选：drift-detector 改成更有意义的检查（如 STATUS.md 漂移检测）
