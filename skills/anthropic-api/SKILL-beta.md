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
