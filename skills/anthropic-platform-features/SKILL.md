---
name: anthropic-platform-features
description: |
  Router skill for Anthropic platform-side features that sit above the
  raw Messages API: Agent Skills format (the spec for `.skill` packages
  used by platform-managed agents), MCP connectors hosted by Anthropic,
  tool use (computer use, code execution, bash tool, define-your-own
  tools), build-with-claude features (extended thinking, message
  batches, citations, Amazon Bedrock, Google Vertex, embeddings, fast
  mode, context editing), manage-claude operations (workload identity
  federation, billing, identity), and the Managed Agents product.

  Use when the user asks about: writing an Agent Skill `.skill` package,
  Anthropic's hosted MCP connector, MCP Tunnels (connecting private-network
  MCP servers without opening inbound ports), the computer-use tool, the
  code_execution tool, bash tool, extended thinking, message batches,
  prompt caching strategy at the platform level, citations, deploying
  via Bedrock or Vertex, embeddings models, fast-mode behavior,
  context editing strategies, WIF setup, billing / cost reports,
  identity & SSO setup, customer-managed encryption keys (CMEK via
  AWS KMS / Google Cloud KMS / Azure Key Vault), the Managed Agents
  product, or self-hosted sandboxes (running agent sessions in your
  own infrastructure).

  Skip: raw POST /v1/messages requests (use anthropic-api), Claude
  Code CLI (use claude-code), Claude Agent SDK (use claude-agent-sdk),
  user-facing Claude Connectors directory (use claude-connectors).
user-invocable: true
---

# Anthropic Platform Features — Router

| Field | Value |
|---|---|
| **Source docs** | [platform.claude.com/docs](https://platform.claude.com/docs) |

> **This skill is auto-updated daily.** A pipeline reads the upstream
> docs and rewrites the per-surface files below. Section structure is
> stable; content drifts to track upstream.

## Dispatch table

| Surface file | Read when the user asks about… |
|---|---|
| [`SKILL-agents-and-tools.md`](SKILL-agents-and-tools.md) | Agent Skills format spec, MCP connector, MCP Tunnels (private-network MCP servers), remote MCP servers, tool use (computer use, code execution, bash, define-your-own tools), tool_choice |
| [`SKILL-build-with-claude.md`](SKILL-build-with-claude.md) | extended thinking, message batches, prompt caching, citations, Amazon Bedrock, Google Vertex, embeddings, fast mode, context editing, vision; also platform foundation (`intro`, `get-started`) and guardrails / streaming-refusals from `test-and-evaluate/` |
| [`SKILL-manage-claude.md`](SKILL-manage-claude.md) | workload identity federation (WIF), billing & usage, organizations & workspaces operations, identity & SSO, customer-managed encryption keys (CMEK) |
| [`SKILL-managed-agents.md`](SKILL-managed-agents.md) | Managed Agents product — agent definitions, deployment, lifecycle, monitoring, self-hosted sandboxes |

---

*This skill is auto-updated daily by a maintainer-run pipeline. File
issues at [xiaolai/anthropic-docs](https://github.com/xiaolai/anthropic-docs).*
