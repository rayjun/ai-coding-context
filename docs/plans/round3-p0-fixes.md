# Round 3 P0 修复 (2026-05-10) [DONE]

**完成日期**: 2026-05-10
**结果**: 3/3 P0 项落地。

## 范围
P0 三项，对应 Round 3 review 的 #12 / #13 / #2。

## 实施

### #12 · Stop hook 顺序 bug（功能性 bug）
**症状**：`session-end.sh` 在末尾用 `rm -rf "$SESSION_DIR"` 清理临时文件；`assertion-audit.sh` 依赖该目录的 `test-evidence`。settings.json 里 session-end 排在 assertion-audit 之前 → assertion-audit 永远看到空 evidence → 永远误报。

**修法**：交换 settings.json 中 Stop 数组里两个 hook 的顺序（assertion-audit 先，session-end 后清理）。

### #13 · evidence session_id 隔离
**症状**：evidence 文件路径基于 PWD 的 md5（`session-dir.sh`），同一项目跨会话共享同一文件。如果 session-end 失败没清理（process killed / hook 超时），下次启动时 evidence 残留 → 没跑测试也能 commit。

**修法**：
- record-test-evidence.sh：从 stdin JSON 读 `session_id`，写入 `test-evidence.${SESSION_ID}` 文件
- pre-commit-check.sh：同样读 session_id，只比对当前会话的 evidence 文件
- session-end.sh：清理只删本会话的 evidence 文件，不再 rm 整个 SESSION_DIR

### #2 · STATUS.md 决策迁移到 docs/decisions/
**症状**：`status-writing-guide.md` 规定 STATUS.md 应"简洁直接、链接报告不复制内容"，但当前 STATUS.md 168 行，含 #22-#25 决策的完整 5-8 行详细叙述。自我违规。

**修法**：
- 新建 `docs/decisions/` 目录
- STATUS.md 中 #22-#25 各自迁出为 `docs/decisions/0022-record-evidence-heuristic.md` 等
- STATUS.md 决策记录 section 缩成索引（1 行/决策 + 链接）
- 旧决策 #1-#21 之前没全部留在 STATUS.md（散落各处），暂不一并迁移；新规则只对未来生效
- `.claude/rules/docs-maintenance.md` 新增"决策记录写到 docs/decisions/"规则
- README / status-writing-guide 同步说明

## 验证
- #12: settings.json 里 Stop 顺序改变；写一个临时 evidence 后跑一次模拟 stop 流程验证 audit 能看到
- #13: 自测两个不同 session_id 的 record / pre-commit；验证 cross-session 不互相干扰
- #2: 4 个 decisions 文件 + STATUS.md 缩到 < 100 行 + grep 决策索引仍能找到全部

## 风险
- #13 改完 record + pre-commit 后，如果 session_id 在某种 stdin 路径中拿不到（比如 PreToolUse Bash），需 fallback 到无后缀文件，否则破坏现有功能
- session-end 清理逻辑变窄，跨会话调试更容易看到上一会话的 evidence — 这是好事不是 bug

## 完成定义
- 4 + 1 = 5 个新文件（4 decisions + plan）
- 3 个 hook 修改（session-end / record-test-evidence / pre-commit-check）
- settings.json Stop 顺序对调
- STATUS.md 收缩
- docs-maintenance.md 新增决策外置规则
