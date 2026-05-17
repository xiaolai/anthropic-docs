---
name: anthropic-manage-claude
description: |
  Deep reference for the manage-claude surface — Admin API,
  authentication, workspaces, rate-limits API, usage/cost API,
  data residency, API data-retention, Workload Identity Federation
  (WIF), Compliance API (activity feed, content data, org data,
  integration patterns, FAQ, errors), and Claude Code Analytics API.
source: https://platform.claude.com/docs/en/manage-claude/admin-api.md
---

# Platform — Manage Claude (Ops / Compliance / WIF)

> *Router lives in [`SKILL.md`](SKILL.md). For the API methods
> themselves (admin endpoints), see [`anthropic-api → SKILL-admin.md`](../anthropic-api/SKILL-admin.md)
> and [`anthropic-api → SKILL-compliance.md`](../anthropic-api/SKILL-compliance.md).*

## Foundations

| Page | Topic |
|---|---|
| [`admin-api.md`](docs-snapshot/platform.claude.com/en/manage-claude/admin-api.md) | Admin API conceptual overview |
| [`authentication.md`](docs-snapshot/platform.claude.com/en/manage-claude/authentication.md) | API key auth, header conventions |
| [`workspaces.md`](docs-snapshot/platform.claude.com/en/manage-claude/workspaces.md) | Workspace concept (cost / quota / member scope) |
| [`api-and-data-retention.md`](docs-snapshot/platform.claude.com/en/manage-claude/api-and-data-retention.md) | What's retained, for how long, ZDR opt-out |
| [`data-residency.md`](docs-snapshot/platform.claude.com/en/manage-claude/data-residency.md) | Per-region API endpoints, residency guarantees |
| [`rate-limits-api.md`](docs-snapshot/platform.claude.com/en/manage-claude/rate-limits-api.md) | Programmatic rate-limit inspection |
| [`usage-cost-api.md`](docs-snapshot/platform.claude.com/en/manage-claude/usage-cost-api.md) | Usage + cost reports |

## Workload Identity Federation (WIF)

Replace long-lived API keys with short-lived tokens minted from a
trusted identity provider (typical for cloud-native deployments
where pod / service identity is the natural credential).

| Page | Topic |
|---|---|
| [`workload-identity-federation.md`](docs-snapshot/platform.claude.com/en/manage-claude/workload-identity-federation.md) | WIF concept + setup overview |
| [`wif-reference.md`](docs-snapshot/platform.claude.com/en/manage-claude/wif-reference.md) | Configuration reference (claims, audiences, scopes) |
| [`wif-providers/`](docs-snapshot/platform.claude.com/en/manage-claude/wif-providers/) | Per-provider setup (AWS, GCP, Azure, GitHub Actions, generic OIDC) |

## Compliance API

Programmatic access to compliance data — audit logs, content
records, org-level data, activity feeds:

| Page | Topic |
|---|---|
| [`compliance-api.md`](docs-snapshot/platform.claude.com/en/manage-claude/compliance-api.md) | Compliance API overview |
| [`compliance-api-access.md`](docs-snapshot/platform.claude.com/en/manage-claude/compliance-api-access.md) | Access model, who can use it |
| [`compliance-activity-feed.md`](docs-snapshot/platform.claude.com/en/manage-claude/compliance-activity-feed.md) | Streaming activity feed |
| [`compliance-content-data.md`](docs-snapshot/platform.claude.com/en/manage-claude/compliance-content-data.md) | Per-message content audit |
| [`compliance-org-data.md`](docs-snapshot/platform.claude.com/en/manage-claude/compliance-org-data.md) | Org-level aggregate data |
| [`compliance-integration-patterns.md`](docs-snapshot/platform.claude.com/en/manage-claude/compliance-integration-patterns.md) | Common integration patterns (SIEM, DLP) |
| [`compliance-errors.md`](docs-snapshot/platform.claude.com/en/manage-claude/compliance-errors.md) | Error semantics |
| [`compliance-faq.md`](docs-snapshot/platform.claude.com/en/manage-claude/compliance-faq.md) | Common questions |

## Claude Code Analytics API

Aggregated usage analytics specifically for Claude Code:

| Page | Topic |
|---|---|
| [`claude-code-analytics-api.md`](docs-snapshot/platform.claude.com/en/manage-claude/claude-code-analytics-api.md) | Per-user / per-team Claude Code usage metrics |

---

*Source pages: 18 under `platform.claude.com/docs/en/manage-claude/`
(including the `wif-providers/` subtree).*
