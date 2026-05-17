> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Configuration reference

> Every managed-configuration key Cowork on 3P supports, what it controls, and recommended security profiles

Cowork on third-party (3P) is configured entirely through OS-native managed preferences: a `.mobileconfig` profile on macOS or registry policy on Windows. This page documents every supported key.

The easiest way to author a configuration is the in-app configuration window (**Developer → Configure third-party inference**), which validates values, shows per-provider requirements, and exports directly to `.mobileconfig` or `.reg`. Use this reference when you need to author policy by hand, audit an existing profile, or understand exactly what a key does.

## How keys are read

| Platform | Managed (MDM) location                                                            | Local (user) location                                    |
| -------- | --------------------------------------------------------------------------------- | -------------------------------------------------------- |
| macOS    | `/Library/Managed Preferences/<user>/com.anthropic.claudefordesktop.plist`        | `~/Library/Application Support/Claude-3p/configLibrary/` |
| Windows  | `HKLM\SOFTWARE\Policies\Claude` (machine), `HKCU\SOFTWARE\Policies\Claude` (user) | `%LOCALAPPDATA%\Claude-3p\configLibrary\`                |

The local location is a directory: `_meta.json` records which saved configuration is applied, and each configuration is a `<id>.json` file alongside it. The in-app configuration window writes here.

When a managed source is present, it wins and locally written values are ignored. Configuration is read **once at launch**, so fully quit and reopen the app after any change. See [Installation and setup](/cowork/3p/installation) for the full precedence rules.

### Value types

All values are stored as **strings** in the OS preference store, even booleans and arrays.

| Documented type  | What to write                                                          | Example                                       |
| ---------------- | ---------------------------------------------------------------------- | --------------------------------------------- |
| string           | Plain string                                                           | `vertex`                                      |
| boolean          | `"true"` or `"false"` (or `1` / `0`)                                   | `"true"`                                      |
| integer          | Decimal string                                                         | `"3600"`                                      |
| string\[] (JSON) | JSON array **encoded as a string** (not a native plist/registry array) | `["claude-sonnet-4","claude-opus-4"]`         |
| object (JSON)    | JSON object mapping name to value, as a string                         | `{"X-Org-Id":"team1"}`                        |
| object\[] (JSON) | JSON array of objects, as a string                                     | see [`managedMcpServers`](#managedmcpservers) |

<Warning>
  The most common configuration mistake is writing array- or object-typed keys as native plist/registry structures. Keys like `inferenceModels`, `inferenceGatewayOidc`, `managedMcpServers`, `coworkEgressAllowedHosts`, and `otlpHeaders` must be **JSON strings**. In a `.mobileconfig`, that means a single `<string>` element containing `[...]` or `{...}` — not an `<array>`, not a `<dict>`, and not separate keys with dotted names like `inferenceGatewayOidc.clientId`.
</Warning>

The sections below match the sidebar of the in-app configuration window.

***

<div className="cfg-keys">
  ## Connection

  ### Activation

  | Setting                                                    | Type    | Description                                                                                                                                                                                                                                                       |
  | ---------------------------------------------------------- | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | Inference provider<br />`inferenceProvider`                | string  | Selects the inference backend. One of `gateway`, `vertex`, `bedrock`, `foundry`. **3P mode activates only when this key is set *and* the required credential keys for the selected provider are present and valid**; otherwise the app launches in standard mode. |
  | Organization UUID<br />`deploymentOrganizationUuid`        | string  | A UUID **you generate** to identify your deployment, in standard `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` format. Used to attribute telemetry to your organization.                                                                                                 |
  | Hide Anthropic sign-in<br />`disableDeploymentModeChooser` | boolean | When `true`, hides the **Sign in to Anthropic** option on the sign-in screen so users see only the third-party option from this configuration. The screen itself still appears. Any previously persisted sign-in choice is ignored.                               |

  <Note>
    Generate and set `deploymentOrganizationUuid` before rollout. Anthropic uses this value to locate crash reports and telemetry from your fleet when you open a support case. If it's unset, your telemetry is tagged with a shared placeholder UUID (`00000000-0000-4000-8000-000000000001`) that every unconfigured deployment also uses, and Anthropic cannot distinguish your organization's events from anyone else's.
  </Note>

  ### Provider credentials

  Each provider has its own required keys, documented on its dedicated page below. Keys for providers other than the one selected in `inferenceProvider` are ignored.

  <CardGroup cols={2}>
    <Card title="Google Cloud's Vertex AI" href="/cowork/3p/vertex">
      `inferenceProvider: "vertex"`
    </Card>

    <Card title="Amazon Bedrock" href="/cowork/3p/bedrock">
      `inferenceProvider: "bedrock"`
    </Card>

    <Card title="Microsoft Foundry" href="/cowork/3p/foundry">
      `inferenceProvider: "foundry"`
    </Card>

    <Card title="LLM gateway" href="/cowork/3p/gateway">
      `inferenceProvider: "gateway"`
    </Card>
  </CardGroup>

  ### Credential helper

  For environments where static API keys aren't permitted, Cowork on 3P can invoke an executable you provide to fetch a short-lived credential at runtime.

  | Setting                                                      | Type    | Description                                                                                                                                               |
  | ------------------------------------------------------------ | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | Credential helper script<br />`inferenceCredentialHelper`    | string  | Absolute path to an executable on the host. Its **stdout** is used as the inference credential, replacing the static API-key key for the chosen provider. |
  | Credential helper TTL<br />`inferenceCredentialHelperTtlSec` | integer | Cache the helper's output for this many seconds before re-running it. Default `3600`.                                                                     |

  The helper runs on the host (outside the sandbox) at session start and on cache expiry. Pair this with your organization's SSO, secrets manager, or PKI tooling. The helper applies to Bedrock, Foundry, and gateway providers; it is not invoked for Google Cloud's Vertex AI, which uses [file-based credentials or Google sign-in](/cowork/3p/vertex#authentication).

  In the in-app configuration window, the **Credential helper script** field has a **Run** button that executes the script once and shows a status chip with the exit code, the run time, and whether stdout produced a non-empty credential. Use it to validate the script before exporting the configuration.

  ### Models

  | Setting                           | Type                         | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
  | --------------------------------- | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
  | Model list<br />`inferenceModels` | (string \| object)\[] (JSON) | Models to expose in the picker. Use the **provider's exact model ID**: Vertex publisher IDs (`claude-sonnet-4@20250514`), Bedrock inference-profile IDs (`us.anthropic.claude-sonnet-4-...-v1:0`), or Foundry deployment names. The first entry is the default. **Required for Vertex and Foundry**; Bedrock auto-discovers when using a bearer token (set explicitly for profile/SSO auth); gateways auto-discover available models. Entries may be plain strings or objects of the form `{"name": "<id>", "labelOverride": "<label>", "supports1m": true}`; see below. |

  #### Offering a 1M-token context variant

  If your provider serves a model with the extended 1M-token context window, you can expose it as a separate picker entry by setting `supports1m: true` on that model's entry:

  ```json theme={null}
  "inferenceModels": [
    { "name": "claude-opus-4", "supports1m": true },
    "claude-sonnet-4"
  ]
  ```

  `supports1m` is a capability assertion you make about your deployment — Cowork doesn't probe the provider to verify it. Only set it for models you've confirmed support the extended window; selecting a 1M variant on a model that doesn't will fail mid-session once the conversation grows past the model's actual limit.

  <Note>
    **Gateway:** the `name` must be the exact ID your gateway's `/v1/models` endpoint returns. If you set `supports1m` on an alias (`sonnet`) but discovery returns the full ID (`claude-sonnet-4-6`), the variant won't appear.
  </Note>

  #### Setting a display label

  By default, Cowork derives a friendly picker label from the model ID. For IDs where that derivation falls through (Bedrock application-inference-profile ARNs, provisioned-throughput ARNs, or gateway routing aliases), set `labelOverride` to the text you want shown in the model picker:

  ```json theme={null}
  "inferenceModels": [
    {
      "name": "arn:aws:bedrock:us-east-1:123456789012:application-inference-profile/abc123",
      "labelOverride": "Claude Opus (Prod)"
    },
    { "name": "us.anthropic.claude-sonnet-4-20250514-v1:0" }
  ]
  ```

  `labelOverride` is display-only; the `name` value is still what Cowork sends to the provider.

  ## Sandbox & workspace

  | Setting                                                                 | Type             | Default                 | Description                                                                                                                                                                                                                                                                                                                                                        |
  | ----------------------------------------------------------------------- | ---------------- | ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
  | Disabled built-in tools<br />`disabledBuiltinTools`                     | string\[] (JSON) | `[]`                    | Built-in tool names to remove from the agent entirely (e.g. `["WebSearch","Bash"]`). Valid names: `Bash`, `Read`, `Write`, `Edit`, `Glob`, `Grep`, `NotebookEdit`, `WebFetch`, `WebSearch`, `Task`, `TodoWrite`, `TaskCreate`, `TaskUpdate`, `TaskGet`, `TaskList`, `TaskStop`, `Skill`, `REPL`, `JavaScript`, `AskUserQuestion`, `ToolSearch`, `SendUserMessage`. |
  | Allowed workspace folders<br />`allowedWorkspaceFolders`                | string\[] (JSON) | unrestricted            | Absolute paths users may attach as workspace folders. Leading `~` expands to the user's home. When set, any path outside this list is rejected.                                                                                                                                                                                                                    |
  | Allowed egress hosts<br />`coworkEgressAllowedHosts`                    | string\[] (JSON) | inference endpoint only | Hostnames the agent's web-fetch and shell tools may reach. Supports `*.example.com` wildcards. `["*"]` disables egress filtering. The configured inference endpoint is always allowed implicitly. When unset, only the inference endpoint is reachable; the agent's package installs and web fetches will fail.                                                    |
  | Allow Claude Code tab<br />`isClaudeCodeForDesktopEnabled`              | boolean          | `true`                  | Show the Code tab.                                                                                                                                                                                                                                                                                                                                                 |
  | Disable claude:// deep-link handling<br />`disableDeepLinkRegistration` | boolean          | `false`                 | Stop the app registering as the `claude://` URL handler, so external apps and websites can't open Cowork via deep links.                                                                                                                                                                                                                                           |

  <Note>
    `coworkEgressAllowedHosts` governs the **Cowork tab's** sandbox — web fetch, shell commands, and package installs run by the Cowork agent. It does **not** restrict the Code tab, which executes on the host with the user's normal network access. To remove the Code tab, set `isClaudeCodeForDesktopEnabled` to `false`.

    It also does **not** apply to [Web Search](/cowork/3p/web-tools#web-search), which runs server-side at your inference provider rather than from the sandbox.
  </Note>

  ## Connectors & extensions

  | Setting                                                              | Type             | Default | Description                                                                                                                                               |
  | -------------------------------------------------------------------- | ---------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | Managed MCP servers<br />`managedMcpServers`                         | object\[] (JSON) | `[]`    | Remote MCP servers deployed to all users. See [schema](#managedmcpservers).                                                                               |
  | Organization plugin settings<br />`orgPluginSettings`                | object (JSON)    | `{}`    | Per-tool policy for MCP servers delivered via [organization plugins](/cowork/3p/extensions#organization-plugins-admin). See [schema](#orgpluginsettings). |
  | Allow user-added MCP servers<br />`isLocalDevMcpEnabled`             | boolean          | `true`  | Allow users to add their own local MCP servers from **Settings → Developer**. End users cannot add remote MCP servers regardless of this setting.         |
  | Allow desktop extensions<br />`isDesktopExtensionEnabled`            | boolean          | `true`  | Allow installing local desktop extensions (`.mcpb`).                                                                                                      |
  | Require signed extensions<br />`isDesktopExtensionSignatureRequired` | boolean          | `false` | Reject unsigned desktop extensions.                                                                                                                       |

  See [MCP, plugins, skills, and hooks](/cowork/3p/extensions) for the org-plugins directory layout and the full `managedMcpServers` schema.

  ### `managedMcpServers`

  A JSON-stringified array of server objects:

  | Field                 | Required         | Description                                                                                                                                                                                                                                  |
  | --------------------- | ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | `name`                | Yes              | Unique display name.                                                                                                                                                                                                                         |
  | `url`                 | For `http`/`sse` | Server URL. Must be `https://`.                                                                                                                                                                                                              |
  | `transport`           | —                | `"http"` (default), `"sse"`, or `"stdio"` for a local command.                                                                                                                                                                               |
  | `headers`             | —                | Static string→string header map. Mutually exclusive with `oauth`.                                                                                                                                                                            |
  | `headersHelper`       | —                | Absolute path to an executable that prints a JSON header object on stdout, for short-lived auth tokens. Mutually exclusive with `oauth`.                                                                                                     |
  | `headersHelperTtlSec` | —                | Cache helper output for this many seconds. Default `300`.                                                                                                                                                                                    |
  | `oauth`               | —                | Enables a browser-based OAuth flow; tokens stored in the OS keychain. Set to `true` for dynamic client registration, or to an object that supplies a pre-registered client (see below). Mutually exclusive with `headers` / `headersHelper`. |
  | `toolPolicy`          | —                | Map of tool name → `"allow"` / `"ask"` / `"blocked"`. Locks the per-tool approval state for that server.                                                                                                                                     |
  | `command`             | For `stdio`      | Absolute path to the executable to spawn.                                                                                                                                                                                                    |
  | `args`                | —                | Command-line arguments (`stdio` only).                                                                                                                                                                                                       |
  | `env`                 | —                | Environment variables for the spawned process (`stdio` only).                                                                                                                                                                                |

  When the MCP server's OAuth provider doesn't support dynamic client registration (for example, Slack or Microsoft Entra ID), set `oauth` to an object describing a client you've registered with that provider:

  | `oauth` field  | Required | Description                                                                                            |
  | -------------- | -------- | ------------------------------------------------------------------------------------------------------ |
  | `clientId`     | Yes      | Client ID of the pre-registered OAuth client.                                                          |
  | `tenantId`     | —        | Tenant ID, for providers that scope clients to a tenant (e.g. Microsoft Entra ID).                     |
  | `scope`        | —        | Space-separated OAuth scopes to request.                                                               |
  | `callbackPort` | —        | Loopback port the client's registered redirect URI uses (1024–65535). Defaults to `53280`.             |
  | `callbackHost` | —        | Loopback host: `127.0.0.1` (default) or `localhost`. Set to match the registered redirect URI exactly. |

  The app builds the redirect URI as `http://<callbackHost>:<callbackPort>/callback`; register that exact value with the OAuth provider.

  ### `orgPluginSettings`

  A JSON-stringified object that applies `toolPolicy` locks to MCP servers delivered through the [org-plugins directory](/cowork/3p/extensions#organization-plugins-admin), keyed by server name:

  ```json theme={null}
  {
    "mcpServers": {
      "internal-search": { "toolPolicy": { "delete_document": "blocked" } }
    }
  }
  ```

  If a `managedMcpServers` entry and an org-plugin server share a name, the `managedMcpServers` entry wins and its `toolPolicy` (if any) applies; the `orgPluginSettings` entry for that name is ignored.

  ## Telemetry & updates

  See [Telemetry and egress](/cowork/3p/telemetry) for what each category sends and the network paths involved.

  ### Anthropic telemetry and updates

  | Setting                                                           | Type    | Default | Description                                                                                                                                                                     |
  | ----------------------------------------------------------------- | ------- | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | Block essential telemetry<br />`disableEssentialTelemetry`        | boolean | `false` | Block crash reports and error telemetry to Anthropic. **Disabling this opts you into a manual support model** in which your team collects and sends logs to Anthropic directly. |
  | Block nonessential telemetry<br />`disableNonessentialTelemetry`  | boolean | `false` | Block product-usage analytics to Anthropic.                                                                                                                                     |
  | Block nonessential services<br />`disableNonessentialServices`    | boolean | `false` | Block non-critical third-party services: connector favicons and the artifact-preview iframe.                                                                                    |
  | Block auto-updates<br />`disableAutoUpdates`                      | boolean | `false` | Block update checks and downloads from Anthropic. Your IT team must redistribute new builds.                                                                                    |
  | Auto-update enforcement window<br />`autoUpdaterEnforcementHours` | integer | `72`    | Force a pending update to install after this many hours (1–72). Ignored when auto-updates are disabled.                                                                         |

  ### OpenTelemetry export

  Export full session activity to your own collector. See [Monitoring](/cowork/monitoring) for the event schema.

  | Setting                                                         | Type          | Description                                                                                                                                                                                                                                                                                                                                                  |
  | --------------------------------------------------------------- | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
  | OpenTelemetry collector endpoint<br />`otlpEndpoint`            | string        | Base URL of your OTLP collector. When set, sessions export logs and metrics (prompts, tool calls, token counts). The endpoint host is automatically added to the sandbox network allowlist.                                                                                                                                                                  |
  | OpenTelemetry exporter protocol<br />`otlpProtocol`             | string        | `http/protobuf` (default), `http/json`, or `grpc`.                                                                                                                                                                                                                                                                                                           |
  | OpenTelemetry exporter headers<br />`otlpHeaders`               | object (JSON) | Headers sent on every OTLP request, as a JSON object mapping header name to value (e.g. `{"Authorization":"Bearer …"}`). A comma-separated `key=value` string (the `OTEL_EXPORTER_OTLP_HEADERS` format) is also accepted for compatibility.                                                                                                                  |
  | OpenTelemetry resource attributes<br />`otlpResourceAttributes` | object (JSON) | Extra resource attributes attached to every exported span and metric, as a JSON object mapping attribute name to value (e.g. `{"enduser.id":"alice@example.com"}`). Appended to the app's built-in attributes; keys that collide with built-ins such as `service.name` are dropped. A comma-separated `key=value` string is also accepted for compatibility. |

  ## Usage limits

  | Setting                                                  | Type    | Description                                                                                                                                                                  |
  | -------------------------------------------------------- | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
  | Max tokens per window<br />`inferenceMaxTokensPerWindow` | integer | Total input + output tokens permitted per device per window. When reached, the app refuses new messages until the window resets. Enforced locally; persists across restarts. |
  | Token cap window<br />`inferenceTokenWindowHours`        | integer | Length of the tumbling window for the cap above, 1–720 hours.                                                                                                                |

  ## Appearance

  | Setting              | Type          | Default | Description                                                                                      |
  | -------------------- | ------------- | ------- | ------------------------------------------------------------------------------------------------ |
  | Banner<br />`banner` | object (JSON) | unset   | A persistent banner shown across the top of the app window after sign-in. See [schema](#banner). |

  ### `banner`

  A JSON-stringified object:

  | Field             | Required     | Description                                                      |
  | ----------------- | ------------ | ---------------------------------------------------------------- |
  | `enabled`         | —            | Show the banner.                                                 |
  | `text`            | When enabled | Banner text. Single line, up to 200 characters.                  |
  | `backgroundColor` | —            | Six-digit hex color (`#RRGGBB`) for the banner background.       |
  | `textColor`       | —            | Six-digit hex color (`#RRGGBB`) for the banner text.             |
  | `linkUrl`         | —            | HTTPS URL. When set, the banner text becomes a link to this URL. |
</div>

## Plugins & skills

Plugins and skills have no configuration keys. They are distributed by placing plugin bundles in the [org-plugins directory](/cowork/3p/extensions#organization-plugins-admin) on each device, which the configuration window's Plugins & skills section displays for reference.

***

## Recommended security profiles

The profiles below are illustrative examples rather than built-in presets, and the labels are descriptive only. Use them as starting points and adjust for your environment. Layer the inference-provider keys for your cloud on top of whichever profile you choose.

<Tabs>
  <Tab title="Standard">
    Recommended for most enterprise deployments. Telemetry and auto-updates stay on so Anthropic can diagnose issues and ship fixes; users can extend Cowork with their own connectors.

    | Key                                   | Value              |
    | ------------------------------------- | ------------------ |
    | `deploymentOrganizationUuid`          | `<your-org-uuid>`  |
    | `autoUpdaterEnforcementHours`         | `24`               |
    | `isDesktopExtensionSignatureRequired` | `true`             |
    | `otlpEndpoint`                        | `<your-collector>` |
  </Tab>

  <Tab title="Restricted">
    For regulated environments that need to control what users can connect Cowork to, while keeping Anthropic supportability.

    | Key                            | Value                    |
    | ------------------------------ | ------------------------ |
    | `deploymentOrganizationUuid`   | `<your-org-uuid>`        |
    | `disableNonessentialTelemetry` | `true`                   |
    | `disableNonessentialServices`  | `true`                   |
    | `isLocalDevMcpEnabled`         | `false`                  |
    | `isDesktopExtensionEnabled`    | `false`                  |
    | `allowedWorkspaceFolders`      | `["~/Documents/Claude"]` |
    | `coworkEgressAllowedHosts`     | `["*.your-org.com"]`     |
    | `otlpEndpoint`                 | `<your-collector>`       |
  </Tab>

  <Tab title="Locked down">
    For air-gapped or maximally restricted environments. **The only traffic leaving the device goes to your inference endpoint and OTLP collector.** With this profile, Anthropic has zero remote visibility, so your team owns log collection and update distribution.

    | Key                            | Value                      |
    | ------------------------------ | -------------------------- |
    | `disableEssentialTelemetry`    | `true`                     |
    | `disableNonessentialTelemetry` | `true`                     |
    | `disableNonessentialServices`  | `true`                     |
    | `disableAutoUpdates`           | `true`                     |
    | `isLocalDevMcpEnabled`         | `false`                    |
    | `isDesktopExtensionEnabled`    | `false`                    |
    | `disabledBuiltinTools`         | `["WebSearch","WebFetch"]` |
    | `coworkEgressAllowedHosts`     | `[]`                       |
    | `allowedWorkspaceFolders`      | `["~/Documents/Claude"]`   |
    | `otlpEndpoint`                 | `<your-collector>`         |
  </Tab>
</Tabs>