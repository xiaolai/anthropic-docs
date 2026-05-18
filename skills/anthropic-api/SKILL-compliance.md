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

All routes under `/v1/organizations/...` requiring an admin-scoped key.

### Activities

| Endpoint | Page |
|---|---|
| `POST /v1/organizations/compliance/activities` | [`compliance/activities/list.md`](https://platform.claude.com/docs/en/api/compliance/activities/list.md) — query compliance activity log |

### Apps — Chats & Projects

| Endpoint | Page |
|---|---|
| `GET /v1/organizations/compliance/apps` | [`compliance/apps.md`](https://platform.claude.com/docs/en/api/compliance/apps.md) |
| List/get/delete chats | [`compliance/apps/chats/`](https://platform.claude.com/docs/en/api/compliance/apps/chats.md) |
| Get chat messages | [`compliance/apps/chats/messages.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/messages.md) |
| Chat files & generated files | [`compliance/apps/chats/files/`](https://platform.claude.com/docs/en/api/compliance/apps/chats/files.md), [`generated_files/`](https://platform.claude.com/docs/en/api/compliance/apps/chats/generated_files.md) |
| Artifacts (content download) | [`compliance/apps/artifacts/`](https://platform.claude.com/docs/en/api/compliance/apps/artifacts.md) |
| Projects (list/get/delete + attachments/documents) | [`compliance/apps/projects/`](https://platform.claude.com/docs/en/api/compliance/apps/projects.md) |

### Groups

| Endpoint | Page |
|---|---|
| List / get compliance groups | [`compliance/groups/`](https://platform.claude.com/docs/en/api/compliance/groups.md) |
| List group members | [`compliance/groups/members/`](https://platform.claude.com/docs/en/api/compliance/groups/members.md) |

### Organizations — Roles & Users

| Endpoint | Page |
|---|---|
| List organizations | [`compliance/organizations/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/list.md) |
| List organization users | [`compliance/organizations/users/list.md`](https://platform.claude.com/docs/en/api/compliance/organizations/users/list.md) |
| List / get compliance roles | [`compliance/organizations/roles/`](https://platform.claude.com/docs/en/api/compliance/organizations/roles.md) |
| List role permissions | [`compliance/organizations/roles/permissions/`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/permissions.md) |

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
