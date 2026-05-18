---
name: anthropic-api-beta
description: |
  Deep reference for Anthropic Beta API surfaces — features
  gated behind the `anthropic-beta` header, plus the
  beta-specific resource catalog (agents, environments, files,
  memory stores, messages, models, sessions, skills, user
  profiles, vaults, webhooks).
source: https://platform.claude.com/docs/en/api/beta/
---

# Anthropic Beta API

> *Router lives in [`SKILL.md`](SKILL.md). Beta features may
> graduate to non-beta, change shape, or be retired. Pin the
> beta header for stability.*

## The `anthropic-beta` header

Beta endpoints and features require:

```
anthropic-beta: <feature-name-1>,<feature-name-2>,...
```

Multiple beta features can be enabled in one request (comma-separated).
Without the header, beta endpoints return 404 / 400 and beta features
on non-beta endpoints are ignored.

### Known beta feature strings

As of 2026-05-18 (from [`models/list.md`](https://platform.claude.com/docs/en/api/models/list.md)):

| Beta string | Feature |
|---|---|
| `message-batches-2024-09-24` | Message batches (graduated — header kept for compat) |
| `prompt-caching-2024-07-31` | Prompt caching (graduated) |
| `computer-use-2024-10-22` | Computer use (older variant) |
| `computer-use-2025-01-24` | Computer use (newer variant) |
| `pdfs-2024-09-25` | PDF input support |
| `token-counting-2024-11-01` | Token counting endpoint |
| `token-efficient-tools-2025-02-19` | Token-efficient tool call encoding |
| `output-128k-2025-02-19` | 128k output tokens |
| `files-api-2025-04-14` | Files API (`/v1/beta/files/`) |
| `mcp-client-2025-04-04` | MCP client integration (older) |
| `mcp-client-2025-11-20` | MCP client integration (newer) |
| `dev-full-thinking-2025-05-14` | Full thinking in dev mode |
| `interleaved-thinking-2025-05-14` | Interleaved (streamed) thinking |
| `code-execution-2025-05-22` | Code execution server tool |
| `extended-cache-ttl-2025-04-11` | Extended cache TTL (`1h` in `cache_control`) |
| `context-1m-2025-08-07` | 1M token context window |
| `context-management-2025-06-27` | Context management strategies |
| `model-context-window-exceeded-2025-08-26` | Explicit context-window-exceeded error signal |
| `skills-2025-10-02` | Skills API (`/v1/beta/skills/`) |
| `fast-mode-2026-02-01` | Fast mode for supported models |
| `output-300k-2026-03-24` | 300k output tokens |
| `user-profiles-2026-03-24` | User profiles API (`/v1/beta/user_profiles/`) |
| `advisor-tool-2026-03-01` | Advisor server tool |
| `managed-agents-2026-04-01` | Managed agents (agents / sessions / environments) |

## Beta resource catalog

The beta API includes its own resources that mirror or extend the
stable API surface. Each lives at `/v1/...` with the beta header
required:

| Resource | Source dir |
|---|---|
| Beta API section index | [`beta.md`](https://platform.claude.com/docs/en/api/beta.md) |
| `agents/` | [`beta/agents/`](https://platform.claude.com/docs/en/api/beta/agents/) |
| `environments/` | [`beta/environments/`](https://platform.claude.com/docs/en/api/beta/environments/) |
| `files/` | [`beta/files/`](https://platform.claude.com/docs/en/api/beta/files/) |
| `memory_stores/` | [`beta/memory_stores/`](https://platform.claude.com/docs/en/api/beta/memory_stores/) |
| `messages/` | [`beta/messages/`](https://platform.claude.com/docs/en/api/beta/messages/) (extends stable messages) |
| `models/` | [`beta/models/`](https://platform.claude.com/docs/en/api/beta/models/) |
| `sessions/` | [`beta/sessions/`](https://platform.claude.com/docs/en/api/beta/sessions/) |
| `skills/` | [`beta/skills/`](https://platform.claude.com/docs/en/api/beta/skills/) (Skills upload/management API) |
| `user_profiles/` | [`beta/user_profiles/`](https://platform.claude.com/docs/en/api/beta/user_profiles/) |
| `vaults/` | [`beta/vaults/`](https://platform.claude.com/docs/en/api/beta/vaults/) |
| `webhooks.md` | [`beta/webhooks.md`](https://platform.claude.com/docs/en/api/beta/webhooks.md) |

Most of these align with the Managed Agents product surface —
see [`anthropic-platform-features → SKILL-managed-agents.md`](../anthropic-platform-features/SKILL-managed-agents.md)
for conceptual coverage of agents / sessions / skills / vaults /
memory.

## Graduation

When a beta graduates to stable:

1. The endpoint becomes available without the `anthropic-beta` header.
2. Existing beta-header requests continue working unchanged for a
   deprecation window.
3. After the window, the beta header for that feature becomes a no-op.

When a beta is retired:

1. Requests with the beta header start returning a deprecation warning.
2. After the announced sunset date, the feature returns 404 / 400.

## Source pages

107 pages under
[`https://platform.claude.com/docs/en/api/beta/`](https://platform.claude.com/docs/en/api/beta/)
— see directory listing for the current per-endpoint set across
the 11 beta resources.

---

*Source pages: 107 under `platform.claude.com/docs/en/api/beta/`.*
