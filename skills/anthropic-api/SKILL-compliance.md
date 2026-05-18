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

Endpoints under `/v1/compliance/...` (note: no `/organizations/` prefix for compliance endpoints). Each page documents parameters, response shape, and pagination.

| Resource | Key endpoints | Source |
|---|---|---|
| API index | — | [`compliance.md`](https://platform.claude.com/docs/en/api/compliance.md) |
| **Activities** | `GET /v1/compliance/activities` — filtered by `activity_types`, `start_time`, `end_time` | [`compliance/activities.md`](https://platform.claude.com/docs/en/api/compliance/activities.md) |
| **Organizations** | `GET /v1/compliance/organizations` | [`compliance/organizations.md`](https://platform.claude.com/docs/en/api/compliance/organizations.md) |
| **Users** | `GET /v1/compliance/organizations/{id}/users` | [`compliance/organizations/users.md`](https://platform.claude.com/docs/en/api/compliance/organizations/users.md) |
| **Roles** | `GET /v1/compliance/organizations/{id}/roles` | [`compliance/organizations/roles.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles.md) |
| **Permissions** | `GET /v1/compliance/organizations/{id}/roles/{role_id}/permissions` | [`compliance/organizations/roles/permissions.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/permissions.md) |
| **Groups** | `GET /v1/compliance/groups`, `GET /v1/compliance/groups/{id}` | [`compliance/groups.md`](https://platform.claude.com/docs/en/api/compliance/groups.md) |
| **Group members** | `GET /v1/compliance/groups/{id}/members` | [`compliance/groups/members.md`](https://platform.claude.com/docs/en/api/compliance/groups/members.md) |
| **Apps** | `GET /v1/compliance/apps` | [`compliance/apps.md`](https://platform.claude.com/docs/en/api/compliance/apps.md) |
| **Chats** | `GET /v1/compliance/apps/{id}/chats`, `DELETE /v1/compliance/apps/{id}/chats/{chat_id}` | [`compliance/apps/chats.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats.md) |
| **Chat files** | `GET /v1/compliance/apps/{id}/chats/{chat_id}/files`, delete, content download | [`compliance/apps/chats/files.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/files.md) |
| **Generated files** | `GET /v1/compliance/apps/{id}/chats/{chat_id}/generated_files`, content download | [`compliance/apps/chats/generated_files.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/generated_files.md) |
| **Projects** | `GET /v1/compliance/apps/{id}/projects`, `DELETE`, retrieve | [`compliance/apps/projects.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects.md) |
| **Project docs** | `GET /v1/compliance/apps/{id}/projects/{proj_id}/documents`, delete, retrieve | [`compliance/apps/projects/documents.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/documents.md) |
| **Artifacts** | `GET /v1/compliance/apps/{id}/artifacts`, content download | [`compliance/apps/artifacts.md`](https://platform.claude.com/docs/en/api/compliance/apps/artifacts.md) |

### Activities endpoint details

The activity feed is the primary endpoint for SIEM integrations. Key query params:

- `activity_types` — array filter; 295+ activity type strings (e.g., `claude_chat_created`, `api_key_created`, `account_deleted`). Omit to receive all types.
- `start_time` / `end_time` — RFC 3339 datetime range filter.
- Cursor pagination via `next_page`.

The conceptual coverage of each resource (what to use it for, what fields
mean, integration patterns) lives in the platform-features
manage-claude surface — start there for understanding, come here
for the wire shape.

## Source pages

37 pages under
[`https://platform.claude.com/docs/en/api/compliance/`](https://platform.claude.com/docs/en/api/compliance/)

---

*Source pages: 37 under `platform.claude.com/docs/en/api/compliance/`.*
