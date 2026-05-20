---
name: anthropic-api-admin
description: |
  Deep reference for the Anthropic Admin API — organizations,
  workspaces, users (list/get/update/delete), API keys (list/get/
  update), invites (create/list/get/delete), cost report, usage
  report (Messages + Claude Code variants), rate limits, and
  workspace member management.
source: https://platform.claude.com/docs/en/api/admin/
---

# Anthropic Admin API

> *Router lives in [`SKILL.md`](SKILL.md). All admin endpoints are
> under `/v1/organizations/...`. Requires an admin-scoped API key.*

## Key facts (at intent time)

- **Auth:** all admin endpoints require an **admin-scoped API key**
  (a separate key type — generated in the Anthropic Console under the
  org's API Keys section, restricted to admin users). Regular API keys
  return `403 admin_scope_required`.
- **No self-deletion:** an admin cannot delete the org via API, nor
  delete the workspace they're currently authenticated against. Use
  the Console for org/self deletion.
- **Cost report lag:** the cost report lags real-time usage by **~24
  hours** — it's an aggregated daily roll-up, not an event stream.
  For real-time visibility use the usage report or the activity feed
  (compliance API).
- **Pagination:** list endpoints use cursor pagination
  (`next_page` cursor + `has_more` boolean). Iterate until `has_more
  == false`. Default `limit` is 20, max is typically 100.
- **Workspaces vs orgs:** workspaces partition cost / quota / member
  scope inside one org. An org can have many workspaces; a workspace
  belongs to exactly one org.
- **Archived workspaces:** archive (not delete) is reversible. Once
  archived, no new requests bill against the workspace.
- **Org-level user roles:** `user`, `developer`, `billing`,
  `claude_code_user`. The `admin` role exists but cannot be set via
  the invite API (Console only). Source:
  [`admin.md`](https://platform.claude.com/docs/en/api/admin.md) (updated 2026-05-19).
- **Member roles:** workspace members have a `workspace_role` field
  distinct from org-level role; set on create, mutable via the Update
  Workspace Member endpoint. Valid values: `workspace_user`,
  `workspace_developer`, `workspace_restricted_developer`,
  `workspace_admin`, `workspace_billing`.
- **Workspace data residency:** the `Workspace` object includes a
  `data_residency` field with `allowed_inference_geos` (array of strings
  or `"unrestricted"`), `default_inference_geo` (string), and
  `workspace_geo` (string, immutable after creation). Update via
  `POST /v1/organizations/workspaces/{id}`.
- **Idempotency:** mutating endpoints (create / update / delete) do
  NOT currently support an `Idempotency-Key` header. Build retry
  logic with caller-side de-duplication.

## Organizations

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/me` | [`admin/organizations/me.md`](https://platform.claude.com/docs/en/api/admin/organizations/me.md) |
| Admin API section index | [`admin.md`](https://platform.claude.com/docs/en/api/admin.md) |

Returns the current organization (the one tied to the API key).

## Workspaces

Workspaces partition an organization for cost / quota / member scope.

| Endpoint | Page |
|---|---|
| `POST /v1/organizations/workspaces` | [`admin/workspaces/create.md`](https://platform.claude.com/docs/en/api/admin/workspaces/create.md) |
| `GET /v1/organizations/workspaces` | [`admin/workspaces/list.md`](https://platform.claude.com/docs/en/api/admin/workspaces/list.md) |
| `GET /v1/organizations/workspaces/{id}` | [`admin/workspaces/retrieve.md`](https://platform.claude.com/docs/en/api/admin/workspaces/retrieve.md) |
| `POST /v1/organizations/workspaces/{id}` | [`admin/workspaces/update.md`](https://platform.claude.com/docs/en/api/admin/workspaces/update.md) — update name or `data_residency` |
| `POST /v1/organizations/workspaces/{id}/archive` | [`admin/workspaces/archive.md`](https://platform.claude.com/docs/en/api/admin/workspaces/archive.md) |

Workspace members:

| Endpoint | Page |
|---|---|
| `POST /v1/organizations/workspaces/{id}/members` | [`admin/workspaces/members/create.md`](https://platform.claude.com/docs/en/api/admin/workspaces/members/create.md) |
| `GET /v1/organizations/workspaces/{id}/members` | [`admin/workspaces/members/list.md`](https://platform.claude.com/docs/en/api/admin/workspaces/members/list.md) |
| `GET /v1/organizations/workspaces/{id}/members/{user_id}` | [`admin/workspaces/members/retrieve.md`](https://platform.claude.com/docs/en/api/admin/workspaces/members/retrieve.md) |
| `POST /v1/organizations/workspaces/{id}/members/{user_id}` | [`admin/workspaces/members/update.md`](https://platform.claude.com/docs/en/api/admin/workspaces/members/update.md) — update `workspace_role` |
| `DELETE /v1/organizations/workspaces/{id}/members/{user_id}` | [`admin/workspaces/members/delete.md`](https://platform.claude.com/docs/en/api/admin/workspaces/members/delete.md) |

## Users

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/users` | [`admin/users/list.md`](https://platform.claude.com/docs/en/api/admin/users/list.md) |
| `GET /v1/organizations/users/{id}` | [`admin/users/retrieve.md`](https://platform.claude.com/docs/en/api/admin/users/retrieve.md) |
| `POST /v1/organizations/users/{id}` | [`admin/users/update.md`](https://platform.claude.com/docs/en/api/admin/users/update.md) |
| `DELETE /v1/organizations/users/{id}` | [`admin/users/delete.md`](https://platform.claude.com/docs/en/api/admin/users/delete.md) |

## API keys

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/api_keys` | [`admin/api_keys/list.md`](https://platform.claude.com/docs/en/api/admin/api_keys/list.md) |
| `GET /v1/organizations/api_keys/{id}` | [`admin/api_keys/retrieve.md`](https://platform.claude.com/docs/en/api/admin/api_keys/retrieve.md) |
| `POST /v1/organizations/api_keys/{id}` | [`admin/api_keys/update.md`](https://platform.claude.com/docs/en/api/admin/api_keys/update.md) (can disable/revoke) |

## Invites

| Endpoint | Page |
|---|---|
| `POST /v1/organizations/invites` | [`admin/invites/create.md`](https://platform.claude.com/docs/en/api/admin/invites/create.md) |
| `GET /v1/organizations/invites` | [`admin/invites/list.md`](https://platform.claude.com/docs/en/api/admin/invites/list.md) |
| `GET /v1/organizations/invites/{id}` | [`admin/invites/retrieve.md`](https://platform.claude.com/docs/en/api/admin/invites/retrieve.md) |
| `DELETE /v1/organizations/invites/{id}` | [`admin/invites/delete.md`](https://platform.claude.com/docs/en/api/admin/invites/delete.md) |

## Usage reports

| Endpoint | Page | Returns |
|---|---|---|
| `GET /v1/organizations/usage_report/messages` | [`admin/usage_report/retrieve_messages.md`](https://platform.claude.com/docs/en/api/admin/usage_report/retrieve_messages.md) | Messages API usage |
| `GET /v1/organizations/usage_report/claude_code` | [`admin/usage_report/retrieve_claude_code.md`](https://platform.claude.com/docs/en/api/admin/usage_report/retrieve_claude_code.md) | Claude Code usage |

**Messages usage report** `group_by` options: `api_key_id`, `workspace_id`, `model`, `service_tier`, `context_window`, `inference_geo`, `speed` (requires `fast-mode-2026-02-01` beta header), `account_id`, `service_account_id`.

**Messages usage report** `service_tiers` filter accepts: `"standard"`, `"batch"`, `"priority"`, `"priority_on_demand"`, `"flex"`, `"flex_discount"`.

**Messages usage report** filter params: `account_ids`, `api_key_ids`, `workspace_ids`, `models`, `service_tiers`, `speeds`, `inference_geos`, `service_account_ids`.

**Messages usage report** `bucket_width` options (time granularity of the response):

| `bucket_width` | Default | Maximum |
|---|---|---|
| `"1d"` (default) | 7 days | 31 days |
| `"1h"` | 24 hours | 168 hours (7 days) |
| `"1m"` | 60 minutes | 1440 minutes (24 hours) |

**Messages usage report** `speeds` filter: `"standard"` or `"fast"` (Claude Code research preview; requires `fast-mode-2026-02-01` beta header when `group_by` includes `speed`).

**Messages usage report** `inference_geos` filter values: `"global"`, `"us"`, `"not_available"` (use `not_available` for models that do not support specifying `inference_geo`).

**Messages usage report** response `results[]` key fields: `account_id`, `api_key_id`, `cache_creation` (`ephemeral_1h_input_tokens`, `ephemeral_5m_input_tokens`), `cache_read_input_tokens`, `context_window`, `inference_geo`, `model`, `output_tokens`, `server_tool_use.web_search_requests`, `service_account_id`, `service_tier`, `uncached_input_tokens`, `workspace_id`.

Source: [`admin/usage_report/retrieve_messages.md`](https://platform.claude.com/docs/en/api/admin/usage_report/retrieve_messages.md) (updated 2026-05-20).

## Cost report

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/cost_report` | [`admin/cost_report/retrieve.md`](https://platform.claude.com/docs/en/api/admin/cost_report/retrieve.md) |

Response schema — `CostReport.data[].results[]` key fields (source: [`admin/cost_report/retrieve.md`](https://platform.claude.com/docs/en/api/admin/cost_report/retrieve.md), updated 2026-05-20):

| Field | Type | Notes |
|---|---|---|
| `cost_type` | string | `"tokens"` \| `"web_search"` \| `"code_execution"` \| `"session_usage"`. `null` if not grouping by `description`. |
| `token_type` | string | `"uncached_input_tokens"` \| `"output_tokens"` \| `"cache_read_input_tokens"` \| `"cache_creation.ephemeral_1h_input_tokens"` \| `"cache_creation.ephemeral_5m_input_tokens"`. Token costs only. |
| `service_tier` | string | `"standard"` \| `"batch"`. Token costs only; `null` otherwise. |
| `context_window` | string | `"0-200k"` \| `"200k-1M"`. Token costs only; `null` otherwise. |
| `inference_geo` | string | Geographic region (or `"not_available"` for models that don't support it). |
| `description` | string | Human-readable cost description (only when `group_by` includes `"description"`). |

Query `group_by` options: `"workspace_id"`, `"description"`. Only `"1d"` bucket width is supported.
Default lag: ~24 hours (daily roll-up, not real-time).

## Rate limits

### Organization-level

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/rate_limits` | [`admin/rate_limits/list.md`](https://platform.claude.com/docs/en/api/admin/rate_limits/list.md) |

### Workspace-level

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/workspaces/{id}/rate_limits` | [`admin/workspaces/rate_limits/list.md`](https://platform.claude.com/docs/en/api/admin/workspaces/rate_limits/list.md) |

Returns only groups with a workspace-level override (not the org-default
groups). Filter by `group_type`: `model_group`, `batch`, `token_count`,
`files`, `skills`, `web_search`. Uses opaque-cursor pagination (`page`
query param + `next_page` in response).

## MCP Tunnels

MCP Tunnels provide Anthropic-hosted ingress for self-hosted MCP servers.
All Tunnel endpoints require the beta header `anthropic-beta: mcp-tunnels-2026-05-19`.

| Endpoint | Page | Purpose |
|---|---|---|
| `GET /v1/organizations/tunnels` | [`admin/mcp_tunnels/list.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/list.md) | List tunnels (filter by `workspace_id`; optionally include archived) |
| `GET /v1/organizations/tunnels/{id}` | [`admin/mcp_tunnels/retrieve.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/retrieve.md) | Retrieve a tunnel |
| `POST /v1/organizations/tunnels/{id}/archive` | [`admin/mcp_tunnels/archive.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/archive.md) | Archive a tunnel (reversible) |
| `POST /v1/organizations/tunnels/{id}/reveal_token` | [`admin/mcp_tunnels/reveal_token.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/reveal_token.md) | Reveal connection token (live fetch; Anthropic does not store it) |
| `POST /v1/organizations/tunnels/{id}/rotate_token` | [`admin/mcp_tunnels/rotate_token.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/rotate_token.md) | Rotate connection token |

Tunnel certificates (CA verification for inner TLS):

| Endpoint | Page | Purpose |
|---|---|---|
| `POST /v1/organizations/tunnels/{id}/certificates` | [`admin/mcp_tunnels/tunnel_certificates/create.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/tunnel_certificates/create.md) | Register a CA cert (PEM, at most 2 non-archived per tunnel) |
| `GET /v1/organizations/tunnels/{id}/certificates` | [`admin/mcp_tunnels/tunnel_certificates/list.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/tunnel_certificates/list.md) | List certificates |
| `GET /v1/organizations/tunnels/{id}/certificates/{cert_id}` | [`admin/mcp_tunnels/tunnel_certificates/retrieve.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/tunnel_certificates/retrieve.md) | Retrieve a certificate |
| `POST /v1/organizations/tunnels/{id}/certificates/{cert_id}/archive` | [`admin/mcp_tunnels/tunnel_certificates/archive.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/tunnel_certificates/archive.md) | Archive a certificate |

Key facts:
- The `domain` field on a tunnel is an Anthropic-assigned hostname; MCP server URLs whose host is a subdomain of `domain` are routed through the tunnel. Globally unique, never reused after archival.
- `reveal_token` is `POST` intentionally — the token does not appear in intermediary access logs.
- A tunnel holds at most **2 non-archived certificates**.
- The `workspace_id` on a tunnel is immutable after creation.

Source: [`admin/mcp_tunnels.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels.md) (added 2026-05-19).

---

*Source pages: 48 under `platform.claude.com/docs/en/api/admin/`.*
