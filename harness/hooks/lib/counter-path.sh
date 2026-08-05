#!/usr/bin/env bash
set -euo pipefail
# Shared helper: derive a session-scoped counter file path.
#
# Reads the hook JSON from stdin (passed as a positional arg via INPUT),
# extracts session_id, and returns:
#   $SESSION_DIR/<basename>.<short-id>
#
# If session_id is unavailable, falls back to the un-suffixed legacy path
# so behavior is non-breaking.
#
# Usage:
#   source "$SCRIPT_DIR/lib/counter-path.sh"
#   COUNTER_FILE=$(counter_path_for_input "$INPUT" "drift-counter")

# shellcheck shell=bash

counter_path_for_input() {
  local input="$1"
  local basename="$2"
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local session_dir
  session_dir=$("$script_dir/session-dir.sh")

  local session_id=""
  if [ -n "$input" ]; then
    session_id=$(printf '%s' "$input" | "$script_dir/json-extract.sh" session_id 2>/dev/null || true)
  fi

  if [ -n "$session_id" ]; then
    local short_id="${session_id:0:12}"
    printf '%s/%s.%s\n' "$session_dir" "$basename" "$short_id"
  else
    printf '%s/%s\n' "$session_dir" "$basename"
  fi
}
