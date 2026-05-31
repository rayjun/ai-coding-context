# Round 9 P0 — 运行时 surface 整理 (2026-05-30) [DONE]

**完成日期**: 2026-05-30
**复杂度**: moderate
**结果**: 2 项落地

## 范围

### P0-1 — settings.json 移除本仓库永远静默的 3 个 PostToolUse hook 注册

| Hook | 本仓库实际触发率 | 处理 |
|------|:-:|------|
| `credential-sniff.sh` | 0%（docs 项目无 secrets） | settings 注册移除，脚本保留 |
| `large-file-warn.sh` | 0%（最大文件 ~250 行 << 1500 阈值） | 同上 |
| `migration-safety.sh` | 0%（无 SQL migration） | 同上 |
| `post-edit-dispatch.sh` | 偶发 | **保留** |

收益：每次 Edit/Write 节省 3 次 fork-exec。本会话约 30 次编辑 → 90 次进程启动消失。

脚本本身仍随 install.sh 分发，下游用户（有 secrets / 大文件 / DB migration 的项目）可手动加回 settings.json。

### P0-2 — 4 个未触发 demo surface 加「示例」标注

| 文件 | 加什么 |
|------|--------|
| `.claude/agents/plan-reviewer.md` | 顶部 blockquote「示例 agent，本仓库未实际调用」 |
| `.claude/agents/retro-writer.md` | 同上 |
| `docs/lessons.md` | 顶部 blockquote「示例文件，自创建以来未追加」 |
| `docs/specs/README.md` | 已有「可选」声明，加一句「本仓库未使用」 |

R4 P0 引入这 4 个 surface 至今 33 天 0 触发，应明确归类为「示例」避免 fork 用户误以为是核心组件。

## 验证

| 检查 | 命令 | 期望 |
|------|------|------|
| settings 注册数减 3 | `jq '[.hooks.PostToolUse[] \| select(.matcher=="Edit\|Write") \| .hooks[]] \| length' .claude/settings.json` | 1 |
| 3 个脚本仍存在 | `ls .claude/hooks/{credential-sniff,large-file-warn,migration-safety}.sh` | 3 个文件 |
| 4 个 demo surface 含示例标记 | grep | 4 处 |
| make test | — | 25/25 PASS |

## 完成定义

- 1 settings.json 修改 + 4 文件顶部加注 + 1 决策记录
- 验证矩阵 4/4 PASS
- 单 commit
- T-034 写入 tasks.json
