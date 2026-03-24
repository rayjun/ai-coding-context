#!/usr/bin/env python3
# Shared utility: parse docs/tasks.json and output task summary.
# Modes (pass as first argument):
#   brief   — one-line: "[Tasks: 3/7] | Active: [T-004] title"
#   full    — multi-line: progress + current + next + notes
#   check   — only output if tasks are in_progress (for session-end warnings)

import json, sys, os

MODE = sys.argv[1] if len(sys.argv) > 1 else "brief"
TASKS_FILE = "docs/tasks.json"

if not os.path.isfile(TASKS_FILE):
    sys.exit(0)

try:
    with open(TASKS_FILE) as f:
        data = json.load(f)
except Exception:
    sys.exit(0)

tasks = data.get("tasks", [])
total = len(tasks)
done = sum(1 for t in tasks if t.get("done", False))
in_prog = [t for t in tasks if t.get("status") == "in_progress"]
pending = [t for t in tasks if not t.get("done", False) and t.get("status") != "in_progress"]

if MODE == "brief":
    parts = [f"[Tasks: {done}/{total}]"]
    if in_prog:
        parts.append(f'Active: [{in_prog[0]["id"]}] {in_prog[0]["title"]}')
    elif pending:
        parts.append(f'Next: [{pending[0]["id"]}] {pending[0]["title"]}')
    print(" | ".join(parts))

elif MODE == "full":
    print(f"Tasks: {done}/{total} completed")
    if in_prog:
        t = in_prog[0]
        print(f'Current: [{t["id"]}] {t["title"]}')
        if t.get("notes"):
            print(f'  Notes: {t["notes"]}')
    if pending:
        print(f'Next: [{pending[0]["id"]}] {pending[0]["title"]}')
    elif total > 0 and not in_prog:
        print("All tasks completed!")

elif MODE == "check":
    if in_prog:
        ids = ", ".join(t["id"] for t in in_prog)
        print(f"Tasks still in_progress (may need status update): {ids}")
