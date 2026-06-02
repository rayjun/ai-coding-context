# Round 10 P0 — 流程强制度提升 (2026-06-02) [DONE]

**完成日期**: 2026-06-02
**复杂度**: moderate
**目标**: §6 流程的两条 P2 待办落地——plan-reviewer 软提醒 + tasks.json `spec_id` 字段。
**架构**: 复用现有 `post-edit-dispatch.sh` dispatcher + 现有 `tasks-validate.sh`，零新顶层 hook 注册、零新 fork-exec。
**Tech Stack**: Bash 4+, Python 3 (随系统), 现有 hook 库 `lib/json-extract.sh`。

---

## 范围

### P0-1 — plan-reviewer 软提醒 hook

**触发点**：`post-edit-dispatch.sh` 新增第 4 分支，匹配 `docs/plans/*.md`。

**行为**：写完计划文件 → stdout 输出一行 system-reminder 文本，告知第 2 续步可调用 `plan-reviewer` subagent。**不阻断**，纯提示。

**对齐**：与现有 `status-reminder.sh` 同模式（无 stderr、永远 exit 0）。

### P0-2 — tasks.json `spec_id` 字段

**schema**：每个 task 可选 `spec_id`（字符串），值约定为 `docs/plans/<file>.md`。

**校验**（增量补到 `tasks-validate.sh` 内 Python 块）：
- 字段缺失 → 静默
- 字段存在但非 string → warning
- 字段存在但路径不以 `docs/plans/` 开头 → warning（提示约定，留弹性）
- 字段存在但目标文件不存在 → warning

**存量保护**：18 个历史 task 不回填，新建任务可选添加。

### 不做的事

- 不动 settings.json 注册项，复用 `post-edit-dispatch.sh` dispatcher
- 不引入 commit 门禁、不加拦截 hook
- 不强制回填历史 task 的 spec_id
- 不引入 `docs/specs/<id>` 路径，与决策 #0027 保持一致

---

## 文件结构

| 文件 | 类型 | 责任 |
|------|------|------|
| `.claude/hooks/plan-review-reminder.sh` | 新建 | 检测 `docs/plans/*.md` 编辑 → 输出 plan-reviewer 提醒 |
| `.claude/hooks/plan-review-reminder.test.sh` | 新建 | 单测：路径匹配 / 不匹配两组 fixture |
| `.claude/hooks/post-edit-dispatch.sh` | 改 | 新增第 4 分支调用 plan-review-reminder.sh |
| `.claude/hooks/tasks-validate.sh` | 改 | Python 校验块加 `spec_id` 检查（4 分支） |
| `AGENTS.md` | 改 | §6 第 2 步 / 第 2 续步行末加注，标明 hook 提醒 + 字段约定 |
| `docs/decisions/0037-round10-flow-rigor.md` | 新建 | 记录"软提醒/可选"边界与取舍 |
| `docs/STATUS.md` | 改 | 当前目标 + 下次从这里开始 |
| `docs/tasks.json` | 改 | 加 T-035 任务记录，本任务自身 spec_id 指向本 plan |

---

## Task 1：新建 plan-review-reminder hook 与单测

**Files:**
- Create: `.claude/hooks/plan-review-reminder.sh`
- Create: `.claude/hooks/plan-review-reminder.test.sh`

- [ ] **Step 1: 写测试驱动器（先红）**

`.claude/hooks/plan-review-reminder.test.sh`:

