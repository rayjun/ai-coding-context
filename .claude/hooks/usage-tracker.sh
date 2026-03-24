#!/bin/bash
# Status line script: track usage metrics per session.
# Receives rich JSON from Claude Code after each assistant message.
# Side effect: appends snapshot to docs/reports/usage-metrics.jsonl.
# Stdout: one-line status bar shown in terminal.

set -euo pipefail

INPUT=$(cat)

# Ensure report directory exists
mkdir -p docs/reports

# Append usage snapshot to JSONL log (only if we have cost data)
if command -v python3 &>/dev/null; then
  python3 -c "
import json, sys, time

data = json.loads(sys.stdin.read())
cost = data.get('cost', {})
ctx = data.get('context_window', {})
model = data.get('model', {})
session_id = data.get('session_id', 'unknown')

# Only log if we have actual data
if not ctx.get('total_input_tokens'):
    sys.exit(0)

record = {
    'timestamp': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
    'session_id': session_id,
    'model': model.get('display_name', 'unknown'),
    'total_input': ctx.get('total_input_tokens', 0),
    'total_output': ctx.get('total_output_tokens', 0),
    'cache_create': ctx.get('current_usage', {}).get('cache_creation_input_tokens', 0),
    'cache_read': ctx.get('current_usage', {}).get('cache_read_input_tokens', 0),
    'context_used_pct': ctx.get('used_percentage', 0),
    'cost_usd': cost.get('total_cost_usd', 0),
    'duration_ms': cost.get('total_duration_ms', 0),
}

with open('docs/reports/usage-metrics.jsonl', 'a') as f:
    f.write(json.dumps(record) + '\n')
" <<< "$INPUT" 2>/dev/null || true
fi

# Output status line for terminal display
if command -v python3 &>/dev/null; then
  python3 -c "
import json, sys

data = json.loads(sys.stdin.read())
model = data.get('model', {}).get('display_name', '?')
ctx = data.get('context_window', {})
cost = data.get('cost', {})

pct = int(ctx.get('used_percentage', 0))
in_tok = ctx.get('total_input_tokens', 0)
out_tok = ctx.get('total_output_tokens', 0)
usd = cost.get('total_cost_usd', 0)

in_k = f'{in_tok/1000:.1f}K' if in_tok >= 1000 else str(in_tok)
out_k = f'{out_tok/1000:.1f}K' if out_tok >= 1000 else str(out_tok)

print(f'[{model}] {pct}% ctx | {in_k}in/{out_k}out | \${usd:.4f}')
" <<< "$INPUT" 2>/dev/null || echo "[?] status unavailable"
else
  echo "[?] python3 not available"
fi
