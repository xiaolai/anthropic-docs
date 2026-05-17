---
name: claude-cowork
description: |
  Router skill for Claude Cowork — the enterprise multi-cloud surface
  and Office agents. Cowork covers Claude for Work deployed on third-
  party clouds (Amazon Bedrock, Microsoft Foundry, LLM gateways),
  enterprise SSO, telemetry, the M365 connector, and policy controls.
  Office agents covers Claude in Excel and Slack-style office
  integrations.

  Use when the user asks about: deploying Claude for Work on Bedrock
  or Microsoft Foundry, integrating an LLM gateway, configuring
  enterprise SSO, enabling telemetry / audit logs, connecting M365,
  applying enterprise policies, Claude in Excel, or Slack-style
  office agent integrations.

  Skip: raw API on Bedrock / Vertex (use anthropic-platform-features),
  user-facing connectors directory (use claude-connectors), Claude
  Code CLI in enterprise contexts (use claude-code).
user-invocable: true
---

# Claude Cowork — Router

| Field | Value |
|---|---|
| **Source docs** | [claude.com/docs/en/cowork](https://claude.com/docs/en/cowork) |

> **This skill is auto-updated daily.** A pipeline reads the upstream
> docs and rewrites the per-surface files below. Section structure is
> stable; content drifts to track upstream.

## Dispatch table

| Surface file | Read when the user asks about… |
|---|---|
| [`SKILL-cowork.md`](SKILL-cowork.md) | Claude for Work multi-cloud — Bedrock, Microsoft Foundry, LLM gateways, enterprise SSO, telemetry, M365 connector, policy controls |
| [`SKILL-office-agents.md`](SKILL-office-agents.md) | Claude in Excel, Slack-style office integrations, office-agent capabilities & limits |

---

*This skill is auto-updated daily by a maintainer-run pipeline. File
issues at [xiaolai/claude-code-documentation-knowledge-autoupdated](https://github.com/xiaolai/claude-code-documentation-knowledge-autoupdated).*
