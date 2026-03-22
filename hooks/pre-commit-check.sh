#!/bin/bash
# Hook: PreToolUse → Bash
# Purpose: Block git commit if no test/build/lint command was run in this session.
#
# Mechanism: Checks for a session marker file written by test commands.
# Files are scoped to project via hooks/lib/session-dir.sh.
#
# Exit codes:
#   0 = allow
#   2 = deny (no test evidence found)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SESSION_DIR=$("$SCRIPT_DIR/lib/session-dir.sh")
EVIDENCE_FILE="$SESSION_DIR/test-evidence"

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.command)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# --- Phase 1: Record test/build/lint execution ---
# Patterns are anchored: command must start with, or follow ;/&&/| before the test command.
# This prevents false matches like: echo "we should run cargo test later"

# Common test commands across languages
if echo "$COMMAND" | grep -qiE '(^|;|\&\&|\|\|?\s*)(cargo test|go test|pytest|python -m pytest|npm test|npx jest|yarn test|pnpm test|mvn test|gradle test|make test|mix test|bundle exec rspec|dotnet test|php artisan test|phpunit)\b'; then
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $COMMAND" >> "$EVIDENCE_FILE"
  exit 0
fi

# Common build commands
if echo "$COMMAND" | grep -qiE '(^|;|\&\&|\|\|?\s*)(cargo build|cargo check|go build|go vet|npm run build|yarn build|pnpm build|mvn compile|mvn package|gradle build|make build|make all|tsc --noEmit|dotnet build)\b'; then
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $COMMAND" >> "$EVIDENCE_FILE"
  exit 0
fi

# Common lint commands
if echo "$COMMAND" | grep -qiE '(^|;|\&\&|\|\|?\s*)(cargo clippy|golangci-lint|eslint|prettier|ruff|flake8|pylint|rubocop|shellcheck)\b'; then
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) $COMMAND" >> "$EVIDENCE_FILE"
  exit 0
fi

# --- Phase 2: Gate git commit ---

if echo "$COMMAND" | grep -qE '\bgit\s+commit\b'; then
  # Check for evidence file modified within last 2 hours
  if [ -f "$EVIDENCE_FILE" ]; then
    if [ "$(find "$EVIDENCE_FILE" -mmin -120 2>/dev/null)" ]; then
      exit 0
    fi
  fi

  # No evidence found — deny
  cat <<'EOF'
{"decision":"deny","reason":"No test/build/lint evidence found in this session. DEV.md Step 7 requires verification before commit.","alternative":"Run your project's test suite first (e.g., `cargo test`, `go test ./...`, `npm test`, `pytest`), then retry the commit."}
EOF
  exit 2
fi

# Not a git commit command, allow
exit 0
