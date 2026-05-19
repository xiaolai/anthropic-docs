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
be sent by the server to signal completion of a URL mode flow.

Source: [`specification/2025-11-25/client/elicitation.md`](https://modelcontextprotocol.io/specification/2025-11-25/client/elicitation.md)

## Client best practices

[`develop/clients/client-best-practices.md`](https://modelcontextprotocol.io/docs/develop/clients/client-best-practices.md)
covers patterns for scaling MCP host applications across many
servers and tools:

- Connection pooling and reuse.
- Per-conversation tool allowlists (don't expose every connected
  tool to every conversation).
- Aggregating capabilities from N servers into a unified tool list
  for the LLM.
- Handling per-tool latency variance (slow MCP servers should not
  block fast ones).
- Graceful degradation when a server disconnects mid-conversation.

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

## Existing clients

[`clients.md`](https://modelcontextprotocol.io/clients.md) is
the registry of applications that support MCP. Notable entries:

- Claude Desktop, Claude Code, Claude.ai (Anthropic).
- GitHub Copilot CLI (supports Tools, Discovery, Instructions, Sampling, Elicitation, DCR, OAuth Client Credentials, Tasks).
- Codex (OpenAI) — lightweight AI coding agent for the terminal; supports Resources, Tools, Elicitation.
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
