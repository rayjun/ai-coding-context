# Round 12 P1 — 质量门禁：代码审查 EVAL + 测试强度校验

**日期**: 2026-06-18
**状态**: done ✅（全部验收项通过，2026-06-18）
**决策参考**: `docs/decisions/0040-quality-gates.md`（第 8 步落盘）

## 目标

P0 两项落地，给「代码质量」装上客观判据：

1. **代码审查有二元 EVAL + 强制工具证据**：新建 `code-review` skill（5 维度 + 工具证据 + §3 哲学 checklist）+ `code-reviewer` agent，接入 AGENTS.md §6 第 6 步。消除「另一个 LLM 读代码且无工具证据」的审查盲区。
2. **测试强度门禁**：`record-test-evidence.sh` 解析测试输出中的 coverage 行写入 evidence；`pre-commit-check.sh` 在 evidence 含 coverage 时校验阈值（默认 60%，`MIN_COVERAGE` 可覆盖），低于阈值 deny commit；无 coverage 的项目不强制（向后兼容）。

## 验收标准

- [ ] `.claude/skills/code-review/SKILL.md`：5 维度 + 工具证据要求（EVAL 4）+ §3 哲学 checklist（EVAL 5）+ EVAL 1-6 二元判据
- [ ] `.claude/agents/code-reviewer.md`：独立上下文、只读、引用 skill 不复制（仿 plan-reviewer 模式）
- [ ] AGENTS.md §6 表格第 6 步指向 `.claude/skills/code-review/SKILL.md`
- [ ] `record-test-evidence.sh`：检测到 coverage 输出时追加 `coverage\t<percent>\t<command>` 行；无 coverage 不写入
- [ ] `pre-commit-check.sh`：evidence 有 coverage 且 < `MIN_COVERAGE`（默认 60）→ deny；无 coverage → 不阻断
- [ ] `record-test-evidence.test.sh` + `pre-commit-check.test.sh` 各新增 coverage 场景，全部 PASS
- [ ] 文档：tasks.json T-038、STATUS.md、决策 0040

## 执行步骤

| # | 动作 | 文件 |
|---|------|------|
| 1 | 新建 code-review skill（TDD 先行：先写 EVAL 判据） | `.claude/skills/code-review/SKILL.md` |
| 2 | 新建 code-reviewer agent | `.claude/agents/code-reviewer.md` |
| 3 | 接入流程 | `AGENTS.md` §6 表格第 6 步 |
| 4 | coverage 解析（红→绿） | `record-test-evidence.sh` + `.test.sh` |
| 5 | 阈值门禁（红→绿） | `pre-commit-check.sh` + `.test.sh` |
| 6 | 全量验证 | `make test` + 手动场景 |
| 7 | 文档维护 | tasks.json / STATUS.md / decisions/0040 |

## 设计细节

### coverage 解析（record-test-evidence.sh）

在现有「成功判定」之后追加，从 COMBINED 输出中提取百分比，支持格式：

```
pytest-cov / coverage.py:  TOTAL\s+\d+\s+\d+\s+(\d+)%
go test -cover:             coverage:\s*(\d+\.?\d*)%
通用:                       (\d+\.?\d*)%\s+coverage
```

- 只认明确带 `%` 的数字，锚定上下文，避免误抓版本号/时间戳。
- 匹配到则追加一行：`coverage\t<percent>\t<command>`（沿用现有 TSV 追加模式）。
- 失败检测逻辑不变：coverage 解析独立于 FAIL 启发式。

### 阈值门禁（pre-commit-check.sh）

- 解析 evidence 中**最后一条** `coverage\t<percent>` 行（时间序最近）。
- 阈值：环境变量 `MIN_COVERAGE`，默认 `60`。
- `coverage < MIN_COVERAGE` → `emit_pretool_deny`（消息含当前值与阈值）。
- 无 coverage 行 → 跳过（保持现有 mtime 门禁行为，不误伤无 coverage 工具的项目）。

### code-review EVAL（SKILL.md）

```
EVAL 1: 五维度全覆盖 — 安全性/正确性/可维护性/测试覆盖/需求符合度各独立段落+评级
EVAL 2: pass/warn/fail 明确评级，无模糊表述
EVAL 3: fail 项有具体修改建议（指出改什么、怎么改）
EVAL 4: 工具证据 — 审查必须实际运行编译/lint/类型检查/测试，引用真实输出；无证据的「通过」判 fail
EVAL 5: §3 哲学 checklist — 过度设计 / 孤儿代码 / 命名一致性 / 外科手术式改动可追溯
EVAL 6: 需求可追溯 — 每项需求 → 代码 → 测试 一一对应
```

## 风险与对策

| 风险 | 对策 |
|------|------|
| coverage 解析误抓（版本号/时间戳） | 百分比必须带 `%` 且锚定上下文模式 |
| 无 coverage 项目被误伤 | 无 coverage 行不阻断，保持向后兼容 |
| 「审查附证据」成为形式主义 | EVAL 4 要求引用具体命令与输出片段，无法引用则 fail |
| 阈值过高伤及低覆盖项目 | 默认 60% 宽松起步，`MIN_COVERAGE` 按项目调整 |

## Loop 信号

- 观察信号：coverage 场景测试全绿；手动构造低覆盖 evidence 触发 deny；高覆盖不触发。
- 退出条件：全部验收项通过 + 全量测试 PASS。
- 升级条件：coverage 解析格式覆盖不足导致误判时，扩大格式清单后重跑同一 gate。
