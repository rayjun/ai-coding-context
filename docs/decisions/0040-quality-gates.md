# 0040 · Round 12 P1 — 质量门禁：代码审查 EVAL + 测试强度校验

**日期**: 2026-06-18
**状态**: accepted
**相关**: AGENTS.md §6, `.claude/skills/code-review/`, record-test-evidence.sh, pre-commit-check.sh

## 背景

评估结论：harness 把「流程可靠性」下限抬得很高，但对「代码质量」没有客观判据。两个最薄弱的环节：

1. **代码审查无质量判据、无工具证据**：plan-review（方案审查）有 5 个二元 EVAL，但第 6 步代码审查只有文本描述。审查是「另一个 LLM 读代码」——同一模型共享认知盲区，且审查者倾向认可团队产出；没有任何编译器 / linter / 类型检查 / 测试输出进入审查。§3 编程哲学（最简实现 / 外科手术）是文本约束，无 EVAL 承接。

2. **测试门禁只校验「跑过」**：pre-commit 是 mtime 证据门禁——测试输出干净即可。`test` 全 PASS 但什么都没测的情况完全合规。无覆盖率、无断言强度要求。

## 决策

**A · 新建 `code-review` skill + `code-reviewer` agent，接入 AGENTS.md §6 第 6 步。**

skill 定义 5 维度（安全性 / 正确性 / 可维护性 / 测试覆盖 / 需求符合度）+ EVAL 1-6，其中两个关键判据：
- **EVAL 4 工具证据（硬性）**：审查必须实际运行编译 / lint / 类型检查 / 测试并引用真实输出；无证据的「通过」判 fail。直接对冲 LLM 读代码的共享盲区。
- **EVAL 5 §3 哲学 checklist**：过度设计 / 孤儿代码 / 命名一致性 / 外科手术四项各需明确判定——把 §3 文本哲学转成可验证项。

agent 仿 plan-reviewer 模式（独立上下文、只读、引用 skill 不复制），但工具白名单含 Bash（必须跑工具收集证据）。

**B · `record-test-evidence.sh` 解析 coverage 并写入 evidence；`pre-commit-check.sh` 增加覆盖率阈值门禁。**

- evidence 格式扩展：测试输出含覆盖率时追加 `coverage\t<percent>\t<command>` 行。支持 pytest-cov `TOTAL ... %`、`go test -cover` 的 `coverage: x%`、通用 `x% coverage` 三种格式；裸百分比（无 coverage 上下文）不解析，防误报。
- pre-commit 门禁：evidence 有 coverage 记录时，低于 `MIN_COVERAGE`（默认 60，环境变量可覆盖）→ deny；无 coverage 记录的项目不阻断（向后兼容，不误伤无覆盖率工具的项目）。

## 后果

**正面**：
- 代码审查从「另一个 LLM 的意见」升级为「有工具证据支撑的验收」，EVAL 4 让「审查通过」可复核、可判假。
- §3 哲学（此前无法验证的文本约束）有了 EVAL 5 承接。
- 覆盖率数据自动进入提交门禁；支持覆盖率工具的项目低覆盖提交被硬拦截。
- 全量测试通过（record-test-evidence 10/10、pre-commit-check 6/6、danger-patterns、plan-review-reminder）。

**负面 / 取舍**：
- `MIN_COVERAGE=60` 是保守起步值，只拦截「明显没测」的提交；高覆盖目标需项目级调高。
- coverage 解析只覆盖三种常见输出格式，其他格式（lcov、cobertura XML 等）暂不解析——需后续按需扩展。
- 审查的 EVAL 6（需求可追溯）依赖需求上下文传递，主 agent 调用 code-reviewer 时必须提供任务/计划上下文。

## 不做

- 不新增 P1 的「断言强度 diff 启发式」：误报风险高（重构、文档项目会被误伤），等 coverage 门禁跑一段时间后再评估。
- 不接入静态分析工具到 harness 层（clippy/mypy 等按项目技术栈在 code-review skill 的前置条件中按需使用，保持通用）。
- 不改 `install.sh` 的目录复制逻辑（skills/agents 目录自动包含新文件）；CORE_FILES 不变。
