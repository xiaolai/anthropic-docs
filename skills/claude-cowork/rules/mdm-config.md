---
name: claude-cowork-mdm-config
description: Edit-time rules for Cowork-on-3P MDM configuration profiles (macOS .plist / Windows registry / Jamf / Intune / Workspace ONE / Group Policy). Catches inferenceProvider enum mismatches, missing region pins, and conflicting telemetry settings.
appliesTo:
  - "**/*.plist"
  - "**/*.mobileconfig"
  - "**/*.reg"
  - "**/cowork-config*.json"
  - "**/intune-cowork*.json"
---

# Cowork on 3P — MDM Configuration Rules

## Rule 1 — `inferenceProvider` is a fixed enum

Valid values: `anthropic`, `vertex`, `bedrock`, `foundry`, `gateway`. Anything
else makes the desktop app fall back to standard Cowork (Anthropic-hosted
inference) — defeating the 3P deployment.

> **Note:** `anthropic` routes directly to the Anthropic API. Use it only when
> you want 3P app delivery with Anthropic inference (e.g., for credential-helper
> management). It does **not** provide 3P data-residency guarantees — for those,
> use `vertex` or `bedrock`.

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

> **Common mistake (Bedrock SSO):** Setting only some of the `inferenceBedrockSso*`
> keys causes the app to silently ignore the partial configuration and fall back
> to bearer-token or named-profile auth. All four must be present together:
> `inferenceBedrockSsoStartUrl`, `inferenceBedrockSsoRegion`,
> `inferenceBedrockSsoAccountId`, `inferenceBedrockSsoRoleName`.
> Requires app version 1.6.0 or later.
> See [`3p/bedrock-aws-sign-in.md`](https://claude.com/docs/cowork/3p/bedrock-aws-sign-in.md).

> **Common mistake (Vertex credential helper):** `inferenceCredentialHelper` is
> **not invoked** when `inferenceProvider` is `vertex`. Vertex authentication is
> file-based — use `inferenceVertexCredentialsFile` (service-account key or ADC
> JSON) or `inferenceVertexOAuthClientId` + `inferenceVertexOAuthClientSecret`
> (in-app Google sign-in) instead.

## Rule 3 — Foundry preview caveat

`inferenceProvider: foundry` is a **preview integration** — model
inference still runs on Anthropic infrastructure during the preview.
The "no conversation egress to Anthropic" guarantee does NOT apply.
For HIPAA / data-sovereignty deployments, use Bedrock or Vertex.

If your org's compliance policy requires no Anthropic egress, the
MDM profile should explicitly NOT set `inferenceProvider: foundry`.

## Rule 4 — Telemetry kill switches

Four independent telemetry/service toggles (all default `false` = enabled):

- `disableEssentialTelemetry`: boolean — blocks crash reports and error telemetry to Anthropic. **Disabling opts you into a manual support model** (your team must collect and send logs directly).
- `disableNonessentialTelemetry`: boolean — blocks product-usage analytics to Anthropic.
- `disableNonessentialServices`: boolean — blocks non-critical third-party fetches (connector favicons, artifact-preview iframe).
- `disableAutoUpdates`: boolean — blocks update checks and downloads from Anthropic (IT must redistribute new builds).

When all four are `true`, the desktop app makes **no outbound connections to Anthropic-operated hosts at runtime**.

Telemetry NEVER contains user prompts or completions, but if your
audit posture requires zero Anthropic-bound network traffic, set all
four to `true`.

> **Common mistake:** the old key names `disableCrashReporting`,
> `disableProductAnalytics`, and `disableAutoUpdate` do not exist —
> they are silently ignored by the app. Always use the names above.

Source: [`cowork/3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md),
[`cowork/3p/telemetry.md`](https://claude.com/docs/cowork/3p/telemetry.md).

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

## Rule 7 — Org-plugins directory: bump `version.json`, not a config key

There is **no `orgPluginsDirectory` configuration key**. Organization plugins
are distributed by placing plugin bundles in a well-known filesystem directory
on each device (MDM-managed or software-distribution channel):

| Platform | Directory |
|---|---|
| macOS | `/Library/Application Support/Claude/org-plugins/` |
| Windows | `C:\Program Files\Claude\org-plugins\` |

Each subdirectory is one plugin and must contain `.claude-plugin/plugin.json`.
To push an update, bump the `version` string in the plugin's `version.json`
(`{"version": "1.2.3"}`). **Any string change triggers re-sync on next
launch — there is no semver ordering.** If `version.json` is absent,
Cowork falls back to the directory's modification time.

> **Common mistake:** setting `orgPluginsDirectory` or `orgPluginsManifestUrl`
> as a config key — neither exists. The directory path is fixed by the
> platform; only its contents are managed by the admin.

## Rule 8 — Token caps are per-device and token-based, not USD per-workspace

`inferenceMaxTokensPerWindow` caps total input + output tokens allowed per
device per rolling window. When hit, the app **refuses new messages locally**
until the window resets — no 429 from the provider.

Pair with `inferenceTokenWindowHours` (integer, 1–720) to set the window
length. Both keys are enforced locally and persist across restarts.

> **Common mistake:** `workspaceSpendCapUSD` does not exist as a config key.
> 3P spend limits are token-based and device-local, not USD-based per-workspace.
> Set `inferenceMaxTokensPerWindow` to a value above your expected daily usage
> times the window length, with a comfortable buffer.

Source: [`cowork/3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md).

## Rule 9 — Set `deploymentOrganizationUuid` before rollout

`deploymentOrganizationUuid` is a UUID **you generate** to identify your
deployment in telemetry. Without it, all events from your fleet are tagged
with a shared placeholder UUID (`00000000-0000-4000-8000-000000000001`) that
every unconfigured deployment also uses — Anthropic cannot distinguish your
organization's crash reports when you open a support case.

Generate before rollout: `uuidgen` (macOS/Linux) or
`[System.Guid]::NewGuid()` (PowerShell).

> **Common mistake:** `disabledBuiltinTools` silently ignores any entry
> whose value doesn't exactly match a recognized tool name (e.g. `"bash"`
> instead of `"Bash"`). Check names against the full list in
> [`cowork/3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md#sandbox--workspace).

Source: [`cowork/3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md).

