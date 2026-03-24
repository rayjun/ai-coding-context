#!/bin/bash
# Shared utility: return a session-scoped directory for temporary files.
# Isolates by project path so parallel sessions on different projects don't collide.
# Usage: SESSION_DIR=$(hooks/lib/session-dir.sh)

set -euo pipefail

# md5sum (Linux) outputs: "<hash>  -"
# md5 -q (macOS) outputs: "<hash>"
PROJECT_HASH=$(printf '%s' "$PWD" | md5sum 2>/dev/null | cut -c1-8) || \
PROJECT_HASH=$(printf '%s' "$PWD" | md5 -q 2>/dev/null | cut -c1-8) || \
PROJECT_HASH="default"

SESSION_DIR="/tmp/claude-hooks/${PROJECT_HASH}"
mkdir -p "$SESSION_DIR"
echo "$SESSION_DIR"
