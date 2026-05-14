# Requirements · <feature-name>

> EARS (Easy Approach to Requirements Syntax) 格式骨架。所有需求语句使用 **WHEN/IF/WHILE + SHALL** 结构。

**日期**: YYYY-MM-DD
**状态**: Draft | Approved | Implemented | Superseded
**Owner**: <name>
**关联**: design.md · tasks.md · `docs/plans/*`（如有）

---

## 背景

为什么要做这个 feature。**问题陈述 + 业务/技术动机**，不要写解决方案。

## 利益相关方

| 角色 | 关注点 |
|------|--------|
| 终端用户 | 体验、性能 |
| 维护者 | 可读性、测试 |
| 运维 | 可观测、可回滚 |

## 范围

### 包含
- ...

### 不包含（显式排除）
- ...

---

## 功能需求 (Functional Requirements)

### FR-1 · <一句话标题>
- **WHEN** \<触发条件>
- **THE SYSTEM SHALL** \<预期行为>
- **验收标准**：
  - [ ] 可执行的检查项 1
  - [ ] 可执行的检查项 2

### FR-2 · ...

---

## 非功能需求 (Non-Functional Requirements)

### NFR-1 · 性能
- **THE SYSTEM SHALL** \<性能阈值>（例：P99 延迟 < 200ms）

### NFR-2 · 安全
- **IF** \<安全场景> **THEN THE SYSTEM SHALL** \<安全行为>

### NFR-3 · 可观测性
- **THE SYSTEM SHALL** 暴露 \<指标/日志/trace>

---

## 约束

- 语言/库版本
- 不能动的现有 API
- 性能上限 / 资源上限

## 假设

- 假设 1（如不成立则范围调整）
- 假设 2

## 开放问题

- [ ] Q1 ...
- [ ] Q2 ...
