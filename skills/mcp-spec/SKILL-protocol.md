---
name: mcp-protocol
description: |
  Deep reference for the MCP wire protocol — JSON-RPC 2.0 framing,
  the initialize handshake, capability negotiation, lifecycle
  (init → operate → shutdown), error codes, and protocol
  versioning. Current protocol version 2025-11-25.
source: https://modelcontextprotocol.io/docs/learn/architecture.md
---

# MCP — Protocol

> *Router lives in [`SKILL.md`](SKILL.md). For client/server
> implementation, see [`SKILL-clients.md`](SKILL-clients.md) and
> [`SKILL-servers.md`](SKILL-servers.md). For transport details,
> [`SKILL-transport.md`](SKILL-transport.md). For primitive
> definitions, [`SKILL-tools-resources-prompts.md`](SKILL-tools-resources-prompts.md).*

## Architecture in one paragraph

MCP follows a client-server architecture. An **MCP host** (an AI
application like Claude Code or Claude Desktop) establishes
connections to one or more **MCP servers** by creating one **MCP
client** per server. Each client maintains a dedicated connection
with its server. Local stdio servers typically serve a single
client; remote HTTP servers typically serve many.

| Role | What it is |
|---|---|
| **MCP Host** | AI application coordinating one or more MCP clients |
| **MCP Client** | Per-server connection holder inside the host |
| **MCP Server** | Program providing context (tools/resources/prompts) |

