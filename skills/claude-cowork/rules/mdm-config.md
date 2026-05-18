---
name: claude-cowork-mdm-config
description: Edit-time rules for Cowork-on-3P MDM configuration profiles (macOS .plist / Windows registry / Jamf / Intune / Workspace ONE / Group Policy). Catches inferenceProvider enum mismatches, missing region pins, and conflicting telemetry settings.
appliesTo:
  - "**/*.plist"
  - "**/*.mobileconfig"
  - "**/cowork-config*.json"
  - "**/intune-cowork*.json"
---

# Cowork on 3P — MDM Configuration Rules

## Rule 1 — `inferenceProvider` is a fixed enum

Valid values: `vertex`, `bedrock`, `foundry`, `gateway`. Anything else
makes the desktop app fall back to standard Cowork (Anthropic-hosted
inference) — defeating the 3P deployment.

```xml
<key>inferenceProvider</key>
<string>bedrock</string>   <!-- not "Bedrock", not "aws-bedrock" -->
```

## Rule 2 — Region pin required for vertex / bedrock

When `inferenceProvider` is `vertex`, **must** also set
`inferenceVertexRegion`. When `bedrock`, set `inferenceBedrockRegion`.
Without these, the app falls back to a default region (us-east) which
defeats data-residency guarantees.

```xml
<key>inferenceProvider</key>
<string>vertex</string>
<key>inferenceVertexRegion</key>
<string>europe-west4</string>
```

## Rule 3 — Foundry preview caveat

`inferenceProvider: foundry` is a **preview integration** — model
inference still runs on Anthropic infrastructure during the preview.
The "no conversation egress to Anthropic" guarantee does NOT apply.
For HIPAA / data-sovereignty deployments, use Bedrock or Vertex.

If your org's compliance policy requires no Anthropic egress, the
MDM profile should explicitly NOT set `inferenceProvider: foundry`.

## Rule 4 — Telemetry kill switches

Four independent telemetry toggles (all default `false` = telemetry enabled):

- `disableEssentialTelemetry`: boolean — disables crash reports and error
  telemetry. **Enabling this moves you to a manual support model** (your team
  must collect and send logs to Anthropic directly).
- `disableNonessentialTelemetry`: boolean — disables product-usage analytics.
- `disableNonessentialServices`: boolean — disables connector favicons and the
  artifact-preview iframe (cosmetic only; doesn't affect functionality).
- `disableAutoUpdates`: boolean (note the trailing **s**) — disables update
  checks and downloads.

For air-gapped or compliance-hardened deployments, set all four to `true`.

Telemetry NEVER contains user prompts or completions, but if your
audit posture requires zero Anthropic-bound network traffic, disable
all four. See [Telemetry and egress](https://claude.com/docs/cowork/3p/telemetry.md)
for the exact hostnames blocked by each toggle.

Source: [`3p/telemetry.md`](https://claude.com/docs/cowork/3p/telemetry.md),
[`3p/configuration.md § Telemetry & updates`](https://claude.com/docs/cowork/3p/configuration.md).

## Rule 5 — Don't mix per-user and admin profiles

When an admin MDM profile is present, end-user overrides are ignored.
If you ship a user-level config that contradicts the admin profile,
the user-level config is silently dropped — debugging takes hours.

Best practice: admin profile owns infrastructure config
(provider, region, auth); per-user config owns preferences (theme,
shortcuts). Don't let them overlap.

## Rule 6 — M365 connector requires Microsoft Graph admin consent

The `enableM365Connector: true` key alone doesn't install the
connector. Microsoft Graph admin consent must complete first (see
[`3p/connectors-m365.md`](https://claude.com/docs/cowork/3p/connectors-m365.md)).
Without the consent, the connector is visible but every operation
errors with "permissions not granted by an admin."

## Rule 7 — Org-plugins directory: pin versions

The `orgPluginsDirectory` config takes a URL to a marketplace-style
JSON file your org publishes. **Pin plugin versions** in that
manifest; bare references resolve to "latest" and inherit any
breaking change immediately.

## Rule 8 — Usage caps are token-window-based, not USD-monthly

There is no `workspaceSpendCapUSD` key. The enforcement primitive is tokens,
not dollars. Two keys work together:

- `inferenceMaxTokensPerWindow`: integer — total input + output tokens per
  device per window. When hit, the app refuses new messages until the window
  resets.
- `inferenceTokenWindowHours`: integer (1–720) — length of the tumbling window
  for the cap above.

Caps are enforced locally on the device and persist across restarts. There is
no server-side `cap_exceeded` response code — the app simply blocks locally.
Size the window and cap to your organization's realistic session volume with a
comfortable buffer.

## Rule 9 — Set `deploymentOrganizationUuid` before fleet rollout

`deploymentOrganizationUuid` is a UUID **you generate** that identifies your
deployment in Anthropic telemetry. Without it, all telemetry from your fleet is
tagged with the shared placeholder `00000000-0000-4000-8000-000000000001` —
making it impossible for Anthropic support to locate your organization's crash
reports when you file a support case.

```xml
<key>deploymentOrganizationUuid</key>
<string>xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx</string>
```

Generate one UUID per deployment (e.g. `uuidgen` on macOS, `[System.Guid]::NewGuid()` on Windows) and set it in the MDM profile before rollout. It does not need to match any Anthropic account ID — it just needs to be consistent across the fleet.

## Rule 10 — JSON-string encoding for array and object keys

The most common authoring mistake: writing array- or object-typed keys as
native plist/registry structures. These keys **must** be JSON strings:

- `inferenceModels` — JSON array of strings or model-descriptor objects
- `inferenceGatewayOidc` — JSON object
- `managedMcpServers` — JSON array of server objects
- `coworkEgressAllowedHosts` — JSON array of hostnames/wildcards
- `otlpHeaders` / `otlpResourceAttributes` — JSON objects

In a `.mobileconfig`, use a single `<string>` containing `[...]` or `{...}` —
**not** an `<array>`, `<dict>`, or dotted keys like
`inferenceGatewayOidc.clientId`.

```xml
<!-- CORRECT -->
<key>coworkEgressAllowedHosts</key>
<string>["*.your-org.com","api.partner.com"]</string>

<!-- WRONG — native plist array is silently ignored -->
<key>coworkEgressAllowedHosts</key>
<array>
  <string>*.your-org.com</string>
</array>
```

Source: [`3p/configuration.md § Value types`](https://claude.com/docs/cowork/3p/configuration.md).

---

*Source: claude.com/docs/cowork/3p/configuration.md + feature-matrix.md + telemetry.md.*
