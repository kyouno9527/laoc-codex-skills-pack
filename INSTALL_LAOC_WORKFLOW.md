# 鹏哥 / 老C 工作流 v2.1 安装指南

目标：让鹏哥项目里的 Codex（老C）具备四件事：

1. `Shikagami` 路由：知 -> 行 -> 验 -> 结。
2. `实事求是` 纪律：先查事实，再判断；没验证不说完成。
3. `图谱记忆`：能查项目长期记忆、状态、case、经验和技能。
4. `兼听则明`：用老G做外部复核，但不让老G替代事实源。

v2.1 新增重点：

- 事实源分级：observed / recorded / indexed / external / backup。
- 方案烤问：方案类问题一次只问一个关键问题，并给推荐答案。
- 四层验收：存在、实质、接线、功能。
- workflow-as-code：长期规则、提示词和检查表写入 Markdown/YAML。
- 老G review-only：老G不写文件、不当事实、不替老C裁决。
- 兼听真实接线：默认 `agy`，先健康检查，正式调用成功必须有 `response.md` 和 `run.log: status=ok`。

## 0. 交付包结构

```text
laoc-codex-skills-pack/
├── README.md
├── INSTALL_LAOC_WORKFLOW.md
├── 老C_AGENTS_工作流.md
├── LAOC_AGENTS_WORKFLOW.md
├── 鹏哥_老C工作流交付说明.html
├── HANDOFF.html
├── AGENTS_LAOC_SNIPPET.md
├── skills/
│   ├── laoc-shikagami/SKILL.md
│   ├── laoc-luwen/SKILL.md
│   ├── laoc-luxing/SKILL.md
│   ├── laoc-luyan/SKILL.md
│   ├── laoc-lujie/SKILL.md
│   ├── laoc-memory-ask/SKILL.md
│   ├── laoc-graph-memory/SKILL.md
│   ├── laoc-laog-review/SKILL.md
│   └── laoc-handoff-package/SKILL.md
├── mcp/
│   ├── README.md
│   ├── mcp.local.template.jsonc
│   └── tool-policy.md
└── scripts/
    ├── install-laoc-workflow.sh
    ├── laoc-memory-ask.sh
    ├── laoc-graph-rebuild.sh
    ├── check-laoc-tools.sh
    ├── check-laog-health.sh
    └── laoc-ask-laog.sh
```

## 1. Git 拉取

推荐直接从 GitHub 拉：

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

脚本会做这些事：

- 在项目里创建 `skills/`、`tools/`、`memory/`、`cases/`、`library/notes/`、`library/topics/`。
- 把老C skills 复制到项目 `skills/`。
- 把记忆、图谱、工具检查和老G兼听脚本复制到项目 `tools/`。
- 创建或追加 `AGENTS.md` 的老C工作流片段。
- 把 MCP 说明和模板复制到项目 `mcp/`。
- 不覆盖已有 `AGENTS.md`；如果已存在，只追加一次标记区块。

## 2. 手动安装方式

如果不想跑脚本，手动做：

```bash
cd /path/to/pengge-project
mkdir -p skills tools memory cases library/notes library/topics
cp -R /path/to/laoc-codex-skills-pack/skills/* skills/
cp -R /path/to/laoc-codex-skills-pack/mcp mcp
cp /path/to/laoc-codex-skills-pack/scripts/*.sh tools/
chmod +x tools/*.sh
cat /path/to/laoc-codex-skills-pack/AGENTS_LAOC_SNIPPET.md >> AGENTS.md
```

## 3. 配置老C启动规则

项目根 `AGENTS.md` 至少要有这些规则：

- 默认称呼用户为“鹏哥”。
- Codex 自称或工作代号为“老C”。
- 新任务先走 `laoc-shikagami`：知 -> 行 -> 验 -> 结。
- 开放问题先查事实；明确任务直接执行；交付前必须验证。
- 方案类问题进入烤问：一次只问一个最影响方向的问题，并给推荐答案。
- 需要查历史规则时先用 `tools/laoc-memory-ask.sh` 或 `laoc-memory-ask` skill。
- 需要外部复核时问老G，但老G只做 review，不做事实源。

完整片段在 `AGENTS_LAOC_SNIPPET.md`。

## 4. 建立项目记忆目录

建议鹏哥项目采用这套轻量结构：

```text
memory/
├── PROJECT_MEMORY.md      # 项目长期事实和入口
├── SOURCE_MAP.md          # 重要源码、数据、文档、交付物索引
└── LESSONS_DIGEST.md      # 可复用规则和踩坑

cases/
└── YYYY-MM-DD-topic.md    # 单个阶段/事故/交付的可续跑记录

library/
├── notes/                 # 消化后的资料笔记
└── topics/                # 跨资料主题沉淀
```

第一天可以先建空文件：

```bash
touch memory/PROJECT_MEMORY.md memory/SOURCE_MAP.md memory/LESSONS_DIGEST.md
```

## 5. 图谱记忆：基础档

基础档不需要额外依赖。直接用：

```bash
cd /path/to/pengge-project
tools/laoc-memory-ask.sh "关于上线包交付有哪些规则"
tools/laoc-memory-ask.sh "这个项目之前怎么处理登录态"
```

它会优先搜：

- `memory/`
- `cases/`
- `docs/`
- `skills/`
- `library/notes/`
- `library/topics/`
- `AGENTS.md`

这个模式像“带范围和纪律的 rg”，优点是稳、快、无依赖；缺点是没有关系图谱推理。

