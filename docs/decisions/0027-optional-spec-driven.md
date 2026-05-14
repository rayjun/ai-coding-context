# 决策 #27 · docs/specs/ 作为可选 Spec-Driven 增强

**日期**: 2026-05-14
**状态**: Adopted

## 背景

业界（Amazon Kiro / GitHub spec-kit / Anthropic 内部实践）正向 **「Spec → Design → Tasks」三件套** 范式收敛：
- **Spec / Requirements**：WHAT + 验收标准（EARS 格式）
- **Design**：HOW（架构、数据流、风险、回滚）
- **Tasks**：可执行步骤 + 验证矩阵

当前本项目的 `docs/plans/*.md` 是 free-form 计划文档，对单 PR 任务足够，但对跨多 PR / 多周迭代的 feature 缺少结构化的需求与设计上下文。
plan-review skill 在没有稳定输入产物的情况下，审查质量受输入风格影响很大。

## 决策

新增 `docs/specs/` 目录，提供模板与写作指南，**作为 `docs/plans/` 的可选替代**：

```
docs/specs/
  ├── README.md          # 何时用 spec vs plan + 写作流程
  └── _template/
      ├── requirements.md   # EARS 格式
      ├── design.md
      └── tasks.md
```

**显式不做的事**：
- **不修改 AGENTS.md §6 流程**，spec 不强制。
- **不在 plan-review skill 中绑定 spec 输入契约**，留给 Round 5 评估。
- **不为 tasks.json 增加 `spec_id` 字段**，避免 tasks-validate.sh 同步改动。
- **不弃用 docs/plans/**，单 PR 任务继续用 plan。

判断口径：3 个月后还会被人翻出来看的 → spec；纯执行性的 → plan。

## 影响

收益：
- complex 级跨多 PR 的 feature 有了结构化的需求与设计承载。
- plan-reviewer subagent 未来可绑定 spec 输入契约，提升审查稳定性（Round 5）。
- 与业界范式对齐，便于后续工具集成。

代价：
- 极低，纯增量。模板由 install.sh 同步覆盖；用户项目的实际 spec 不会被覆盖。
- 学习成本：新写作风格（EARS）需要团队适应；通过 README 写作指南降低门槛。

后续：
- Round 5 评估：plan-reviewer 是否绑定 spec schema、tasks.json 是否加 spec_id。
- 累积 1-2 个真实 spec 后回看模板是否需要调整。
