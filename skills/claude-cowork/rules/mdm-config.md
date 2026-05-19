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

Five independent telemetry/update toggles (all `false` by default):

- `disableEssentialTelemetry`: boolean — block crash reports and error telemetry to Anthropic. **Enabling this opts you into a manual support model** (your team must collect and send logs).
- `disableNonessentialTelemetry`: boolean — block product-usage analytics.
- `disableNonessentialServices`: boolean — block non-critical third-party services (connector favicons, artifact-preview iframe).
- `disableAutoUpdates`: boolean — block update checks and downloads (IT team must redistribute new builds).
- `autoUpdaterEnforcementHours`: integer (1–72) — force a pending update to install after this many hours. Ignored when `disableAutoUpdates` is `true`.

Telemetry NEVER contains user prompts or completions, but if your
audit posture requires zero Anthropic-bound network traffic, set all
four boolean toggles to `true`.

> **Key-name change:** The former keys `disableCrashReporting`,
> `disableProductAnalytics`, and `disableAutoUpdate` (no trailing "s")
> are **no longer valid** — use the names above.
> Source: [`3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md)

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

## Rule 8 — Token caps are per-device, per-window

`inferenceMaxTokensPerWindow` (integer) caps total input + output tokens per
device per rolling window. `inferenceTokenWindowHours` (integer, 1–720) sets
the window length. When the cap is hit, the app refuses new messages until
the window resets. Both values are enforced locally and persist across
restarts.

> Note: the former `workspaceSpendCapUSD` key (USD spend cap) has been
> replaced by the token-based cap above.
> Source: [`3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md)

## Rule 9 — `deploymentOrganizationUuid` must be set before rollout

Generate a UUID for your org and set `deploymentOrganizationUuid` before
fleet deployment. Anthropic uses this value to locate crash reports and
telemetry from your fleet when you open a support case. Without it, your
telemetry is tagged with a shared placeholder UUID that every unconfigured
deployment also uses, making fleet-specific debugging impossible.

## Rule 10 — `inferenceModels` entries may be strings or objects

The `inferenceModels` key takes a JSON-stringified `(string | object)[]`.
Plain strings use the provider's exact model ID. Objects allow:

- `name` (required): provider model ID.
- `labelOverride`: friendly display name for IDs the picker can't parse
  (e.g. Bedrock ARNs, provisioned-throughput ARNs, gateway aliases).
- `supports1m`: set `true` only if you've confirmed the deployed model
  supports the 1M-token context window. Do NOT set speculatively — sessions
  will fail mid-conversation once the context grows past the real limit.

```text
inferenceModels: '[{"name":"claude-opus-4","supports1m":true},"claude-sonnet-4"]'
```

## Rule 11 — `inferenceCredentialHelper` for short-lived tokens

If static API keys are not permitted, set `inferenceCredentialHelper` to an
absolute path to an executable on the host. Its stdout is used as the
inference credential. Set `inferenceCredentialHelperTtlSec` (default `3600`)
to control how long the output is cached before re-invoking.

The helper runs **outside the sandbox**, at session start and on cache expiry.
Pair with your SSO / secrets manager / PKI tooling.
**Not applicable to Vertex AI**, which uses file-based credentials or Google
sign-in.

---

*Source: [`claude.com/docs/cowork/3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md) + [`feature-matrix.md`](https://claude.com/docs/cowork/3p/feature-matrix.md).*
