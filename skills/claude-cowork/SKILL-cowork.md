---
name: claude-cowork-3p
description: |
  Deep reference for Cowork — Anthropic's agentic workspace inside
  Claude Desktop, with a focus on the multi-cloud "Cowork on 3P"
  deployment mode that routes inference through customer-controlled
  endpoints (Vertex AI, Bedrock, Microsoft Foundry, or an LLM gateway).
  Covers architecture, configuration, MDM rollout, RBAC, telemetry,
  data residency, M365 connector, and operational monitoring.
source: https://claude.com/docs/cowork/overview.md
---

# Claude Cowork

> *Router lives in [`SKILL.md`](SKILL.md). This file is the deep
> reference for everything under `claude.com/docs/cowork/*`.*

## What Cowork is

Cowork is Anthropic's agentic workspace, accessible inside Claude
Desktop (no terminal required). It uses the same agentic architecture
that powers Claude Code: rather than answering prompts sequentially,
Claude tackles intricate multi-step tasks autonomously. Users describe
a desired outcome and return later to completed work — polished
documents, organized files, synthesized research, Excel spreadsheets
with formulas, PowerPoint decks.

**Standard Cowork vs Cowork on 3P:**

| Component              | Standard Cowork              | Cowork on 3P                                            |
| ---------------------- | ---------------------------- | ------------------------------------------------------- |
| Model inference        | Anthropic API                | Your Vertex AI / Bedrock / Foundry / gateway endpoint   |
| Web application        | Loaded from claude.ai        | Bundled inside the desktop app                          |
| User identity          | Anthropic account            | Local device identity only                              |
| Conversation storage   | Anthropic backend            | Local disk on the user's machine                        |
| Code execution sandbox | Local VM                     | Local VM (identical)                                    |
| Configuration          | Admin console at claude.ai   | OS-native (MDM-managed or per-user)                     |
| Billing                | Anthropic seat / consumption | Token-based, billed by your cloud provider              |

The desktop app detects 3P mode at launch from the configured
inference provider. When credentials are present, the sign-in screen
offers an option to skip Anthropic authentication and start using the
3P configuration instead.

