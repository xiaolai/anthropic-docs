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

## Cost report

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/cost_report` | [`admin/cost_report/retrieve.md`](https://platform.claude.com/docs/en/api/admin/cost_report/retrieve.md) |

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

Admin endpoints for managing MCP Tunnel registrations and their TLS certificates.
Added 2026-05-19.

**Key facts:**
- **Auth:** WIF (Workload Identity Federation) — `Authorization: Bearer $ANTHROPIC_WIF_BEARER_TOKEN`, **not** `x-api-key`.
- **Beta header required:** `anthropic-beta: mcp-tunnels-2026-05-19` on all tunnel endpoints.
- **Base path:** `/v1/organizations/tunnels/`
- **Tunnel domain:** each tunnel has an Anthropic-assigned `domain`; MCP server URLs whose host is a subdomain of that value are routed through the tunnel. Globally unique; never reused after archive.
- **Tunnel limit per workspace:** at most two non-archived certificates per tunnel.
- **Token lifecycle:** the connection token is fetched live on each `reveal_token` call. Repeated calls return the same value until `rotate_token` is called.

| Endpoint | Description | Page |
|---|---|---|
| `GET /v1/organizations/tunnels` | List tunnels (filter by `workspace_id`; use `include_archived` to see archived) | [`admin/mcp_tunnels/list.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/list.md) |
| `GET /v1/organizations/tunnels/{id}` | Retrieve a tunnel | [`admin/mcp_tunnels/retrieve.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/retrieve.md) |
| `POST /v1/organizations/tunnels/{id}/reveal_token` | Return current connection token (not stored by Anthropic) | [`admin/mcp_tunnels/reveal_token.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/reveal_token.md) |
| `POST /v1/organizations/tunnels/{id}/rotate_token` | Rotate connection token (invalidates previous) | [`admin/mcp_tunnels/rotate_token.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/rotate_token.md) |
| `POST /v1/organizations/tunnels/{id}/archive` | Archive tunnel (also archives all its certificates) | [`admin/mcp_tunnels/archive.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/archive.md) |

### Tunnel Certificates

Register CA certificates to verify the gateway's TLS server certificate.

| Endpoint | Description | Page |
|---|---|---|
| `POST /v1/organizations/tunnels/{id}/certificates` | Register a CA cert (PEM, one X.509 cert, no private key) | [`admin/mcp_tunnels/tunnel_certificates/create.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/tunnel_certificates/create.md) |
| `GET /v1/organizations/tunnels/{id}/certificates` | List certificates for a tunnel | [`admin/mcp_tunnels/tunnel_certificates/list.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/tunnel_certificates/list.md) |
| `GET /v1/organizations/tunnels/{id}/certificates/{cert_id}` | Retrieve a certificate | [`admin/mcp_tunnels/tunnel_certificates/retrieve.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/tunnel_certificates/retrieve.md) |
| `POST /v1/organizations/tunnels/{id}/certificates/{cert_id}/archive` | Archive a certificate | [`admin/mcp_tunnels/tunnel_certificates/archive.md`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels/tunnel_certificates/archive.md) |

Certificate response fields: `id`, `archived_at`, `created_at`, `expires_at`, `fingerprint` (SHA-256 lowercase hex), `tunnel_id`, `type: "tunnel_certificate"`.

Source: [`admin/mcp_tunnels/`](https://platform.claude.com/docs/en/api/admin/mcp_tunnels.md) (added 2026-05-19)

---

*Source pages: 48 under `platform.claude.com/docs/en/api/admin/` (37 original + 11 MCP tunnels).*
