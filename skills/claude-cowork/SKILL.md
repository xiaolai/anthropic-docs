---
name: claude-cowork
description: |
  Claude Cowork (Claude for Work on third-party clouds) and Office agents.
  Use for deploying Claude for Work on Bedrock or Microsoft Foundry, LLM
  gateways, enterprise SSO, telemetry / audit logs, the M365 connector,
  enterprise policy controls, Claude in Excel, Slack-style office agent
  integrations. Skip: raw API on Bedrock / Vertex (use
  anthropic-platform-features), user-facing connectors directory (use
  claude-connectors), Claude Code CLI in enterprise contexts (use
  claude-code).
user-invocable: true
---

# Claude Cowork — Router

| Field | Value |
|---|---|
| **Source docs** | [claude.com/docs/en/cowork](https://claude.com/docs/en/cowork) |

> **This skill is auto-updated daily.** A pipeline reads the upstream
> docs and rewrites the per-surface files below. Section structure is
> stable; content drifts to track upstream.

## When to use

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

## Dispatch table

| Surface file | Read when the user asks about… |
|---|---|
| [`SKILL-cowork.md`](SKILL-cowork.md) | Claude for Work multi-cloud — Bedrock, Microsoft Foundry, LLM gateways, enterprise SSO, telemetry, M365 connector, policy controls |
| [`SKILL-office-agents.md`](SKILL-office-agents.md) | Claude in Excel, Slack-style office integrations, office-agent capabilities & limits |

## Examples

<example>
Context: An IT admin is rolling out Claude for Work.
user: "Can we deploy Claude for Work on Bedrock with our own SSO?"
assistant: Uses claude-cowork and reads the third-party cloud deployment and SSO surfaces.
</example>

<example>
Context: A developer calls the API directly on Vertex.
user: "Which model IDs does Vertex AI accept for Claude?"
assistant: Routes to anthropic-platform-features instead; raw cloud API access is covered there.
</example>

---

*This skill is auto-updated daily by a maintainer-run pipeline. File
issues at [xiaolai/anthropic-docs](https://github.com/xiaolai/anthropic-docs).*
