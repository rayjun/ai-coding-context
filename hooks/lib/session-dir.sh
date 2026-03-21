#!/bin/bash
# Shared utility: return a session-scoped directory for temporary files.
# Isolates by project path so parallel sessions on different projects don't collide.
# Usage: SESSION_DIR=$(hooks/lib/session-dir.sh)

set -euo pipefail

PROJECT_HASH=$(echo "$PWD" | md5sum 2>/dev/null | cut -c1-8 || echo "$PWD" | md5 2>/dev/null | cut -c1-8 || echo "default")
SESSION_DIR="/tmp/claude-hooks/${PROJECT_HASH}"
mkdir -p "$SESSION_DIR"
echo "$SESSION_DIR"
