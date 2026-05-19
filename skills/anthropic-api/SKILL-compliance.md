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

- **Auth:** uses a **compliance API key** (a separate key from the standard
  API key and admin API key). Passed as a Bearer token:
  `Authorization: Bearer $ANTHROPIC_COMPLIANCE_API_KEY`.
  The compliance API does **not** use `x-api-key` — that header is for the
  Messages / Admin API only.
- **No `anthropic-version` required** for compliance endpoints (unlike the
  Messages API). No `anthropic-beta` header required.
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

All compliance endpoints are under the `https://api.anthropic.com/v1/compliance/...`
path. Each page in the snapshot documents one endpoint's parameters, response
shape, and pagination.

| Endpoint | Source |
|---|---|
| Compliance API section index | [`compliance.md`](https://platform.claude.com/docs/en/api/compliance.md) |
| `GET /v1/compliance/activities` | [`compliance/activities.md`](https://platform.claude.com/docs/en/api/compliance/activities.md) — activity feed (filter by `activity_types`; 290+ event type enum values) |
| `GET /v1/compliance/apps/chats` | [`compliance/apps/chats`](https://platform.claude.com/docs/en/api/compliance/apps/chats/list.md) — list chat metadata; requires `user_ids` (1–10 IDs) |
| `GET /v1/compliance/apps/chats/{chat_id}/messages` | [`compliance/apps/chats`](https://platform.claude.com/docs/en/api/compliance/apps/chats.md) — retrieve chat messages |
| `GET /v1/compliance/apps/projects` | [`compliance/apps/projects`](https://platform.claude.com/docs/en/api/compliance/apps/projects.md) — list Claude projects |
| `GET /v1/compliance/groups` | [`compliance/groups.md`](https://platform.claude.com/docs/en/api/compliance/groups.md) — list compliance groups (filter by `name_prefix`) |
| `GET /v1/compliance/groups/{group_id}/members` | [`compliance/groups/members`](https://platform.claude.com/docs/en/api/compliance/groups/members.md) — list group members |
| `GET /v1/compliance/organizations` | [`compliance/organizations.md`](https://platform.claude.com/docs/en/api/compliance/organizations.md) — list sub-organizations (no pagination; max 1,000) |
| `GET /v1/compliance/organizations/{uuid}/users` | [`compliance/organizations/users`](https://platform.claude.com/docs/en/api/compliance/organizations/users.md) — list org users |
| `GET /v1/compliance/organizations/{uuid}/roles` | [`compliance/organizations/roles`](https://platform.claude.com/docs/en/api/compliance/organizations/roles.md) — list compliance roles + permissions |

The conceptual coverage of each (what to use it for, what fields
mean, integration patterns) lives in the platform-features
manage-claude surface — start there for understanding, come here
for the wire shape.

## Source pages

37 pages under
[`https://platform.claude.com/docs/en/api/compliance/`](https://platform.claude.com/docs/en/api/compliance/)
— see directory listing for the current per-endpoint set.

---

*Source pages: 37 under `platform.claude.com/docs/en/api/compliance/`.*
