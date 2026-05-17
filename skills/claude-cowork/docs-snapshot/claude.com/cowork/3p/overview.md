> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Overview

> Run Cowork against your own cloud inference provider

<Info>
  **Research Preview.** Cowork on 3P is under active development. These docs will be updated with new product features. We will share the timeline for GA when it is available.
</Info>

Cowork on third-party (3P) is a deployment mode of Claude Desktop (Cowork and Code tabs) that routes all model inference through a provider you configure: Google Cloud's Vertex AI, Amazon Bedrock, Microsoft Foundry, or any compatible gateway you operate. The app runs from a bundled local web application, and conversation history is stored on the user's device.

You get the same agentic Cowork experience (file creation, multi-step research, sub-agent coordination, the Code tab) with inference and billing handled by the provider you choose.

<Note>
  The data-residency, compliance, and "no conversation data sent to Anthropic" statements throughout these pages apply when `inferenceProvider` is `vertex` or `bedrock`. They also apply when `inferenceProvider` is `gateway`, provided your gateway does not route inference to Anthropic infrastructure (directly or via Microsoft Foundry). They do not apply when using Microsoft Foundry.

  **Microsoft Foundry (preview):** In this preview platform integration, Claude models run on Anthropic's infrastructure. This is a commercial integration for billing and access through Azure. As an independent processor for Microsoft, customers using Claude through Microsoft Foundry are subject to Anthropic's data use terms. Anthropic continues to provide its industry-leading safety and data commitments, including zero data retention availability.
</Note>

## Who it's for

Cowork on 3P is designed for organizations whose security, regulatory, or contractual requirements prevent them from sending data to Anthropic's first-party infrastructure. Typical deployments include:

* **Highly regulated enterprises on 3P only** — organizations that use third-party inference for regulatory or security reasons
* **International enterprises with data residency requirements** — organizations that require in-region data residency and cannot send conversation data to the United States

If your organization can use Anthropic's first-party products directly, standard [Cowork](/cowork/overview) on a Team or Enterprise plan is simpler to deploy, offers an in-app UI for user management, analytics, and RBAC, and releases new features more quickly than Cowork on 3P. Choose Cowork on 3P when routing inference through Anthropic's API is not an option.

## Architecture

Cowork on 3P keeps the standard Cowork feature set and relocates inference to the provider you configure.

| Component              | Standard Cowork            | Cowork on 3P                                          |
| ---------------------- | -------------------------- | ----------------------------------------------------- |
| Model inference        | Anthropic API              | Your Vertex AI / Bedrock / Foundry / gateway endpoint |
| Web application        | Loaded from claude.ai      | Bundled inside the desktop app                        |
| User identity          | Anthropic account          | Local device identity only                            |
| Conversation storage   | Anthropic backend          | Local disk on the user's machine                      |
| Code execution sandbox | Local VM                   | Local VM (identical)                                  |
| Configuration          | Admin console at claude.ai | OS-native configuration (MDM-managed or per-user)     |

The desktop app detects 3P mode at launch from the configured inference provider. When a provider and its credentials are present, the sign-in screen offers the option to skip Anthropic authentication and start the app using your inference-provider configuration instead.

### Security posture

* **No conversation egress to Anthropic** (Vertex AI and Bedrock only). Prompts, responses, files, and tool outputs are sent only to your configured inference endpoint and stored only on the local machine.
* **Sandboxed tool execution.** Shell commands run in the hardened Cowork VM; file access is scoped to your allowed folders and web fetches to your egress allowlist.
* **Auditable telemetry.** Crash reports and product analytics are scrubbed of conversation and user data before being sent to Anthropic, and can be fully disabled via configuration keys. Independently, you can export full session activity (prompts, tool calls, token counts) to your own OpenTelemetry collector.
* **Centrally managed.** All configuration is delivered via your existing MDM (Jamf, Intune, Workspace ONE, Group Policy) and cannot be overridden by end users when an admin profile is present.

For a detailed treatment of the threat model, sandbox boundaries, and data flows, request access to the [Claude Cowork Desktop Security Architecture Overview](https://trust.anthropic.com/resources?s=2a7bbzo1lyymvdt551q7kl\&name=claude-cowork-desktop-security-architecture-overview) on Anthropic's Trust Center. For architecture, telemetry, and controls information specific to Cowork on 3P, see the [Claude Cowork Security Overview (Third-Party Platforms)](https://trust.anthropic.com/resources?s=0c8rx4s7mm5ierz8ppetfs\&name=claude-cowork-security-overview-\(third-party-platforms\)) on the Trust Center.

## Data residency and international deployment

This section applies when using Vertex AI or Bedrock.

Inference requests go directly from the user's machine to the regional endpoint you configure (`inferenceVertexRegion` or `inferenceBedrockRegion`). Because conversation data goes only to that endpoint and to local disk, residency is determined entirely by:

1. The cloud region you select for inference
2. The physical location of the user's device, where conversations are persisted

For multi-region organizations, deploy distinct MDM configuration profiles per geography so each user population points at an in-region endpoint. Vertex AI and Bedrock each offer Claude models in EU, UK, APJ, and other sovereign regions; consult your provider's model-availability documentation for the current list.

## Public sector and highly regulated environments

This section applies when using Vertex AI or Bedrock.

Because inference runs in your cloud tenant, Cowork on 3P operates inside whatever compliance boundary your provider and region give you. The desktop application itself contacts Anthropic only for crash reporting, product analytics, and auto-updates, and each of these can be disabled independently via managed configuration.

With Anthropic-bound telemetry and updates disabled, the compliance posture of your deployment is determined entirely by your inference provider. See [Telemetry and egress](/cowork/3p/telemetry) for the full set of network paths and how to lock them down.

## HIPAA

This section applies when using Vertex AI or Bedrock.

Cowork on 3P does not process user data, prompts, or completions. As such, Anthropic does not interact with PHI the user may upload to Cowork on 3P; that data is transmitted only to the customer's cloud service provider or any remote MCP servers they optionally choose to configure. For a HIPAA-compliant solution, customers should ensure they have a BAA in place with their CSP and review any MCP servers for HIPAA compliance before connecting them to Cowork on 3P.

Disabling telemetry is not required to run Cowork on 3P in a HIPAA-compliant way, since Anthropic's telemetry does not collect user data, prompts, or completions, only redacted crash reporting and aggregated usage metrics that do not reveal sensitive data.

## Next steps

<Columns cols={2}>
  <Card title="Installation and setup" icon="download" href="/cowork/3p/installation">
    Roll out Cowork on 3P to your organization with MDM, or configure a single machine for evaluation.
  </Card>

  <Card title="Configuration reference" icon="sliders" href="/cowork/3p/configuration">
    Every managed-configuration key, what it does, and recommended security profiles.
  </Card>

  <Card title="Extensions" icon="puzzle-piece" href="/cowork/3p/extensions">
    Deploy MCP servers, plugins, skills, and hooks across your fleet.
  </Card>

  <Card title="Telemetry and egress" icon="shield-halved" href="/cowork/3p/telemetry">
    What the app sends to Anthropic, how to turn it off, and the firewall allowlist you'll need.
  </Card>
</Columns>