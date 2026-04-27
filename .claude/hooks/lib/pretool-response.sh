#!/bin/bash
# Shared helper: emit the Claude Code PreToolUse deny response.
# Uses the current (non-deprecated) hookSpecificOutput format.
# See: https://code.claude.com/docs/en/hooks
#
# Usage:
#   emit_pretool_deny "Reason shown to the user"
# The helper writes the JSON to stdout; caller should exit 0 after it.

# shellcheck shell=bash

emit_pretool_deny() {
  local reason="$1"
  REASON="$reason" python3 - <<'PY'
import json, os
print(json.dumps({
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": os.environ["REASON"],
  }
}))
PY
}
