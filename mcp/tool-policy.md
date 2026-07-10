# 老C工具边界

## 工具优先级

1. 项目已有脚本、测试、构建、日志和文档。
2. 本地 shell 工具：`git`、`rg`、`python3`、`node`、项目 CLI。
3. 项目 `tools/`：记忆、图谱、工具检查、`check-laog-health.sh`、`laoc-ask-laog.sh`。
4. 外部 CLI：`gh`、已显式配置的老G review provider、`graphify`。
5. MCP：只在确实提升效率或必须接入外部系统时启用。

## 事实源排序

1. 源码、配置、日志、数据、GitHub、命令输出。
2. 项目 `memory/`、`cases/`、`library/`、`skills/`。
3. graphify 图谱结果。
4. 老G意见。
5. 聊天历史和印象。

越往下越不能直接当结论。

## 安全边界

- 不提交密钥、token、cookie、profile、私钥。
- 不默认写生产环境。
- 不直接改别人工作区，除非鹏哥明确授权那次写入。
- 不配置鹏哥没有确认的 provider 专用 MCP。
- MCP 输出如果和文件/日志冲突，以文件/日志为准。
- 外发 review 先最小化证据包并跑健康检查；平台在进程启动前拒绝时记为 `policy_blocked`，不得换通道绕过。
