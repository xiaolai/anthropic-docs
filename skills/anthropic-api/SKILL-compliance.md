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

- **Auth:** uses a **compliance API key** passed as
  `Authorization: Bearer <compliance-key>` (not the standard
  `x-api-key` header used by Messages / Admin endpoints). The key is
  distinct from admin-scoped API keys — mint it in the Anthropic
  Console under Compliance API settings.
- **Header:** `Authorization: Bearer <compliance-key>`. No
  `anthropic-version` or `anthropic-beta` header required.
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

All endpoints are under the base path `/v1/compliance/` (not
`/v1/organizations/compliance/`). Each page in the snapshot
documents one endpoint's parameters, response shape, and pagination.

### Activities

| Endpoint | Page |
|---|---|
| `GET /v1/compliance/activities` | [`compliance/activities/list.md`](https://platform.claude.com/docs/en/api/compliance/activities/list.md) — paginated event feed; filter by `activity_types` (292 event types including API key operations, chat events, workspace changes, SCIM, etc.), `user_id`, date range |

### Apps (Claude.ai chats and projects)

| Endpoint | Page |
|---|---|
| `GET /v1/compliance/apps/chats` | [`compliance/apps/chats/list.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/list.md) |
| `DELETE /v1/compliance/apps/chats/{id}` | [`compliance/apps/chats/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/delete.md) |
| `GET /v1/compliance/apps/chats/{id}/messages` | [`compliance/apps/chats/messages.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/messages.md) |
| `GET /v1/compliance/apps/chats/{id}/files` | [`compliance/apps/chats/files.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/files.md) |
| `GET /v1/compliance/apps/chats/{id}/generated_files` | [`compliance/apps/chats/generated_files.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/generated_files.md) |
| `GET /v1/compliance/apps/projects` | [`compliance/apps/projects/list.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/list.md) |
| `GET /v1/compliance/apps/projects/{id}` | [`compliance/apps/projects/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/retrieve.md) |
| `DELETE /v1/compliance/apps/projects/{id}` | [`compliance/apps/projects/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/delete.md) |
| `GET /v1/compliance/apps/projects/{id}/documents` | [`compliance/apps/projects/documents.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/documents.md) |
| `GET /v1/compliance/apps/artifacts` | [`compliance/apps/artifacts.md`](https://platform.claude.com/docs/en/api/compliance/apps/artifacts.md) |

### Groups (SCIM-managed user groups)

| Endpoint | Page |
|---|---|
| `GET /v1/compliance/groups` | [`compliance/groups/list.md`](https://platform.claude.com/docs/en/api/compliance/groups/list.md) — filter by `name_prefix`; returns `id`, `name`, `roles`, `source_type` (`direct` or `scim`) |
| `GET /v1/compliance/groups/{id}` | [`compliance/groups/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/groups/retrieve.md) |
| `GET /v1/compliance/groups/{id}/members` | [`compliance/groups/members/list.md`](https://platform.claude.com/docs/en/api/compliance/groups/members/list.md) |

### Organizations

| Endpoint | Page |
|---|---|
| `GET /v1/compliance/organizations` | [`compliance/organizations/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/list.md) — no pagination; errors if >1000 orgs |
| `GET /v1/compliance/organizations/{uuid}/users` | [`compliance/organizations/users/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/users/list.md) |
| `GET /v1/compliance/organizations/{uuid}/roles` | [`compliance/organizations/roles/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/list.md) |
| `GET /v1/compliance/organizations/{uuid}/roles/{role_id}` | [`compliance/organizations/roles/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/retrieve.md) |
| `GET /v1/compliance/organizations/{uuid}/roles/{role_id}/permissions` | [`compliance/organizations/roles/permissions/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/permissions/list.md) |

The conceptual coverage of each (what to use it for, what fields
mean, integration patterns) lives in the platform-features
manage-claude surface — start there for understanding, come here
for the wire shape.

## Source pages

38 pages under
[`https://platform.claude.com/docs/en/api/compliance/`](https://platform.claude.com/docs/en/api/compliance/).

---

*Source pages: 38 under `platform.claude.com/docs/en/api/compliance/`.*