Source: [`cowork/overview.md`](https://claude.com/docs/cowork/overview.md),
[`cowork/3p/overview.md`](https://claude.com/docs/cowork/3p/overview.md).

## Cowork on 3P: who it's for

3P mode targets organizations whose security, regulatory, or
contractual requirements prevent sending data to Anthropic's
first-party infrastructure:

- Highly regulated enterprises requiring third-party inference for
  compliance or security.
- International organizations with in-region data-residency
  requirements that cannot route conversation data to the United States.

If your organization can use Anthropic's first-party products
directly, standard Cowork on a Team or Enterprise plan is simpler:
in-app UI for user management, analytics, RBAC, and faster feature
rollout. Choose 3P when routing through Anthropic's API is not an
option.

> **Microsoft Foundry preview caveat.** During the Foundry preview,
> Claude models still run on Anthropic infrastructure. Foundry is a
> commercial billing/access integration through Azure; Anthropic acts
> as an independent processor for Microsoft. Customers using Claude
> through Foundry are subject to Anthropic's data-use terms (with
> zero-data-retention availability). The "no conversation egress to
> Anthropic" guarantees apply to **Vertex AI and Bedrock**, and to
> **gateway** mode as long as the gateway does not itself route to
> Anthropic infrastructure.

## Inference providers (3P)

| Provider | Setup page | Authentication |
|---|---|---|
| **Amazon Bedrock** | [`3p/bedrock.md`](https://claude.com/docs/cowork/3p/bedrock.md) | [`3p/bedrock-aws-sign-in.md`](https://claude.com/docs/cowork/3p/bedrock-aws-sign-in.md) |
| **Google Cloud Vertex AI** | [`3p/vertex.md`](https://claude.com/docs/cowork/3p/vertex.md) | [`3p/vertex-google-sign-in.md`](https://claude.com/docs/cowork/3p/vertex-google-sign-in.md) |
| **Microsoft Foundry (preview)** | [`3p/foundry.md`](https://claude.com/docs/cowork/3p/foundry.md) | (uses Azure / Foundry tokens) |
| **LLM Gateway** (any compatible provider) | [`3p/gateway.md`](https://claude.com/docs/cowork/3p/gateway.md) | [`3p/gateway-sso.md`](https://claude.com/docs/cowork/3p/gateway-sso.md) |

Each provider page documents the regional endpoints, model IDs (in
that provider's namespace), the `inferenceProvider`/`inferenceVertexRegion`/`inferenceBedrockRegion`
configuration keys, and the credential flow.

## Security posture (3P)

- **No conversation egress to Anthropic** (Vertex / Bedrock; and
  gateway when not routing to Anthropic). Prompts, responses, files,
  and tool outputs go only to the configured inference endpoint and
  to local disk.
- **Sandboxed tool execution.** Shell commands run in the hardened
  Cowork VM; file access scoped to allowed folders; web fetches
  scoped to an egress allowlist.
- **Auditable telemetry.** Crash reports and product analytics are
  scrubbed of conversation data before being sent to Anthropic and
  can be fully disabled. Independently, session activity (prompts,
  tool calls, token counts) can be exported to your own OpenTelemetry
  collector.
- **Centrally managed.** All configuration is delivered via your
  existing MDM (Jamf, Intune, Workspace ONE, Group Policy) and cannot
  be overridden by end users when an admin profile is present.

For threat-model and sandbox details, request access to the *Claude
Cowork Desktop Security Architecture Overview* on Anthropic's Trust
Center. For 3P-specific architecture / controls, see the *Claude
Cowork Security Overview (Third-Party Platforms)*.

## Installation & MDM rollout

See [`3p/installation.md`](https://claude.com/docs/cowork/3p/installation.md)
for the full deployment matrix — single-machine evaluation, fleet
rollout via Jamf / Intune / Workspace ONE / Group Policy, and the
MDM profile schema.

For multi-region deployments, deploy distinct MDM configuration
profiles per geography so each user population points at an in-region
endpoint (Vertex AI and Bedrock both offer Claude models in EU, UK,
APJ, and other sovereign regions).

## Configuration reference

Every managed-configuration key lives in
[`3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md).
That page is the source of truth for:

**Connection**
- Inference provider selection (`inferenceProvider`: `vertex` | `bedrock` | `foundry` | `gateway`)
- Organization UUID (`deploymentOrganizationUuid`) — required before rollout for telemetry attribution
- Sign-in screen control (`disableDeploymentModeChooser`) — hides Anthropic sign-in option
- Credential helper executable (`inferenceCredentialHelper`, `inferenceCredentialHelperTtlSec`) — for dynamic short-lived credentials
- Model list (`inferenceModels` — string or `{"name","labelOverride","supports1m"}` objects)
- Region pinning (`inferenceVertexRegion`, `inferenceBedrockRegion`)

**Sandbox & workspace**
- Code tab toggle (`isClaudeCodeForDesktopEnabled`)
- Egress allowlist (`coworkEgressAllowedHosts`) — governs Cowork tab sandbox only, not Code tab
- Disabled built-in tools (`disabledBuiltinTools` — array of tool names)
- Allowed workspace folders (`allowedWorkspaceFolders`)
- Deep-link handling (`disableDeepLinkRegistration`)

**Extensions**
- Managed MCP servers (`managedMcpServers` — supports `oauth`, `headersHelper`, `toolPolicy`)
- Org-plugin tool policy (`orgPluginSettings`)
- User extension controls (`isLocalDevMcpEnabled`, `isDesktopExtensionEnabled`, `isDesktopExtensionSignatureRequired`)

**Telemetry & updates**
- Crash/error reports (`disableEssentialTelemetry`)
- Usage analytics (`disableNonessentialTelemetry`)
- Non-critical third-party services (`disableNonessentialServices`)
- Auto-updates (`disableAutoUpdates`, `autoUpdaterEnforcementHours` 1–72 h, default 72)
- OpenTelemetry export (`otlpEndpoint`, `otlpProtocol`, `otlpHeaders`, `otlpResourceAttributes`)

**Usage limits**
- Per-device token cap (`inferenceMaxTokensPerWindow`, `inferenceTokenWindowHours` 1–720 h)

**Appearance**
- Persistent banner (`banner` — `{enabled, text, backgroundColor, textColor, linkUrl}`)

## Data residency

When using Vertex AI or Bedrock, inference requests go directly from
the user's machine to the regional endpoint you configure. Residency
is determined entirely by:

1. The cloud region you select for inference.
2. The physical location of the user's device, where conversations
   are persisted.

Conversation data never traverses Anthropic's backend in these modes.

For data-storage details (memory, conversation history, file
artifacts), see [`3p/data-storage.md`](https://claude.com/docs/cowork/3p/data-storage.md).

## HIPAA

Cowork on 3P does not process user data, prompts, or completions
itself. PHI uploaded to Cowork on 3P is transmitted only to the
customer's CSP and any remote MCP servers the customer chooses to
configure. For HIPAA compliance: ensure a BAA with your CSP, review
all MCP servers, disable Anthropic-bound telemetry if your audit
posture requires it (telemetry itself does not collect user data —
only redacted crash reports and aggregated metrics).

## Telemetry and egress

What the app sends to Anthropic, how to turn it off, and the firewall
allowlist live in [`3p/telemetry.md`](https://claude.com/docs/cowork/3p/telemetry.md).
With Anthropic-bound telemetry and updates disabled, the compliance
posture of your deployment is determined entirely by your inference
provider.

## Extensions (skills, plugins, hooks, MCP)

3P supports the full Cowork extension model: skills, plugins, hooks,
and MCP servers (local + remote). The org-plugins directory acts as
an organization-internal marketplace; the public Anthropic plugin
marketplace is not available in 3P.

See [`3p/extensions.md`](https://claude.com/docs/cowork/3p/extensions.md)
for the per-extension distribution mechanics.

**Auto-install preference for org plugins.** Set `installationPreference` in `.claude-plugin/plugin.json`:

| Value | Behavior |
|---|---|
| `"required"` | Auto-installs; Uninstall action hidden; reinstalls if removed from disk |
| `"auto_install"` | Auto-installs; users may uninstall |
| `"available"` (default) | Users install manually from plugin browser |

## M365 connector (3P-specific)

The Anthropic-built M365 connector **is** available in Cowork on 3P
(unlike most Anthropic 1P connectors, which are not). Setup lives in
[`3p/connectors-m365.md`](https://claude.com/docs/cowork/3p/connectors-m365.md).
Google Workspace connector is not currently supported in 3P (planned).

## Feature matrix (Enterprise vs 3P)

Full comparison: [`3p/feature-matrix.md`](https://claude.com/docs/cowork/3p/feature-matrix.md).

Available in 3P but different from Enterprise:

- Memory: ✓ in 3P, but stored **on device** (not Anthropic infrastructure); no chat-history search or nightly summaries.
- Scheduled tasks: ✓ in 3P.
- Plugin marketplace: org-plugins directory acts as an organization-internal marketplace; public Anthropic plugin marketplace not available.
- Per-user spend caps: blanket token caps (`inferenceMaxTokensPerWindow`) only, not differentiated by role.
- OpenTelemetry export: ✓ in both; replaces Compliance/Analytics API equivalents.

Absent from 3P (versus full Claude Enterprise):

- No Chat tab (Cowork + Code tabs only).
- No Anthropic 1P connectors (except M365; Google Workspace coming soon).
- No Project / plugin sharing across orgs.
- No mobile Dispatch.
- No voice mode.
- No Claude in Chrome.
- No web-based admin console — admin functions delivered via MDM.
- No Compliance API or Analytics API — use OpenTelemetry export instead.

## Cowork guide (standard mode)

User-facing how-to pages for standard Cowork (non-3P):

- [`guide/dispatch.md`](https://claude.com/docs/cowork/guide/dispatch.md) — mobile dispatch.
- [`guide/projects.md`](https://claude.com/docs/cowork/guide/projects.md) — projects in Cowork.
- [`guide/plugins.md`](https://claude.com/docs/cowork/guide/plugins.md) — plugins user guide.

## Monitoring

[`monitoring.md`](https://claude.com/docs/cowork/monitoring.md)
covers OpenTelemetry export, usage analytics, spend tracking, and the
session-activity event schema.

---

*Source pages: 24 under `claude.com/docs/cowork/`. See
[`https://claude.com/docs/cowork/`](https://claude.com/docs/cowork/)
for the version-pinned mirror.*
