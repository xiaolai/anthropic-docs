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
- **Member roles:** workspace members have a `workspace_role` field
  distinct from org-level role; set on create, mutable via the members
  endpoint.
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
| `POST /v1/organizations/workspaces/{id}` | [`admin/workspaces/update.md`](https://platform.claude.com/docs/en/api/admin/workspaces/update.md) |
| `POST /v1/organizations/workspaces/{id}/archive` | [`admin/workspaces/archive.md`](https://platform.claude.com/docs/en/api/admin/workspaces/archive.md) |
| `GET /v1/organizations/workspaces/{id}/rate_limits` | [`admin/workspaces/rate_limits/list.md`](https://platform.claude.com/docs/en/api/admin/workspaces/rate_limits/list.md) |

Workspace members:

| Endpoint | Page |
|---|---|
| `POST /v1/organizations/workspaces/{id}/members` | [`admin/workspaces/members/create.md`](https://platform.claude.com/docs/en/api/admin/workspaces/members/create.md) |
| `GET /v1/organizations/workspaces/{id}/members` | [`admin/workspaces/members/list.md`](https://platform.claude.com/docs/en/api/admin/workspaces/members/list.md) |
| `GET /v1/organizations/workspaces/{id}/members/{user_id}` | [`admin/workspaces/members/retrieve.md`](https://platform.claude.com/docs/en/api/admin/workspaces/members/retrieve.md) |
| `POST /v1/organizations/workspaces/{id}/members/{user_id}` | [`admin/workspaces/members/update.md`](https://platform.claude.com/docs/en/api/admin/workspaces/members/update.md) |
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

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/rate_limits` | [`admin/rate_limits/list.md`](https://platform.claude.com/docs/en/api/admin/rate_limits/list.md) |

---

*Source pages: 37 under `platform.claude.com/docs/en/api/admin/`.*
