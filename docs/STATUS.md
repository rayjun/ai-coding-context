> **最后更新**: 2026-05-10 UTC
> **当前阶段**: [Round 3 P0 修复 — 完成]
> **整体进度**: 3/3 P0 项落地

## 当前目标
修复 Round 3 review 提出的 P0 三项：Stop hook 顺序 bug、evidence session 隔离、决策外置到 `docs/decisions/`。
**参考**: `docs/plans/round3-p0-fixes.md`

## 任务进度

任务 SSoT 见 `docs/tasks.json`。本节只记录上下文。

| Round | 范围 | 状态 |
|-------|------|------|
| Round 1 (T-001~T-016) | 优先级统一 / harness 重构 / 流程分级 / 4 新 hook | ✓ |
| Round 2 (T-017~T-020) | Claude Code 官方 API 合规性 | ✓ |
| Round 3 P0 | Stop 顺序 + evidence 隔离 + 决策外置 | ✓ |

## 最新发现

- **Stop hook 执行顺序很重要**：`session-end.sh` 之前会 `rm -rf` 整个 SESSION_DIR，在 `assertion-audit.sh` 之前跑会让审计永远看到空 evidence。Round 3 把 audit 调到 session-end 之前，并把清理逻辑收窄到只删本会话的 evidence 文件。
- **Claude Code 启动后才加载 settings.json hooks**：本会话内修改 settings.json 不会重载，新加的 hook 直到下次启动才生效。验证 hook 的修改要么用功能测试 + 真实 stdin payload 模拟，要么重启会话。
- **session_id 是 PostToolUse / PreToolUse 输入 JSON 的顶层字段**：`evidence-path.sh` helper 抽取它，作为 evidence 文件后缀，实现跨会话隔离。

## 决策记录

详见 [`docs/decisions/`](./decisions/)。每决策一文件。STATUS.md 不再复制决策正文。

| # | 标题 | 日期 |
|---|------|------|
| 22 | [record-test-evidence 改用 stdout 启发式](./decisions/0022-record-evidence-heuristic.md) | 2026-04-27 |
| 23 | [PreToolUse deny 格式全面升级](./decisions/0023-pretool-deny-format.md) | 2026-04-27 |
| 24 | [回归 rules/*.md 原生 paths 机制](./decisions/0024-rules-native-paths.md) | 2026-04-27 |
| 25 | [纠正斜杠命令语法文档](./decisions/0025-slash-command-syntax.md) | 2026-04-27 |

新决策**写到 `docs/decisions/NNNN-slug.md`**，本节只追加索引行（一行/决策）。

## 下次从这里开始

### 恢复上下文

```bash
python3 .claude/hooks/lib/task-summary.py full        # 任务进度
bash .claude/hooks/lib/danger-patterns.test.sh        # 25/25 PASS
ls docs/decisions/                                    # 决策档案
```

### 继续工作

Round 3 review 还有 P1 / P2 / P3 待办（见 review 报告或 `docs/plans/round3-p0-fixes.md` 的"后续"段）：

- P1：CLAUDE.md 精简 / AGENTS.md §0 去 Ray 化 / EVAL schema 文档化 / onboarding.md
- P2：hooks 集成测试 / session metrics / install.sh 版本号
- P3：plan-review 自动触发 / migration drill / 历史扫描 / log.sh 统一 / 逃生通道

---

## 历史记录（保留）

### 2026-04-27: Round 2 — Claude Code 官方 API 合规性
4 项修正：record-test-evidence stdout 启发式、PreToolUse hookSpecificOutput、rules paths 原生机制、slash 命令前缀纠正。决策 #22-#25 见 [`docs/decisions/`](./decisions/)。

### 2026-04-27: Round 1 — 16 项规范审计
P0 优先级统一 / STATUS bootstrap / EVAL 补齐；P1 pre-commit mtime 判据 / danger-patterns SSoT / review 动态分支 / post-edit 合并 / 流程分级；P2 TDD 限定 / 4 个新 hook / eval-runner / 工具兼容矩阵 / install.sh .bak。

### 2026-04-21: 融入 4 条编码原则
将 Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution 融入 AGENTS.md。

### 2026-03-11: Skill 国际化
将 skills 目录下所有 SKILL.md 翻译为中文，保留 YAML `name` 为英文标识符。
