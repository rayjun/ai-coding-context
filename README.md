# AI Coding Context (AI 编程上下文)

中文 | [English](./README_en.md)

AI 编程助手上下文文件，旨在增强代码生成、重构和项目维护能力。

## 📄 `AGENTS.md`

该文件定义了一套完整的 AI 行为准则、推理框架和编码规范。它分叉并改编自 [Xuanwo 的 AI Context Gist](https://gist.github.com/Xuanwo/fa5162ed3548ae4f962dcc8b8e256bed)。

## 12 Factors

使用 AI Agents 的 (12 条原则)[https://github.com/humanlayer/12-factor-agents]，这是我目前最认可的对大模型使用的一些基础准则，核心其实只有一个：控制向大模型输入的上下文的大小。无论后面大模型怎么发展，但上下文还是会有限制。

如果用更简短的 prompt 表述清楚需求，那么大模型的表现就会更好。

## Spec-Driven

(spec-kit)[https://github.com/github/spec-kit] 和 (OpenSpec)[https://github.com/Fission-AI/OpenSpec] 都很好用，都可以用来规划开发任务，但这两个工具的重点都是开发任务的分解和执行，对于开发之外的任务，还需要其他的工具来补充对应的能力。


## Superpowers
在理解了大模型上下文的限制和 Spec-Driven 的开发模型之后，我也想到了要做一个适合自己的开发流程，结果在使用 (Superpowers)[https://github.com/obra/superpowers] 做一个小项目之后就放弃自己造轮子了，后续可能会继续补充一些 subagents 和 Skills。
