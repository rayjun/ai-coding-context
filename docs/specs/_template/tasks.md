# Tasks · <feature-name>

**日期**: YYYY-MM-DD
**状态**: Draft | In Progress | Done
**关联**: requirements.md · design.md

> 这份 tasks.md 是 spec 的一部分，记录**人类可读**的任务拆解和上下文。
> 真正的执行 SSoT 仍是 `docs/tasks.json`。两者通过 `spec_id` 字段（未来）建立映射；当前阶段手工对应即可。

---

## 拆解

| ID | 任务 | 输出物 | 依赖 | 估算 | 状态 |
|----|------|--------|------|:-:|:-:|
| T-NNN | ... | ... | — | S | pending |
| T-NNN | ... | ... | T-NNN | M | pending |

> 估算：S (< 半天) / M (< 2 天) / L (> 2 天，应继续拆)

## 实施顺序

1. 先做 T-NNN（因为 ...）
2. T-NNN 与 T-NNN 可并行
3. T-NNN 是收尾验证

## 验证矩阵

每个 FR / NFR 至少对应 1 个测试任务。

| 需求 | 验证任务 | 检查方式 |
|------|----------|----------|
| FR-1 | T-NNN | 单元测试 |
| FR-2 | T-NNN | 集成测试 |
| NFR-1 | T-NNN | benchmark |
| NFR-2 | T-NNN | 安全扫描 |

## 完成定义 (Definition of Done)

- [ ] 所有 FR 对应测试通过
- [ ] 所有 NFR 阈值达标（含证据：benchmark 输出 / metrics 截图）
- [ ] design.md 与实现一致（实现偏离须更新 design）
- [ ] STATUS.md 追加完成记录
- [ ] 重大决策已归档到 `docs/decisions/`
- [ ] tasks.json 对应任务 status=done
