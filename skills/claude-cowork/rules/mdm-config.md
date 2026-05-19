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

Four independent telemetry/update toggles (all boolean, all default `false`):

- `disableEssentialTelemetry`: crash reports and error telemetry. **Disabling opts you into a manual support model** — your team must collect and send logs.
- `disableNonessentialTelemetry`: product-usage analytics.
- `disableNonessentialServices`: non-critical third-party services (connector favicons, artifact-preview iframe).
- `disableAutoUpdates`: update checks and downloads. When disabled, IT must redistribute new builds manually. Companion key `autoUpdaterEnforcementHours` (integer, default `72`) forces a pending update to install after that many hours (ignored when updates are disabled).

> **Common mistake:** the old names `disableCrashReporting`, `disableProductAnalytics`, and `disableAutoUpdate` are **not recognised** — use the names above or the keys will be silently ignored and telemetry will remain enabled.

For air-gapped or compliance-hardened deployments, set `disableEssentialTelemetry`, `disableNonessentialTelemetry`, `disableNonessentialServices`, and `disableAutoUpdates` all to `true`.

Telemetry NEVER contains user prompts or completions, but if your
audit posture requires zero Anthropic-bound network traffic, disable
all four.

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

For token-level rate-limiting use the per-device token window keys
instead: `inferenceMaxTokensPerWindow` (integer, total input+output tokens)
and `inferenceTokenWindowHours` (integer, 1–720, length of the tumbling
window). The token cap is enforced locally and persists across restarts.

## Rule 9 — Set `deploymentOrganizationUuid` before rollout

`deploymentOrganizationUuid` is a UUID **you generate** to identify your
deployment. Without it, all telemetry from your fleet is tagged with a
shared placeholder UUID (`00000000-0000-4000-8000-000000000001`) that
every unconfigured deployment also uses — making it impossible for
Anthropic to isolate your organization's events when opening a support
case.

Generate once, set in the admin MDM profile, and keep it stable. Format:
`xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`.

## Rule 10 — Credential helper for short-lived tokens

When static API keys are not permitted (e.g. by a secrets-management
policy), use `inferenceCredentialHelper` instead:

```xml
<key>inferenceCredentialHelper</key>
<string>/usr/local/bin/corp-credential-helper</string>
<key>inferenceCredentialHelperTtlSec</key>
<string>3600</string>
```

The helper is an executable the app runs outside the sandbox. Its
**stdout** replaces the static credential. `inferenceCredentialHelperTtlSec`
(default `3600`) caches the output to avoid re-running on every request.

Supported for Bedrock, Foundry, and gateway providers. **Not invoked for
Vertex AI**, which uses file-based credentials or per-user Google sign-in.

---

*Source: claude.com/docs/cowork/3p/configuration.md + feature-matrix.md.*
