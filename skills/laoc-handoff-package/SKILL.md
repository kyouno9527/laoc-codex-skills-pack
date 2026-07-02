---
name: laoc-handoff-package
description: 给鹏哥准备可交付给同事或外部的材料包。用于文档、配置、补丁、脚本、上线包、分析报告等交付。
---

# 老C交付包

## 何时用

- 鹏哥说“给某人一份”“打包”“交付”“发给主策/技术/同事”。
- 需要把结果从聊天变成可打开、可审、可转发的材料。

## 交付纪律

- “给某人”默认是给鹏哥准备，不等于直接写进对方工作区。
- 交付包必须包含说明文件，推荐 HTML + Markdown。
- 包内写清来源、范围、使用步骤、验证结果、风险和人工跟进项。
- 不放密钥、cookie、token、私密账号材料、浏览器 profile。
- 如果包含补丁或脚本，说明目标路径和应用方式。

## 推荐结构

```text
deliverables/YYYY-MM-DD-topic/
├── README.md
├── HANDOFF.html
├── docs/
├── patches/
├── scripts/
└── validation/
```

## 验收

- HTML 能打开。
- README 能独立说明怎么用。
- 文件名和目录名让接手人能看懂。
- 验证结果和剩余风险明确。