```bash
#!/bin/bash
# Unit tests for .claude/hooks/plan-review-reminder.sh
# Run: bash .claude/hooks/plan-review-reminder.test.sh
set +e

SCRIPT="$(cd "$(dirname "$0")" && pwd)/plan-review-reminder.sh"

fail=0
run() {
  local label="$1" file_path="$2" expect_match="$3"
  local input out
  input=$(printf '{"tool_input":{"file_path":"%s"}}' "$file_path")
  out=$(echo "$input" | bash "$SCRIPT" 2>&1)
  if [ -z "$expect_match" ]; then
    if [ -z "$out" ]; then
      printf 'PASS  %-50s -> silent\n' "$label"
    else
      printf 'FAIL  %-50s expected=silent got=%s\n' "$label" "$out"
      fail=1
    fi
  else
    if echo "$out" | grep -q "$expect_match"; then
      printf 'PASS  %-50s -> matched %s\n' "$label" "$expect_match"
    else
      printf 'FAIL  %-50s expected=%s got=%s\n' "$label" "$expect_match" "$out"
      fail=1
    fi
  fi
}

run "plan file triggers reminder"   "docs/plans/round10-p0.md"  "plan-reviewer"
run "absolute plan path"            "/repo/docs/plans/x.md"     "plan-reviewer"
run "non-plan md silent"            "docs/STATUS.md"            ""
run "source file silent"            ".claude/hooks/foo.sh"      ""
run "empty path silent"             ""                          ""
run "plan without md silent"        "docs/plans/notes.txt"      ""

if [ "$fail" -eq 0 ]; then
  echo "All plan-review-reminder tests PASS"
else
  echo "FAIL: plan-review-reminder tests"
  exit 1
fi
```

- [ ] **Step 2: 跑测试确认全 FAIL（脚本不存在）**

```bash
bash .claude/hooks/plan-review-reminder.test.sh
```

期望：所有 PASS 行变 FAIL，因为 `plan-review-reminder.sh` 不存在 bash 会报错。OK，可以进 Step 3。

- [ ] **Step 3: 写最小实现**

`.claude/hooks/plan-review-reminder.sh`:

```bash
#!/bin/bash
# Hook: PostToolUse → Edit|Write
# Purpose: Remind to run plan-reviewer subagent after editing docs/plans/*.md.
# Non-blocking: stdout only, exit 0 always.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | "$SCRIPT_DIR/lib/json-extract.sh" tool_input.file_path)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Match docs/plans/*.md (anywhere in the path, including absolute)
if ! echo "$FILE_PATH" | grep -qE '(^|/)docs/plans/[^/]+\.md$'; then
  exit 0
fi

# Extract just the docs/plans/<file>.md portion for cleaner output
PLAN_PATH=$(echo "$FILE_PATH" | grep -oE 'docs/plans/[^/]+\.md$')

cat <<EOF
Reminder: $PLAN_PATH 已更新。complex 任务进入第 4-5 步前，建议运行第 2 续步：
  Agent(subagent_type="plan-reviewer", prompt="Review $PLAN_PATH")
trivial / moderate 可在主上下文用 plan-review skill 直接审。
EOF

exit 0
```

```bash
chmod +x .claude/hooks/plan-review-reminder.sh
chmod +x .claude/hooks/plan-review-reminder.test.sh
```

- [ ] **Step 4: 跑测试确认全 PASS**

```bash
bash .claude/hooks/plan-review-reminder.test.sh
```

期望输出（6 个 PASS）：
```
PASS  plan file triggers reminder                        -> matched plan-reviewer
PASS  absolute plan path                                 -> matched plan-reviewer
PASS  non-plan md silent                                 -> silent
PASS  source file silent                                 -> silent
PASS  empty path silent                                  -> silent
PASS  plan without md silent                             -> silent
All plan-review-reminder tests PASS
```

- [ ] **Step 5: 提交**

```bash
git add .claude/hooks/plan-review-reminder.sh .claude/hooks/plan-review-reminder.test.sh
git commit -m "feat(hooks): add plan-review-reminder hook + tests"
```

---

## Task 2：把 plan-review-reminder 接入 dispatcher

**Files:**
- Modify: `.claude/hooks/post-edit-dispatch.sh` — 末尾加第 4 分支

- [ ] **Step 1: 读现状确认 dispatcher 末尾结构**

```bash
tail -10 .claude/hooks/post-edit-dispatch.sh
```

期望最后两行是 `run_with_input "$SCRIPT_DIR/status-reminder.sh"` 和 `exit 0`。

- [ ] **Step 2: 在 status-reminder 之后、`exit 0` 之前，新增第 4 分支**

把这段：

```bash
# 3. STATUS.md update reminder — fires when source files (non-docs) are edited
run_with_input "$SCRIPT_DIR/status-reminder.sh"

exit 0
```

替换成：

