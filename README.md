# AI Coding Context

AI Coding 的本质是 **上下文管理**，旨在 LLM 的概率性与软件工程的确定性之间通过精细的规范、工具和 Skill 寻找平衡。

本项目提供了一套完整的 AI 行为准则、自动化开发流程和文档规范，以确保代码质量、可维护性和开发的可追踪性。

---

## ⚡ 快速安装 (Quick Start)

在你的项目根目录下执行以下命令（一键初始化/更新）：

```bash
# 请将 [USER]/[REPO] 替换为你的真实仓库路径
curl -sSL https://raw.githubusercontent.com/[USER]/[REPO]/main/install.sh | bash
```

*如果你是第一次使用，该命令将创建目录并初始化状态；如果你已经安装过，它将同步最新的规范文件。*

---

## 🛠️ 自动化开发流程 (Automated Workflow)

项目强制执行以下 **9 步走** 开发流程：

1.  **头脑风暴 (Brainstorming)**: 探索用户意图、需求和设计方案。
2.  **制定计划 (Plan Writing)**: 拆解任务，生成 `docs/plans/TASK_NAME.md`。
3.  **创建 Git 工作树**: 隔离开发分支。
4.  **测试驱动开发 (TDD)**: 每个功能变更必须有对应测试。
5.  **执行计划 (Execution)**: 具体的实现过程。
6.  **代码审查 (Code Review)**: 验证成果是否满足原始需求。
7.  **验证 (Verification)**: 运行测试并生成 `docs/reports/TASK_NAME.md`。
8.  **文档维护 (Document Maintenance)**: 更新 `DOCS.md` 沉淀项目知识。
9.  **完成分支**: 合并并清理开发分支。

---

## 📂 文档体系结构

```bash
docs/
├── plans/      # 存档详细的开发计划文件
├── reports/    # 存档测试结果、Lint 报告和验证证据
└── STATUS.md   # 记录项目的实时状态、进度和决策
```

---

## 📄 核心规范文件

### `AGENTS.md` (最高行为准则)
定义 AI 的推理框架（Abductive Reasoning）、工作模式（Plan/Code）和编码风格。
*   **自动化约束**: 所有任务必须遵守：状态先行、计划存档、验证闭环、**文档同步**、方法论回哺。

### `DEV.md` (强制流程)
定义详细的 **9 步开发流程** 及其跳步规则，禁止静默跳过任何关键步骤。

### `STATUS.md` (状态规范)
定义如何维护 `docs/STATUS.md`。该文件是项目的 **单一事实源 (SSoT)**，记录进度、决策和阻塞。

### `DOCS.md` (文档原则)
定义文档维护的 **核心原则**（如追加记录、存量保护）。它是 AI 执行“第八步：文档维护”时的最高行动指南。

---

## 📏 核心准则

*   **12 Factor Agents**: 控制上下文大小，利用 sub-agents 和 skills 扩展能力。
*   **Spec-Driven**: 所有的代码变更应源于清晰的 Spec（计划）。
*   **Recursive Improvement**: 任务完成后，自动提炼经验并回哺至 `AGENTS.md`。
