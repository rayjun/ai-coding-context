# Lessons Learned

> **示例文件**：自 2026-04-27 创建以来本仓库未追加任何 lesson（retro-writer subagent 0 触发）。保留作为「会话经验沉淀」的设计模式示范，fork 用户可启用 retro-writer 或手工追加。
>
> 本文件由 `retro-writer` subagent 维护（也可手工追加）。**追加式**记录会话中发现的认知修正、工具陷阱、流程教训。
>
> 目的：让经验沉淀可被未来 `SessionStart` hook 注入，避免重复踩坑。

## 写作格式

每条 lesson 三段式 + 元数据：

```markdown
### YYYY-MM-DD · [类别] 一句话标题

- **以为**：（之前的错误认知）
- **实际**：（实际情况是什么）
- **教训**：（下次怎么做）
- 相关：[commit hash | decisions/00NN-*.md | plans/*.md]（可选）
```

类别：`流程` / `工具` / `认知` / `环境` / `API` / `安全`

---

## 流程

### 2026-05-10 · [流程] Stop hook 顺序决定 audit 是否能看到 evidence

- **以为**：Stop 数组里 hook 顺序无所谓，反正都会跑。
- **实际**：`session-end.sh` 里 `rm -rf SESSION_DIR` 在 `assertion-audit.sh` 前面跑，audit 永远看到空 evidence → 永远误报。
- **教训**：清理类 hook 必须排最后；任何依赖临时文件的 hook 必须排在清理之前。settings.json 数组顺序是协议的一部分。
- 相关：`docs/decisions/0023-pretool-deny-format.md`、Round 3 P0 #12

### 2026-05-10 · [流程] settings.json hooks 在会话内修改不会重载

- **以为**：改完 settings.json 立刻生效，可以在同一会话验证。
- **实际**：Claude Code 启动后才加载 hooks，本会话内的修改要下次启动才生效。
- **教训**：验证 hook 修改要么用真实 stdin payload 模拟（直接跑脚本），要么重启会话。修完不要在原会话里假装"测过了"。
- 相关：Round 3 P0 总结

---

## 工具

### 2026-05-10 · [工具] PostToolUse Bash JSON 没有 exit_code 字段

- **以为**：Bash 工具的 PostToolUse 输入 JSON 像 shell 一样含 `exit_code`，可以靠它判断成功失败。
- **实际**：实际 schema 只有 `tool_response.{stdout, stderr, interrupted, isImage, noOutputExpected}`，**没有 exit_code**。
- **教训**：判断 Bash 命令成败要用启发式（找 FAILED / ERROR / panic / 测试通过等关键词），别等 exit code。同时也意味着 PostToolUse 不能区分"非 0 退出但无关键词"和"成功"。
- 相关：`docs/decisions/0022-record-evidence-heuristic.md`

---

## 认知

（待第一条）

---

## 环境

（待第一条）

---

## API

### 2026-05-10 · [API] PreToolUse deny 必须用 hookSpecificOutput 格式

- **以为**：返回 `{"decision":"deny", "reason":"..."}` + exit 2 就能拦截。
- **实际**：那是已 deprecated 的旧格式。新格式是 `{"hookSpecificOutput": {"hookEventName":"PreToolUse", "permissionDecision":"deny", "permissionDecisionReason":"..."}}`。
- **教训**：deny 响应必须走 `lib/pretool-response.sh` 的 `emit_pretool_deny`，禁止手写 JSON。Round 2 之前的旧 hook 全部需要改造。
- 相关：`docs/decisions/0023-pretool-deny-format.md`

---

## 安全

（待第一条）
