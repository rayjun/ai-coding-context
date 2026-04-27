> **最后更新**: 2026-04-27 14:30 UTC
> **当前阶段**: [规范审计 Round 2 — Claude Code 合规性修正]
> **整体进度**: 20/20 任务完成 (100%)

## 当前目标
Round 1（16 项审计）完成后，对照 Claude Code 官方文档做合规性修正，避免假设偏离文档导致的硬伤。
**参考**: `docs/plans/audit-fixes-2026-04.md` [DONE]、本文档 Round 2 决策记录

## 任务进度

任务 SSoT 见 `docs/tasks.json`。Round 1 16 项 + Round 2 4 项 = 20/20。

### Round 1 (A + B + C) — 见 tasks.json T-001 ~ T-016

| 批次 | 重点 |
|------|------|
| A · P0 | 优先级统一 / STATUS 同步 / EVAL 补齐 |
| B · P1 | pre-commit mtime 判据 / danger-patterns SSoT / review 动态分支 / post-edit 合并 / 流程分级 |
| C · P2 | TDD 限定 / 新增 credential-sniff/large-file-warn/migration-safety/assertion-audit / eval-runner / 工具兼容矩阵 / install.sh .bak |

### Round 2 (T-017 ~ T-020) — Claude Code 合规性修正

- T-017 探针证明 PostToolUse Bash 的 `tool_response` **不含** `exit_code`，只有 `stdout/stderr/interrupted` ✓
- T-018 `record-test-evidence.sh` 改用 stdout/stderr 启发式 + interrupted 判定，5/5 场景测试通过 ✓
- T-019 `careful-ops-check.sh` / `pre-commit-check.sh` 升级为官方 `hookSpecificOutput` deny 格式，新增 `lib/pretool-response.sh`；danger-patterns 25/25 测试通过；**已通过真实 PreToolUse 拦截验证** ✓
- T-020 删除 3 个冗余子目录 CLAUDE.md；恢复 rules/*.md 的 `paths` frontmatter 为原生机制；纠正 README/install 中 `/project:xxx` 误用为 `/xxx` ✓

## 最新发现

- **Bash PostToolUse 无 exit_code**: 实测 JSON 结构为 `{session_id, tool_name, tool_input:{command, description}, tool_response:{stdout, stderr, interrupted, isImage, noOutputExpected}, tool_use_id}`。`record-test-evidence` 改用输出启发式（匹配 FAIL/ERROR/panic 标记）。
- **hookSpecificOutput 格式在线验证**: 修好的 careful-ops 在本会话中**真的阻断了我自己的 bash 测试命令两次**，确认 Claude Code 支持新格式 `{hookSpecificOutput:{hookEventName:"PreToolUse", permissionDecision:"deny", permissionDecisionReason:"..."}}` + exit 0。旧的 `{decision:"deny"}` + exit 2 对 PreToolUse 已 deprecated。
- **`.claude/rules/` 的 `paths` 是官方原生机制**: 之前子代理说"不被原生解析"是错的。官方文档 [memory#organize-rules-with-claude/rules/](https://code.claude.com/docs/en/memory) 明确支持。Round 1 建的 3 个子目录 CLAUDE.md 是冗余。
- **斜杠命令无 `project:` 前缀**: `.claude/commands/review.md` 对应 `/review`（不是 `/project:review`）。同名时 `.claude/skills/<name>/SKILL.md` 优先。

## 决策记录

### 决策 #22 (2026-04-27): record-test-evidence 改用 stdout 启发式
**背景**: 官方 PostToolUse Bash schema 不含 exit_code；之前设计依赖的字段根本不存在。
**决策**: 用 `interrupted=false` + 输出中无 `FAILED/ERROR/panic/build failed/lint errors` 标记作为"成功"启发式；继续由 pre-commit gate 的 mtime 比对作为第二道关卡。
**影响**: 可能少量误判（比如故意输出 "Error:" 作为文本的正常命令），但 mtime 机制能兜底。

### 决策 #23 (2026-04-27): PreToolUse deny 格式全面升级
**背景**: PreToolUse 上 `{decision:"deny"}` + `exit 2` 已 deprecated；应使用 `hookSpecificOutput.permissionDecision`。
**决策**: 新增 `.claude/hooks/lib/pretool-response.sh#emit_pretool_deny`；careful-ops-check.sh 和 pre-commit-check.sh 全部走新 API；exit 0 + stdout JSON。
**影响**: 与未来 Claude Code 版本兼容；旧格式虽仍工作但文档已标废弃。

### 决策 #24 (2026-04-27): 回归 rules/*.md 原生 paths 机制
**背景**: 官方文档证实 `.claude/rules/*.md` + `paths: [...]` frontmatter 是原生加载机制。Round 1 我错误地"改造"成子目录 CLAUDE.md 级联，属于重复造轮子。
**决策**: 删除 `.claude/hooks/CLAUDE.md`、`.claude/skills/CLAUDE.md`、`docs/CLAUDE.md` 三个冗余文件；rules/*.md 保留为 SSoT，由 Claude Code 原生按 paths glob 加载。
**影响**: 配置更精简；消除 SSoT 分叉；新人不用理解"两套路径作用域机制"。

### 决策 #25 (2026-04-27): 纠正斜杠命令语法文档
**背景**: 文档多处写 `/project:review`、`/project:status`，Claude Code 实际无此前缀。
**决策**: 全部改为 `/review`、`/status`、`/fix-issue`。在 README 补注"命令与 skill 同名时 skill 优先"。
**影响**: 新用户调用 `/project:review` 会失败 — 纠正后符合官方行为。

## 下次从这里开始

### 恢复上下文
Round 1 + Round 2 全部落地，20/20 任务完成。

```bash
python3 .claude/hooks/lib/task-summary.py full  # 20/20 done
bash .claude/hooks/lib/danger-patterns.test.sh  # 25/25 PASS
```

### 继续工作
建议分 3 批 commit（便于审阅）：

1. **Round 1 P0 基线**：T-001 ~ T-003（AGENTS.md 优先级、STATUS/tasks、EVAL）
2. **Round 1 P1/P2 机制 + 扩展**：T-004 ~ T-016
3. **Round 2 合规性修正**：T-017 ~ T-020

后续潜在改进：
- eval-runner 接入 CI
- assertion-audit 升级为 blocking
- migration-safety 扩展 ORM 框架
- credential-sniff 结合 trufflehog/gitleaks

---

## 历史记录（保留）

### 2026-04-21: 融入 4 条编码原则
将 Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution 融入 AGENTS.md。

### 2026-03-11: Skill 国际化 (Task-32/33 — 已完成)
将 skills 目录下所有 SKILL.md 翻译为中文，保留 YAML `name` 为英文标识符。
