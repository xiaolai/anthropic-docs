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

## Base path

All compliance endpoints are under **`/v1/compliance/...`** (not `/v1/organizations/compliance/...`). The API key header is `x-api-key` (same as other API calls).

## Endpoint catalog

| Endpoint | Page |
|---|---|
| Compliance API section index | [`compliance.md`](https://platform.claude.com/docs/en/api/compliance.md) |
| `GET /v1/compliance/activities` | [`compliance/activities/list.md`](https://platform.claude.com/docs/en/api/compliance/activities/list.md) — paginated activity feed; filter by `activity_types` (295+ event types), time range, etc. |
| Apps section | [`compliance/apps.md`](https://platform.claude.com/docs/en/api/compliance/apps.md) |
| `GET /v1/compliance/apps/chats` | [`compliance/apps/chats/list.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/list.md) |
| `DELETE /v1/compliance/apps/chats/{id}` | [`compliance/apps/chats/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/delete.md) |
| `GET /v1/compliance/apps/chats/{id}/messages` | [`compliance/apps/chats/messages.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/messages.md) |
| Files / generated files | [`compliance/apps/chats/files.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/files.md), [`compliance/apps/chats/generated_files.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/generated_files.md) |
| Artifacts | [`compliance/apps/artifacts.md`](https://platform.claude.com/docs/en/api/compliance/apps/artifacts.md) |
| Projects / documents | [`compliance/apps/projects.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects.md), [`compliance/apps/projects/documents.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/documents.md) |
| `GET /v1/compliance/groups` | [`compliance/groups/list.md`](https://platform.claude.com/docs/en/api/compliance/groups/list.md) — list groups; filter by `name_prefix`. Pagination: `page` cursor, max 1000. |
| `GET /v1/compliance/groups/{id}` | [`compliance/groups/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/groups/retrieve.md) |
| `GET /v1/compliance/groups/{id}/members` | [`compliance/groups/members/list.md`](https://platform.claude.com/docs/en/api/compliance/groups/members/list.md) |
| `GET /v1/compliance/organizations` | [`compliance/organizations/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/list.md) |
| `GET /v1/compliance/organizations/{org_uuid}/roles` | [`compliance/organizations/roles/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/list.md) |
| `GET /v1/compliance/organizations/{org_uuid}/roles/{role_id}` | [`compliance/organizations/roles/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/retrieve.md) |
| `GET /v1/compliance/organizations/{org_uuid}/roles/{role_id}/permissions` | [`compliance/organizations/roles/permissions/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/permissions/list.md) |
| `GET /v1/compliance/organizations/{org_uuid}/users` | [`compliance/organizations/users/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/users/list.md) |

The conceptual coverage of each (what to use it for, what fields
mean, integration patterns) lives in the platform-features
manage-claude surface — start there for understanding, come here
for the wire shape.

## Source pages

38 pages under
[`https://platform.claude.com/docs/en/api/compliance/`](https://platform.claude.com/docs/en/api/compliance/)
— see directory listing for the current per-endpoint set.

---

*Source pages: 38 under `platform.claude.com/docs/en/api/compliance/` (as of 2026-05-19).*
