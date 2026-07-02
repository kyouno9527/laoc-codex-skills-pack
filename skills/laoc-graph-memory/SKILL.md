---
name: laoc-graph-memory
description: 维护鹏哥项目图谱记忆。用于建立 memory/cases/library/skills corpus、运行 graphify、检查图谱新鲜度和把稳定结论写回记忆。
---

# 老C图谱记忆维护

图谱记忆分工：

- `memory/`、`cases/`、`library/`、`skills/` 保存人类可读正文和判断。
- `graphify-out/` 保存关系图谱和查询加速结果。
- 图谱不是事实源本体；图谱是导航层。

## 何时用

- 新项目第一次接入老C工作流。
- 项目记忆、case、skill 有明显新增。
- 鹏哥开始问“这些事之间有什么关系”。
- 老C发现旧规则难找，需要把历史沉淀图谱化。

## 基础目录

```text
memory/
cases/
library/notes/
library/topics/
skills/
graphify-out/
```

## 重建命令

```bash
tools/laoc-graph-rebuild.sh
```

如果安装了 graphify，脚本会运行：

```bash
graphify .
```

如果没安装，脚本会生成一个轻量 `memory/GRAPH_INDEX.md`，列出当前记忆文件，作为退化索引。

## 新鲜度判断

- 刚改完 `memory/`、`cases/`、`library/`、`skills/` 后，图谱可能过期。
- 如果 `graphify-out/graph.json` 比这些目录旧，应重建。
- 如果图谱查询和原文冲突，以原文为准。

## 禁止

- 不要把密钥、cookie、token、私密账号材料写入记忆或图谱。
- 不要为了图谱好看重排大量目录。
- 不要把 AI 原始输出全量塞进长期记忆。
- 不要把第三方全文搬进项目；保存链接、短摘录和自己的总结即可。
