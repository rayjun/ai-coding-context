# Plan: 文档同步流程整合 (V2)

## 1. 目标
*   重塑 `DOCS.md` 结构为“项目百科”。
*   将开发流程扩展为 9 步，强制执行文档补全。

## 2. 具体步骤

### 2.1 DOCS.md 结构优化
*   **模块架构 (Architecture)**: 记录系统组成。
*   **知识库 (Knowledge Base)**: API、库选择理由、关键路径说明。
*   **指南 (Operation Guides)**: 环境配置、脚本运行。
*   **变更追踪 (Change Log)**: 简要记录每次任务的影响。

### 2.2 规范更新 (DEV.md & README.md)
*   更新 `DEV.md`: 
    *   增加 **第八步：文档维护 (Document Maintenance)**。
    *   更新 **第九步：完成分支 (Finishing Branch)**。
*   同步更新 `README.md` 的“自动化开发流程”章节。

### 2.3 行为更新 (AGENTS.md & SKILL.md)
*   更新 `AGENTS.md`: 在 5.0 自动化约束中增加“文档同步”规则。
*   更新 `skills/workflow-management/SKILL.md`: 增加“文档同步自动触发”逻辑。

## 3. 验证方式
*   模拟一个开发任务结束后的场景，检查是否自动更新了 `DOCS.md`。
*   检查 9 步走流程在 `README.md` 中是否清晰呈现。
