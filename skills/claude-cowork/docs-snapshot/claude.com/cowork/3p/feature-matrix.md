> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Features on 3P

> Feature comparison between Claude Enterprise and Cowork on third-party (3P)

The tables below compare the feature set of Cowork on third-party (3P) to Claude Enterprise.

## Key differences

**Configuration.** Claude Enterprise uses a web-based admin console. Cowork on 3P is configured entirely via MDM (Jamf, Intune, Group Policy), with no Anthropic-hosted admin interface.

**Telemetry.** Cowork on 3P sends usage and debugging metrics only, and these can be fully disabled via managed configuration. Claude Enterprise does not offer telemetry toggles. See [Telemetry and egress](/cowork/3p/telemetry).

**Inference.** Cowork on 3P routes all inference through the provider you configure. When using Vertex AI or Bedrock, Anthropic never sees prompts or completions; during the Microsoft Foundry preview, Claude models run on Anthropic's infrastructure — see the [Overview](/cowork/3p/overview) for details.

**Pricing.** Cowork on 3P is token-based consumption billed by your cloud provider, with no seat licensing.

**Features not available in 3P.** Features marked with — are absent from the UI. Users see a clean interface without error states for unavailable features.

## User features

| Feature                         | Claude Enterprise | Cowork on 3P |
| ------------------------------- | :---------------: | :----------: |
| Cowork tab                      |         ✓         |       ✓      |
| Code tab                        |         ✓         |       ✓      |
| Chat tab                        |         ✓         |       —      |
| Projects                        |         ✓         |       ✓      |
| Code execution for analysis     |         ✓         |       ✓      |
| File access, upload, and export |         ✓         |       ✓      |
| Local MCP                       |         ✓         |       ✓      |
| Remote MCP                      |         ✓         |       ✓      |
| Anthropic 1P Connectors         |         ✓         |     — \*     |
| Skills, plugins, and hooks      |         ✓         |       ✓      |
| Artifacts                       |         ✓         |       ✓      |
| Memory                          |         ✓         |      ✓ †     |
| Scheduled tasks                 |         ✓         |       ✓      |
| Global languages                |         ✓         |       ✓      |
| Project and plugin sharing      |         ✓         |       —      |
| Plugin Marketplaces             |         ✓         |    ✓ \*\*    |
| Dispatch / mobile               |         ✓         |       —      |
| Voice mode                      |         ✓         |       —      |
| Claude in Chrome                |         ✓         |       —      |
| Computer use                    |         —         |       —      |

\* The Anthropic Microsoft 365 connector is available in Cowork on 3P; see the [setup guide](/cowork/3p/connectors-m365). Google Workspace is not currently supported but will be available soon.

\*\* Plugins distributed via the [org-plugins directory](/cowork/3p/extensions#organization-plugins-admin) appear to users as an organization marketplace. The public Anthropic plugin marketplace is not available.

† Memory in Cowork on 3P is stored on the device, not on Anthropic infrastructure. Users can review, delete, or pause it under **Settings → Cowork → Memory**; see [Memory](/cowork/3p/data-storage#memory). Chat-history search and nightly summary generation are Chat-tab features and are not applicable in 3P.

## Admin features

| Feature                                       |  Claude Enterprise |   Cowork on 3P   |
| --------------------------------------------- | :----------------: | :--------------: |
| Endpoint / gateway configuration              |          —         |         ✓        |
| Skills, hooks, and plugins distribution       |          ✓         |         ✓        |
| MCP server allowlist                          |          ✓         |         ✓        |
| Feature toggles (web search, local MCP, etc.) |          ✓         |         ✓        |
| Auto-updates                                  |          ✓         | ✓ (configurable) |
| Per-user spend caps                           | ✓ (differentiated) | ✓ (blanket only) |
| Compliance API                                |          ✓         |        — ‡       |
| Analytics API                                 |          ✓         |        — ‡       |
| OpenTelemetry export                          |          ✓         |         ✓        |
| User management via UI                        |          ✓         |         —        |
| RBAC                                          |          ✓         |      via MDM     |

‡ Many of these capabilities can be achieved via OpenTelemetry export to your own collector. See [Monitoring](/cowork/monitoring).