# Skill: Workflow Management

## 目的
实现从需求提出到最终集成的全自动化、标准化开发流程，确保每一步都有迹可循、结果可验证。

## 自动化操作流

### 1. 任务初始化
*   **触发**: 接收到非 trivial 的开发指令。
*   **操作**: 
    1.  更新 `docs/STATUS.md` 的当前目标与进度。
    2.  在 `docs/plans/` 下创建一个与任务同名的 `.md` 文件。
    3.  自动激活 `brainstorming` skill。

### 2. 状态自动化 (Status Automator)
*   **触发**: 完成 `DEV.md` 中的任一关键步骤（Brainstorming, Plan, Code, Test）。
*   **操作**:
    1.  自动计算 `docs/STATUS.md` 中的进度 (X/Y) 和百分比。
    2.  记录当前步骤的 **核心决策** 或 **最新发现**。
    3.  记录当前 UTC 时间。

### 3. 验证网关 (Verification Gateway)
*   **触发**: 切换到 Code 模式之前，以及宣称任务完成之前。
*   **操作**:
    1.  **强制执行测试策略**: 运行 `test`, `lint`, `build` 等命令。
    2.  **生成报告**: 将命令输出重定向或总结到 `docs/reports/` 下。
    3.  **阻断逻辑**: 任何失败均视为阻塞，必须先解决阻塞并记录在 `STATUS.md`。

### 4. 文档补全 (Document Maintenance)
*   **触发**: 验证通过后。
*   **操作**:
    1.  分析当前任务对 **架构、API 或 配置** 的影响。
    2.  更新 `DOCS.md` 中的对应章节。
    3.  更新 `README.md` 中的 Quick Start 或流程说明（如有变动）。

### 5. 知识归档与方法论提取 (Recursive Learning)
*   **触发**: 任务完成（Finishing branch）。
*   **操作**:
    1.  比对当前开发中的决策记录，识别出通用的最佳实践。
    2.  提出对 `AGENTS.md` 的增量修改建议。
    3.  更新 `STATUS.md` 至“任务完成”状态，标记日期。

## 约束
- 禁止跳过 `docs/reports/` 的生成。
- 任何代码变更必须附带测试验证报告。
- `docs/STATUS.md` 必须是每轮会话更新的第一个或最后一个文件。
