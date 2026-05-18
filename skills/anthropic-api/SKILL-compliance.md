---
name: anthropic-api-compliance
description: |
  Deep reference for the Anthropic Compliance API endpoints — audit
  logs, content records, org-level data, activity feeds, and the
  integration patterns for SIEM / DLP / compliance monitoring tools.
source: https://platform.claude.com/docs/en/api/compliance/
---

# Anthropic Compliance API

> *Router lives in [`SKILL.md`](SKILL.md). For the conceptual
> overview (what the compliance API exposes and why), see
> [`anthropic-platform-features → SKILL-manage-claude.md`](../anthropic-platform-features/SKILL-manage-claude.md).
> This surface is the wire reference.*

## Audience

Compliance API access is gated by organization plan + admin
scope. Typical consumers: security teams running SIEMs, DLP teams
monitoring sensitive-content flow, compliance officers building
audit reports.

## Key facts (at intent time)

- **Auth:** uses an **admin-scoped API key**, not a regular API key.
  Mint one in the Anthropic Console under the org's API Keys section
  (admin-only).
- **Header:** standard `x-api-key: <admin-key>` plus the usual
  `anthropic-version`. No `anthropic-beta` header required (compliance
  is stable, not beta).
- **Plan gating:** Compliance API endpoints return `403` for orgs
  without the required plan. Check eligibility at
  [`compliance-api-access`](https://platform.claude.com/docs/en/manage-claude/compliance-api-access.md)
  before integration.
- **Pagination:** all list endpoints use cursor pagination
  (`next_page` field in the response). Treat as a stream.
- **Retention:** activity feed events are retained per the org's
  data-retention setting (default 30d, longer on enterprise plans).
  See [`api-and-data-retention`](https://platform.claude.com/docs/en/manage-claude/api-and-data-retention.md).
- **Rate limits:** compliance endpoints are subject to their own
  rate-limit bucket, separate from Messages rate limits. Monitor
  via the rate-limits API.
- **Concept overview** lives in
  [`anthropic-platform-features → SKILL-manage-claude.md`](../anthropic-platform-features/SKILL-manage-claude.md);
  this surface is the wire reference.

## Endpoint catalog

Base path: **`/v1/compliance/...`** (not `/v1/organizations/compliance/...`).

### Activity feed

| Endpoint | Notes |
|---|---|
| `GET /v1/compliance/activities` | [`compliance/activities/list.md`](https://platform.claude.com/docs/en/api/compliance/activities/list.md) — filter by `activity_types` (295+ event types), time ranges, user IDs, org IDs. Cursor paginated via `next_page`. |

Common `activity_types` values: `account_deleted`, `admin_api_key_created/deleted/updated`, `api_key_created`, `scoped_api_key_deleted/updated`, `claude_chat_created/deleted/updated`, `claude_file_uploaded/deleted/viewed`, `claude_project_created/archived/deleted`, `claude_project_document_uploaded/deleted`, `claude_artifact_published/deleted/viewed`.

### Apps — chats & projects

| Endpoint | Notes |
|---|---|
| `GET /v1/compliance/apps/chats` | [`compliance/apps/chats/list.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/list.md) — **`user_ids` required** (1–10 per call); filter by org, project, time ranges |
| `GET /v1/compliance/apps/chats/{id}/messages` | [`compliance/apps/chats/messages.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/messages.md) |
| `DELETE /v1/compliance/apps/chats/{id}` | [`compliance/apps/chats/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/delete.md) |
| `GET /v1/compliance/apps/chats/{id}/files` | [`compliance/apps/chats/files.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/files.md) |
| `GET /v1/compliance/apps/chats/{id}/files/{fid}/content` | [`compliance/apps/chats/files/content.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/files/content.md) |
| `DELETE /v1/compliance/apps/chats/{id}/files/{fid}` | [`compliance/apps/chats/files/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/files/delete.md) |
| `GET /v1/compliance/apps/chats/{id}/generated_files` | [`compliance/apps/chats/generated_files.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/generated_files.md) |
| `GET /v1/compliance/apps/projects` | [`compliance/apps/projects/list.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/list.md) |
| `GET /v1/compliance/apps/projects/{id}` | [`compliance/apps/projects/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/retrieve.md) |
| `DELETE /v1/compliance/apps/projects/{id}` | [`compliance/apps/projects/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/delete.md) |
| `GET /v1/compliance/apps/projects/{id}/documents` | [`compliance/apps/projects/documents.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/documents.md) |
| `GET /v1/compliance/apps/artifacts/{id}/content` | [`compliance/apps/artifacts/content.md`](https://platform.claude.com/docs/en/api/compliance/apps/artifacts/content.md) |

### Groups

| Endpoint | Notes |
|---|---|
| `GET /v1/compliance/groups` | [`compliance/groups/list.md`](https://platform.claude.com/docs/en/api/compliance/groups/list.md) — `name_prefix` filter, default limit 500, max 1000 |
| `GET /v1/compliance/groups/{id}` | [`compliance/groups/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/groups/retrieve.md) |
| `GET /v1/compliance/groups/{id}/members` | [`compliance/groups/members/list.md`](https://platform.claude.com/docs/en/api/compliance/groups/members/list.md) |

Group object fields: `id`, `created_at`, `description`, `name`, `roles` (role IDs), `source_type` (`direct` or `scim`), `updated_at`.

### Organizations

| Endpoint | Notes |
|---|---|
| `GET /v1/compliance/organizations` | [`compliance/organizations/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/list.md) |
| `GET /v1/compliance/organizations/{id}/users` | [`compliance/organizations/users/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/users/list.md) |
| `GET /v1/compliance/organizations/{id}/roles` | [`compliance/organizations/roles/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/list.md) |
| `GET /v1/compliance/organizations/{id}/roles/{role_id}` | [`compliance/organizations/roles/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/retrieve.md) |
| `GET /v1/compliance/organizations/{id}/roles/{role_id}/permissions` | [`compliance/organizations/roles/permissions/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/permissions/list.md) |

## Source pages

~37 pages under
[`https://platform.claude.com/docs/en/api/compliance/`](https://platform.claude.com/docs/en/api/compliance/)
— see directory listing for the current per-endpoint set.

---

*Source pages: ~37 under `platform.claude.com/docs/en/api/compliance/`.*
