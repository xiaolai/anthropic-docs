---
name: mcp-transport
description: |
  Deep reference for MCP transport layers — stdio (local
  subprocess), streamable HTTP (remote, HTTP POST + optional
  Server-Sent Events for streaming), and legacy SSE (separate
  POST + EventStream endpoints, now superseded). Covers when to
  choose each, message framing, auth wrapping, and the connection
  lifecycle per transport.
source: https://modelcontextprotocol.io/specification/2025-11-25/basic/
---

# MCP — Transports

> *Router lives in [`SKILL.md`](SKILL.md). For the JSON-RPC
> framing carried inside any transport, see
> [`SKILL-protocol.md`](SKILL-protocol.md).*

## The two recommended transports

| Transport | Use for | Connection model | Auth |
|---|---|---|---|
| **stdio** | Local processes on the same machine | One client ↔ one subprocess | Inherited (OS user) |
| **streamable HTTP** | Remote servers (cloud / shared infrastructure) | Many clients ↔ one server | HTTP standard (Bearer, OAuth, custom headers) |

The legacy **SSE transport** (separate POST + EventStream endpoints)
is being deprecated in favor of streamable HTTP. New servers should
use streamable HTTP; existing SSE servers should plan migration.

## stdio transport

The server is launched as a subprocess by the client. Messages are
newline-delimited JSON-RPC over the subprocess's stdin / stdout.
stderr is reserved for human-readable logs (not protocol traffic).

### Framing

```
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{...}}\n
{"jsonrpc":"2.0","id":1,"result":{...}}\n
```

Each line is one complete JSON-RPC message. No length prefixes; no
multipart framing.

### Lifecycle

- Client launches the subprocess (e.g., `npx -y @modelcontextprotocol/server-foo`).
- Client and server perform the `initialize` handshake over stdio.
- Operation continues until either side terminates the process.
- Clean shutdown: client sends EOF on stdin; server flushes and
  exits.

### Use cases

- Local file-system servers.
- Local database servers.
- Servers that integrate with local installed tools (Docker, Git,
  IDE, etc.).
- Local privacy-sensitive operations (data stays on the user's
  machine).

### Performance

Optimal — no network overhead, no serialization beyond the JSON-RPC
itself.

## Streamable HTTP transport

A single HTTP endpoint per server. Clients send messages via HTTP
POST; responses can be plain JSON (single response) or a Server-Sent
Events stream (for streaming responses, e.g., long-running tool calls).

### Security (DNS rebinding)

Streamable HTTP servers MUST implement these protections to prevent DNS rebinding attacks:

1. **Validate the `Origin` header** on all incoming connections. If the `Origin` header is present and does not match an expected value, respond with HTTP 403 Forbidden.
2. **Bind locally to 127.0.0.1**, not 0.0.0.0, when running on a local machine.
3. **Implement authentication** for all connections.

Without these protections, a remote website can use DNS rebinding to reach and interact with a locally running MCP server.

Source: [`specification/2025-11-25/basic/transports.md`](https://modelcontextprotocol.io/specification/2025-11-25/basic/transports.md)

### Framing

- **Request**: `POST <endpoint>` with `Content-Type: application/json`
  and a JSON-RPC message in the body.
- **Single response**: HTTP 200 + JSON-RPC response body.
- **Streaming response**: HTTP 200 + `Content-Type: text/event-stream`
  with framed events, each event being one JSON-RPC notification or
  the final response.

### MCP-Protocol-Version header (required for HTTP)

After a successful `initialize` handshake, clients using Streamable HTTP **MUST**
include the `MCP-Protocol-Version` HTTP header on every subsequent request:

```
MCP-Protocol-Version: 2025-11-25
```

The value SHOULD be the protocol version negotiated during initialization.
If the server receives an invalid or unsupported version it MUST respond
with `400 Bad Request`. Servers that receive no header SHOULD assume protocol
version `2025-03-26` for backwards compatibility.

Source: [`specification/2025-11-25/basic/transports.md#protocol-version-header`](https://modelcontextprotocol.io/specification/2025-11-25/basic/transports.md)

### Auth

Standard HTTP authentication methods:

- **Bearer tokens** — `Authorization: Bearer <token>`.
- **API keys** — custom header (e.g., `X-API-Key: <key>`).
- **OAuth** — recommended for user-facing MCP servers. The MCP
  client handles the OAuth flow; tokens flow as bearer.

### Use cases

- Cloud services with centralized infrastructure.
- Servers serving many users (multi-tenant).
- Servers behind enterprise SSO.
- Servers needing centralized logging / audit.

## Legacy SSE transport (deprecated)

The earlier transport used two endpoints:

- `POST /messages` for client → server.
- `GET /events` (EventStream) for server → client.

This model is being phased out in favor of streamable HTTP, which
unifies both directions on a single endpoint. New servers should
implement streamable HTTP only.

Migration path: streamable HTTP servers can offer SSE compatibility
during a transition period by exposing both endpoints; once all
clients update, the SSE endpoints can be removed.

## Choosing a transport

```
Is the server bound to a single user's machine, with local resources only?
  → stdio

Is the server cloud-hosted, serving multiple users, or needing centralized auth?
  → streamable HTTP

Are you maintaining an existing SSE server?
  → plan migration to streamable HTTP; offer both during transition.
```

## Authorization

The spec separates **authentication** (who is the user?) from
**authorization** (what may they do?):

- Transport handles authentication (Bearer / OAuth / API key).
- Server logic handles authorization (per-tool / per-resource
  permission checks).

For OAuth, the spec defines a recommended flow that supports
public clients (no client secret), suitable for the typical MCP
client deployment.

Reference: [`specification/2025-11-25/basic/`](https://modelcontextprotocol.io/specification/2025-11-25/basic/)
under the `auth*` pages.

## Connection lifecycle (transport-agnostic)

Regardless of transport, the data-layer lifecycle is the same:

1. Transport establishes the channel.
2. Client sends `initialize` → server responds.
3. Client sends `notifications/initialized` (no response) →
   operation begins.
4. Bidirectional JSON-RPC.
5. Transport tears down the channel (subprocess exit, HTTP close).

---

*Source pages: `specification/2025-11-25/basic/transports.md`
and adjacent transport / auth pages under the spec subtree.*
