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

Endpoints under `/v1/compliance/...` (note: **no** `/organizations` prefix — these are org-scoped by auth key). Each page documents parameters, response shape, and pagination.

| Topic | Endpoints | Source |
|---|---|---|
| Section index | — | [`compliance.md`](https://platform.claude.com/docs/en/api/compliance.md) |
| **Activities** | `GET /v1/compliance/activities` | [`compliance/activities/list.md`](https://platform.claude.com/docs/en/api/compliance/activities/list.md) — 290+ filterable `activity_types` |
| **Apps** | — | [`compliance/apps/`](https://platform.claude.com/docs/en/api/compliance/apps/) |
| Apps › Chats | `GET .../chats`, `DELETE .../chats/{id}`, `GET .../chats/{id}/messages` | Chat records + message content |
| Apps › Chat files | `GET .../files`, `GET .../files/{id}/content`, `DELETE .../files/{id}` | Uploaded file records |
| Apps › Chat generated files | `GET .../generated_files`, `GET .../generated_files/{id}/content` | Claude-generated file records |
| Apps › Artifacts | `GET .../artifacts`, `GET .../artifacts/{id}/content` | Artifact records |
| Apps › Projects | `GET .../projects`, `GET .../projects/{id}`, `DELETE .../projects/{id}` | Project records |
| Apps › Project documents | `GET .../documents`, `GET .../documents/{id}`, `DELETE .../documents/{id}` | Project document records |
| Apps › Project attachments | `GET .../attachments` | [`compliance/apps/projects/attachments.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/attachments.md) |
| **Groups** | `GET /v1/compliance/groups`, `GET .../groups/{id}`, `GET .../groups/{id}/members` | Compliance groups and members |
| **Organizations** | `GET /v1/compliance/organizations` | Org listing |
| Org roles | `GET .../organizations/roles`, `GET .../roles/{id}`, `GET .../roles/{id}/permissions` | Role and permission discovery |
| Org users | `GET .../organizations/users` | User listing |

The conceptual coverage of each (what to use it for, what fields
mean, integration patterns) lives in the platform-features
manage-claude surface — start there for understanding, come here
for the wire shape.

## Source pages

37 pages under
[`https://platform.claude.com/docs/en/api/compliance/`](https://platform.claude.com/docs/en/api/compliance/)
— see directory listing for the current per-endpoint set.

---

*Source pages: 37 under `platform.claude.com/docs/en/api/compliance/`. Last audited 2026-05-18.*
