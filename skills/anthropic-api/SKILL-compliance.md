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
| Compliance API section index | [`compliance`](https://platform.claude.com/docs/en/api/compliance) |
| `GET /v1/compliance/activities` | [`compliance/activities.md`](https://platform.claude.com/docs/en/api/compliance/activities.md) — activity feed (filter by `activity_types`; 305+ event type enum values) |
| `GET /v1/compliance/apps/chats` | [`compliance/apps/chats/list.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/list.md) — list chat metadata; requires `user_ids` (1–10 IDs) |
| `GET /v1/compliance/apps/chats/{chat_id}/messages` | [`compliance/apps/chats/messages/list.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/messages/list.md) — list chat messages with cursor pagination (`after_id`, `before_id`, `created_at` range filters); includes `artifacts[]` and `generated_files[]` |
| `DELETE /v1/compliance/apps/chats/{chat_id}` | [`compliance/apps/chats/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/delete.md) — permanently delete a chat + messages + files; returns `{id, type: "claude_chat_deleted"}` |
| `GET /v1/compliance/apps/chats/files/{file_id}` | [`compliance/apps/chats/files/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/files/retrieve.md) — retrieve file metadata |
| `GET /v1/compliance/apps/chats/files/{file_id}/content` | [`compliance/apps/chats/files/download.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/files/download.md) — download file bytes |
| `DELETE /v1/compliance/apps/chats/files/{file_id}` | [`compliance/apps/chats/files/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/files/delete.md) — delete a chat file |
| `GET /v1/compliance/apps/chats/{id}/generated_files` | [`compliance/apps/chats/generated_files.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/generated_files.md) — list model-generated files |
| `GET /v1/compliance/apps/chats/generated-files/{fid}` | [`compliance/apps/chats/generated_files/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/generated_files/retrieve.md) — retrieve generated file **metadata** (no bytes); fields: `id`, `claude_chat_id`, `md5`, `size_bytes` — use for DLP hash-dedup without downloading |
| `GET /v1/compliance/apps/chats/generated-files/{fid}/content` | [`compliance/apps/chats/generated_files/download.md`](https://platform.claude.com/docs/en/api/compliance/apps/chats/generated_files/download.md) — download generated file bytes |
| `GET /v1/compliance/apps/artifacts/{artifact_version_id}` | [`compliance/apps/artifacts/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/apps/artifacts/retrieve.md) — retrieve artifact **metadata** (no bytes); fields: `id`, `artifact_type`, `md5`, `size_bytes` — use for DLP hash-dedup without downloading |
| `GET /v1/compliance/apps/artifacts/{artifact_version_id}/content` | [`compliance/apps/artifacts/download.md`](https://platform.claude.com/docs/en/api/compliance/apps/artifacts/download.md) — download artifact text content |
| `GET /v1/compliance/apps/projects` | [`compliance/apps/projects/list.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/list.md) — list Claude projects |
| `GET /v1/compliance/apps/projects/{id}` | [`compliance/apps/projects/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/retrieve.md) — retrieve a project |
| `DELETE /v1/compliance/apps/projects/{id}` | [`compliance/apps/projects/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/delete.md) — delete project + all documents/files |
| `GET /v1/compliance/apps/projects/{id}/attachments` | [`compliance/apps/projects/attachments/list.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/attachments/list.md) — list project attachments (files + documents); paginated with opaque `page` cursor |
| `GET /v1/compliance/apps/projects/{id}/documents` | [`compliance/apps/projects/documents.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/documents.md) — list project documents |
| `GET /v1/compliance/apps/projects/{id}/documents/{doc_id}` | [`compliance/apps/projects/documents/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/documents/retrieve.md) — retrieve a document (with text content) |
| `GET /v1/compliance/apps/projects/{id}/documents/{doc_id}/metadata` | [`compliance/apps/projects/documents/metadata.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/documents/metadata.md) — retrieve document **metadata** (no content); fields: `id`, `claude_project_id`, `md5`, `size_bytes` — use for DLP hash-dedup |
| `DELETE /v1/compliance/apps/projects/{id}/documents/{doc_id}` | [`compliance/apps/projects/documents/delete.md`](https://platform.claude.com/docs/en/api/compliance/apps/projects/documents/delete.md) — delete a document |
| `GET /v1/compliance/groups` | [`compliance/groups.md`](https://platform.claude.com/docs/en/api/compliance/groups.md) — list compliance groups (filter by `name_prefix`) |
| `GET /v1/compliance/groups/{group_id}` | [`compliance/groups/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/groups/retrieve.md) — retrieve a group |
| `GET /v1/compliance/groups/{group_id}/members` | [`compliance/groups/members.md`](https://platform.claude.com/docs/en/api/compliance/groups/members.md) — list group members |
| `GET /v1/compliance/organizations` | [`compliance/organizations.md`](https://platform.claude.com/docs/en/api/compliance/organizations.md) — list sub-organizations (no pagination; max 1,000) |
| `GET /v1/compliance/organizations/{uuid}/users` | [`compliance/organizations/users.md`](https://platform.claude.com/docs/en/api/compliance/organizations/users.md) — list org users |
| `GET /v1/compliance/organizations/{uuid}/roles` | [`compliance/organizations/roles.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles.md) — list compliance roles |
| `GET /v1/compliance/organizations/{uuid}/roles/{role_id}` | [`compliance/organizations/roles/retrieve.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/retrieve.md) — retrieve a role |
| `GET /v1/compliance/organizations/{uuid}/roles/{role_id}/permissions` | [`compliance/organizations/roles/permissions.md`](https://platform.claude.com/docs/en/api/compliance/organizations/roles/permissions.md) — list role permissions |

The conceptual coverage of each (what to use it for, what fields
mean, integration patterns) lives in the platform-features
manage-claude surface — start there for understanding, come here
for the wire shape.

## Source pages

42 pages under
[`https://platform.claude.com/docs/en/api/compliance/`](https://platform.claude.com/docs/en/api/compliance/)
— see directory listing for the current per-endpoint set.

New in 2026-05-19: `artifacts/retrieve.md`, `chats/generated_files/retrieve.md`,
`projects/documents/metadata.md` (metadata-only endpoints for DLP hash-dedup);
`chats/messages/list.md` (pagination params); `projects/attachments/list.md`.

---

*Source pages: 42 under `platform.claude.com/docs/en/api/compliance/`.*
