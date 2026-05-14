# Specs — Spec-Driven Development（可选）

> 受 Amazon Kiro / GitHub spec-kit 范式启发的「Spec → Design → Tasks」三件套。
>
> **当前为可选增强**，不影响 AGENTS.md §6 的 9 步流程。complex 级任务可选用 spec 替代单文件 plan，moderate / trivial 继续用 `docs/plans/`。

---

## 目录结构

```
docs/specs/
  ├── README.md          # 本文件 — 何时用 + 写作指南
  ├── _template/         # 模板（install.sh 同步）
  │   ├── requirements.md
  │   ├── design.md
  │   └── tasks.md
  └── <feature-slug>/    # 实际 spec
      ├── requirements.md
      ├── design.md
      └── tasks.md
```

`<feature-slug>` 用 kebab-case，例：`subagents-integration`、`payment-refund-flow`。

---

## 何时用 spec vs 何时用 plan

| 情境 | 用 plan (`docs/plans/`) | 用 spec (`docs/specs/`) |
|------|:-:|:-:|
| 单 PR 范围、单文件改动 | ✅ | — |
| 1-3 天可完成 | ✅ | — |
| 跨多个 PR / 多周迭代 | — | ✅ |
| 涉及外部利益相关方（PM、合规） | — | ✅ |
| 需要长期回查决策上下文 | — | ✅ |
| 数据模型 / 公共 API 变更 | — | ✅ |
| 纯重构 / bug fix | ✅ | — |
| Hooks / skills / 内部工具改进 | ✅ | — |

**判断口径**：3 个月后还会被人翻出来看的 → spec；纯执行性的 → plan。

---

## 写作流程

### 1. 复制模板

```bash
cp -r docs/specs/_template docs/specs/<feature-slug>
```

### 2. 填 requirements.md（WHAT）

- 用 EARS 格式：`WHEN <trigger> THE SYSTEM SHALL <behavior>`
- 每个 FR / NFR 必须有可执行的验收标准（checklist）
- 显式列出**不包含**的范围，避免后期范围蔓延
- 开放问题集中在末尾，不要散在各 FR 中

### 3. 填 design.md（HOW）

- 数据流图先写文字版，画图工具留到必要时
- 每个关键决策要有 1-2 个备选 + 理由
- 重大决策 → 同步归档到 `docs/decisions/NNNN-*.md`，design 里只放索引链接
- 风险表必须含「概率 × 影响 × 缓解」三列

### 4. 填 tasks.md（BREAKDOWN）

- 每个任务对应 `docs/tasks.json` 的一项（手工映射）
- 验证矩阵：每个 FR/NFR ↔ 至少 1 个验证任务
- 完成定义 (DoD) 必须可勾选，不写「质量好」「跑得快」这种主观词

---

## 与现有流程的关系

| AGENTS.md §6 步骤 | spec 对应 |
|------------------|-----------|
| 1. 头脑风暴 | requirements.md 「背景 / 利益相关方」 |
| 2. 制定计划 | design.md + tasks.md |
| 2 续. 架构审查 | plan-reviewer subagent 读 design.md |
| 4-5. 执行 | tasks.md 拆解 → tasks.json 跟踪 |
| 7. 验证 | tasks.md 「验证矩阵」 + DoD |
| 8. 文档维护 | spec 状态变更 + STATUS.md 索引 |

> **plan-review skill 当前不强制 spec 输入**。本轮（Round 4）只交付模板；plan-reviewer subagent 是否绑定 spec schema 留到 Round 5 评估。

## 与 docs/decisions/ 的边界

- **spec**：完整设计上下文，feature 级别
- **decision**：单点架构选择，可独立于 spec 存在（小到「Stop hook 顺序」也算）
- spec 里的关键决策必须**同时**归档到 decisions/，避免 spec 被 superseded 时决策丢失

## 与 docs/tasks.json 的边界

- tasks.md：人类可读的拆解、依赖、验证矩阵
- tasks.json：harness 可校验的执行 SSoT（pre-commit / status hooks 读它）
- 当前阶段两者**手工对应**；未来可能为 tasks.json 加 `spec_id` 字段（Round 5 决定）

---

## 生命周期

```
Draft → Approved → In Progress → Implemented → [Superseded]
```

- **Draft**：随便改，no review
- **Approved**：用户/团队拍板，进入实现期；后续修改需要明显的 changelog 标注
- **In Progress**：tasks 部分完成
- **Implemented**：所有 DoD 勾选完
- **Superseded**：被新 spec 替代时标注 `Superseded by docs/specs/<new>`，**不删除**

---

## 例子

> 真实 spec 出现后会列在这里。