```bash
# 3. STATUS.md update reminder — fires when source files (non-docs) are edited
run_with_input "$SCRIPT_DIR/status-reminder.sh"

# 4. plan-review reminder — only fires when docs/plans/*.md edited
if [ -n "$FILE_PATH" ] && echo "$FILE_PATH" | grep -qE '(^|/)docs/plans/[^/]+\.md$'; then
  run_with_input "$SCRIPT_DIR/plan-review-reminder.sh"
fi

exit 0
```

- [ ] **Step 3: 手动验证 dispatcher 路径分发**

```bash
echo '{"tool_input":{"file_path":"docs/plans/test-stub.md"}}' \
  | bash .claude/hooks/post-edit-dispatch.sh
```

期望：输出包含 `plan-reviewer` 字样。

```bash
echo '{"tool_input":{"file_path":"AGENTS.md"}}' \
  | bash .claude/hooks/post-edit-dispatch.sh
```

期望：不包含 `plan-reviewer` 字样（其他 reminder 可能出现，是正常的）。

- [ ] **Step 4: 提交**

```bash
git add .claude/hooks/post-edit-dispatch.sh
git commit -m "feat(hooks): dispatch plan-review-reminder for docs/plans edits"
```

---

## Task 3：tasks-validate 加 spec_id 校验

**Files:**
- Modify: `.claude/hooks/tasks-validate.sh` — Python 块内每个 task 循环里加 4 条 spec_id 检查

- [ ] **Step 1: 准备三个 fixture 文件用于本任务的端到端验证**

```bash
mkdir -p /tmp/round10-fixtures
cat > /tmp/round10-fixtures/no-spec.json <<'EOF'
{"tasks":[{"id":"T-1","title":"x","done":false,"status":"pending"}]}
EOF
cat > /tmp/round10-fixtures/good-spec.json <<'EOF'
{"tasks":[{"id":"T-1","title":"x","done":false,"status":"pending","spec_id":"docs/plans/round10-p0-flow-rigor.md"}]}
EOF
cat > /tmp/round10-fixtures/bad-string-spec.json <<'EOF'
{"tasks":[{"id":"T-1","title":"x","done":false,"status":"pending","spec_id":123}]}
EOF
cat > /tmp/round10-fixtures/wrong-prefix-spec.json <<'EOF'
{"tasks":[{"id":"T-1","title":"x","done":false,"status":"pending","spec_id":"docs/elsewhere/x.md"}]}
EOF
cat > /tmp/round10-fixtures/missing-target-spec.json <<'EOF'
{"tasks":[{"id":"T-1","title":"x","done":false,"status":"pending","spec_id":"docs/plans/does-not-exist.md"}]}
EOF
```

- [ ] **Step 2: 修改 tasks-validate.sh 的 Python 校验块**

在文件中找到这段（约第 50 行附近）：

```python
        if task.get('done') and task.get('status') != 'done':
            warnings.append(f'{prefix}: done=true but status=\"{task.get(\"status\")}\"')
        if not task.get('done') and task.get('status') == 'done':
            warnings.append(f'{prefix}: status=\"done\" but done=false')
```

紧接着这一段后面、循环体内，加 spec_id 校验：

```python
        if 'spec_id' in task:
            sid = task['spec_id']
            if not isinstance(sid, str):
                warnings.append(f'{prefix}: spec_id must be string, got {type(sid).__name__}')
            elif not sid.startswith('docs/plans/'):
                warnings.append(f'{prefix}: spec_id should start with \"docs/plans/\" (got \"{sid}\")')
            elif not __import__('os').path.exists(sid):
                warnings.append(f'{prefix}: spec_id target not found: {sid}')
```

> 用 `__import__('os')` 是为了避免在文件顶部 import 区域改动——hook 脚本里 Python 是嵌入在 bash heredoc 里的，影响范围最小。

- [ ] **Step 3: 用 fixture 跑校验**

