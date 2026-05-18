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

- **Auth:** uses a **compliance API key** (`Authorization: Bearer $ANTHROPIC_COMPLIANCE_API_KEY`). This is a separate key type from the regular API key and the admin-scoped key — request it from Anthropic separately.
- **Base path:** all compliance endpoints are under `/v1/compliance/...` — **not** `/v1/organizations/...`.
- **No `anthropic-version` header required** for compliance endpoints; use only `Authorization: Bearer <key>` and optionally `x-api-key` as documented per endpoint.
- **Plan gating:** Compliance API endpoints return `403` for orgs
  without the required plan. Check eligibility at
  [`compliance-api-access`](https://platform.claude.com/docs/en/manage-claude/compliance-api-access.md)
  before integration.
- **Pagination:** list endpoints use cursor pagination
  (`next_page` token in the response; default `limit` 500, max 1000).
- **Retention:** activity feed events are retained per the org's
  data-retention setting (default 30d, longer on enterprise plans).
  See [`api-and-data-retention`](https://platform.claude.com/docs/en/manage-claude/api-and-data-retention.md).
- **Concept overview** lives in
  [`anthropic-platform-features → SKILL-manage-claude.md`](../anthropic-platform-features/SKILL-manage-claude.md);
  this surface is the wire reference.

## Endpoint catalog

All compliance endpoints are at `https://api.anthropic.com/v1/compliance/...`.

### Activities

| Endpoint | Page |
|---|---|
| `GET /v1/compliance/activities` | [`compliance/activities/list.md`](https://platform.claude.com/docs/en/api/compliance/activities/list.md) |

Returns a paginated list of compliance activities (audit events). Supports `activity_types` filter (290+ event type strings including account lifecycle, API key events, chat events, project events, etc.) plus date range filters.

### Apps (Claude.ai content)

| Endpoint | Page |
|---|---|
| `GET /v1/compliance/apps` | [`compliance/apps.md`](https://platform.claude.com/docs/en/api/compliance/apps.md) |
| `GET /v1/compliance/apps/chats` | [`compliance/apps/chats.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats.md) |
| `GET /v1/compliance/apps/chats/list` | [`compliance/apps/chats/list.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/list.md) |
| `DELETE /v1/compliance/apps/chats/{id}` | [`compliance/apps/chats/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/delete.md) |
| Chat files, generated files | [`compliance/apps/chats/files/`](https://platform.claude.com/docs/en/api/compliance/apps/chats/files.md), [`generated_files/`](https://platform.claude.com/docs/en/api/compliance/apps/chats/generated_files.md) |
| Chat messages | [`compliance/apps/chats/messages.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/messages.md) |
| Projects + documents | [`compliance/apps/projects/`](https://platform.claude.com/docs/en/api/compliance/apps/projects.md) |
| Artifacts | [`compliance/apps/artifacts.md`](https://platform.claude.com/docs/en/api/compliance/apps/artifacts.md) |

### Groups

| Endpoint | Page |
|---|---|
| `GET /v1/compliance/groups` | [`compliance/groups/list.md`](https://platform.claude.com/docs/en/api/compliance/groups/list.md) — supports `name_prefix` filter |
| `GET /v1/compliance/groups/{id}` | [`compliance/groups/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/groups/retrieve.md) |
| `GET /v1/compliance/groups/{id}/members` | [`compliance/groups/members/list.md`](https://platform.claude.com/docs/en/api/compliance/groups/members/list.md) |

Group object fields: `id`, `name`, `description`, `roles` (array of role IDs), `source_type` (`"direct"` or `"scim"`), `created_at`, `updated_at`.

### Organizations

| Endpoint | Page |
|---|---|
| `GET /v1/compliance/organizations` | [`compliance/organizations/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations.md) — no pagination; max 1000 |
| `GET /v1/compliance/organizations/{id}/users` | [`compliance/organizations/users/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/users/list.md) |
| `GET /v1/compliance/organizations/{id}/roles` | [`compliance/organizations/roles/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/list.md) |
| `GET /v1/compliance/organizations/{id}/roles/{role_id}` | [`compliance/organizations/roles/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/retrieve.md) |
| Role permissions | [`compliance/organizations/roles/permissions/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/permissions/list.md) |

Organization list response: `{ data: [ { uuid, name, created_at } ] }`.

The conceptual coverage (what to use each endpoint for, integration
patterns with SIEM/DLP tools) lives in the platform-features
manage-claude surface — start there for understanding, come here
for the wire shape.

## Source pages

37 pages under
[`https://platform.claude.com/docs/en/api/compliance/`](https://platform.claude.com/docs/en/api/compliance/)
— see directory listing for the current per-endpoint set.

---

*Source pages: 37 under `platform.claude.com/docs/en/api/compliance/` (as of 2026-05-18). Base path corrected to `/v1/compliance/...`.*
