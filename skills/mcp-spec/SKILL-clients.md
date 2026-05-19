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
user for structured input via the host:

```
← elicitation/create { message, requestedSchema }
→ { action: "accept" | "decline" | "cancel", content?: <matching schema> }
```

The host renders an appropriate UI (form, dialog) and returns the user's response.

**URL mode** (SEP-1036, `2025-11-25`+): servers may also request out-of-band interactions
(OAuth, payments) by sending `mode: "url"` with a `url` and `elicitationId`. The client
shows the URL to the user; the server may later notify via
`notifications/elicitation/complete { elicitationId }` when complete.
See [`SKILL-tools-resources-prompts.md`](SKILL-tools-resources-prompts.md#url-mode-elicitation-sep-1036-2025-11-25) for the full schema.

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

## Existing clients

[`clients.md`](https://modelcontextprotocol.io/clients.md) is
the registry of applications that support MCP. Notable entries:

- Claude Desktop, Claude Code, Claude Cowork (Anthropic).
- VS Code (via the MCP extension).
- Cline, Zed, other editor integrations.
- Third-party IDE / agent platforms.

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
