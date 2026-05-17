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

## Endpoint catalog

Endpoints under `/v1/organizations/compliance/...`. Each page in
the snapshot documents one endpoint's parameters, response shape,
and pagination.

| Topic | Source dir |
|---|---|
| Activity feed | [`compliance/`](docs-snapshot/platform.claude.com/en/api/compliance/) |
| Content data (per-message records) | [`compliance/`](docs-snapshot/platform.claude.com/en/api/compliance/) |
| Org-level data | [`compliance/`](docs-snapshot/platform.claude.com/en/api/compliance/) |
| Errors | [`compliance/`](docs-snapshot/platform.claude.com/en/api/compliance/) |

The conceptual coverage of each (what to use it for, what fields
mean, integration patterns) lives in the platform-features
manage-claude surface — start there for understanding, come here
for the wire shape.

## Source pages

37 pages under
[`docs-snapshot/platform.claude.com/en/api/compliance/`](docs-snapshot/platform.claude.com/en/api/compliance/)
— see directory listing for the current per-endpoint set.

---

*Source pages: 37 under `platform.claude.com/docs/en/api/compliance/`.*
