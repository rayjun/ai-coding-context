# Plan: 远程安装脚本 (install.sh)

## 1. 目标
通过 `curl -sSL [URL] | bash` 在目标项目中快速初始化 AI Context 规范。

## 2. 核心逻辑

### 2.1 环境变量与配置
*   `REPO_URL`: 指向 GitHub/Gitee 仓库的 Raw 文件根目录（默认使用本项目 URL）。
*   `TARGET_DIR`: 默认当前目录。
*   `FILES_TO_SYNC`: `AGENTS.md`, `DEV.md`, `README.md` (可选), `docs/STATUS.md` (模版), `skills/workflow-management/SKILL.md`。

### 2.2 主要步骤
1.  **环境检测**:
    *   检查 `curl` 或 `wget` 是否可用。
    *   检查目标目录是否有 `.git`。
2.  **创建目录**:
    *   `mkdir -p docs/plans docs/reports skills/workflow-management`.
3.  **下载/同步文件**:
    *   `AGENTS.md` & `DEV.md`: 始终覆盖（确保遵循最新规范）。
    *   `docs/STATUS.md`: 若不存在则下载模版，若已存在则跳过以保留当前项目进度。
    *   `skills/workflow-management/SKILL.md`: 下载最新的自动化指令。
4.  **初始化反馈**:
    *   成功后打印“AI Context 已就绪”及使用建议。

## 3. 安全与容错
*   **静默安装**: 默认静默，遇到文件冲突时使用提示。
*   **回滚机制**: 如果下载中途出错，清理已创建的空目录（由退出钩子处理）。

## 4. 验证策略
*   在 `/tmp/test-ai-context` 下模拟运行脚本。
*   检查文件完整性（`ls -R`）。
*   检查文件内容是否正确下载（`grep` 关键字）。
