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

Four independent telemetry toggles (all boolean, default `false` / enabled):

- `disableEssentialTelemetry`: disables crash reports and error stack traces sent to Anthropic. **Opts you into a manual support model** — collect and send logs yourself.
- `disableNonessentialTelemetry`: disables product-usage analytics (feature adoption, session counts, UI interactions).
- `disableNonessentialServices`: blocks cosmetic third-party fetches (connector favicons, artifact-preview iframe).
- `disableAutoUpdates`: disables update checks and downloads; your IT team must redistribute new builds.

For air-gapped or compliance-hardened deployments, set all four to `true`.

Telemetry NEVER contains user prompts or completions, but if your
audit posture requires zero Anthropic-bound network traffic, disable
all four.

Source: [`cowork/3p/telemetry.md`](https://claude.com/docs/cowork/3p/telemetry.md),
[`cowork/3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md).

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

## Rule 8 — Usage limits are token-based windows, not dollar-based monthly caps

Two keys control the token usage limit:

- `inferenceMaxTokensPerWindow` (integer): total input + output tokens permitted per device per window. Enforced locally; persists across restarts.
- `inferenceTokenWindowHours` (integer, 1–720): length of the tumbling window for the cap above.

There is **no `workspaceSpendCapUSD` key** in the configuration schema. Dollar-based or role-differentiated spend caps are only available in full Claude Enterprise (not Cowork on 3P). Set `inferenceMaxTokensPerWindow` above your expected per-device usage for the window, with a buffer.

Source: [`cowork/3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md).

---

*Source: claude.com/docs/cowork/3p/configuration.md + feature-matrix.md.*
