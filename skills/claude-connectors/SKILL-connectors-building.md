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

> **Build with Claude.** Install the official [`mcp-server-dev` plugin](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/mcp-server-dev)
> in Claude Code — it walks you through building, testing, and packaging an
> MCP server interactively, using these docs as its reference.

### Supported transports

Claude supports **Streamable HTTP** (preferred) and the legacy **HTTP+SSE** transport.
The legacy HTTP+SSE transport is being deprecated in favour of Streamable HTTP.

### Technical limits

| Constraint | Limit |
|---|---|
| Claude.ai / Desktop max tool result size | ~150,000 characters |
| Claude Code max tool result size | 25,000 tokens (configurable via `MAX_MCP_OUTPUT_TOKENS`) |
| Claude Code timeout | Configurable via `MCP_TOOL_TIMEOUT` |
| Claude.ai / Desktop timeout | 300 seconds (5 minutes) |

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

### Auth spec support

Claude supports MCP auth specifications
[2025-03-26](https://modelcontextprotocol.io/specification/2025-03-26/basic/authorization),
[2025-06-18](https://modelcontextprotocol.io/specification/2025-06-18/basic/authorization), and
[2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/basic/authorization).

| Feature | Notes |
|---|---|
| Dynamic Client Registration (DCR) | Enabled |
| OAuth callback (hosted surfaces) | `https://claude.ai/api/mcp/auth_callback` |
| OAuth callback (Claude Code) | Loopback redirect — see [`authentication.md#callback-urls`](https://claude.com/docs/connectors/building/authentication.md) |
| Token refresh + expiry | Supported |
| Custom credentials | Available for non-DCR servers |

Source: [`building/index.md`](https://claude.com/docs/connectors/building/index.md).

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
