#!/bin/bash
# Shared utility: extract a field from JSON piped via stdin.
# Usage: echo '{"tool_input":{"command":"ls"}}' | hooks/lib/json-extract.sh tool_input.command
# Uses python3 for robust parsing (handles escapes, multiline, nested fields).
# Falls back to basic grep if python3 unavailable.

set -euo pipefail

FIELD_PATH="${1:-}"
if [ -z "$FIELD_PATH" ]; then
  echo ""
  exit 0
fi

INPUT=$(cat)

if [ -z "$INPUT" ]; then
  echo ""
  exit 0
fi

# Primary: python3 (available on macOS and most Linux)
if command -v python3 &>/dev/null; then
  FIELD_PATH="$FIELD_PATH" python3 -c "
import json, sys, os
try:
    data = json.loads(sys.stdin.read())
    keys = os.environ['FIELD_PATH'].split('.')
    val = data
    for k in keys:
        if isinstance(val, dict):
            val = val.get(k, '')
        else:
            val = ''
            break
    print(val if isinstance(val, str) else json.dumps(val))
except Exception:
    print('')
" <<< "$INPUT"
  exit 0
fi

# Fallback: jq
if command -v jq &>/dev/null; then
  JQ_PATH=".$FIELD_PATH"
  echo "$INPUT" | jq -r "$JQ_PATH // empty" 2>/dev/null || echo ""
  exit 0
fi

# Last resort: grep (fragile, but better than nothing)
# Only handles simple single-line cases
LAST_KEY=$(echo "$FIELD_PATH" | rev | cut -d. -f1 | rev)
echo "$INPUT" | grep -o "\"${LAST_KEY}\"\s*:\s*\"[^\"]*\"" | head -1 | sed "s/\"${LAST_KEY}\"\s*:\s*\"//;s/\"$//" || echo ""
