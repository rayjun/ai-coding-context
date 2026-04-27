---
paths:
  - ".claude/hooks/**/*.sh"
  - ".claude/hooks/lib/**"
---

# Hook 开发规则

> 本文件由 Claude Code 的 `.claude/rules/` 原生机制加载；编辑上述 `paths` 匹配的文件时自动注入上下文。

- 所有 hook 脚本必须以 `set -euo pipefail` 开头。
- JSON 解析统一使用 `.claude/hooks/lib/json-extract.sh`，禁止 grep/sed 手写解析。
- 任务解析统一使用 `.claude/hooks/lib/task-summary.py`，禁止内联 Python。
- 危险命令检测统一来自 `.claude/hooks/lib/danger-patterns.sh`，禁止在 hook 里各自写 regex。修改后跑 `.test.sh`。
- PreToolUse 的 deny 响应统一通过 `.claude/hooks/lib/pretool-response.sh` 的 `emit_pretool_deny` 发射（hookSpecificOutput 格式，非 deprecated 的 `{"decision":"deny"}`）。
- 临时文件必须通过 `.claude/hooks/lib/session-dir.sh` 获取项目隔离的目录，禁止直接写 `/tmp`。
- 外部输入（JSON 字段值）禁止拼接到 Python/AppleScript 字符串中，必须通过环境变量或 argv 传递。
- 计数器等状态文件使用原子写入（写 tmp + mv）。
- `echo -e` 不可移植，使用 `printf "%b"` 替代。
- Bash 工具的 PostToolUse JSON **不含 `exit_code`**。可用字段：`tool_response.stdout / stderr / interrupted`。用输出内容的启发式判断（FAIL/ERROR/panic 等）代替 exit code。
- 新增 hook 后必须同步更新 `.claude/settings.json`、`.gemini/settings.json` 和 `install.sh` 的 CORE_FILES 清单。

- 所有 hook 脚本必须以 `set -euo pipefail` 开头。
- JSON 解析统一使用 `.claude/hooks/lib/json-extract.sh`，禁止 grep/sed 手写解析。
- 任务解析统一使用 `.claude/hooks/lib/task-summary.py`，禁止内联 Python。
- 临时文件必须通过 `.claude/hooks/lib/session-dir.sh` 获取项目隔离的目录，禁止直接写 `/tmp`。
- 外部输入（JSON 字段值）禁止拼接到 Python/AppleScript 字符串中，必须通过环境变量或 argv 传递。
- 计数器等状态文件使用原子写入（写 tmp + mv）。
- `echo -e` 不可移植，使用 `printf "%b"` 替代。
