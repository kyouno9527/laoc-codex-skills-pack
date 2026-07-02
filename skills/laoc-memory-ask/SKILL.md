---
name: laoc-memory-ask
description: 用项目记忆和图谱查鹏哥项目的历史规则、决策、教训、入口和 case。适用于“关于 X 之前怎么定的”。
---

# 老C记忆查询

## 何时用

- 鹏哥问“之前怎么定的”“有哪些规则”“这事以前踩过坑吗”。
- 新任务可能受历史路径、交付规则、账号状态、同事边界影响。
- 老C准备判断，但记忆中可能已有事实。

## 查询顺序

1. `AGENTS.md`
2. `memory/PROJECT_MEMORY.md`
3. `memory/SOURCE_MAP.md`
4. `memory/LESSONS_DIGEST.md`
5. `cases/`
6. `library/notes/` 和 `library/topics/`
7. `skills/`
8. `graphify-out/GRAPH_REPORT.md` 和 `graphify-out/graph.json`（如果存在）

## 推荐命令

```bash
tools/laoc-memory-ask.sh "关于 X 有哪些规则"
tools/laoc-memory-ask.sh "A 和 B 之前有什么关系"
```

如果安装了 graphify 且存在 `graphify-out/graph.json`，脚本优先查图谱；否则回退到文本检索。

## 回答纪律

- 引用命中的文件路径。
- 区分“记忆中找到”和“现场推断”。
- 图里没有就说没找到。
- 图谱结果是导航，最终判断要回到原始文件、源码、日志、数据或鹏哥确认。

## 输出格式

```markdown
记忆结论：...

命中来源：
- path/to/file.md: 说明

可信度：
- 高 / 中 / 低

仍需现场确认：
- ...
```
