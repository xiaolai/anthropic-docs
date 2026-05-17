> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Telemetry and egress

> What Cowork on 3P sends to Anthropic, how to disable it, and the network paths your firewall needs to allow

When Cowork on third-party (3P) is configured with Vertex AI or Bedrock, conversation content never reaches Anthropic. The app does, by default, send a small amount of operational telemetry (crash reports and product analytics) that helps Anthropic diagnose issues and improve the product. Each category can be disabled independently via managed configuration.

This page covers what each category contains, how to turn it off, and the complete set of outbound hostnames the app uses so you can configure your perimeter firewall.

## Telemetry categories

### Essential telemetry

Crash reports, error stack traces, and performance timings. Contains diagnostic metadata (app version, OS, error type, redacted stack frames) but **never prompt or response content**. Attributed to your organization via `deploymentOrganizationUuid` so Anthropic support can find issues you report.

| Setting                     | Default | Effect when `true`                        |
| --------------------------- | ------- | ----------------------------------------- |
| `disableEssentialTelemetry` | `false` | No crash or error data leaves the device. |

<Warning>
  Disabling essential telemetry opts you into a **manual support model**. Anthropic will have zero remote visibility into failures on your fleet, so to get help with an issue your team will need to collect application logs from affected machines and send them to Anthropic directly. We strongly recommend leaving this enabled during initial rollout.
</Warning>

### Non-essential telemetry

Product-usage analytics: feature adoption, session counts, UI interactions. Used to understand how Cowork is used in aggregate. Contains no prompt or response content.

| Setting                        | Default | Effect when `true`                     |
| ------------------------------ | ------- | -------------------------------------- |
| `disableNonessentialTelemetry` | `false` | No product analytics leave the device. |

### Non-essential services

Cosmetic third-party fetches: favicons for connectors shown in the UI, and the sandboxed iframe that renders interactive artifact previews. Disabling these degrades the UI slightly (generic icons, static artifact previews) but doesn't affect functionality.

| Setting                       | Default | Effect when `true`                                |
| ----------------------------- | ------- | ------------------------------------------------- |
| `disableNonessentialServices` | `false` | Favicon and artifact-preview fetches are blocked. |

### Auto-updates

Checks Anthropic's update feed and downloads new builds.

| Setting              | Default | Effect when `true`                                                                        |
| -------------------- | ------- | ----------------------------------------------------------------------------------------- |
| `disableAutoUpdates` | `false` | The app never checks for or downloads updates. Your IT team must redistribute new builds. |

## Sending telemetry to your own collector

Independently of what's sent to Anthropic, you can export full session activity (prompts, tool calls, token counts, errors) to your own OpenTelemetry collector by setting `otlpEndpoint`. This is the recommended way to retain an audit trail in environments that disable Anthropic-bound telemetry.