## Rule 10 — Array/object keys must be JSON strings, not native plist/registry structures

The most common configuration mistake: writing array- or object-typed keys as
native plist `<array>` / `<dict>` or registry multi-value types instead of as
a single JSON-encoded `<string>`.

Affected keys: `inferenceModels`, `managedMcpServers`, `coworkEgressAllowedHosts`,
`disabledBuiltinTools`, `allowedWorkspaceFolders`, `otlpHeaders`,
`otlpResourceAttributes`, `inferenceGatewayOidc`.

**Correct (macOS .mobileconfig / .plist):**

```xml
<key>inferenceModels</key>
<string>["claude-sonnet-4","claude-opus-4"]</string>

<key>managedMcpServers</key>
<string>[{"name":"search","url":"https://mcp.corp","oauth":true}]</string>
```

**Wrong — silently ignored:**

```xml
<key>inferenceModels</key>
<array>
  <string>claude-sonnet-4</string>
</array>
```

> **Common mistake:** never use dotted key names like
> `inferenceGatewayOidc.clientId` — only the flat string-encoded JSON object
> is supported.

Source: [`cowork/3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md#value-types).

---

## Rule 11 — `builtinToolPolicy` vs `disabledBuiltinTools`

Two keys control built-in tool access; they operate at different levels:

- **`builtinToolPolicy`** — keeps the tool available but adds a per-call user
  approval prompt. JSON object mapping tool name → `"allow"` (default, no prompt)
  or `"ask"` (requires user approval each call).
- **`disabledBuiltinTools`** — removes the tool from the agent entirely.

> **Common mistake:** setting `"blocked"` as a value in `builtinToolPolicy` — it
> is not accepted there. To block a tool, add it to `disabledBuiltinTools`.

> **Common mistake:** using the old `inferenceGatewayHeaders` key for custom
> inference headers. The canonical name is now `inferenceCustomHeaders`;
> `inferenceGatewayHeaders` is still accepted as an alias but may be removed in
> a future version.

Source: [`cowork/3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md#workspace-restrictions).

---

*Source: claude.com/docs/cowork/3p/configuration.md + feature-matrix.md.*
