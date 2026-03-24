---
paths:
  - ".claude/hooks/**/*.sh"
  - ".claude/hooks/lib/**"
---

# Hook 开发规则

- 所有 hook 脚本必须以 `set -euo pipefail` 开头。
- JSON 解析统一使用 `.claude/hooks/lib/json-extract.sh`，禁止 grep/sed 手写解析。
- 任务解析统一使用 `.claude/hooks/lib/task-summary.py`，禁止内联 Python。
- 临时文件必须通过 `.claude/hooks/lib/session-dir.sh` 获取项目隔离的目录，禁止直接写 `/tmp`。
- 外部输入（JSON 字段值）禁止拼接到 Python/AppleScript 字符串中，必须通过环境变量或 argv 传递。
- 计数器等状态文件使用原子写入（写 tmp + mv）。
- `echo -e` 不可移植，使用 `printf "%b"` 替代。
