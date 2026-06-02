#!/bin/bash
# Hook: PostToolUse → Edit|Write
# Purpose: Remind to run plan-reviewer subagent after editing docs/plans/*.md.
# Non-blocking: stdout only, exit 0 always.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.file_path)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Match docs/plans/*.md (anywhere in the path, including absolute)
if ! echo "$FILE_PATH" | grep -qE '(^|/)docs/plans/[^/]+\.md$'; then
  exit 0
fi

# Extract just the docs/plans/<file>.md portion for cleaner output
PLAN_PATH=$(echo "$FILE_PATH" | grep -oE 'docs/plans/[^/]+\.md$')

cat <<EOF
Reminder: $PLAN_PATH 已更新。complex 任务进入第 4-5 步前，建议运行第 2 续步：
  Agent(subagent_type="plan-reviewer", prompt="Review $PLAN_PATH")
trivial / moderate 可在主上下文用 plan-review skill 直接审。
EOF

exit 0