## 6. 图谱记忆：增强档 graphifyy

增强档使用官方 `graphifyy` 包；命令名通常是 `graphify`，需要 Python 3.10+。

推荐安装：

```bash
uv tool install graphifyy
```

如果没有 `uv`：

```bash
pipx install graphifyy
```

装好后，在鹏哥项目根运行：

```bash
graphify install --project --platform codex
graphify .
```

生成后会有：

```text
graphify-out/
├── graph.html
├── GRAPH_REPORT.md
└── graph.json
```

如果 `graphify` 可用且 `graphify-out/graph.json` 存在，`tools/laoc-memory-ask.sh` 会优先走图谱查询；失败再回退到文本检索。

## 7. 配置老G

老G是外部复核席，不是执行者。便携默认 provider 是官方 `agy`；先在鹏哥机器上完成安装和登录，再检查本地命令：

```bash
command -v agy
export LAOG_PROVIDER=agy
```

也可以显式选 Kimi，或接一个遵守 `COMMAND "PROMPT"` 输入合同的自有可执行文件：

```bash
export LAOG_PROVIDER=kimi

# 自有 CLI：只填单个可执行文件，不填 shell 片段
export LAOG_PROVIDER=custom
export LAOG_CMD=/absolute/path/to/review-command
```

不要使用旧包里的占位名 `external_review`；它不是 Codex 内置命令。

正式复核前跑无敏感健康检查：

```bash
tools/check-laog-health.sh cases/<case>/laog/health
```

把最小必要证据写进 request 文件，再由固定入口调用：

```bash
tools/laoc-ask-laog.sh cases/<case>/laog/request.md cases/<case>/laog
```

成功合同：`cases/<case>/laog/response.md` 存在且非空，`run.log` 包含 `status=ok`。如果健康检查失败、provider 失败、空输出或平台在进程启动前拒绝外发，都不能算成功。

平台前置拒绝应记为 `policy_blocked`：这不是等待鹏哥审批，也不能据此判断老G接口坏了。长期授权不能覆盖宿主平台安全门禁；不要用其他命令、代理或 curl 绕过。人工转发最小脱敏稿仍是合规 fallback。

老C问老G的标准提示词：

```text
你是鹏哥项目的外部复核席“老G”。请只做审查和质疑，不写文件，不假设你看到本地真实文件。

请检查以下方案/结果的漏洞：
1. 事实依据是否不足
2. 是否有遗漏的业务边界
3. 是否有验证缺口
4. 哪些结论必须回到源码/日志/数据里确认

待审内容：
...
```

老C汇总时必须写：

```text
老G意见：
共识：
分歧：
老C裁决：
需要验证的下一步：
```

## 8. 配置 tools / MCP

先跑本地工具检查：

```bash
tools/check-laoc-tools.sh
```

推荐能力分层：

- 必需：`git`、`rg`、`python3`、项目自己的构建/测试工具。
- 强推荐：`gh`，用于 GitHub issues、PR、checks、workflow runs。
- 强推荐：官方 `agy` 或鹏哥显式配置的 review CLI，用作老G。
- 推荐：`graphify`，用于图谱记忆增强档。
- 可选 MCP：GitHub、浏览器/Playwright、graphify MCP、文件/数据库只读查询。

MCP 配置看 `mcp/README.md` 和 `mcp/mcp.local.template.jsonc`。原则是：

- 只提交模板，不提交真实 token。
- 真正的 MCP 配置放在鹏哥机器的本地配置路径或 Codex/IDE 私有配置里。
- MCP 是能力入口，不是事实源；结果仍要回到文件、日志、GitHub、数据和鹏哥确认。

## 9. 验收安装是否成功

在鹏哥项目根执行：

```bash
test -f AGENTS.md
test -d skills/laoc-shikagami
test -x tools/laoc-memory-ask.sh
test -x tools/check-laog-health.sh
test -x tools/laoc-ask-laog.sh
tools/check-laoc-tools.sh
tools/laoc-memory-ask.sh "老C应该怎么验收"
```

如果装了 graphify：

```bash
graphify --version
tools/laoc-graph-rebuild.sh
test -f graphify-out/graph.json
```

让老C做一次自检：

```text
请按 laoc-shikagami 读取本项目规则，说明你怎么称呼我、遇到开放问题怎么查、交付前怎么验、什么时候问老G。
```

通过标准：

- 老C称呼“鹏哥”。
- 老C能说出知 -> 行 -> 验 -> 结。
- 老C知道先查 `memory/`、`cases/`、`AGENTS.md`、源码和日志。
- 老C知道方案烤问一次只问一个关键问题，并给推荐答案。
- 老C知道交付前做存在、实质、接线、功能四层验收。
- 老C知道老G只做复核，不当事实源。
- 老C知道兼听成功必须有 `response.md` 和 `run.log: status=ok`，也知道 `policy_blocked` 不能绕过。
- 老C不会说“没验证也算完成”。

## 10. 后续使用口令

鹏哥可以直接这样说：

- “老C，按 Shikagami 看下这个问题。”
- “老C，先查记忆和图谱，这事之前怎么定的？”
- “老C，方案烤问一下，一次问一个。”
- “老C，走鹿行，直接改完并验证。”
- “老C，走鹿验，看看能不能交。”
- “老C，问老G兼听则明，然后你裁决。”
- “老C，鹿结一下，下次能接着跑。”
