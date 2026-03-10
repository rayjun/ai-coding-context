# 项目文档 (DOCS.md)

本文件是项目的核心知识库，记录架构设计、关键决策、API 规范及操作指南。

---

## 🏛️ 模块架构 (Architecture)

*   **项目核心**: AI Context 管理规范 (AGENTS.md, DEV.md, STATUS.md)。
*   **自动化层**: `skills/` 目录下定义的各种自动化任务指令。
*   **状态层**: `docs/` 目录下的实时任务状态、计划及验证报告。

---

## 📚 知识库 (Knowledge Base)

### 核心决策理由
- **12 Factor Agents**: 为了在有限上下文中提供最精准的响应，将复杂逻辑拆分为 sub-agents。
- **Spec-Driven**: 先写计划（Spec）再写代码，减少重构成本。

---

## 🛠️ 操作指南 (Guides)

### 环境配置
1.  确保本地已安装 `curl`, `bash` 和 `git`。
2.  通过本项目根目录下的 `install.sh` 初始化新项目。

### 脚本运行
- **install.sh**: `bash install.sh [BASE_URL]` 用于部署或更新规范。

---

## 📝 变更追踪 (Change Log)

- **2026-03-10**: 
    - 增加自动化开发流程（8 步走）。
    - 增加远程安装脚本 `install.sh`。
    - **[重大变更]** 扩展开发流程为 **9 步走**，新增“文档维护”步骤。
