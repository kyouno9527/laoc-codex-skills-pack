# 鹏哥 / 老C 工作流交付包 v2.1

更新时间：2026-07-10

这份包把最新 Shikagami 工作流蒸馏成鹏哥那边可直接使用的“老C”版本。核心仍是：

**知 -> 行 -> 验 -> 结**

v2/v2.1 相比 2026-06-08 旧包，重点补上：

- 本地事实源优先：源码、日志、数据、命令输出、运行结果和鹏哥确认优先于模型意见。
- 鹿问升级：开放问题先摸真实使用者、入口、历史和一手材料；方案类进入“烤问”，一次只问一个关键问题，并给推荐答案。
- 鹿行升级：明确目标后小步执行，每步带 DoD 和验证方式，不扩大范围。
- 鹿验升级：按“存在、实质、接线、功能”四层验收，不能把文件存在当完成。
- 鹿结升级：验收通过后沉淀状态、入口、风险和可复用经验，方便下次接着跑。
- 老G定位更清楚：只做兼听复核和挑错，不写文件，不当事实源，不替老C裁决。
- 兼听接线补全：默认使用官方 `agy`，新增健康检查、正式调用、`response.md` / `run.log` 成功合同和 `policy_blocked` 口径；删除对占位命令 `external_review` 的依赖。

## 文件

- `老C_AGENTS_工作流.md`：可放进项目根 `AGENTS.md` 或作为老C启动提示词。
- `LAOC_AGENTS_WORKFLOW.md`：上面文件的 ASCII 文件名副本，方便 Windows/英文终端。
- `INSTALL_LAOC_WORKFLOW.md`：一步步配置老C、skills、tools、图谱记忆和老G。
- `AGENTS_LAOC_SNIPPET.md`：可直接追加到项目根 `AGENTS.md` 的片段。
- `skills/`：老C可用的核心 skills。
- `scripts/`：安装、记忆查询、图谱重建、工具检查和老G兼听脚本。
- `tests/`：便携 provider、失败降级、stale response 清理和安装复制烟测。
- `mcp/`：MCP/外接工具配置说明和模板；不包含真实 token。
- `鹏哥_老C工作流交付说明.html`：给鹏哥打开阅读/转发的说明版。
- `HANDOFF.html`：上面 HTML 的 ASCII 文件名副本，方便直接打开。

## 角色映射

- 用户称呼：鹏哥
- Codex 名称：老C
- 主工作流：`laoc-shikagami`
- 外部复核席：老G

## 使用建议

主入口建议用 git：

```bash
git clone https://github.com/kyouno9527/laoc-codex-skills-pack.git
cd laoc-codex-skills-pack
bash scripts/install-laoc-workflow.sh /path/to/pengge-project
```

后续更新：

```bash
cd laoc-codex-skills-pack
git pull
bash scripts/install-laoc-workflow.sh /path/to/pengge-project
```

使用原则：

1. 先把 `老C_AGENTS_工作流.md` 放到鹏哥常用项目根目录，或并入已有 `AGENTS.md`。
2. 如果项目已经有自己的工程规则，以项目现有规则为第一优先级；这份工作流补“怎么查、怎么做、怎么验、怎么沉淀”。
3. 老C能自己查、跑、改、验的，不把问题推回鹏哥。
4. 老G只做复核和挑错，不替代老C读源码、跑命令、验收和裁决。
5. 正式兼听前先跑 `tools/check-laog-health.sh`；成功必须有 `response.md` 且 `run.log` 为 `status=ok`。平台拒绝外发时不绕过。