```bash
for f in no-spec good-spec bad-string-spec wrong-prefix-spec missing-target-spec; do
  echo "=== $f ==="
  echo '{"tool_input":{"file_path":"docs/tasks.json"}}' \
    | (cd /tmp/round10-fixtures && cp $f.json docs-tasks-tmp.json && \
       mkdir -p docs && cp $f.json docs/tasks.json && \
       bash "$OLDPWD/.claude/hooks/tasks-validate.sh"; \
       rm -rf docs docs-tasks-tmp.json)
done
```

> 这段 fixture 跑法因为 hook 写死读 `docs/tasks.json`，需要 cd 到 fixture 目录构造同名文件。也可以临时改用 cat 直接喂 stdin 的简化版本——但保留这段以确保和真实路径一致。

期望：
- `no-spec` → `tasks.json valid: 0/1 completed.`，无 spec_id warning
- `good-spec` → 同上，无 spec_id warning（指向本 plan 文件，本任务执行时已存在）
- `bad-string-spec` → warning 含 `spec_id must be string`
- `wrong-prefix-spec` → warning 含 `should start with "docs/plans/"`
- `missing-target-spec` → warning 含 `spec_id target not found`

- [ ] **Step 4: 清理 fixture**

```bash
rm -rf /tmp/round10-fixtures
```

- [ ] **Step 5: 提交**

```bash
git add .claude/hooks/tasks-validate.sh
git commit -m "feat(hooks): validate optional spec_id field in tasks.json"
```

---

## Task 4：AGENTS.md §6 行末加注

**Files:**
- Modify: `AGENTS.md` — §6 表格行 2 / 2续 行末加备注；流程规则末尾不动

- [ ] **Step 1: 找到 §6 当前表格**

```bash
grep -n '^| 2 ' AGENTS.md
grep -n '2续' AGENTS.md
```

定位「制定计划」「架构审查」两行。

- [ ] **Step 2: 修改第 2 行（writing-plans）**

把：

```markdown
| 2 | 制定计划 | writing-plans ★ | 产出计划文件（`docs/plans/`）+ 创建/更新 `docs/tasks.json` |
```

改为：

```markdown
| 2 | 制定计划 | writing-plans ★ | 产出计划文件（`docs/plans/`）+ 创建/更新 `docs/tasks.json`（可选 `spec_id` 指向计划文件） |
```

- [ ] **Step 3: 修改第 2 续行（plan-review）**

把：

```markdown
| 2续 | 架构审查 | plan-review | 5 维度 pass/warn/fail，complex 级别必做 |
```

改为：

```markdown
| 2续 | 架构审查 | plan-review | 5 维度 pass/warn/fail，complex 级别必做（计划保存后 hook 会提醒） |
```

- [ ] **Step 4: 提交**

```bash
git add AGENTS.md
git commit -m "docs(agents): note plan-review hook reminder + tasks.json spec_id"
```

---

## Task 5：决策记录 #0037

**Files:**
- Create: `docs/decisions/0037-round10-flow-rigor.md`

- [ ] **Step 1: 看 0036 决策格式对齐文风**

```bash
head -30 docs/decisions/0036-round9-runtime-surface.md
```

- [ ] **Step 2: 写决策档**

`docs/decisions/0037-round10-flow-rigor.md`:

