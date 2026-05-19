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

## Authentication

Source pages:
[`authentication.md`](https://claude.com/docs/connectors/building/authentication.md) |
[`lazy-authentication.md`](https://claude.com/docs/connectors/building/lazy-authentication.md)

### Supported authentication types

| Type | Description | Availability |
|---|---|---|
| `oauth_dcr` | OAuth 2.0 with Dynamic Client Registration (RFC 7591) | Out of the box |
| `oauth_cimd` | OAuth 2.0 with Client ID Metadata Document | Out of the box |
| `oauth_anthropic_creds` | OAuth 2.0 with Anthropic-held client credentials | Contact `mcp-review@anthropic.com` |
| `custom_connection` | Custom URL or credentials supplied at connection time | Contact `mcp-review@anthropic.com` |
| `none` | Authless server (partial-auth mode is experimental) | Supported |

**Not supported:** `static_bearer` (user-pasted tokens). Tokens or API
keys in the connector URL query string (`?token=`, `?apiKey=`, `?userToken=`)
are also **not supported** — the MCP authorization spec prohibits access
tokens in URI query strings.

For high-traffic directory connectors, prefer **CIMD or
`oauth_anthropic_creds` over DCR**. DCR registers a new OAuth client on
every fresh connection; CIMD and Anthropic-held credentials skip the
registration call.

### PKCE and scopes

Claude includes a `code_challenge` with `code_challenge_method=S256` on
**every** authorization request. Your authorization server must:
- Support S256 PKCE.
- Advertise `"code_challenge_methods_supported": ["S256"]` in its metadata.

To control which scopes Claude requests, include a `scope` parameter in
the `WWW-Authenticate` header on your `401` response.

### Callback URLs

| Surface | Redirect URI |
|---|---|
| Claude.ai web, Desktop, Mobile, Cowork | `https://claude.ai/api/mcp/auth_callback` |
| Claude Code | Loopback redirect — `http://localhost/callback` or `http://127.0.0.1/callback`; port-agnostic match required |

### Token refresh

Tokens are refreshed **reactively on a 401** and proactively up to 5
minutes before expiry. Rotation requirements:
- Return RFC 6749 error codes (`invalid_grant`) when a refresh token is invalid.
- Rotate refresh tokens for DCR/CIMD connections (public clients).
- Token endpoint must accept `Content-Type: application/x-www-form-urlencoded`.

### Lazy authentication (401 pattern)

The lazy pattern is recommended: expose public tools without auth, only
challenge when a protected tool is actually invoked.

**Critical:** The server must refuse with an HTTP `401` status **and**
a `WWW-Authenticate: Bearer` header — never a `200 OK` wrapping
`isError: true`. A 200-wrapped error is treated as a tool failure; only
a transport-level 401 triggers the OAuth popup and auto-retry.

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer error="invalid_token",
  resource_metadata="https://example.com/.well-known/oauth-protected-resource/mcp",
  scope="orders:read"
```

A `403` triggers re-authentication **only** when accompanied by
`WWW-Authenticate: Bearer error="insufficient_scope"` (scope step-up);
any other 403 is surfaced as a terminal error.

### Egress IP range

Anthropic's outbound traffic to your MCP server originates from
`160.79.104.0/21`. Allowlist this range for WAF / firewall rules.

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
