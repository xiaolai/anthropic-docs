---
name: mcp-clients
description: |
  Deep reference for implementing an MCP client — the per-server
  connection holder inside an MCP host. Covers discovering server
  capabilities, calling tools (tools/call), reading resources
  (resources/read + subscriptions), listing/getting prompts,
  handling server-initiated sampling/createMessage and
  roots/list requests, and the catalog of existing MCP clients
  in the wild.
source: https://modelcontextprotocol.io/clients.md
---

# MCP — Clients

> *Router lives in [`SKILL.md`](SKILL.md). For protocol-level
> details (initialize, capabilities, framing), see
> [`SKILL-protocol.md`](SKILL-protocol.md). For server
> implementation, [`SKILL-servers.md`](SKILL-servers.md).*

## What an MCP client is

An MCP client is the per-server connection holder inside an MCP
host. The host (AI application) creates one client per server it
connects to. Each client:

1. Establishes the transport connection (stdio subprocess or HTTP).
2. Performs the `initialize` handshake.
3. Negotiates capabilities.
4. During operate phase: sends client-originated requests (tools/call,
   resources/read, prompts/get, etc.) and handles server-originated
   requests (sampling/createMessage, roots/list, elicitation).
5. Disconnects cleanly on shutdown.

## Building a client

The canonical guide:
[`develop/build-client.md`](https://modelcontextprotocol.io/docs/develop/build-client.md).

It walks through the TypeScript and Python SDK flows, the
initialize handshake, calling tools, and handling sampling
requests from the server.

## Discovering server capabilities

After `initialize`, the client knows what the server supports:

- `serverInfo` — name + version of the server.
- `capabilities` — declared features.
- `instructions` — optional plain-language hints from the server.

Then the client can fetch the catalogs:

```
→ tools/list       → { tools: [{ name, description, inputSchema, outputSchema? }, ...] }
→ resources/list   → { resources: [{ uri, name, description, mimeType }, ...] }
→ resources/templates/list → { resourceTemplates: [{ uriTemplate, ... }, ...] }
→ prompts/list     → { prompts: [{ name, description, arguments }, ...] }
```

## Calling tools

```
→ tools/call { name, arguments }
← { content: [...], isError?: false }
```

`content` is an array of content blocks — typically `{type: "text", text}`
or `{type: "image", data, mimeType}`. See [`SKILL-tools-resources-prompts.md`](SKILL-tools-resources-prompts.md)
for the content-block schema.

## Reading resources

```
→ resources/read { uri }
← { contents: [{ uri, mimeType, text? | blob? }, ...] }
```

For subscribable resources, the client can subscribe and receive
`notifications/resources/updated` from the server when content
changes:

```
→ resources/subscribe { uri }
← {}
... later ...
← notifications/resources/updated { uri }
→ resources/read { uri }    (to fetch the new contents)
```

## Listing and getting prompts

Prompts are server-provided message templates the user can invoke:

```
→ prompts/get { name, arguments }
← { description, messages: [{ role, content }, ...] }
```

The client renders the returned messages into the host's
conversation.

## Roots

If the client declared the `roots` capability, the server can
request the filesystem roots the host is operating in:

```
← roots/list   (from server to client)
→ { roots: [{ uri: "file:///path", name? }, ...] }
```

If the client also declared `roots.listChanged`, it can notify the
server when roots change:

```
→ notifications/roots/list_changed
```

## Sampling (server asks client to LLM-sample)

> **Deprecation notice:** [SEP-2577](https://modelcontextprotocol.io/seps/2577-deprecate-roots-sampling-and-logging.md) (Final) marks `sampling/createMessage` for deprecation in the next spec revision (expected June 2026). See [`SKILL-tools-resources-prompts.md`](SKILL-tools-resources-prompts.md#sampling) for details.

If the client declared `sampling`, the server can ask the host to
sample from its LLM:

```
← sampling/createMessage { messages, modelPreferences?, includeContext?, ... }
→ { role: "assistant", content: { type, text }, model, stopReason }
```

This is how MCP servers leverage the host's LLM without needing
their own API key. The client decides whether to allow the request
(typically asking the user first).

## Elicitation (server asks user for structured input)

If the client declared `elicitation`, the server can prompt the
user for structured input via the host. Two modes exist:

### Form mode (structured data)

```
← elicitation/create { mode: "form", message, requestedSchema }
→ { action: "accept" | "decline" | "cancel", content?: <matching schema> }
```

The host renders a form/dialog. `mode` may be omitted for backwards
compatibility (defaults to `"form"`).

### URL mode (out-of-band / sensitive)

```
← elicitation/create { mode: "url", elicitationId, url, message }
→ { action: "accept" | "decline" | "cancel" }
```

The client shows the user the `url` and asks for consent before
opening it. Used for OAuth flows, payment pages, and other
interactions where sensitive data must NOT pass through the MCP
client. The client MUST NOT auto-fetch the URL or expose its
response content.

### Capability declaration

```json
{
  "capabilities": {
    "elicitation": {
      "form": {},
      "url": {}
    }
  }
}
```

For backwards compatibility, `elicitation: {}` (empty) is treated
as `form`-only. Servers MUST NOT send URL mode requests unless the
client declared `elicitation.url`.

An optional `notifications/elicitation/complete` notification may
be sent by the server to signal completion of a URL mode flow. It
MUST include the `elicitationId` from the original request:

```
← notifications/elicitation/complete { elicitationId }
```

### URLElicitationRequiredError (server-initiated elicitation)

A server may return error code **`-32042`** (`URLElicitationRequiredError`)
in response to *any* request to indicate that URL mode elicitation must
be completed before the request can proceed. The error's `data` field
embeds the pending elicitation:

```json
{
  "code": -32042,
  "message": "URL Elicitation Required",
  "data": {
    "elicitations": [
      {
        "mode": "url",
        "elicitationId": "550e8400-e29b-41d4-a716-446655440000",
        "url": "https://mcp.example.com/connect?elicitationId=...",
        "message": "Authorize access to continue."
      }
    ]
  }
}
```

The client MUST:
1. Extract and display the embedded elicitation URL to the user.
2. Wait for `notifications/elicitation/complete` (matching `elicitationId`).
3. Retry the original request.

The server MUST NOT return this error except when URL mode elicitation is
genuinely required to proceed.

Source: [`specification/2025-11-25/client/elicitation.md`](https://modelcontextprotocol.io/specification/2025-11-25/client/elicitation.md)

## Client best practices

[`develop/clients/client-best-practices.md`](https://modelcontextprotocol.io/docs/develop/clients/client-best-practices.md)
covers patterns for scaling MCP host applications across many
servers and tools. Two key patterns for large-scale deployments:

### Progressive Tool Discovery

When tool definitions fill a significant fraction of the context window (recommended
threshold: **1–5% of total context**), load definitions on demand instead of all at once:

1. **Catalog** — expose a lightweight `search_tools` meta-tool; pass only tool names and
   one-line descriptions.
2. **Inspect** — expose a `get_tool_details` meta-tool; fetch the full schema for a single
   tool when the model selects it.
3. **Execute** — call the actual tool via the standard `tools/call` flow.

Implementation tips:

- Cache tool definitions host-side after `tools/list` so `get_tool_details` doesn't
  need a round-trip every time.
- Re-index the search catalog on `notifications/tools/list_changed`.
- Preserve prompt-cache hits by appending new definitions after the cache breakpoint
  (or route every call through a stable `call_tool({name, args})` meta-tool so the
  `tools` array never changes).
- Discovery strategies: keyword (BM25), embedding (vector similarity), subagent
  (secondary model routes to right tools), or hybrid.

### Dynamic Server Management

Rather than connecting to every configured server at startup, hosts can:

1. Maintain a registry of available servers with high-level descriptions.
2. Connect a server only when the model determines it needs that server's capabilities.
3. Disconnect idle servers to free context.

Source: [`develop/clients/client-best-practices.md`](https://modelcontextprotocol.io/docs/develop/clients/client-best-practices.md)

## Client capability features

The [`clients.md`](https://modelcontextprotocol.io/clients.md) matrix
uses feature badges to indicate what each client supports. Key feature
identifiers relevant to implementers:

| Feature | What it means |
|---|---|
| `Tools` | Client can call server tools |
| `Resources` | Client can read server resources |
| `Prompts` | Client can use server prompt templates |
| `Sampling` | Client supports `sampling/createMessage` from server |
| `Elicitation` | Client supports `elicitation/create` from server |
| `Roots` | Client provides `roots/list` to server |
| `Discovery` | Client supports server discovery |
| `Instructions` | Client uses server `instructions` field |
| `Tasks` | Client supports async task handles (`io.modelcontextprotocol/tasks` extension) |
| `Apps` | Client supports MCP Apps (`io.modelcontextprotocol/ui` extension) |
| `DCR` | OAuth 2.0 Dynamic Client Registration (RFC 7591) |
| `CIMD` | OAuth Client ID Metadata Documents — client's `client_id` is a URL pointing to a metadata document; avoids per-server registration |
| `OAuth Client Credentials` | Machine-to-machine OAuth Client Credentials flow extension |
| `Enterprise-Managed Authorization` | Centralized IdP access control extension |

Source: [`clients.md`](https://modelcontextprotocol.io/clients.md)

## Extension Support Matrix

The [`extensions/client-matrix.md`](https://modelcontextprotocol.io/extensions/client-matrix.md)
page tracks which clients implement which official extensions (declared via
`extensions` capability in `initialize`):

| Client | MCP Apps | OAuth Client Credentials | Enterprise Auth |
|---|:---:|:---:|:---:|
| Claude (web) | ✓ | | |
| Claude Desktop | ✓ | | |
| VS Code GitHub Copilot | ✓ | | |
| Goose | ✓ | | |
| Postman | ✓ | | |
| MCPJam | ✓ | | |
| ChatGPT | ✓ | | |
| Cursor | ✓ | | |

Extension identifiers: MCP Apps = `io.modelcontextprotocol/ui`,
OAuth Client Credentials = `io.modelcontextprotocol/oauth-client-credentials`,
Enterprise Auth = `io.modelcontextprotocol/enterprise-managed-authorization`.

Source: [`extensions/client-matrix.md`](https://modelcontextprotocol.io/extensions/client-matrix.md)

## Existing clients

[`clients.md`](https://modelcontextprotocol.io/clients.md) is
the registry of applications that support MCP. Notable entries:

- Claude Desktop, Claude Code, Claude.ai (Anthropic).
- GitHub Copilot CLI (supports Tools, Discovery, Instructions, Sampling, Elicitation, DCR, OAuth Client Credentials, Tasks).
- Codex (OpenAI) — lightweight AI coding agent for the terminal; supports Resources, Tools, Elicitation, Instructions.
- Gemini CLI (Google) — terminal agent; supports Prompts, Tools, Instructions, DCR.
- VS Code (via GitHub Copilot extension).
- Cline, Zed (with Discovery support), Cursor, Windsurf, other editor integrations.
- Third-party IDE / agent platforms including Archestra (enterprise AI platform, supports CIMD, Enterprise-Managed Authorization).

The list grows constantly — consult the source page for the
current state.

## Local vs remote connection guides

| Page | Topic |
|---|---|
| [`develop/connect-local-servers.md`](https://modelcontextprotocol.io/docs/develop/connect-local-servers.md) | Extending Claude Desktop with local stdio servers |
| [`develop/connect-remote-servers.md`](https://modelcontextprotocol.io/docs/develop/connect-remote-servers.md) | Connecting Claude to remote HTTP servers |

---

*Source pages: `clients.md`, `docs/develop/build-client.md`,
`docs/develop/clients/client-best-practices.md`,
`docs/develop/connect-{local,remote}-servers.md`.*
