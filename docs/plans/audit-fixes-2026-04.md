# 规范审计与优化 (2026-04-27) [DONE]

**完成日期**: 2026-04-27
**结果**: 16/16 任务全部完成。详见 `docs/tasks.json`。

## 目标
修复 AI Coding Context 规范中的内部矛盾、SSoT 漂移与 harness 执行欠缺问题。分 P0/P1/P2 三批落地，共 16 项。

## 范围
- P0 (内部矛盾)：AGENTS.md 优先级、STATUS.md/tasks.json 漂移、SKILL EVAL 缺失
- P1 (执行机制)：pre-commit 证据判据、careful-ops 去重、review 分支检测、hooks 合并、命名冲突、rules 加载验证、9 步分级
- P2 (能力扩展)：TDD 限定、secrets scan、大文件拦截、EVAL runner、工具兼容矩阵、install 安全、自验证 hook

## 实施分组

### 批次 A — P0 基线修复
| # | 文件 | 改动要点 |
|---|------|---------|
| 1 | AGENTS.md §1/§3 | 统一优先级：正确性与安全性 > 可读性 > 性能 > 代码长度 |
| 2 | docs/STATUS.md | 同步为当前真实状态（本次审计即为当前 Task） |
| 2 | docs/tasks.json | 初始化为真实任务列表（非 example） |
| 3 | skills/workflow-management/SKILL.md | 补 EVAL 章节 |
| 3 | skills/monitoring-security/SKILL.md | 补 EVAL 章节 |
| 3 | skills/careful-ops/SKILL.md | 补 EVAL 章节 |

### 批次 B — P1 执行机制
| # | 文件 | 改动要点 |
|---|------|---------|
| 4 | hooks/pre-commit-check.sh | 改为 source mtime vs evidence mtime 比较；仅 exit 0 后记录 evidence |
| 5 | hooks/lib/danger-patterns.sh | 新建共享清单，careful-ops-check 与 SKILL 共享；补 `rm -rf $VAR/` 检测 |
| 6 | commands/review.md | 用 `origin/HEAD` 动态检测 base 分支 |
| 7 | hooks/post-edit-dispatch.sh | 合并 status-reminder + status-format-check + tasks-validate |
| 7 | .claude/settings.json | drift-detector 改用 matcher 限定 Bash\|Edit\|Write |
| 8 | 根目录 STATUS.md | 改名并重定位为 `docs/status-writing-guide.md` |
| 9 | Rules 加载验证 | 写探测脚本；失败则迁移为子目录 CLAUDE.md |
| 10 | AGENTS.md §2/§6 | 加 moderate/complex 流程分级矩阵 |

### 批次 C — P2 能力扩展
| # | 文件 | 改动要点 |
|---|------|---------|
| 11 | AGENTS.md §4 | TDD 限定为"生产业务逻辑"，明确排除探索场景 |
| 12 | hooks/secrets-scan.sh | PostToolUse Edit\|Write 扫 API key / PEM / AKIA / ghp_ |
| 12 | hooks/large-file-warn.sh | Write >1500 行 warn |
| 12 | hooks/migration-safety.sh | `db/migrations/**` / `*.sql` 强制可回滚性提醒 |
| 13 | skills/lib/eval-runner.py | 读取 SKILL.md EVAL 块，对 transcript 打分 |
| 14 | README.md | 加多工具兼容矩阵（Claude/Gemini/Codex 各 hook 支持度） |
| 15 | install.sh | 覆盖前写 .bak；增加 --dry-run |
| 16 | hooks/assertion-audit.sh | Stop hook 扫"测试通过/已验证"断言与最近 Bash exit 0 的一致性 |

## 验证计划
- **批次 A**：grep 出 AGENTS.md 两处优先级，确认一致；cat STATUS.md/tasks.json 确认反映当前；grep EVAL 块覆盖所有 SKILL
- **批次 B**：bash -n 所有改动脚本；rules 加载验证脚本输出 PASS/FAIL；`/project:review` 在非 main 分支仓库模拟跑通
- **批次 C**：secrets-scan 自测（塞一个假 key）；large-file-warn 用 2000 行假文件；eval-runner 对 investigate skill 跑一次

## 风险
- **rules 迁移**：如果实测 paths frontmatter 无效，迁移成 CLAUDE.md 方式会改变文件位置，install.sh 需联动
- **post-edit-dispatch 合并**：旧的 3 个 hook 在 .gemini/settings.json 里有独立注册，Gemini 那份也要同步
- **secrets-scan 误报**：需要白名单（测试 fixture / 示例 key）

## 完成定义
- 16 项全部在 git log 中可追溯
- docs/STATUS.md 反映新基线
- docs/tasks.json 全部 done=true
- 本 plan 文件标记 [DONE]
