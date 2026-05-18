---
name: anthropic-api
description: |
  Router skill for the Anthropic Messages API and adjacent surfaces
  (admin endpoints, compliance, beta features, models catalog) hosted
  under platform.claude.com/docs/en/api/.

  Use when the user asks about: POST /v1/messages, tool_use / tool_result
  blocks, count_tokens, message batches, streaming responses, prompt
  caching, prompt cache TTL / breakpoints, system prompts, anthropic-beta
  headers, the admin API (organizations / workspaces / API keys /
  invites), compliance endpoints (data residency, audit logs, retention),
  beta-only features behind a beta header, or the models catalog
  (model IDs, deprecation dates, context window sizes).

  Skip: questions about Claude Code (use claude-code skill), the
  Claude Agent SDK (use claude-agent-sdk), platform features beyond
  the raw API such as Agent Skills format or tool-use guides (use
  anthropic-platform-features), MCP connector docs (claude-connectors),
  or per-language auto-generated SDK reference (use anthropic-sdk's
  TypeScript / Python types directly via your IDE).
user-invocable: true
---

# Anthropic API Reference — Router

| Field | Value |
|---|---|
| **API base** | `https://api.anthropic.com/v1/` |
| **Source docs** | [platform.claude.com/docs/en/api](https://platform.claude.com/docs/en/api) |
| **TypeScript SDK** | [`@anthropic-ai/sdk`](https://www.npmjs.com/package/@anthropic-ai/sdk) |
| **Python SDK** | [`anthropic`](https://pypi.org/project/anthropic/) |

> **This skill is auto-updated every 30 min.** A pipeline reads the upstream
> docs and rewrites the per-surface files below. Section structure is
> stable; content drifts to track upstream.

## Dispatch table

| Surface file | Read when the user asks about… |
|---|---|
| [`SKILL-messages.md`](SKILL-messages.md) | `POST /v1/messages`, request/response shape, `tool_use` / `tool_result` content blocks, streaming (`stream: true`), system prompts, `count_tokens`, message batches; also legacy `/v1/complete` (text completions) |
| [`SKILL-admin.md`](SKILL-admin.md) | admin API — organizations, workspaces, API keys, invites, usage reports, cost reports |
| [`SKILL-compliance.md`](SKILL-compliance.md) | data residency, audit logs, retention policies, compliance API endpoints |
| [`SKILL-beta.md`](SKILL-beta.md) | features gated behind `anthropic-beta` header, beta endpoints, opt-in feature flags |
| [`SKILL-models.md`](SKILL-models.md) | model IDs (`claude-opus-4-7`, `claude-sonnet-4-6`, `claude-haiku-4-5-20251001`, …), context window sizes, deprecation dates, model card / capabilities |

> **Out of scope for this skill** (intentionally excluded by `docsPathFilter`):
> the auto-generated per-language SDK reference under
> `platform.claude.com/docs/en/api/{cli,csharp,go,java,php,python,ruby,terraform,typescript}/`
> (~1100 pages). Use your IDE's type-defs from `@anthropic-ai/sdk`
> (npm) or `anthropic` (PyPI) for those — they ship the authoritative
> signatures and stay in sync with the SDK release you're using.

## Auto-correction rules

| Rule file | Triggers on edits to |
|---|---|
| `rules/messages-api.md` | code calling `client.messages.create`, `POST /v1/messages`, or constructing `tool_use` / `tool_result` content blocks |

---

*This skill is auto-updated every 30 minutes by a maintainer-run pipeline. File
issues at [xiaolai/autoupdated-anthropic-documentation-knowledge](https://github.com/xiaolai/autoupdated-anthropic-documentation-knowledge) —
SKILL fixes flow through the next research run, not via PRs.*
