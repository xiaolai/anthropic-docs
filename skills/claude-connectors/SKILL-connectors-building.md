---
name: claude-connectors-building
description: |
  Deep reference for building a custom Claude connector — the OAuth
  + token flow, the lazy-authentication pattern, the testing workflow
  before submission, the submission process to the Connectors
  Directory, the review criteria, and the post-publishing maintenance
  workflow. Also covers the "what should I build" decision (MCP
  server vs plugin vs both).
source: https://claude.com/docs/connectors/building/index.md
---

# Building Custom Claude Connectors

> *Router lives in [`SKILL.md`](SKILL.md). For Desktop MCPB packaging
> + MCP Apps design, see [`SKILL-mcp-apps.md`](SKILL-mcp-apps.md). For
> first-party connector usage, see [`SKILL-connectors-overview.md`](SKILL-connectors-overview.md).*

## Decision: MCP server vs plugin vs both

Most partners ship **both** a remote MCP server and a plugin that
wraps it with skills. The decision guide:
[`building/what-to-build.md`](https://claude.com/docs/connectors/building/what-to-build.md).

Salient axes:

|  | MCP server | Plugin |
|---|---|---|
| **What it is** | A live tool surface Claude calls over HTTP | An installable bundle of skills and connectors |
| **Mental model** | "Claude can call your API" | "Claude knows how to *use* your product" |
| **Contains** | Tools, prompts, resources, optionally MCP App UI | Skills, MCP connector refs, slash commands |
| **Works in** | Claude.ai, Desktop, mobile, Cowork, Claude Code | Claude Code, Cowork |

> **Note:** Plugins currently work in Claude Code and Cowork only — not on Claude.ai web or Mobile.

**Skills are not a standalone directory type.** Skills are user-shared micro-workflows and must be distributed as part of a plugin — you cannot submit a skill to the directory on its own.

## Custom connector: building an MCP server

The foundation: [`building/index.md`](https://claude.com/docs/connectors/building/index.md).

Connector authoring is MCP server authoring — see [`mcp-spec`](../mcp-spec/SKILL.md)
for the protocol details. The Claude-specific concerns are:

- **Tool annotations** are *mandatory* for directory submission (every
  tool must declare its destructive / idempotent / read-only nature).
- **Working examples** that exercise each tool — required for review.
- **Privacy policy** — required for review.
- **Test credentials** — required for review (so Anthropic reviewers
  can validate end-to-end without acquiring production access).

> **Tip:** Install the official [`mcp-server-dev` plugin](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/mcp-server-dev)
> in Claude Code and run `/mcp-server-dev:build-mcp-server` — it interviews you about your
> use case, picks the right deployment model, and generates a working server.

### Key resources

- **TypeScript SDK** — [`modelcontextprotocol/typescript-sdk`](https://github.com/modelcontextprotocol/typescript-sdk) (examples included)
- **Python SDK** — [`modelcontextprotocol/python-sdk`](https://github.com/modelcontextprotocol/python-sdk) (examples included)
- **Protocol spec** — [modelcontextprotocol.io](https://modelcontextprotocol.io)
- **Hosting** — Platforms like Cloudflare offer remote MCP server hosting with autoscaling and OAuth management
- **Auth spec (third-party flows)** — [authorization spec](https://modelcontextprotocol.io/specification/latest/basic/authorization)

### Supported transports

Claude supports both **Streamable HTTP** (preferred) and the legacy
**HTTP+SSE** transport. The legacy HTTP+SSE transport is being deprecated
in favor of Streamable HTTP.

### Authentication — supported spec versions

The 2025-03-26, 2025-06-18, and 2025-11-25 MCP auth specifications are all
supported.

### Authentication — supported types

| Type | Description | Availability |
|---|---|---|
| `oauth_dcr` | OAuth 2.0 with Dynamic Client Registration (RFC 7591) | Supported out of the box |
| `oauth_cimd` | OAuth 2.0 with Client ID Metadata Document (CIMD) | Supported out of the box |
| `oauth_anthropic_creds` | OAuth 2.0 with Anthropic-held client credentials | Contact `mcp-review@anthropic.com` |
| `custom_connection` | Custom URL or credentials supplied at connection time | Contact `mcp-review@anthropic.com` |
| `none` | No authentication (authless server) | Supported. An optional partial-auth mode is experimental. |

**Not supported:**

- `static_bearer` (user-pasted bearer tokens) — not yet supported.
- Tokens or API keys in the connector URL query string (`?token=`, `?apiKey=`) — explicitly prohibited by the MCP auth spec.

Additional auth features:

- Dynamic Client Registration (DCR) enabled.
- OAuth callback: `https://claude.ai/api/mcp/auth_callback` (hosted surfaces); loopback redirect for Claude Code — see [callback URLs](https://claude.com/docs/connectors/building/authentication#callback-urls).
- Token refresh: reactive on `401`, plus proactive refresh up to **5 minutes** before stored expiry. Your `/token` endpoint must accept `Content-Type: application/x-www-form-urlencoded` (RFC 6749 §4.1.3) — registration uses `application/json`, but token exchange does not.
- Custom credentials for non-DCR servers supported.
- PKCE (S256) is included on every authorization request; your authorization server must support it.
- **For high-traffic servers, prefer CIMD or `oauth_anthropic_creds` over DCR.** DCR registers a new client on every fresh connection — this creates large numbers of registered clients on your authorization server at scale. CIMD and Anthropic-held credentials avoid the registration call entirely.

### Enterprise and custom connector auth

**Directory connectors** use a single shared OAuth application per connector — no per-org client is issued. Enterprise customers connect to the same OAuth app as all other users; access is scoped by their own permissions on your service.

**Custom connectors** differ: when a user (or admin) adds a connector by URL, the OAuth Client Secret field is **optional** — supply it only if your authorization server requires confidential-client authentication. Team/Enterprise admins can supply their own OAuth client credentials to scope the client to their organization.

**Anthropic's outbound egress range:** `160.79.104.0/21` — allowlist this if you use WAF/firewall conditional access rules. See [IP address reference](https://platform.claude.com/docs/en/api/ip-addresses).

Full details: [`authentication.md`](https://claude.com/docs/connectors/building/authentication.md).

### Protocol features — not yet supported

- Resource subscriptions
- Sampling
- Advanced/draft capabilities

### Technical limits

| Constraint | Limit |
|---|---|
| Claude.ai/Desktop max tool result size | ~150,000 characters |
| Claude Code max tool result size | 25,000 tokens (configurable via `MAX_MCP_OUTPUT_TOKENS`) |
| Claude Code timeout | Configurable via `MCP_TOOL_TIMEOUT` |
| Claude.ai/Desktop timeout | 300 seconds (5 minutes) |
| Transport protocol | Streamable HTTP (legacy HTTP+SSE being deprecated) |

Source: [`building/index.md`](https://claude.com/docs/connectors/building/index.md).

## Authentication

Two pages cover auth:

| Page | Topic |
|---|---|
| [`authentication.md`](https://claude.com/docs/connectors/building/authentication.md) | OAuth flows, scope design, token handling, refresh, revocation |
| [`lazy-authentication.md`](https://claude.com/docs/connectors/building/lazy-authentication.md) | Let users call public tools immediately and defer OAuth until a protected tool is actually invoked |

The lazy pattern is recommended: surface as much value as possible
before forcing the user through OAuth. Users who never invoke a
protected tool never need to authenticate.

## Directory vs custom

[`directory-vs-custom.md`](https://claude.com/docs/connectors/building/directory-vs-custom.md)
clarifies the distinction:

- **Directory-listed connectors** appear in the Connectors Directory
  catalog. Users can browse and enable them with one click. Subject
  to Anthropic review.
- **Custom connectors** are URL-based. Users add them by pasting an
  MCP server URL into Settings. No review; no listing; full
  flexibility for internal-only deployments.

## Testing your connector

Before submission, test against Claude:
[`testing.md`](https://claude.com/docs/connectors/building/testing.md).

Quick start:
1. Add your server directly to Claude via **Settings → Connectors** (any plan including Free).
2. Use the [MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector) to validate auth flows and protocol compliance.
3. For local servers, expose via a tunnel (Cloudflare Tunnel or ngrok) then add the tunnel URL as a custom connector.

Coverage points:

- All tools work end-to-end with realistic inputs.
- Error responses are surfaced cleanly (not silently swallowed).
- OAuth flow completes for new users without manual intervention.
- Idempotent tools behave correctly on retry.
- Long-running tools surface progress / completion correctly.

**Detecting Claude as the client:** Claude identifies itself in the MCP `initialize` handshake via `clientInfo` as `"claude-ai"`, `"Anthropic"`, or `"claude-code"` depending on surface and request path. **Do not gate authorization decisions on `clientInfo`** — it is unauthenticated and varies across surfaces. Use it for telemetry only.

**Troubleshooting connection failures:** When a connection fails, Claude's error toast and the page URL include a reference ID starting with `ofid_` (e.g., `?flow_id=ofid_d32594c73257a651`). Include this when filing issues on [`anthropics/claude-ai-mcp`](https://github.com/anthropics/claude-ai-mcp/issues). See [`troubleshooting.md`](https://claude.com/docs/connectors/building/troubleshooting.md) for the full diagnostic flow (DNS, WAF, OAuth discovery).

## Pre-submission checklist

[`review-criteria.md`](https://claude.com/docs/connectors/building/review-criteria.md)
documents exactly what Anthropic reviewers test. Key requirements:

- **Separate read and write tools.** A catch-all `api_request` tool with a `method` parameter is rejected — split into distinct read and write tools.
- **Reference API docs in custom query tools.** If a tool accepts freeform endpoint paths, its description must include a link to the target API.
- **Tool names ≤ 64 characters.** Tool `title` is also required; `readOnlyHint: true` or `destructiveHint: true` must be set.
- **No prompt-injection patterns** in tool descriptions (no instructions telling Claude to call external tools, pull instructions from external sources, or override system instructions).
- **Unsupported use cases (automatic rejection):** money/crypto/asset transfers; AI-generated images, video, or audio.
- **Allowed link URIs** are recommended if your server calls `ui/open-link`.

Run `claude plugin validate` on plugins before submitting.

## Submission

[`submission.md`](https://claude.com/docs/connectors/building/submission.md)
covers the submission form, required materials (privacy policy URL,
documentation URL, support contact, test credentials, working
examples), and the review timeline.

**Submission form URLs:**
- Desktop extensions (MCPB): [clau.de/desktop-extention-submission](https://clau.de/desktop-extention-submission)
- Remote MCPs (including MCP Apps): [clau.de/mcp-directory-submission](https://clau.de/mcp-directory-submission)

MCP Apps require 3–5 carousel screenshots (PNG, ≥1000px wide, cropped to the app response only — no prompt visible). See [asset specifications](https://claude.com/docs/connectors/building/submission#asset-specifications).

## Troubleshooting

[`troubleshooting.md`](https://claude.com/docs/connectors/building/troubleshooting.md)
covers the common failure modes:

- "Connection refused" / TLS errors.
- OAuth callback misconfigurations.
- Tool-discovery mismatches between server and client.
- MCP protocol-version mismatches.

Plus [`mcp-apps/troubleshooting.md`](https://claude.com/docs/connectors/building/mcp-apps/troubleshooting.md)
for MCP App-specific issues (rendering, transparent theming,
external links, instance supersession).

## Post-publishing

[`after-publishing.md`](https://claude.com/docs/connectors/building/after-publishing.md)
covers maintenance:

- Updating your MCP server (semantic-version bumps, breaking-change
  policy).
- Updating your directory listing (description, screenshots, links).
- Deprecation flow for retiring a tool.
- Sunset flow for retiring a whole connector.

## Foundational background

[`mcp.md`](https://claude.com/docs/connectors/building/mcp.md) is a
quick MCP-protocol primer for connector authors who have not yet
read the full spec. For the full spec, see [`mcp-spec`](../mcp-spec/SKILL.md).

## Page index (building/ subtree)

11 source pages under [`https://claude.com/docs/connectors/building/`](https://claude.com/docs/connectors/building/):

- `index.md`, `mcp.md` — MCP primer for connector authors
- `what-to-build.md`, `directory-vs-custom.md` — decision guides
- `authentication.md`, `lazy-authentication.md` — OAuth + token handling
- `testing.md`, `review-criteria.md`, `submission.md` — pre-publish workflow
- `troubleshooting.md`, `after-publishing.md` — post-publish workflow

(The 7 MCP-Apps-specific pages under `building/mcp-apps/` are covered
by [`SKILL-mcp-apps.md`](SKILL-mcp-apps.md); the MCPB packaging page
is covered there too.)

---

*Source pages: 11 under `claude.com/docs/connectors/building/`.*
