# 老C MCP / 外接工具配置说明

这层是可选增强，不是老C工作的前提。

## 原则

- 不在项目里提交真实 token、cookie、浏览器 profile、私钥或账号材料。
- 项目内只放模板和说明；真实配置放鹏哥机器本地的 Codex/IDE/MCP 私有配置。
- MCP 只是能力入口，不是事实源。事实仍回到源码、日志、GitHub、数据、命令输出和鹏哥确认。
- 不配置鹏哥没有确认的 provider 专用 MCP；工具能力只放模板，不放私有账号状态。

## 推荐能力

| 能力 | 用途 | 建议 |
|---|---|---|
| GitHub / `gh` | issues、PR、checks、workflow runs、notifications | 优先用已登录 `gh`；MCP 可选 |
| External review CLI / 老G | 兼听则明外部复核 | 只 review，不写文件 |
| 浏览器 / Playwright MCP | 打开本地页面、截图、点击、UI 验收 | 前端项目推荐 |
| graphify / graphify MCP | 项目图谱和长期记忆查询 | 推荐增强档 |
| Filesystem | 受控读写项目文件 | Codex已有文件能力时不必重复 |
| Database | 只读排查、报表核验 | 严格限制连接和写权限 |

## 不推荐默认开启

- 鹏哥没有确认过的 provider 专用 MCP。
- 会自动写外部系统的 MCP：除非鹏哥确认目标系统和权限。
- 带生产写权限的数据库 MCP：默认只读。
- 会把大量私密上下文发给第三方的工具：先做范围和脱敏。

## 安装顺序

1. 先让老C在纯本地状态可用：`AGENTS.md` + `skills/` + `tools/`。
2. 配老G：确认 `external_review --version` 或设置 `LAOG_CMD`。
3. 配 GitHub：确认 `gh auth status`。
4. 配 graphify：安装 `graphifyy`，在项目根跑 `graphify .`。
5. 前端项目再配浏览器/Playwright MCP。
6. 最后再加项目专用数据库、云服务、看板等 MCP。

## 验收

```bash
tools/check-laoc-tools.sh
gh auth status
external_review --version
graphify --version
```

没有装某个可选工具不算失败；老C需要在汇报里说清哪些能力可用、哪些不可用。
