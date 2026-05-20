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

| Component              | Standard Cowork              | Cowork on 3P                                                              |
| ---------------------- | ---------------------------- | ------------------------------------------------------------------------- |
| Model inference        | Anthropic API                | Your Vertex AI / Bedrock / Foundry / gateway endpoint, or the Anthropic API |
| Web application        | Loaded from claude.ai        | Bundled inside the desktop app                                            |
| User identity          | Anthropic account            | Local device identity only                                                |
| Conversation storage   | Anthropic backend            | Local disk on the user's machine                                          |
| Code execution sandbox | Local VM                     | Local VM (identical)                                                      |
| Configuration          | Admin console at claude.ai   | OS-native (MDM-managed or per-user)                                       |

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
> Anthropic infrastructure. They do **not** apply to Microsoft Foundry
> or when `inferenceProvider` is `anthropic`.

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

For threat-model and sandbox details, see the
[Claude Cowork Desktop Security Architecture Overview](https://trust.anthropic.com/resources?s=2a7bbzo1lyymvdt551q7kl&name=claude-cowork-desktop-security-architecture-overview)
on Anthropic's Trust Center. For 3P-specific architecture / controls, see
[Claude Cowork Security Overview (Third-Party Platforms)](https://trust.anthropic.com/resources?s=0c8rx4s7mm5ierz8ppetfs&name=claude-cowork-security-overview-\(third-party-platforms\))
on the Trust Center.

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

- **Deployment identity** — `deploymentOrganizationUuid` (UUID to attribute
  your fleet's telemetry; shared placeholder used if unset), `disableDeploymentModeChooser`
  (hides Anthropic sign-in option on launch screen)
- **Inference provider** — `inferenceProvider` (`anthropic` | `vertex` | `bedrock` |
  `foundry` | `gateway`); `anthropic` routes directly to the Anthropic API (no
  3P data-residency guarantees)
- **Anthropic API key** — `inferenceAnthropicApiKey` (for `inferenceProvider: anthropic`)
- **Custom inference headers** — `inferenceCustomHeaders` (JSON object or `"Name: Value"`
  array sent on every inference request; legacy alias `inferenceGatewayHeaders` still
  accepted)
- **Region pinning / base URL** — `inferenceVertexRegion`, `inferenceBedrockRegion`;
  `inferenceVertexBaseUrl`, `inferenceBedrockBaseUrl` (override the default inference
  endpoint host for firewall / private endpoint scenarios)
- **Provider-specific credentials:**
  - *Bedrock* — `inferenceBedrockBearerToken` (shared Bedrock API key); `inferenceBedrockProfile` (named AWS CLI profile); `inferenceBedrockSsoStartUrl` + `inferenceBedrockSsoRegion` + `inferenceBedrockSsoAccountId` + `inferenceBedrockSsoRoleName` (in-app IAM Identity Center sign-in, no AWS CLI required; app ≥ 1.6.0; **all four required** — partial config silently ignored); `inferenceBedrockAwsDir` (non-default `~/.aws` path); `inferenceBedrockServiceTier` (`flex` | `priority`; omit for on-demand). Source: [`3p/bedrock.md`](https://claude.com/docs/cowork/3p/bedrock.md), [`3p/bedrock-aws-sign-in.md`](https://claude.com/docs/cowork/3p/bedrock-aws-sign-in.md).
  - *Vertex AI* — `inferenceVertexProjectId` (GCP project ID); `inferenceVertexCredentialsFile` (path to service-account key, `authorized_user`, or Workforce Identity Federation `external_account` JSON); `inferenceVertexOAuthClientId` + `inferenceVertexOAuthClientSecret` (in-app Google sign-in); `inferenceVertexOAuthScopes` (space-separated; default `openid email https://www.googleapis.com/auth/cloud-platform`). **`inferenceCredentialHelper` is not invoked for Vertex** — use file-based credentials or OAuth keys. Source: [`3p/vertex.md`](https://claude.com/docs/cowork/3p/vertex.md).
  - *Foundry* — `inferenceFoundryResource` (Azure AI Foundry resource name, 2–64 lowercase alphanumeric chars); `inferenceFoundryApiKey` (API key, or use `inferenceCredentialHelper`). Source: [`3p/foundry.md`](https://claude.com/docs/cowork/3p/foundry.md).
  - *Gateway* — `inferenceGatewayBaseUrl` (gateway base URL, must be HTTPS); `inferenceGatewayApiKey` (API key; use a placeholder if gateway uses network identity and requires no key); `inferenceGatewayAuthScheme` (`bearer` (default) | `x-api-key` | `sso`). Source: [`3p/gateway.md`](https://claude.com/docs/cowork/3p/gateway.md).
- **Model discovery** — `modelDiscoveryEnabled` (boolean, default `true`; set `false`
  to use a fixed list without querying the provider's model-list endpoint); `inferenceModels`
  (JSON array; each entry may be a plain string ID or
  `{"name":"<id>","labelOverride":"<label>","supports1m":true}`)
- **Credential helper** — `inferenceCredentialHelper` (path to executable whose
  stdout becomes the API credential; may print a bare token or
  `{"token":"...","headers":{...}}`), `inferenceCredentialHelperTtlSec` (cache
  TTL, default 3600 s), `inferenceCredentialHelperTimeoutSec` (max seconds to wait
  for helper, default 60 s; applies to Bedrock/Foundry/gateway/anthropic, not Vertex AI)
- **Sandbox & workspace** — `builtinToolPolicy` (JSON object mapping tool name →
  `"allow"` | `"ask"`, controls per-tool approval prompts without removing the tool);
  `disabledBuiltinTools` (JSON string[] of tool names to remove entirely; valid:
  `Bash`, `Read`, `Write`, `Edit`, `Glob`, `Grep`, `NotebookEdit`, `WebFetch`,
  `WebSearch`, `Task`, `TodoWrite`, `TaskCreate`, `TaskUpdate`, `TaskGet`,
  `TaskList`, `TaskStop`, `Skill`, `REPL`, `JavaScript`, `AskUserQuestion`,
  `ToolSearch`, `SendUserMessage`), `allowedWorkspaceFolders` (restrict attachable
  paths), `coworkEgressAllowedHosts` (agent egress allowlist; `["*"]` disables
  filtering), `isClaudeCodeForDesktopEnabled` (show/hide Code tab, default `true`),
  `disableDeepLinkRegistration`
- **Telemetry toggles** — `disableEssentialTelemetry`, `disableNonessentialTelemetry`,
  `disableNonessentialServices`, `disableAutoUpdates`; `autoUpdaterEnforcementHours`
  (force pending update after N hours, 1–72, default 72)
- **MCP & extensions** — `managedMcpServers` (JSON array; each server supports
  `transport` (`"http"` (default) | `"sse"` | `"stdio"`), `headers`,
  `headersHelper`/`headersHelperTtlSec` (default 300 s), `oauth` (`true` for
  dynamic client registration, or an object for pre-registered clients: `clientId`,
  `tenantId`, `scope`, `callbackPort` (default `53280`), `callbackHost`
  (`"127.0.0.1"` default | `"localhost"`); redirect URI is
  `http://<callbackHost>:<callbackPort>/callback`), `toolPolicy` (map tool name →
  `"allow"` | `"ask"` | `"blocked"`); `stdio` transport also takes `command`,
  `args`, `env`); `orgPluginSettings` (per-tool policy for org-plugin servers,
  keyed as `{"mcpServers":{"<name>":{"toolPolicy":{...}}}}`);
  `isLocalDevMcpEnabled`; `isDesktopExtensionEnabled`;
  `isDesktopExtensionSignatureRequired`
- **OTLP export** — `otlpEndpoint` (OTLP collector base URL; endpoint host is
  auto-added to sandbox allowlist), `otlpProtocol` (`"http/protobuf"` (default)
  | `"http/json"` | `"grpc"`), `otlpHeaders` (JSON object or `key=value` string),
  `otlpResourceAttributes` (JSON object or `key=value` string of extra resource
  attributes; built-in keys such as `service.name` are dropped if they collide)
- **Appearance** — `banner` (JSON object: `enabled`, `text` (≤ 200 chars),
  `backgroundColor` (`#RRGGBB`), `textColor` (`#RRGGBB`), `linkUrl` (HTTPS URL))
- **Token spend caps** — `inferenceMaxTokensPerWindow`, `inferenceTokenWindowHours`
  (1–720 hours)

## Recommended security profiles

Three named starting-point profiles from
[`3p/configuration.md`](https://claude.com/docs/cowork/3p/configuration.md).
Layer the inference-provider keys for your cloud on top.

| Profile | Description | Key settings |
|---|---|---|
| **Standard** | Most enterprise deployments — telemetry and auto-updates on; users can extend | `deploymentOrganizationUuid`, `autoUpdaterEnforcementHours: 24`, `isDesktopExtensionSignatureRequired: true`, `otlpEndpoint` |
| **Restricted** | Regulated environments — control extensions and egress while keeping Anthropic supportability | + `disableNonessentialTelemetry: true`, `disableNonessentialServices: true`, `isLocalDevMcpEnabled: false`, `isDesktopExtensionEnabled: false`, `allowedWorkspaceFolders`, `coworkEgressAllowedHosts` |
| **Locked down** | Air-gapped / maximally restricted — all Anthropic network traffic disabled; IT owns update distribution | + `disableEssentialTelemetry: true`, `disableAutoUpdates: true`, `disabledBuiltinTools: ["WebSearch","WebFetch"]`, `coworkEgressAllowedHosts: []` |

The **Locked down** profile means the only traffic leaving the device goes to your inference endpoint and OTLP collector. With this profile Anthropic has zero remote visibility, so your team owns log collection and update distribution.

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
all MCP servers. Disabling Anthropic-bound telemetry is **not
required** for HIPAA compliance — Anthropic's telemetry never includes
user data, prompts, or completions (only redacted crash reports and
aggregated usage metrics). Disable it only if your audit posture
demands zero Anthropic-bound network traffic.

Source: [`cowork/3p/overview.md`](https://claude.com/docs/cowork/3p/overview.md#hipaa).

## Telemetry and egress

What the app sends to Anthropic, how to turn it off, and the firewall
allowlist live in [`3p/telemetry.md`](https://claude.com/docs/cowork/3p/telemetry.md).
With Anthropic-bound telemetry and updates disabled, the compliance
posture of your deployment is determined entirely by your inference
provider.

**Always-required egress:** `downloads.claude.ai` — VM workspace bundle and
Claude CLI binary are fetched at session start. Without this host, Cowork
sessions cannot start, regardless of which telemetry options are enabled.

**Proxy support:** The Cowork sandbox honors the host OS proxy configuration,
including PAC files. On macOS with TLS-intercepting proxies, add the corporate
CA with full root trust:
```bash
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain /path/to/corp-ca.pem
```
If the certificate is MDM-managed and cannot be changed, use `launchctl setenv
NODE_EXTRA_CA_CERTS "$HOME/corp-ca.pem"` as a fallback (applies to Finder/Dock
launches; lasts until reboot — add to a LaunchAgent for persistence).

Source: [`cowork/3p/telemetry.md`](https://claude.com/docs/cowork/3p/telemetry.md).

## Extensions (skills, plugins, hooks, MCP)

3P supports the full Cowork extension model: skills, plugins, hooks,
and MCP servers (local + remote). The org-plugins directory acts as
an organization-internal marketplace; the public Anthropic plugin
marketplace is not available in 3P.

**Org-plugins directory paths:**

| Platform | Path |
|---|---|
| macOS | `/Library/Application Support/Claude/org-plugins/` |
| Windows | `C:\Program Files\Claude\org-plugins\` |

Each subdirectory is one plugin and must contain `.claude-plugin/plugin.json`.
Use `version.json` (`{"version":"<string>"}`) to trigger re-sync on next
launch. **Any string change triggers re-sync — there is no semver ordering,
so a "downgrade" is just another version string.** If `version.json` is absent,
the directory's modification time is used instead.

Set `installationPreference` in `plugin.json` to control rollout:
- `"required"` — auto-installs; Uninstall action hidden; reinstalls if removed from disk
- `"auto_install"` — auto-installs; users can uninstall and it stays uninstalled
- `"available"` (default) — users install manually

**Plugin symlink handling:** Symlinks inside a plugin directory are followed
as long as they resolve to a path inside that plugin. Symlinks pointing outside
(e.g. `skills/foo/SKILL.md → /etc/hosts`) are skipped. A symlinked top-level
plugin directory (`org-plugins/my-plugin → /opt/shared/my-plugin`) is also followed.

**MCP servers in `.mcp.json` do not carry a `toolPolicy` field.** To apply tool
policy to a plugin-delivered MCP server, set `orgPluginSettings` in managed
configuration keyed on the server's name — not in the plugin file itself.

End users **cannot add remote MCP servers** — only local ones (when
`isLocalDevMcpEnabled` is `true`). Remote servers come only via
`managedMcpServers` or org-plugins.

**`isLocalDevMcpEnabled: false` and `isDesktopExtensionEnabled: false` restrict
local MCP servers and `.mcpb` desktop extensions only.** Users can still install
skills and plugins (which bundle skills, commands, hooks, sub-agents) regardless
of these settings.

Every connector in the [Claude connector directory](https://claude.com/connectors)
not labeled "Made by Anthropic" is accessible in 3P via `managedMcpServers` or
user install. Connectors labeled "Made by Anthropic" require Anthropic
infrastructure and are not available.

See [`3p/extensions.md`](https://claude.com/docs/cowork/3p/extensions.md)
for the per-extension distribution mechanics.

## M365 connector (3P-specific)

The Anthropic-built M365 connector **is** available in Cowork on 3P
(unlike most Anthropic 1P connectors, which are not). Setup lives in
[`3p/connectors-m365.md`](https://claude.com/docs/cowork/3p/connectors-m365.md).
Google Workspace connector is not currently supported in 3P (planned).

## Feature matrix (Enterprise vs 3P)

Full comparison: [`3p/feature-matrix.md`](https://claude.com/docs/cowork/3p/feature-matrix.md).

Salient gaps in 3P (versus full Claude Enterprise):

- No Chat tab (Cowork + Code tabs only).
- No Anthropic 1P connectors (except M365; Google Workspace planned).
- No Project / plugin sharing across orgs.
- No public Anthropic plugin marketplace — the org-plugins directory
  provides an org-internal marketplace (see
  [`3p/extensions.md`](https://claude.com/docs/cowork/3p/extensions.md)).
- No mobile dispatch (Dispatch/mobile feature absent).
- No voice mode.
- No Claude in Chrome.
- No computer use (also absent on Claude Enterprise).
- No web-based admin console — admin functions delivered via MDM.
- Per-user spend caps are blanket-only (not differentiated by role);
  token-based and device-enforced via `inferenceMaxTokensPerWindow`.
- Compliance / Analytics APIs are not exposed; equivalent capability
  via OpenTelemetry export.

Features confirmed available in 3P that are sometimes assumed missing:

- **Projects** — fully supported.
- **Memory** — supported; stored on the user's device (not Anthropic
  infrastructure). Users can review, delete, or pause under
  **Settings → Cowork → Memory**. Chat-history search and nightly
  summary generation are Chat-tab features; not available in 3P.
- **Scheduled tasks** — supported.
- **Skills, plugins, and hooks** — full extension model supported.
- **Remote MCP** — supported.
- **Artifacts** — supported.

## Web tools (3P)

Cowork includes two web-access tools. Their availability and behaviour
differ in 3P mode.

| Tool | How it runs | Availability |
|---|---|---|
| **Web Search** | Server-side at your inference provider | Vertex AI ✓, Foundry ✓, Bedrock ✗, Gateway (if provider implements `web_search`) |
| **Web Fetch** | Client-side on user's device | Gated by `coworkEgressAllowedHosts` |

**Critical:** `coworkEgressAllowedHosts` governs only the **Cowork tab's
sandbox** (web fetch, shell commands, package installs). It does **not**
restrict Web Search (server-side at your provider — add `"WebSearch"` to
`disabledBuiltinTools` to block it) and does **not** restrict the Code tab,
which runs on the host with normal network access. To remove the Code tab,
set `isClaudeCodeForDesktopEnabled` to `false`.

**Default when unset:** only the configured inference endpoint is reachable.
Agent package installs (`pip install`, `npm install`) and web fetches to
other hosts will fail until you add those hosts to the list or set `["*"]`.

URLs returned in search results are **automatically allowed** for a
follow-up Web Fetch even if they are not in your `coworkEgressAllowedHosts`
list.

**Wildcard semantics for `coworkEgressAllowedHosts`:** `*.example.com`
matches `a.example.com` and `a.b.example.com` (one or more leading
subdomain labels) but does **not** match the apex domain `example.com`
itself. Add both `example.com` and `*.example.com` if both are needed.
`["*"]` disables all filtering (use with caution).

The allowlist governs all in-sandbox network activity — Web Fetch,
`curl`, `pip install`, and other shell network calls — not just the
Web Fetch tool.

Source: [`cowork/3p/web-tools.md`](https://claude.com/docs/cowork/3p/web-tools.md).

## Desktop and filesystem access

Users attach **workspace folders** to a session; the agent can read,
create, and modify files anywhere inside those folders. Admins restrict
attachable paths via `allowedWorkspaceFolders`.

**Windows network drives:** Users can attach a mapped network drive
(e.g. `Z:\`) through the folder picker. Raw UNC paths (`\\server\share`)
are **not supported** — map the share to a drive letter first. Shell
commands run in an isolated sandbox that cannot reach network shares;
have the agent copy files to a local folder before running scripts.

Source: [`cowork/3p/local-access.md`](https://claude.com/docs/cowork/3p/local-access.md).

## Cowork guide (standard mode)

User-facing how-to pages for standard Cowork (non-3P):

- [`guide/dispatch.md`](https://claude.com/docs/cowork/guide/dispatch.md) — mobile dispatch.
- [`guide/projects.md`](https://claude.com/docs/cowork/guide/projects.md) — projects in Cowork.
- [`guide/plugins.md`](https://claude.com/docs/cowork/guide/plugins.md) — plugins user guide.

## Monitoring

[`monitoring.md`](https://claude.com/docs/cowork/monitoring.md)
covers OpenTelemetry export, usage analytics, spend tracking, and the
session-activity event schema. Available for Team and Enterprise plans
(requires Claude desktop app ≥ 1.1.4173).

**Event types:** `user_prompt`, `tool_result`, `api_request`, `api_error`,
`tool_decision`. All events share a `prompt.id` UUID that correlates every
event produced while processing a single user prompt.

**Standard attributes on all events:** `session.id`, `organization.id`,
`user.account_uuid`, `user.account_id` (tagged format, e.g.
`user_01BWBeN28…`), `user.id` (anonymous device/install identifier),
`user.email`, `workspace.host_paths`, `terminal.type`.

**Service resource attributes (on all spans):** `service.name` (`"cowork"`),
`service.version`, `host.arch`, `os.type`, `os.version`.

**Notable per-event attributes:**
- `user_prompt` — `event.timestamp`, `event.sequence`, `prompt_length`,
  `prompt` (content)
- `tool_result` — `event.timestamp`, `event.sequence`, `tool_name`,
  `success` (`"true"` | `"false"`), `duration_ms`, `error` (if failed),
  `decision_type` (`"accept"` / `"reject"`), `decision_source` (`"config"` |
  `"hook"` | `"user_permanent"` | `"user_temporary"` | `"user_abort"` |
  `"user_reject"`), `tool_result_size_bytes`, `tool_input` (JSON-serialized
  args, strings >512 chars truncated, total ≤ ~4 KB), `tool_parameters`
  (incl. `mcp_server_name` + `mcp_tool_name` for MCP tools),
  `mcp_server_scope` (MCP tools only)
- `api_request` — `event.timestamp`, `event.sequence`, `model`,
  `speed` (`"fast"` or `"normal"`), `cost_usd`, `input_tokens`,
  `output_tokens`, `cache_read_tokens`, `cache_creation_tokens`, `duration_ms`
- `api_error` — `event.timestamp`, `event.sequence`, `model`, `error`,
  `speed`, `status_code` (HTTP code or `"undefined"` for non-HTTP),
  `attempt` (retry count), `duration_ms`
- `tool_decision` — `event.timestamp`, `event.sequence`, `tool_name`,
  `decision` (`"accept"` / `"reject"`), `source`

---

*Source pages: 24 under `claude.com/docs/cowork/`. See
[`https://claude.com/docs/cowork/`](https://claude.com/docs/cowork/)
for the version-pinned mirror.*
