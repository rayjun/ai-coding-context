# AI Coding Context (AI 编程上下文)

中文 | [English](./README_en.md)

一套标准化的 AI 编程助手上下文集合（包含 Agent、规则和技能），旨在增强代码生成、重构和项目维护能力。理想的情况这个，在开发任意一个项目的时候，都可以使用这个仓库的内容。

**`AGENTS.md`**：该文件分叉并改编自 [Xuanwo 的 AI Context Gist](https://gist.github.com/Xuanwo/fa5162ed3548ae4f962dcc8b8e256bed)。


## 🌟 特性

- **模块化上下文**：分为 Agent（人格设定）、Rules（编程标准）和 Skills（特定任务指令）。
- **Cursor IDE 就绪**：自动设置 `.cursorrules` 和 `.cursor/rules` 集成。

## 🚀 安装与使用

本仓库包含一个安装脚本，帮助在目标项目中设置上下文。

1.  **克隆本仓库**（或下载脚本）。
2.  **在仓库根目录下运行安装程序**，指向你的项目目录：

    ```bash
    ./install_context.sh <你的项目路径>
    ```

    *如果直接在目标项目中运行：*
    ```bash
    ./install_context.sh
    ```

3.  **按照交互式提示操作**：
    - 选择你偏好的语言（英文/中文）。
    - 选择是否自动生成/覆盖 `.cursorrules` 以进行 Cursor IDE 优化。

### 安装内容

- 在你的项目中创建 `.ai-context/` 目录，包含：
    - `AGENTS.md`：核心人格定义。
    - `agents/`：专业角色定义（`architect.md`, `debugger.md`, `reviewer.md`, `security.md`）。
    - `rules/`：语言和工具特定的编程标准（例如 `git.mdc`, `rust.mdc`）。
    - `skills/`：特定任务的操作指南（例如 `refactor_safe.md`）。
- （可选）配置 `.cursorrules` 和 `.cursor/rules` 以实现无缝 IDE 集成。