Source: [`learn/architecture.md`](https://modelcontextprotocol.io/docs/learn/architecture.md).

## Two layers

| Layer | What it owns |
|---|---|
| **Data layer** | JSON-RPC 2.0 messages, lifecycle, capabilities, primitives (tools / resources / prompts / sampling / elicitation / logging) |
| **Transport layer** | Connection mechanics, framing, auth — stdio or streamable HTTP |

Most SDK users only interact with the data layer; transport is
handled by the SDK. See [`SKILL-transport.md`](SKILL-transport.md)
for transport choice.

## JSON-RPC 2.0 framing

All MCP messages are JSON-RPC 2.0:

- **Request** — `{jsonrpc: "2.0", id, method, params}`. Expects a response.
- **Notification** — `{jsonrpc: "2.0", method, params}`. No response.
- **Response** — `{jsonrpc: "2.0", id, result}` or
  `{jsonrpc: "2.0", id, error: {code, message, data?}}`.

## Initialization handshake

1. Client sends `initialize` request with its `protocolVersion`,
   declared `capabilities`, and `clientInfo`.
2. Server responds with the version it picked (highest mutually
   supported), its `capabilities`, and `serverInfo`.
3. Client sends `notifications/initialized` (a notification, no
   response expected) — operation phase begins.

See [`specification/2025-11-25/basic/`](https://modelcontextprotocol.io/specification/2025-11-25/basic/)
for the formal lifecycle spec.

## Capability negotiation

Each side advertises what it supports. The other side only invokes
features that the peer advertised. Typical capabilities:

**Server capabilities** (subset):
- `tools` — provides callable tools, optionally with `listChanged`.
- `resources` — provides readable resources, optionally with `subscribe` and `listChanged`.
- `prompts` — provides prompt templates, optionally with `listChanged`.
- `logging` — accepts client log messages.
- `completions` — provides argument completion for prompts/resource URIs.
- `tasks` *(experimental)* — supports task-augmented requests (e.g., `tasks.requests.tools.call`).

**Client capabilities** (subset):
- `sampling` — server may request the client to sample from the host LLM.
- `roots` — server may request the list of filesystem roots, optionally with `listChanged`.
- `elicitation` — server may request structured input from the user.
- `tasks` *(experimental)* — supports task-augmented requests (e.g., `tasks.requests.sampling.createMessage`, `tasks.requests.elicitation.create`).

> **Experimental: Tasks.** Tasks are durable state machines for long-running or deferred
> operations. Either side can declare `tasks` capability broken down by request type
> (`tasks.list`, `tasks.cancel`, `tasks.requests.*`). Tools opt in per-tool via the
> `execution.taskSupport` field (`"forbidden"` | `"optional"` | `"required"`).
> See [`specification/2025-11-25/basic/utilities/tasks.md`](https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/tasks.md).

## Lifecycle

```
[Initialize] → [Operate] → [Shutdown]
     ↑              ↓
     └── error / disconnect
```

- **Initialize** — handshake above; capability negotiation.
- **Operate** — bidirectional JSON-RPC traffic per the negotiated
  capabilities.
- **Shutdown** — clean disconnect on either side (transport-dependent).

## Error codes

Standard JSON-RPC error codes plus MCP-specific extensions:

| Code | Meaning |
|---|---|
| -32700 | Parse error (malformed JSON) |
| -32600 | Invalid Request |
| -32601 | Method not found |
| -32602 | Invalid params |
| -32603 | Internal error |
| -32000…-32099 | Implementation-defined server errors |

MCP-defined error semantics live in the spec under
[`specification/2025-11-25/basic/`](https://modelcontextprotocol.io/specification/2025-11-25/basic/).

> **Pending SEP:** [SEP-2164](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md)
> (Draft, Standards Track) proposes standardising the resource-not-found error to `-32602`
> (Invalid Params). Current SDKs are inconsistent: TypeScript uses `-32602`, Python uses `0`,
> and C#/Rust/Java/Go use a custom `-32002`. Until SEP-2164 is Final, clients that need to
> reliably detect resource-not-found across SDKs should handle `-32602`, `-32002`, and `-32603`
> defensively.

## Protocol versioning

Version string format: `YYYY-MM-DD` — the date of the last
backwards-incompatible change.

- **Current**: `2025-11-25`. See
  [`specification/2025-11-25/`](https://modelcontextprotocol.io/specification/2025-11-25/).
- **Draft**: in-progress, not for production use.
- **Final**: past, complete, never changes.

The version is NOT incremented for backwards-compatible additions.

Version negotiation: clients and servers MAY support multiple
versions simultaneously but MUST agree on a single version per
session. If negotiation fails, the connection terminates with an
appropriate error.

Reference: [`learn/versioning.md`](https://modelcontextprotocol.io/docs/learn/versioning.md).

## Specification subtree

| Path | Topic |
|---|---|
| [`specification/2025-11-25/basic/`](https://modelcontextprotocol.io/specification/2025-11-25/basic/) | Lifecycle, framing, transports, auth, utilities |
| [`specification/2025-11-25/client/`](https://modelcontextprotocol.io/specification/2025-11-25/client/) | Client features (sampling, roots, elicitation) |
| [`specification/2025-11-25/server/`](https://modelcontextprotocol.io/specification/2025-11-25/server/) | Server features (tools, resources, prompts) |
| [`specification/2025-11-25/architecture/`](https://modelcontextprotocol.io/specification/2025-11-25/architecture/) | Architectural overview |
| [`specification/2025-11-25/changelog.md`](https://modelcontextprotocol.io/specification/2025-11-25/changelog.md) | Per-version changelog |
| [`specification/2025-11-25/schema.md`](https://modelcontextprotocol.io/specification/2025-11-25/schema.md) | TypeScript / JSON-Schema definitions |

## Specification Enhancement Proposals (SEPs)

Protocol evolution happens via SEPs — Specification Enhancement
Proposals. The process is documented at
[`community/sep-guidelines.md`](https://modelcontextprotocol.io/community/sep-guidelines.md).
Active SEPs live under [`seps/`](https://modelcontextprotocol.io/seps/).

Notable recently-added Draft SEPs (added 2026-05-19):

| SEP | Title | Status | Affects |
|---|---|---|---|
| [SEP-2106](https://modelcontextprotocol.io/seps/2106-json-schema-2020-12.md) | Tools `inputSchema` & `outputSchema` conform to JSON Schema 2020-12 | Draft | Tools primitive — `inputSchema`, `outputSchema`, `structuredContent` |
| [SEP-2164](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md) | Standardize resource-not-found error code to `-32602` | Draft | Error codes, Resources error handling |
| [SEP-2596](https://modelcontextprotocol.io/seps/2596-spec-feature-lifecycle-and-deprecation.md) | Specification feature lifecycle and deprecation policy | Draft | Governance process; grandfathers HTTP+SSE transport and `includeContext: "thisServer"/"allServers"` as formally Deprecated |

SEP-2596 also introduces the concept of a **deprecated registry** (`deprecated.mdx`) listing
every feature in the Deprecated state, their migration targets, and earliest removal dates.
When it reaches Final, the minimum deprecation window is 12 months measured from the revision
release in which the feature is first marked Deprecated.

---

*Source pages: `learn/architecture.md`, `learn/versioning.md`,
`specification/2025-11-25/*` (multi-page subtree),
`community/sep-guidelines.md`, `seps/*`
(including `seps/2106-json-schema-2020-12.md`,
`seps/2164-resource-not-found-error.md`,
`seps/2596-spec-feature-lifecycle-and-deprecation.md`).*
