# 决策 #22 · record-test-evidence 改用 stdout 启发式

**日期**: 2026-04-27
**状态**: Adopted

## 背景

官方 PostToolUse Bash schema 不含 `exit_code`；之前 `record-test-evidence.sh` 设计依赖的字段根本不存在。实测 JSON 结构为：

```json
{
  "session_id": "...",
  "tool_name": "Bash",
  "tool_input": {"command": "...", "description": "..."},
  "tool_response": {
    "stdout": "...",
    "stderr": "...",
    "interrupted": false,
    "isImage": false,
    "noOutputExpected": false
  },
  "tool_use_id": "..."
}
```

## 决策

用 `interrupted=false` + 输出中无 `FAILED/ERROR/panic/build failed/lint errors` 标记作为"成功"启发式。继续由 pre-commit gate 的 mtime 比对作为第二道关卡。

## 影响

可能少量误判（比如故意输出 `Error:` 作为正常文本的命令），但 mtime 机制能兜底。命令真失败时 stdout/stderr 一般会含 `FAIL`/`ERROR` 等标志词。
