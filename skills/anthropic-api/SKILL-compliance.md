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

Endpoints under `/v1/compliance/...`. Each page in the snapshot documents
one endpoint's parameters, response shape, and pagination.

| Topic | Key endpoints |
|---|---|
| Compliance API section index | [`compliance.md`](https://platform.claude.com/docs/en/api/compliance.md) |
| **Activities** | `GET /v1/compliance/activities` (list) — activity feed for audit/SIEM |
| **Apps / Chats** | `GET /v1/compliance/apps`, `GET /v1/compliance/apps/chats` (list, delete, files, messages), `GET /v1/compliance/apps/chats/generated_files` |
| **Apps / Artifacts** | `GET /v1/compliance/apps/artifacts` (content) |
| **Apps / Projects** | `GET /v1/compliance/apps/projects` (list, retrieve, delete, documents, attachments) |
| **Groups** | `GET /v1/compliance/groups` (list, retrieve), `GET /v1/compliance/groups/{id}/members` (list) — filter by `name_prefix`; pagination via `next_page` cursor. Source: [`compliance/groups.md`](https://platform.claude.com/docs/en/api/compliance/groups.md) |
| **Organizations** | `GET /v1/compliance/organizations` (list, roles/list, roles/{id}/retrieve, roles/{id}/permissions/list, users/list) — roles and user assignments across orgs. Source: [`compliance/organizations.md`](https://platform.claude.com/docs/en/api/compliance/organizations.md) |

The conceptual coverage of each (what to use it for, what fields
mean, integration patterns) lives in the platform-features
manage-claude surface — start there for understanding, come here
for the wire shape.

## Source pages

38 pages under
[`https://platform.claude.com/docs/en/api/compliance/`](https://platform.claude.com/docs/en/api/compliance/)
— see directory listing for the current per-endpoint set.

---

*Source pages: 38 under `platform.claude.com/docs/en/api/compliance/`.*