```markdown
# 0037 · Round 10 P0 — 流程强制度提升

**日期**: 2026-06-02
**状态**: accepted
**相关**: AGENTS.md §6, plan-reviewer agent (R4 P0 引入), tasks.json schema

## 背景

§6 流程的两条 P2 待办：
1. plan-reviewer 接入第 2 续步「强制触发」（来自 R4 后续）。
2. tasks.json 加 `spec_id` 字段（来自 R4 后续）。

R4 P0 引入 plan-reviewer agent 后 33+ 天 0 触发——本仓库 complex 任务也直接在主上下文用 plan-review skill 解决。文档措辞是「推荐」，没有 runtime 提示，等于隐形。tasks.json 没有 spec_id，task 与 plan 之间靠人脑映射。

## 决策

**A · plan-reviewer 走"软提醒"，不上拦截门禁。**

复用 `post-edit-dispatch.sh` dispatcher 加第 4 分支，匹配 `docs/plans/*.md` 编辑时输出一行 reminder。零额外 fork-exec、零阻断。

不上 commit 门禁（候选方案）的理由：
- 本仓库 trivial / moderate 任务也写 plan，但不一定需要 plan-reviewer（用 plan-review skill 即可）。commit 门禁会误伤。
- 软提醒 = 让 agent 看见，让用户决策，不剥夺判断空间。

**B · `spec_id` 走"可选 + 提醒"，不强制回填。**

schema：每个 task 可选 `spec_id`（字符串，约定 `docs/plans/<file>.md`）。
校验：字段存在时检查类型 / 路径前缀 / 文件存在；缺失静默。

不强制（候选方案）的理由：
- 18 个历史 task 跨多轮，部分已完成，回填成本高、价值低。
- trivial 任务可能没有 plan 文件，强制 = 鼓励造空 plan。

**约定 spec_id = `docs/plans/*.md`（不是 `docs/specs/*`）**：
- 决策 #0027 已把 `docs/specs/` 标为可选，本仓库未采用。
- 第 2 步 writing-plans 已经必出 plan 文件，spec_id 直接指 plan 路径，零新资产。

## 后果

**正面**：
- plan 文件写完即获 reminder，第 2 续步从「文档约定」进入 runtime。
- task ↔ plan 可追溯，回看历史进度更快。
- 零新 hook 注册（接到现有 dispatcher），不增加 fork-exec。

**负面 / 取舍**：
- 软提醒可被忽略——这是有意为之，强制成本 > 收益。
- spec_id 可选 = 字段填充率会参差，但符合"trivial 不必有 plan"的现实。
- spec_id 路径前缀写死 `docs/plans/`——fork 用户若用 `docs/specs/` 需改 hook（warning 而非 error 已留弹性）。

## 不做

- 不引入 commit 门禁拦截 plan-reviewer。
- 不强制回填历史 task 的 spec_id。
- 不引入 `docs/specs/<id>` 路径，与 #0027 保持一致。
```

- [ ] **Step 3: 提交**

```bash
git add docs/decisions/0037-round10-flow-rigor.md
git commit -m "docs(decisions): record 0037 round10 P0 flow rigor"
```

---

## Task 6：tasks.json 加 T-035 + STATUS.md 更新

**Files:**
- Modify: `docs/tasks.json` — 加新 task，spec_id 指向本 plan
- Modify: `docs/STATUS.md` — 当前目标 / 下次从这里开始

- [ ] **Step 1: 看 tasks.json 末尾结构**

```bash
python3 -c "import json; d=json.load(open('docs/tasks.json')); print(d['tasks'][-1])"
```

- [ ] **Step 2: 加 T-035**

在 `docs/tasks.json` 的 `tasks` 数组末尾加一条（保留原有 task 不动）：

```json
{
  "id": "T-035",
  "title": "Round10-P0: plan-reviewer 软提醒 + tasks.json spec_id",
  "status": "in_progress",
  "blocked_by": [],
  "notes": "见 docs/plans/round10-p0-flow-rigor.md",
  "done": false,
  "spec_id": "docs/plans/round10-p0-flow-rigor.md"
}
```

也更新顶部 `updated_at` 字段为 `"2026-06-02"`。

- [ ] **Step 3: 验证 tasks.json 通过校验**

```bash
echo '{"tool_input":{"file_path":"docs/tasks.json"}}' \
  | bash .claude/hooks/tasks-validate.sh
```

期望：`tasks.json valid: 18/19 completed.` 且无 warning。

- [ ] **Step 4: 更新 STATUS.md**

把「当前目标」段落替换为：

```markdown
## 当前目标
Round 10 P0：(1) plan-reviewer 软提醒 hook（post-edit-dispatch 第 4 分支，匹配 `docs/plans/*.md`）；(2) tasks.json 加可选 `spec_id` 字段，tasks-validate 校验类型 / 路径前缀 / 目标存在。零新 hook 注册、零阻断。
**参考**: `docs/plans/round10-p0-flow-rigor.md`、`docs/decisions/0037-round10-flow-rigor.md`
```

把「下次从这里开始」的恢复上下文与继续工作段落更新（保留历史块）：

```markdown
## 下次从这里开始

### 恢复上下文

\`\`\`bash
python3 .claude/hooks/lib/task-summary.py full        # 任务进度 28/28 (R10 P0 完成后)
bash .claude/hooks/lib/danger-patterns.test.sh        # 25/25 PASS
bash .claude/hooks/plan-review-reminder.test.sh       # 6/6 PASS
ls docs/decisions/                                    # 决策档案 #22-#37
\`\`\`

### 继续工作

Round 10 P0 已完成。剩余待办（按优先级）：

- **P1（来自 Round 3 review 遗留）**：CLAUDE.md 精简 / AGENTS.md §0 去 Ray 化 / EVAL schema 文档化 / onboarding.md
- **P1（Round 4 中 ROI 项）**：statusline 脚本 / token 预算 hook / output-styles 分场景输出
- **P2（来自 Round 3 review 遗留）**：hooks 集成测试 / session metrics / install.sh 版本号
- **P3（Round 4 后续）**：MCP servers 显式管理 / lessons-extractor Stop hook 自动跑 retro-writer / eval 进 CI
```

> 注意：HEREDOC 里的反引号已转义。落地编辑时直接用 markdown 反引号即可。

- [ ] **Step 5: 完成本 task 后改 T-035 为 done**

最后一个 commit 之前：

```bash
python3 -c "
import json
d = json.load(open('docs/tasks.json'))
for t in d['tasks']:
    if t['id'] == 'T-035':
        t['status'] = 'done'
        t['done'] = True
json.dump(d, open('docs/tasks.json','w'), ensure_ascii=False, indent=2)
print('T-035 → done')
"
```

- [ ] **Step 6: 提交（连本 plan 文件一起）**

```bash
git add docs/tasks.json docs/STATUS.md docs/plans/round10-p0-flow-rigor.md
git commit -m "chore(workflow): Round 10 P0 — flow rigor (plan-review reminder + spec_id)"
```

---

## Task 7：第 7 步 验证（Verification）

- [ ] **Step 1: 全量 hook 测试**

```bash
bash .claude/hooks/lib/danger-patterns.test.sh
bash .claude/hooks/plan-review-reminder.test.sh
```

期望：两者均 PASS（25/25 + 6/6）。

- [ ] **Step 2: 端到端：编辑一个 plan 文件触发 dispatcher**

```bash
echo '{"tool_input":{"file_path":"docs/plans/round10-p0-flow-rigor.md"}}' \
  | bash .claude/hooks/post-edit-dispatch.sh 2>&1
```

期望输出包含 `plan-reviewer`。

- [ ] **Step 3: 端到端：编辑非 plan 文件不触发 plan-review reminder**

```bash
echo '{"tool_input":{"file_path":"AGENTS.md"}}' \
  | bash .claude/hooks/post-edit-dispatch.sh 2>&1 \
  | grep -i plan-reviewer && echo FAIL || echo OK
```

期望：`OK`（grep 无匹配）。

- [ ] **Step 4: tasks.json 自身合法**

```bash
python3 -c "import json; print('OK' if 'spec_id' in json.load(open('docs/tasks.json'))['tasks'][-1] else 'FAIL')"
```

期望：`OK`。

- [ ] **Step 5: 决策与计划文件齐全**

```bash
ls docs/plans/round10-p0-flow-rigor.md docs/decisions/0037-round10-flow-rigor.md
```

期望：两个文件都列出。

- [ ] **Step 6: git log 显示 6 个 commit**

```bash
git log --oneline -8
```

期望前 6 个为本计划的 6 个 commit（按 Task 1~6 顺序）。

---

## 完成定义

- 7 个文件改动（4 改 + 3 新建）：`post-edit-dispatch.sh` / `tasks-validate.sh` / `AGENTS.md` / `docs/STATUS.md` / `docs/tasks.json` / `plan-review-reminder.sh` / `plan-review-reminder.test.sh` / `0037-...md` / 本 plan 文件本身（共 9 个文件，跨 6 个 commit）
- 验证矩阵 6/6 PASS
- T-035 写入 tasks.json 并改为 done
- 单 PR / 单分支 main commit chain（仓库为 main-only 工作流，跳第 9 步）
