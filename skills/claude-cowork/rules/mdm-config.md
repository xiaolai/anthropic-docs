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

Three independent telemetry toggles:

- `disableCrashReporting`: boolean, scrubs and disables crash reports
- `disableProductAnalytics`: boolean, disables usage telemetry
- `disableAutoUpdate`: boolean, disables auto-update checks

All three are off-by-default (telemetry enabled). For air-gapped or
compliance-hardened deployments, set all three to `true`.

Telemetry NEVER contains user prompts or completions, but if your
audit posture requires zero Anthropic-bound network traffic, disable
all three.

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

## Rule 8 — Spend caps are workspace-monthly, not per-request

`workspaceSpendCapUSD` caps monthly usage per workspace. When hit,
requests return 429 `cap_exceeded` until the next billing month.
Set to a value above your monthly forecast, with a buffer.

## Rule 9 — Array- and object-typed keys must be JSON-encoded strings

Keys like `inferenceModels`, `inferenceGatewayOidc`, `managedMcpServers`,
`coworkEgressAllowedHosts`, and `otlpHeaders` store arrays or objects.
In a `.mobileconfig`, write them as a **single `<string>` element containing
a JSON literal** — not a native `<array>` or `<dict>`, and not separate
dotted keys like `inferenceGatewayOidc.clientId`.

```xml
<!-- CORRECT -->
<key>coworkEgressAllowedHosts</key>
<string>["*.example.com","api.partner.com"]</string>

<!-- WRONG — native plist array, will be silently ignored -->
<key>coworkEgressAllowedHosts</key>
<array>
  <string>*.example.com</string>
</array>
```

Same rule applies to Windows registry: write a `REG_SZ` value containing
the JSON string, not separate `REG_MULTI_SZ` or child key structures.

This is documented as the most common configuration mistake in the
[Configuration reference](/cowork/3p/configuration).

## Rule 10 — Set `deploymentOrganizationUuid` before fleet rollout

Generate a UUID (`uuidgen` on macOS/Linux) and set `deploymentOrganizationUuid`
in your MDM profile **before** rollout. Without it, telemetry is tagged
with a shared placeholder UUID and Anthropic cannot isolate your
organization's events when debugging support cases.

---

*Source: claude.com/docs/cowork/3p/configuration.md + feature-matrix.md.*
