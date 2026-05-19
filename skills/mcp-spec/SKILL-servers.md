---
name: mcp-servers
description: |
  Deep reference for implementing an MCP server in TypeScript
  (@modelcontextprotocol/sdk) or Python (mcp). Covers server-side
  capability advertisement, lifecycle (startup → idle → shutdown),
  logging + diagnostics, server-initiated requests (sampling,
  roots, elicitation), the reference-server gallery, and tutorial
  resources.
source: https://modelcontextprotocol.io/docs/develop/build-server.md
---

# MCP — Servers

> *Router lives in [`SKILL.md`](SKILL.md). For the protocol-level
> details, see [`SKILL-protocol.md`](SKILL-protocol.md). For
> defining tools / resources / prompts, see
> [`SKILL-tools-resources-prompts.md`](SKILL-tools-resources-prompts.md).
> For transport choice, [`SKILL-transport.md`](SKILL-transport.md).*

## What an MCP server is

An MCP server is a program that provides context to MCP clients —
tools, resources, prompts, and optionally sampling/elicitation
requests back to the client. It speaks JSON-RPC 2.0 over either
stdio (local) or streamable HTTP (remote).

Key invariant: a server runs as either local (one client) or
remote (many clients) — not both. Choose at design time.

## Building a server

The canonical guide:
[`develop/build-server.md`](https://modelcontextprotocol.io/docs/develop/build-server.md).

### TypeScript

```bash
npm install @modelcontextprotocol/sdk
```

Reference SDK: [TypeScript SDK on GitHub](https://github.com/modelcontextprotocol/typescript-sdk).

### Python

```bash
pip install mcp
```

Reference SDK: [Python SDK on GitHub](https://github.com/modelcontextprotocol/python-sdk).

Both SDKs abstract transport, lifecycle, and capability negotiation
— the developer wires up tool/resource/prompt handlers and the SDK
handles the rest.

## Server-side capability advertisement

During `initialize`, the server declares what it offers:

```json
{
  "capabilities": {
    "tools": {},
    "resources": { "subscribe": true, "listChanged": true },
    "prompts": { "listChanged": true },
    "logging": {},
    "completions": {}
  }
}
```

Subfields are commonly:

- `subscribe` — server supports `resources/subscribe`.
- `listChanged` — server emits `notifications/.../list_changed` when
  the catalog changes (clients can re-list lazily).

## Server lifecycle

```
startup → initialize → operate → shutdown
```

- **Startup** — process launches (stdio) or HTTP listener binds.
- **Initialize** — handle the client's `initialize` request,
  declare capabilities, return `serverInfo`.
- **Operate** — handle `tools/list`, `tools/call`, `resources/*`,
  `prompts/*`, etc. Optionally initiate `sampling/createMessage`,
  `roots/list`, `elicitation/create` if the client allows.
- **Shutdown** — handle disconnect (transport-dependent).

## Logging from the server

If the client declared `logging`, the server can send structured
log messages:

```
→ notifications/message { level, logger?, data }
```

`level` is one of `debug | info | notice | warning | error | critical | alert | emergency`.

> **Scoping rule**: `notifications/message` is **request-scoped**.
> The server MAY emit it on the response stream of the request whose
> `_meta` object included `io.modelcontextprotocol/logLevel`.
> It MUST NOT be delivered on a `subscriptions/listen` stream or any
> other unrelated stream. The `subscriptions/listen` stream carries only
> opted-in change-notification types (resources, tools, prompts, etc.),
> not per-request log output.
> Source: [#2728](https://github.com/modelcontextprotocol/modelcontextprotocol/issues/2728)

## Server-initiated requests

If the client declared the corresponding capability, the server
can initiate:

| Request | Purpose |
|---|---|
| `sampling/createMessage` | Ask client to LLM-sample (uses host's API key) |
| `roots/list` | Ask client for filesystem roots |
| `elicitation/create` | Ask user for structured input via the host |

## Build with Agent Skills

[`develop/build-with-agent-skills.md`](https://modelcontextprotocol.io/docs/develop/build-with-agent-skills.md)
covers using Anthropic-style Agent Skills to guide AI coding
assistants through MCP server design and implementation — a
self-referential pattern (skills helping you build MCP servers
that themselves teach skills).

## Tutorials

Walk-throughs under [`tutorials/`](https://modelcontextprotocol.io/tutorials/)
cover common server-building scenarios end-to-end.

## Reference server gallery

The MCP project maintains [reference server implementations](https://github.com/modelcontextprotocol/servers)
covering common targets:

- Filesystem
- Git
- Postgres
- SQLite
- Brave Search
- Fetch
- Memory
- Sequential Thinking
- (many more — consult the repo)

These are useful as both ready-to-use servers and as code
examples for new server authors.

## Examples

[`examples.md`](https://modelcontextprotocol.io/examples.md)
catalogs example server implementations beyond the reference
gallery.

## Extensions

[`extensions/`](https://modelcontextprotocol.io/extensions/)
documents experimental protocol extensions — features under
discussion that haven't made it into the core spec yet.

## SDK tiering

[`community/sdk-tiers.md`](https://modelcontextprotocol.io/community/sdk-tiers.md)
defines feature-completeness, protocol-support, and maintenance
commitment levels for MCP SDKs. Useful when choosing a non-TypeScript /
non-Python SDK from the community.

## Inspector

The [MCP Inspector](https://github.com/modelcontextprotocol/inspector)
is the canonical interactive debugger for an MCP server — lets you
manually invoke tools, read resources, and watch the wire protocol.
Use during development.

## Server tutorials & cookbook

| Page | Topic |
|---|---|
| [`tutorials/`](https://modelcontextprotocol.io/tutorials/) | Walk-through tutorials |
| [`sdk.md`](https://modelcontextprotocol.io/sdk.md) | SDK landing page |
| [`tools/`](https://modelcontextprotocol.io/tools/) | MCP development tools |

---

*Source pages: `docs/develop/build-server.md`,
`docs/develop/build-with-agent-skills.md`, `tutorials/*`,
`examples.md`, `extensions/*`, `community/sdk-tiers.md`,
`sdk.md`, `tools/*`.*
