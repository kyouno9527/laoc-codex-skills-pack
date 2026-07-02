# v2 更新说明

时间：2026-07-02

这版是给鹏哥的老C工作流二次蒸馏，基于最新 Shikagami 主工作法和当前本地执行规范。

## 相比 2026-06-08 旧包的主要变化

- 增加事实源分级：`observed`、`recorded`、`indexed`、`external`、`backup`。
- 增加“方案烤问”：方案、设计、计划类问题一次只问一个关键问题，并给推荐答案和理由。
- 增加前提 confidence：事实不足时先补事实，不急着问老G。
- 强化老C默认单线程执行：只有鹏哥明确要求并行/分兵/代理协作时才派子 agent。
- 强化四层验收：存在、实质、接线、功能。
- 强化 workflow-as-code：长期规则、提示词、检查表、状态和经验应进入 Markdown/YAML。
- 明确老G review-only：只审查和质疑，不写文件、不当事实、不替老C裁决。

## 仍然保留

- 鹏哥称呼。
- 老C命名。
- 知 -> 行 -> 验 -> 结。
- `laoc-memory-ask`、`laoc-graph-memory`、`laoc-laog-review`、`laoc-handoff-package`。
- 安装脚本、工具检查脚本、MCP 模板。

## 不放进包里的内容

- 源工作区的本机路径、账号、登录态、私有模型路由和敏感配置。
- 我们当前机器上的具体 review seat 名单。
- 任何 token、cookie、密钥或私密授权材料。
