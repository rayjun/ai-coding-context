# AI Coding Context (AI 编程上下文)

[中文](./README.md) | English

A standardized collection of AI coding assistant contexts (Agents, Rules, Skills) designed to enhance code generation, refactoring, and project maintenance. Ideally, this repository can be used in any project during development.

**`AGENTS.md`**: This file is forked and adapted from [Xuanwo's AI Context Gist](https://gist.github.com/Xuanwo/fa5162ed3548ae4f962dcc8b8e256bed).

## 🌟 Features

- **Modular Context**: Separated into Agents (personas), Rules (coding standards), and Skills (task-specific instructions).
- **Cursor IDE Ready**: Automated setup for `.cursorrules` and `.cursor/rules` integration.

## 🚀 Installation & Usage

This repository includes an installation script to help you set up the context in your target project.

1.  **Clone this repository** (or download the script).
2.  **Run the installer** from the root of this repository, targeting your project directory:

    ```bash
    ./install_context.sh <path-to-your-project>
    ```

    *If running inside the target project itself:*
    ```bash
    ./install_context.sh
    ```

3.  **Follow the interactive prompts**:
    - Select your preferred language (English/Chinese).
    - Choose whether to automatically generate/overwrite `.cursorrules` for Cursor IDE optimization.

### What it installs

- Creates a `.ai-context/` directory in your project containing:
    - `AGENTS.md`: Core persona definitions.
    - `agents/`: Specialized role definitions (`architect.md`, `debugger.md`, `reviewer.md`, `security.md`).
    - `rules/`: Language and tool-specific coding standards (e.g., `git.mdc`, `rust.mdc`).
    - `skills/`: Instructions for specific tasks (e.g., `refactor_safe.md`).
- (Optional) Configures `.cursorrules` and `.cursor/rules` for seamless IDE integration.