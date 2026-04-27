#!/bin/bash
# Hook: PostToolUse → Bash
# Purpose: Record evidence of a successful test/build/lint command so the
#          pre-commit gate can verify the working tree was tested.
#
# Signal source: Claude Code does NOT provide exit_code in tool_response for
# Bash. It provides {stdout, stderr, interrupted}. We heuristically treat a
# command as successful when `interrupted=false` AND stderr does not contain
# common failure markers. This is imperfect but matches the information
# available from the platform.
#
# To be extra safe, the pre-commit gate compares source mtime to evidence
# mtime — so even if a flaky command slips through, any post-test edit
# invalidates the evidence.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SESSION_DIR=$("$SCRIPT_DIR/lib/session-dir.sh")
EVIDENCE_FILE="$SESSION_DIR/test-evidence"

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.command)
INTERRUPTED=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_response.interrupted)
STDERR=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_response.stderr)
STDOUT=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_response.stdout)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# Skip if command was interrupted
if [ "$INTERRUPTED" = "true" ] || [ "$INTERRUPTED" = "True" ]; then
  exit 0
fi

# Refuse to record if the command is just an echo/printf with a test keyword.
# Anchored check avoids `echo "run cargo test later"` poisoning the evidence.
if echo "$COMMAND" | grep -qE '^[[:space:]]*(echo|printf|:)[[:space:]]'; then
  exit 0
fi

# Test / build / lint command detection (anchored to start or after ; / && / ||)
PATTERN='(^|[;&|]\s*)(cargo (test|build|check|clippy)|go (test|build|vet)|pytest|python -m pytest|npm (test|run build)|npx jest|yarn (test|build)|pnpm (test|build)|mvn (test|compile|package)|gradle (test|build)|make (test|build|check|all)|mix test|bundle exec rspec|dotnet (test|build)|php artisan test|phpunit|tsc --noEmit|golangci-lint|eslint|prettier|ruff|flake8|pylint|rubocop|shellcheck)\b'

if ! echo "$COMMAND" | grep -qiE "$PATTERN"; then
  exit 0
fi

# Heuristic failure detection in output. Tuned to avoid false positives like
# "0 failed" in a passing summary. Requires either all-caps FAILED/ERROR as
# a discrete marker, or a nonzero failure count, or a language-specific
# panic/compile marker.
COMBINED="${STDOUT}
${STDERR}"
FAIL_PATTERNS='(\bFAILED\b|\bFAIL\b|[1-9][0-9]* failed|[1-9][0-9]* failing|[1-9][0-9]* error|panic:|compilation error|build failed|lint errors?|^ERROR:|Error:\s+(\w+Error|compilation|test))'
if echo "$COMBINED" | grep -qE "$FAIL_PATTERNS"; then
  # Probable failure — don't record
  exit 0
fi

printf '%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$COMMAND" >> "$EVIDENCE_FILE"

exit 0
