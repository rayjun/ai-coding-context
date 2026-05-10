# 决策 #23 · PreToolUse deny 格式全面升级

**日期**: 2026-04-27
**状态**: Adopted

## 背景

PreToolUse 上 `{decision:"deny"}` + `exit 2` 已被 Claude Code 文档标为 deprecated。新格式是 `hookSpecificOutput.permissionDecision`。

## 决策

- 新增共享 helper：`.claude/hooks/lib/pretool-response.sh#emit_pretool_deny`
- `careful-ops-check.sh` 和 `pre-commit-check.sh` 全部走新 API
- exit 0 + stdout JSON

JSON 形如：

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "..."
  }
}
```

## 影响

与未来 Claude Code 版本兼容；旧格式虽仍工作但文档已标废弃。已在真实 PreToolUse 拦截中验证生效。
