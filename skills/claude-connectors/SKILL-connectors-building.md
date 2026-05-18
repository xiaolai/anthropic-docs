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

| If you need… | Build a… |
|---|---|
| Action-taking with external APIs | MCP server |
| Reusable task recipes that compose actions | Plugin (with skills) |
| Both — capability + how-to-use | Both — wrap the server in a plugin |
| Distribution to Claude Code users specifically | Plugin |
| Distribution across all Claude products | MCP server + plugin |

> **Scaffold tip:** The fastest way to start is the
> [`mcp-server-dev` plugin](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/mcp-server-dev)
> for Claude Code. Install it and run `/mcp-server-dev:build-mcp-server` —
> it interviews you about your use case, picks the deployment model,
> and generates a working server. Source: [`what-to-build.md`](https://claude.com/docs/connectors/building/what-to-build.md).

> **Skills are not a standalone directory type.** If you have skills
> to ship, bundle them in a plugin. The Connectors Directory only
> accepts MCP servers; the plugin directory accepts plugins (which
> bundle skills + connectors). You cannot submit a bare skill.

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

## Authentication

Source: [`authentication.md`](https://claude.com/docs/connectors/building/authentication.md).
For deferring auth until it is needed, see
[`lazy-authentication.md`](https://claude.com/docs/connectors/building/lazy-authentication.md).

### Supported authentication types

Claude supports five auth approaches for remote MCP servers across all
platforms (Claude.ai, Desktop, Mobile, Claude Code, Cowork):

| Type | Description |
|---|---|
| **OAuth + Dynamic Client Registration (DCR)** | Automatic client registration per RFC 7591 — default choice |
| **OAuth + Client ID Metadata Document (CIMD)** | Self-hosted client identification document instead of DCR |
| **Anthropic-held credentials** | Partner submits client credentials to Anthropic; Anthropic completes token exchange after user consent |
| **Custom connections** | Platform-specific auth (requires Anthropic approval) |
| **No authentication** | Public servers without access controls |

Bearer tokens pasted by users and credentials in URL query parameters
are **not supported** — the MCP spec explicitly prohibits them.

### Key differences from the generic MCP spec

| Requirement | Detail |
|---|---|
| **User consent always required** | No pure machine-to-machine flows; every connection needs explicit user approval |
| **PKCE mandatory (S256)** | All authorization requests must include an S256 code challenge; servers must advertise PKCE support |
| **DCR efficiency concern** | DCR creates a new OAuth client per connection — can overwhelm authorization servers at high directory traffic; Anthropic-held credentials sidestep this |

### Token management

Claude refreshes tokens both **reactively** (upon a `401` response) and
**proactively** (up to 5 minutes before expiry). Authorization servers
should rotate refresh tokens for public-client connections and return
RFC 6749-compliant error codes (e.g. `invalid_grant`). The `/token`
endpoint must accept `application/x-www-form-urlencoded` per RFC 6749.

### Callback URLs

| Surface | Callback URL |
|---|---|
| Hosted surfaces (Claude.ai, Desktop, Mobile, Cowork) | `https://claude.ai/api/mcp/auth_callback` |
| Claude Code | Ephemeral loopback, e.g. `http://localhost:3118/callback` |

### Lazy authentication (recommended pattern)

Surface as much value as possible before requiring OAuth. Users who
never invoke a protected tool never need to authenticate.
Reference: [`lazy-authentication.md`](https://claude.com/docs/connectors/building/lazy-authentication.md).

## Supported capabilities and performance limits

Source: [`building/index.md`](https://claude.com/docs/connectors/building/index.md).

### Supported transport and features

| Category | Supported |
|---|---|
| Transport | Streamable HTTP, legacy HTTP+SSE |
| Primitives | Tools, prompts, resources |
| Tool result types | Text, image |
| Resource types | Text, binary |
| Auth | OAuth callback handling, token refresh, Dynamic Client Registration |

### Not supported

- Resource subscriptions
- Sampling
- Advanced / draft MCP capabilities

### Performance limits

| Surface | Tool result size | Timeout |
|---|---|---|
| Claude.ai / Desktop / Mobile / Cowork | ~150,000 characters | 5 minutes |
| Claude Code | 25,000 tokens (configurable) | Configurable |

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

Coverage points:

- All tools work end-to-end with realistic inputs.
- Error responses are surfaced cleanly (not silently swallowed).
- OAuth flow completes for new users without manual intervention.
- Idempotent tools behave correctly on retry.
- Long-running tools surface progress / completion correctly.

## Pre-submission checklist

[`review-criteria.md`](https://claude.com/docs/connectors/building/review-criteria.md)
documents exactly what Anthropic reviewers test. Pass these on the
first try by running through the checklist before submitting.

## Submission

[`submission.md`](https://claude.com/docs/connectors/building/submission.md)
covers the submission form, required materials (privacy policy URL,
documentation URL, support contact, test credentials, working
examples), and the review timeline.

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

10 source pages under [`https://claude.com/docs/connectors/building/`](https://claude.com/docs/connectors/building/):

- `index.md`, `mcp.md` — MCP primer for connector authors
- `what-to-build.md`, `directory-vs-custom.md` — decision guides
- `authentication.md`, `lazy-authentication.md` — OAuth + token handling
- `testing.md`, `review-criteria.md`, `submission.md` — pre-publish workflow
- `troubleshooting.md`, `after-publishing.md` — post-publish workflow

(The 7 MCP-Apps-specific pages under `building/mcp-apps/` are covered
by [`SKILL-mcp-apps.md`](SKILL-mcp-apps.md); the MCPB packaging page
is covered there too.)

---

*Source pages: 10 under `claude.com/docs/connectors/building/`.*
