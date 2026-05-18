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

## Organizations

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/me` | [`admin/organizations/me.md`](docs-snapshot/platform.claude.com/en/api/admin/organizations/me.md) |
| Admin API section index | [`admin.md`](docs-snapshot/platform.claude.com/en/api/admin.md) |

Returns the current organization (the one tied to the API key).

## Workspaces

Workspaces partition an organization for cost / quota / member scope.

| Endpoint | Page |
|---|---|
| `POST /v1/organizations/workspaces` | [`admin/workspaces/create.md`](docs-snapshot/platform.claude.com/en/api/admin/workspaces/create.md) |
| `GET /v1/organizations/workspaces` | [`admin/workspaces/list.md`](docs-snapshot/platform.claude.com/en/api/admin/workspaces/list.md) |
| `POST /v1/organizations/workspaces/{id}/archive` | [`admin/workspaces/archive.md`](docs-snapshot/platform.claude.com/en/api/admin/workspaces/archive.md) |

Workspace members:

| Endpoint | Page |
|---|---|
| `POST /v1/organizations/workspaces/{id}/members` | [`admin/workspaces/members/create.md`](docs-snapshot/platform.claude.com/en/api/admin/workspaces/members/create.md) |
| `GET /v1/organizations/workspaces/{id}/members` | [`admin/workspaces/members.md`](docs-snapshot/platform.claude.com/en/api/admin/workspaces/members.md) |
| `DELETE /v1/organizations/workspaces/{id}/members/{user_id}` | [`admin/workspaces/members/delete.md`](docs-snapshot/platform.claude.com/en/api/admin/workspaces/members/delete.md) |

## Users

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/users` | [`admin/users/list.md`](docs-snapshot/platform.claude.com/en/api/admin/users/list.md) |
| `GET /v1/organizations/users/{id}` | [`admin/users/retrieve.md`](docs-snapshot/platform.claude.com/en/api/admin/users/retrieve.md) |
| `POST /v1/organizations/users/{id}` | [`admin/users/update.md`](docs-snapshot/platform.claude.com/en/api/admin/users/update.md) |
| `DELETE /v1/organizations/users/{id}` | [`admin/users/delete.md`](docs-snapshot/platform.claude.com/en/api/admin/users/delete.md) |

## API keys

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/api_keys` | [`admin/api_keys/list.md`](docs-snapshot/platform.claude.com/en/api/admin/api_keys/list.md) |
| `GET /v1/organizations/api_keys/{id}` | [`admin/api_keys/retrieve.md`](docs-snapshot/platform.claude.com/en/api/admin/api_keys/retrieve.md) |
| `POST /v1/organizations/api_keys/{id}` | [`admin/api_keys/update.md`](docs-snapshot/platform.claude.com/en/api/admin/api_keys/update.md) (can disable/revoke) |

## Invites

| Endpoint | Page |
|---|---|
| `POST /v1/organizations/invites` | [`admin/invites/create.md`](docs-snapshot/platform.claude.com/en/api/admin/invites/create.md) |
| `GET /v1/organizations/invites` | [`admin/invites/list.md`](docs-snapshot/platform.claude.com/en/api/admin/invites/list.md) |
| `GET /v1/organizations/invites/{id}` | [`admin/invites/retrieve.md`](docs-snapshot/platform.claude.com/en/api/admin/invites/retrieve.md) |
| `DELETE /v1/organizations/invites/{id}` | [`admin/invites/delete.md`](docs-snapshot/platform.claude.com/en/api/admin/invites/delete.md) |

## Usage reports

| Endpoint | Page | Returns |
|---|---|---|
| `GET /v1/organizations/usage_report/messages` | [`admin/usage_report/retrieve_messages.md`](docs-snapshot/platform.claude.com/en/api/admin/usage_report/retrieve_messages.md) | Messages API usage |
| `GET /v1/organizations/usage_report/claude_code` | [`admin/usage_report/retrieve_claude_code.md`](docs-snapshot/platform.claude.com/en/api/admin/usage_report/retrieve_claude_code.md) | Claude Code usage |

## Cost report

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/cost_report` | [`admin/cost_report/retrieve.md`](docs-snapshot/platform.claude.com/en/api/admin/cost_report/retrieve.md) |

## Rate limits

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/rate_limits` | [`admin/rate_limits/list.md`](docs-snapshot/platform.claude.com/en/api/admin/rate_limits/list.md) |

---

*Source pages: 23 under `platform.claude.com/docs/en/api/admin/`.*
