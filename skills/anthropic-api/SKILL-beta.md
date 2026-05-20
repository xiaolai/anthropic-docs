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

As of 2026-05-19 (from [`models/list.md`](https://platform.claude.com/docs/en/api/models/list.md)):

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
| `cache-diagnosis-2026-04-07` | Cache diagnostics — per-request cache hit/miss metadata |
| `mcp-tunnels-2026-05-19` | MCP Tunnels admin API (`/v1/organizations/tunnels/`) |

## Beta resource catalog

The beta API includes its own resources that mirror or extend the
stable API surface. Each lives at `/v1/...` with the beta header
required:

| Resource | Source dir |
|---|---|
| Beta API section index | [`beta.md`](https://platform.claude.com/docs/en/api/beta.md) |
| `agents/` | [`beta/agents/`](https://platform.claude.com/docs/en/api/beta/agents/) — CRUD + archive; `GET /v1/agents/{id}` retrieve |
| `agents/versions/` | [`beta/agents/versions/`](https://platform.claude.com/docs/en/api/beta/agents/versions.md) — list historical snapshots: `GET /v1/agents/{agent_id}/versions` (opaque `page` cursor, max 100); each item is a full `BetaManagedAgentsAgent` |
| `environments/` | [`beta/environments/`](https://platform.claude.com/docs/en/api/beta/environments/) |
| `environments/work/` | [`beta/environments/work/`](https://platform.claude.com/docs/en/api/beta/environments/work.md) — work-item queue for self-hosted sandbox environments (poll, ack, heartbeat, stop, stats); called automatically by SDK/CLI environment worker |
| `files/` | [`beta/files/`](https://platform.claude.com/docs/en/api/beta/files/) |
| `memory_stores/` | [`beta/memory_stores/`](https://platform.claude.com/docs/en/api/beta/memory_stores/) |
| `memory_stores/memory_versions/` | [`beta/memory_stores/memory_versions/`](https://platform.claude.com/docs/en/api/beta/memory_stores/memory_versions.md) — list/retrieve/redact individual memory write events. Filter by `api_key_id`, `memory_id`, `session_id`, `operation` (`created`/`modified`/`deleted`), or time range. `view=full` includes `content` + `path`; `view=basic` omits them. `POST .../redact` removes a version's content (sets `redacted_at`, nulls `content`/`path`). Response field `created_by`/`redacted_by` are typed `BetaManagedAgentsActor`. |
| `messages/` | [`beta/messages/`](https://platform.claude.com/docs/en/api/beta/messages/) (extends stable messages) |
| `models/` | [`beta/models/`](https://platform.claude.com/docs/en/api/beta/models/) |
| `sessions/` | [`beta/sessions/`](https://platform.claude.com/docs/en/api/beta/sessions/) |
| `sessions/events/` | [`beta/sessions/events/`](https://platform.claude.com/docs/en/api/beta/sessions/events.md) — list, send, and stream events within a session. `GET /v1/sessions/{id}/events` supports `types[]` filter and `created_at` range (gt/gte/lt/lte). `POST /v1/sessions/{id}/events` sends an event synchronously. Known event types: `user.message`, `user.interrupt`, `user.tool_confirmation`, `user.custom_tool_result`, `user.define_outcome`; `agent.message`, `agent.tool_use`, `agent.mcp_tool_use`, `agent.thinking`; `session.status_running`, `session.status_idle`, `session.error`, `session.terminated`; `span.outcome_evaluation_start`, `span.outcome_evaluation_end`. |
| `sessions/resources/` | [`beta/sessions/resources/`](https://platform.claude.com/docs/en/api/beta/sessions/resources.md) — add, list, retrieve, update, delete resources attached to a session |
| `sessions/threads/` | [`beta/sessions/threads/`](https://platform.claude.com/docs/en/api/beta/sessions/threads.md) — list, retrieve, archive threads within a session; thread events (list/stream) via `GET /v1/sessions/{session_id}/threads` |
| `skills/` | [`beta/skills/`](https://platform.claude.com/docs/en/api/beta/skills/) (Skills upload/management; `GET /v1/skills/{id}/versions/{ver}/content` downloads a version as a zip archive) |
| `user_profiles/` | [`beta/user_profiles/`](https://platform.claude.com/docs/en/api/beta/user_profiles/) |
| `vaults/` | [`beta/vaults/`](https://platform.claude.com/docs/en/api/beta/vaults/) |
| `vaults/credentials/mcp_oauth_validate` | [`beta/vaults/credentials/mcp_oauth_validate.md`](https://platform.claude.com/docs/en/api/beta/vaults/credentials/mcp_oauth_validate.md) — `POST /v1/vaults/{vault_id}/credentials/{credential_id}/mcp_oauth_validate`. Validates and optionally refreshes an OAuth credential. Response: `{ credential_id, vault_id, status: "valid"\|"invalid"\|"unknown", has_refresh_token, validated_at, refresh: { status: "succeeded"\|"failed"\|"connect_error"\|"no_refresh_token" }, mcp_probe: { method, http_response } }`. |
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

166 pages under
[`https://platform.claude.com/docs/en/api/beta/`](https://platform.claude.com/docs/en/api/beta/)
— see directory listing for the current per-endpoint set across
the 15 beta resources. (Updated 2026-05-20: added agents/versions, memory_stores/memory_versions, sessions/events, sessions/resources, vaults/credentials/mcp_oauth_validate.)

---

*Source pages: 166 under `platform.claude.com/docs/en/api/beta/`.*