See [Monitoring](/cowork/monitoring) for the event schema and the [`otlp*` keys](/cowork/3p/configuration#opentelemetry-export) in the configuration reference.

## Required egress paths

Cowork on 3P has **two** independent network boundaries:

1. **Perimeter firewall** — your corporate network controls what the device can reach. The hostnames below are what you allowlist here.
2. **Agent egress allowlist** — the [`coworkEgressAllowedHosts`](/cowork/3p/configuration#sandbox-%26-workspace) key controls what the agent's web-fetch and shell tools can reach. This is independent of, and stricter than, the perimeter.

<Note>
  The **Egress Requirements** section of the in-app configuration window is the authoritative source for your deployment. It computes the exact allowlist from your current settings, updates as you change them, and can export the list as a text file for your firewall team. Use the tables below as a static reference; defer to the configuration window for the precise set your build requires.
</Note>

All traffic is HTTPS on port 443. Allowlist by hostname (SNI); path-level rules aren't required.

### Always required

| Host                  | Purpose                                                                                                              |
| --------------------- | -------------------------------------------------------------------------------------------------------------------- |
| `downloads.claude.ai` | VM workspace bundle and Claude CLI binary, fetched at session start. **Without this, Cowork sessions cannot start.** |

### Inference provider

The host(s) for your configured provider. These carry conversation content.

<Tabs>
  <Tab title="Vertex AI">
    | Host                                 | Purpose                                                                                                                            |
    | ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
    | `<region>-aiplatform.googleapis.com` | Model inference (or `aiplatform.googleapis.com` for the `global` region). Replaced by the host of `inferenceVertexBaseUrl` if set. |
    | `oauth2.googleapis.com`              | Google auth token exchange                                                                                                         |
    | `sts.googleapis.com`                 | Google auth token exchange                                                                                                         |
    | `accounts.google.com`                | Google auth token exchange                                                                                                         |
    | `iamcredentials.googleapis.com`      | Google auth token exchange                                                                                                         |
  </Tab>

  <Tab title="Bedrock">
    | Host                                                               | Purpose                                                                    |
    | ------------------------------------------------------------------ | -------------------------------------------------------------------------- |
    | `bedrock-runtime.<region>.amazonaws.com`                           | Model inference. Replaced by the host of `inferenceBedrockBaseUrl` if set. |
    | `bedrock.<region>.amazonaws.com`                                   | Control plane (model discovery and profile auth)                           |
    | `sts.amazonaws.com`, `sts.<region>.amazonaws.com`                  | STS token exchange (profile auth only)                                     |
    | `portal.sso.<region>.amazonaws.com`, `oidc.<region>.amazonaws.com` | AWS SSO (profile auth only)                                                |

    With `inferenceBedrockBearerToken` set, the runtime and control-plane hosts are required.
  </Tab>

  <Tab title="Foundry">
    | Host                               | Purpose         |
    | ---------------------------------- | --------------- |
    | `<resource>.services.ai.azure.com` | Model inference |

    During the Foundry preview, Claude models run on Anthropic's infrastructure. The client connects only to the Azure host above, but conversation content leaves the Azure boundary — see the [Overview](/cowork/3p/overview) for details.
  </Tab>

  <Tab title="Gateway">
    | Host                              | Purpose         |
    | --------------------------------- | --------------- |
    | Host of `inferenceGatewayBaseUrl` | Model inference |
  </Tab>
</Tabs>

### Auto-updates (`disableAutoUpdates: false`)

| Host                  | Purpose                                  |
| --------------------- | ---------------------------------------- |
| `api.anthropic.com`   | Update feed                              |
| `downloads.claude.ai` | Update binaries (already required above) |

### Essential telemetry (`disableEssentialTelemetry: false`)

| Host                               | Purpose                                                                                         |
| ---------------------------------- | ----------------------------------------------------------------------------------------------- |
| `*.sentry.io`                      | Crash and error reporting                                                                       |
| `*.ingest.us.sentry.io`            | Crash and error reporting (listed separately for firewalls that match wildcards one label deep) |
| `browser-intake-us5-datadoghq.com` | Performance timing                                                                              |

### Non-essential telemetry (`disableNonessentialTelemetry: false`)

| Host                  | Purpose          |
| --------------------- | ---------------- |
| `a-cdn.anthropic.com` | Analytics SDK    |
| `a-api.anthropic.com` | Analytics events |
| `claude.ai`           | Analytics events |

### Non-essential services (`disableNonessentialServices: false`)

| Host                                                               | Purpose                     |
| ------------------------------------------------------------------ | --------------------------- |
| `api.anthropic.com`                                                | Artifact preview            |
| `www.claudeusercontent.com`                                        | Artifact preview iframe     |
| `cdnjs.cloudflare.com`, `cdn.jsdelivr.net`, `fonts.googleapis.com` | Artifact preview asset CDNs |
| `www.google.com`, `*.gstatic.com`                                  | Connector favicons          |

### Optional features

| Host                                                                                | Required when                               |
| ----------------------------------------------------------------------------------- | ------------------------------------------- |
| Host of `otlpEndpoint`                                                              | OpenTelemetry export is configured          |
| `github.com`, `objects.githubusercontent.com`, `pypi.org`, `files.pythonhosted.org` | Python-based desktop extensions are enabled |
| Hosts of each entry in `managedMcpServers`                                          | Managed MCP servers are configured          |
| Hosts in `coworkEgressAllowedHosts`                                                 | Sandbox web access is configured            |

## Disabling all Anthropic-bound connections

With `disableEssentialTelemetry`, `disableNonessentialTelemetry`, `disableNonessentialServices`, and `disableAutoUpdates` all set to `true`, the desktop application makes **no outbound connections to Anthropic-operated hosts at runtime**. The only required egress is `downloads.claude.ai` (for the VM bundle at session start) and your inference provider. This describes the application's own connections; the guarantee that conversation content does not reach Anthropic via the inference path applies only when using Vertex AI or Bedrock.

See the [Locked down profile](/cowork/3p/configuration#recommended-security-profiles) for a complete configuration.

## Proxy support

The Cowork sandbox honors the host operating system's proxy configuration, including PAC (proxy auto-configuration) files. If the device routes HTTPS through a corporate proxy, the sandbox will too, with no additional configuration required.

### TLS-intercepting proxies on macOS

If your proxy performs TLS interception, it presents its own certificate authority. Claude configures its CLI processes to trust the macOS System keychain in addition to the bundled CA roots, so a corporate CA installed there normally works without extra setup.

If inference or tool requests still fail certificate verification, the CA was likely added with policy-restricted trust: certificates installed via `security add-trusted-cert -p ssl …` are trusted by Safari and Chrome but are not picked up by the CLI runtime's keychain reader. Re-add the CA with full root trust (omit `-p`):

```bash theme={null}
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain /path/to/corp-ca.pem
```

If the certificate is MDM-managed and you cannot change how it is installed, set `NODE_EXTRA_CA_CERTS` as a fallback, then quit and relaunch Claude:

```bash theme={null}
security find-certificate -a -p /Library/Keychains/System.keychain > ~/corp-ca.pem
launchctl setenv NODE_EXTRA_CA_CERTS "$HOME/corp-ca.pem"
```

`launchctl setenv` makes the variable visible to apps launched from Finder or the Dock (shell-profile exports only reach terminal sessions). It applies until the next reboot — to make it permanent, run the command from a LaunchAgent at login.