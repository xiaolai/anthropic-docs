---
name: anthropic-manage-claude
description: |
  Deep reference for the manage-claude surface — Admin API,
  authentication, workspaces, rate-limits API, usage/cost API,
  data residency, API data-retention, Workload Identity Federation
  (WIF), Customer-Managed Encryption Keys (CMEK — AWS KMS, Google
  Cloud KMS, Azure Key Vault), Compliance API (activity feed, content
  data, org data, integration patterns, FAQ, errors), and Claude Code
  Analytics API.
source: https://platform.claude.com/docs/en/manage-claude/admin-api.md
---

# Platform — Manage Claude (Ops / Compliance / WIF)

> *Router lives in [`SKILL.md`](SKILL.md). For the API methods
> themselves (admin endpoints), see [`anthropic-api → SKILL-admin.md`](../anthropic-api/SKILL-admin.md)
> and [`anthropic-api → SKILL-compliance.md`](../anthropic-api/SKILL-compliance.md).*

## Key facts (at intent time)

- **Three API key tiers:** regular (per-user/app, calls Messages),
  admin (org-scoped, calls Admin API), compliance (org-scoped, calls
  Compliance API). Distinct keys, distinct scopes, distinct rate
  limits. Never reuse a regular key where admin scope is required.
- **WIF over long-lived keys:** for cloud-native deployments (AWS /
  GCP / Azure / GitHub Actions / generic OIDC), prefer
  workload-identity federation. Short-lived tokens minted from your
  IdP, no long-lived secrets to rotate or leak. Setup is per-provider
  — see the [`wif-providers/`](https://platform.claude.com/docs/en/manage-claude/wif-providers/)
  subtree.
- **Data residency is region-pinned, not per-call.** Once your org's
  data-residency region is set, all requests land there. To force a
  specific region for a multi-region deployment, use the per-region
  endpoint URLs documented at
  [`data-residency`](https://platform.claude.com/docs/en/manage-claude/data-residency.md).
- **Workspaces ≠ tenants.** Workspaces partition cost / quota inside
  one org. They do NOT provide data isolation between teams in the
  way a tenant boundary would. Sensitive multi-team isolation needs
  separate orgs.
- **Compliance API requires plan + admin key.** Returns `403` for
  ineligible orgs. Pre-flight check the access endpoint before
  building integrations.
- **Spend caps** can be set per workspace; they cap MONTHLY usage,
  not per-request. When the cap is hit, the workspace returns `429`
  with `cap_exceeded` error code until the next billing month.
- **Audit log retention** defaults to 30 days; enterprise plans
  extend to longer windows. Verify your plan's setting before relying
  on long-tail audit availability.
- **HIPAA-ready API access** (new): Organizations handling PHI can now
  sign a Business Associate Agreement (BAA) without enabling ZDR first.
  Anthropic provisions a dedicated HIPAA-enabled org that auto-blocks
  ineligible features (returns `400` if request uses a non-eligible
  feature). Not available on Claude Platform on AWS, Foundry, or Claude
  Code. Feature eligibility (ZDR and HIPAA) is tabulated at
  [`api-and-data-retention.md`](https://platform.claude.com/docs/en/manage-claude/api-and-data-retention.md).
  Contact [Anthropic sales](https://claude.com/contact-sales) to sign a BAA.

## Foundations

| Page | Topic |
|---|---|
| [`admin-api.md`](https://platform.claude.com/docs/en/manage-claude/admin-api.md) | Admin API conceptual overview |
| [`authentication.md`](https://platform.claude.com/docs/en/manage-claude/authentication.md) | API key auth, header conventions |
| [`workspaces.md`](https://platform.claude.com/docs/en/manage-claude/workspaces.md) | Workspace concept (cost / quota / member scope) |
| [`api-and-data-retention.md`](https://platform.claude.com/docs/en/manage-claude/api-and-data-retention.md) | What's retained, ZDR opt-out, HIPAA-ready API (BAA), feature eligibility table |
| [`data-residency.md`](https://platform.claude.com/docs/en/manage-claude/data-residency.md) | Per-region API endpoints, residency guarantees |
| [`rate-limits-api.md`](https://platform.claude.com/docs/en/manage-claude/rate-limits-api.md) | Programmatic rate-limit inspection |
| [`usage-cost-api.md`](https://platform.claude.com/docs/en/manage-claude/usage-cost-api.md) | Usage + cost reports |

## Customer-Managed Encryption Keys (CMEK)

Encrypt workspace data at rest with a key you hold in your own cloud
account (AWS KMS, Google Cloud KMS, or Azure Key Vault). Anthropic uses
your key for envelope encryption; key operations are recorded in your
cloud provider's audit logs. CMEK is per-workspace and requires
Organization Admin access.

**Critical caveats:**
- **Permanent and irreversible.** Once a key is attached to a workspace
  it cannot be detached or swapped. Key deletion or material destruction
  permanently destroys CMEK-protected data — Anthropic holds no copy.
- **No retroactive encryption.** Only data written *after* the key is
  enabled is protected; prior data remains under Anthropic-managed keys.
- **US regions only.** Multi-region keys and EU key residency are not
  yet supported.
- **Not supported on HIPAA-enabled orgs** (support planned).
- **Revocation delay:** key revocation can take up to one hour (cache TTL).

**What CMEK protects:** message content, inline file attachments, MCP and
tool configuration, backups and snapshots.

**Features disabled when CMEK is on:** Skills, sessions, server-side
stateful tools, Files API (`/v1/files`), Batch API, code execution, and
most beta / research-preview features.

**Not encrypted under your key:** Workbench in the Console, in-flight
caches and data with a TTL under 24 hours, Activity Feed and audit
logs / telemetry (so compliance access is maintained even if a key is
revoked).

**Recommended regions (minimal latency to Anthropic US infrastructure):**

| Provider | Recommended region(s) |
|---|---|
| AWS KMS | `us-east-2` |
| Google Cloud KMS | `us-central1`, `us-east5` |
| Azure Key Vault | `northcentralus`, `eastus2` |

**Admin API flow (same for all providers):**

1. Create the key in your cloud provider; grant Anthropic's principal access.
2. `POST /v1/organizations/external_keys` — register the key, receive `ekey_<id>`.
3. `POST /v1/organizations/external_keys/ekey_<id>/validate` — run an encrypt/decrypt round-trip to confirm access.
4. `POST /v1/organizations/workspaces/<id>` — attach the key (`external_key_id: "ekey_<id>"`).

| Page | Topic |
|---|---|
| [`cmek.md`](https://platform.claude.com/docs/en/manage-claude/cmek.md) | Overview, availability, what CMEK protects / disables / excludes, limitations |
| [`cmek-aws-kms.md`](https://platform.claude.com/docs/en/manage-claude/cmek-aws-kms.md) | AWS KMS: cross-account key policy, Anthropic IAM role ARN (`arn:aws:iam::915198916910:role/anthropic-cmek-client-us`), encryption context, troubleshooting |
| [`cmek-google-cloud-kms.md`](https://platform.claude.com/docs/en/manage-claude/cmek-google-cloud-kms.md) | Google Cloud KMS: key ring, HSM vs software keys, service account IAM (`anthropic-cmek-client-us@gcp-anthropic-cmek-clients.iam.gserviceaccount.com`), VPC SC |
| [`cmek-azure-key-vault.md`](https://platform.claude.com/docs/en/manage-claude/cmek-azure-key-vault.md) | Azure Key Vault: RSA key (3072+ bit), RBAC authorization, multi-tenant app consent (app ID `8635ae1a-3e5d-44e8-a4ed-e0f614466f87`), purge-protection requirement |

## Workload Identity Federation (WIF)

Replace long-lived API keys with short-lived tokens minted from a
trusted identity provider (typical for cloud-native deployments
where pod / service identity is the natural credential).

| Page | Topic |
|---|---|
| [`workload-identity-federation.md`](https://platform.claude.com/docs/en/manage-claude/workload-identity-federation.md) | WIF concept + setup overview |
| [`wif-reference.md`](https://platform.claude.com/docs/en/manage-claude/wif-reference.md) | Configuration reference (claims, audiences, scopes) |
| [`wif-providers/`](https://platform.claude.com/docs/en/manage-claude/wif-providers/) | Per-provider setup (AWS, GCP, Azure, GitHub Actions, generic OIDC) |

## Compliance API

Programmatic access to compliance data — audit logs, content
records, org-level data, activity feeds:

| Page | Topic |
|---|---|
| [`compliance-api.md`](https://platform.claude.com/docs/en/manage-claude/compliance-api.md) | Compliance API overview |
| [`compliance-api-access.md`](https://platform.claude.com/docs/en/manage-claude/compliance-api-access.md) | Access model, who can use it |
| [`compliance-activity-feed.md`](https://platform.claude.com/docs/en/manage-claude/compliance-activity-feed.md) | Streaming activity feed |
| [`compliance-content-data.md`](https://platform.claude.com/docs/en/manage-claude/compliance-content-data.md) | Per-message content audit |
| [`compliance-org-data.md`](https://platform.claude.com/docs/en/manage-claude/compliance-org-data.md) | Org-level aggregate data |
| [`compliance-integration-patterns.md`](https://platform.claude.com/docs/en/manage-claude/compliance-integration-patterns.md) | Common integration patterns (SIEM, DLP) |
| [`compliance-errors.md`](https://platform.claude.com/docs/en/manage-claude/compliance-errors.md) | Error semantics |
| [`compliance-faq.md`](https://platform.claude.com/docs/en/manage-claude/compliance-faq.md) | Common questions |

## Claude Code Analytics API

Aggregated usage analytics specifically for Claude Code:

| Page | Topic |
|---|---|
| [`claude-code-analytics-api.md`](https://platform.claude.com/docs/en/manage-claude/claude-code-analytics-api.md) | Per-user / per-team Claude Code usage metrics |

---

*Source pages: 29 under `platform.claude.com/docs/en/manage-claude/`
(22 top-level + 7 under `wif-providers/`: aws, azure, gcp, github-actions, kubernetes, okta, spiffe).*
