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

Endpoints under `/v1/compliance/...`. Each page in the snapshot
documents one endpoint's parameters, response shape, and pagination.

| Topic | Endpoint | Source |
|---|---|---|
| Compliance API index | — | [`compliance.md`](https://platform.claude.com/docs/en/api/compliance.md) |
| Activity feed | `GET /v1/compliance/activities` | [`compliance/activities/list.md`](https://platform.claude.com/docs/en/api/compliance/activities/list.md) |
| Apps | — | [`compliance/apps.md`](https://platform.claude.com/docs/en/api/compliance/apps.md) |
| Chats | — | [`compliance/apps/chats.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats.md) |
| Artifacts | — | [`compliance/apps/artifacts.md`](https://platform.claude.com/docs/en/api/compliance/apps/artifacts.md) |
| Projects | — | [`compliance/apps/projects.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects.md) |
| Organizations | — | [`compliance/organizations.md`](https://platform.claude.com/docs/en/api/compliance/organizations.md) |
| Compliance roles | — | [`compliance/organizations/roles.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles.md) |
| Groups | — | [`compliance/groups.md`](https://platform.claude.com/docs/en/api/compliance/groups.md) |

### Activity feed (`GET /v1/compliance/activities`)

Filterable by `activity_types` (292+ event types, e.g.
`account_deleted`, `api_key_created`, `claude_chat_created`,
`desktop_extension_allowlisted`, …). Cursor-paginated.
Source: [`compliance/activities/list.md`](https://platform.claude.com/docs/en/api/compliance/activities/list.md).

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
