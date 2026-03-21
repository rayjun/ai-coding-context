#!/bin/bash
# Hook: PostToolUse → Edit|Write
# Purpose: After docs/tasks.json is edited, validate its structure.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.file_path)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

if ! echo "$FILE_PATH" | grep -qE '(^|/)docs/tasks\.json$'; then
  exit 0
fi

if [ ! -f "docs/tasks.json" ]; then
  exit 0
fi

python3 -c "
import json, sys

try:
    with open('docs/tasks.json') as f:
        data = json.load(f)
except json.JSONDecodeError as e:
    print(f'ERROR: docs/tasks.json is not valid JSON: {e}')
    sys.exit(0)

errors = []
warnings = []

if 'tasks' not in data:
    errors.append('Missing top-level \"tasks\" array')
elif not isinstance(data['tasks'], list):
    errors.append('\"tasks\" must be an array')
else:
    for i, task in enumerate(data['tasks']):
        prefix = f'Task [{i}]'
        if 'id' not in task:
            errors.append(f'{prefix}: missing \"id\"')
        if 'title' not in task:
            errors.append(f'{prefix}: missing \"title\"')
        if 'done' not in task:
            errors.append(f'{prefix}: missing \"done\" (boolean)')
        if 'status' not in task:
            errors.append(f'{prefix}: missing \"status\"')
        elif task['status'] not in ('pending', 'in_progress', 'done', 'blocked'):
            warnings.append(f'{prefix}: unexpected status \"{task[\"status\"]}\"')

        if task.get('done') and task.get('status') != 'done':
            warnings.append(f'{prefix}: done=true but status=\"{task.get(\"status\")}\"')
        if not task.get('done') and task.get('status') == 'done':
            warnings.append(f'{prefix}: status=\"done\" but done=false')

    total = len(data['tasks'])
    completed = sum(1 for t in data['tasks'] if t.get('done'))
    pending = [t for t in data['tasks'] if not t.get('done')]

    if not errors:
        print(f'tasks.json valid: {completed}/{total} completed.')
        if pending:
            print(f'Next task: [{pending[0][\"id\"]}] {pending[0][\"title\"]}')

if errors:
    print('tasks.json validation ERRORS:')
    for e in errors:
        print(f'  - {e}')

if warnings:
    print('tasks.json warnings:')
    for w in warnings:
        print(f'  - {w}')
" 2>/dev/null || echo "(python3 not available for tasks.json validation)"

exit 0
