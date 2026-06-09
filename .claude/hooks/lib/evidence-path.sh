#!/usr/bin/env bash
set -euo pipefail
# Shared helper: derive the session-scoped evidence file path.
#
# Reads the hook JSON from stdin (passed as a positional arg via INPUT),
# extracts session_id, and returns:
#   $SESSION_DIR/test-evidence.<short-id>
#
# If session_id is unavailable (rare; older hook versions or non-hook callers),
# falls back to the un-suffixed legacy path so behavior is non-breaking.
#
# Usage:
#   SCRIPT_DIR=...
#   source "$SCRIPT_DIR/lib/evidence-path.sh"
#   EVIDENCE_FILE=$(evidence_path_for_input "$INPUT")

# shellcheck shell=bash

evidence_path_for_input() {
  local input="$1"
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local session_dir
  if [ -n "${HERMES_HOOK_EVIDENCE_DIR:-}" ]; then
    session_dir="$HERMES_HOOK_EVIDENCE_DIR"
  else
    session_dir=$("$script_dir/session-dir.sh")
  fi

  local session_id=""
  if [ -n "$input" ]; then
    session_id=$(printf '%s' "$input" | "$script_dir/json-extract.sh" session_id 2>/dev/null || true)
  fi

  if [ -n "$session_id" ]; then
    # Short id: first 12 chars of the UUID-like session_id
    local short_id="${session_id:0:12}"
    printf '%s/test-evidence.%s\n' "$session_dir" "$short_id"
  else
    # Legacy fallback for callers without session_id in stdin
    printf '%s/test-evidence\n' "$session_dir"
  fi
}
