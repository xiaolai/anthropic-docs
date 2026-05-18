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

Endpoints under `/v1/organizations/compliance/...`. Each page in
the snapshot documents one endpoint's parameters, response shape,
and pagination.

### Activities (audit log)

| Endpoint | Source |
|---|---|
| `GET /v1/organizations/compliance/activities` | [`compliance/activities/list.md`](https://platform.claude.com/docs/en/api/compliance/activities/list.md) |

### Apps — Chats

| Endpoint | Source |
|---|---|
| `GET /v1/organizations/compliance/apps/{app_id}/chats` | [`compliance/apps/chats/list.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/list.md) |
| `DELETE /v1/organizations/compliance/apps/{app_id}/chats/{chat_id}` | [`compliance/apps/chats/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/delete.md) |
| Chat messages listing | [`compliance/apps/chats/messages.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/messages.md) |
| Chat files | [`compliance/apps/chats/files.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/files.md) and sub-endpoints |
| Chat generated files | [`compliance/apps/chats/generated_files.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/generated_files.md) |

### Apps — Projects

| Endpoint | Source |
|---|---|
| `GET /v1/organizations/compliance/apps/{app_id}/projects` | [`compliance/apps/projects/list.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/list.md) |
| `GET /v1/organizations/compliance/apps/{app_id}/projects/{id}` | [`compliance/apps/projects/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/retrieve.md) |
| `DELETE /v1/organizations/compliance/apps/{app_id}/projects/{id}` | [`compliance/apps/projects/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/delete.md) |
| Project documents, attachments | sub-endpoints under [`compliance/apps/projects/`](https://platform.claude.com/docs/en/api/compliance/apps/projects/) |

### Apps — Artifacts

| Endpoint | Source |
|---|---|
| Artifact content retrieval | [`compliance/apps/artifacts/content.md`](https://platform.claude.com/docs/en/api/compliance/apps/artifacts/content.md) |

### Groups

| Endpoint | Source |
|---|---|
| `GET /v1/organizations/compliance/groups` | [`compliance/groups/list.md`](https://platform.claude.com/docs/en/api/compliance/groups/list.md) |
| `GET /v1/organizations/compliance/groups/{id}` | [`compliance/groups/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/groups/retrieve.md) |
| Group members listing | [`compliance/groups/members/list.md`](https://platform.claude.com/docs/en/api/compliance/groups/members/list.md) |

### Organizations

| Endpoint | Source |
|---|---|
| `GET /v1/organizations/compliance/organizations` | [`compliance/organizations/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/list.md) |
| Roles | [`compliance/organizations/roles/`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/) |
| Roles permissions | [`compliance/organizations/roles/permissions/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/permissions/list.md) |
| Users listing | [`compliance/organizations/users/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/users/list.md) |

The conceptual coverage of each (what to use it for, what fields
mean, integration patterns) lives in the platform-features
manage-claude surface — start there for understanding, come here
for the wire shape.

## Source pages

37 pages under
[`https://platform.claude.com/docs/en/api/compliance/`](https://platform.claude.com/docs/en/api/compliance/)
— see directory listing for the current per-endpoint set.

---

*Source pages: 37 under `platform.claude.com/docs/en/api/compliance/`. Last audited: 2026-05-18.*
