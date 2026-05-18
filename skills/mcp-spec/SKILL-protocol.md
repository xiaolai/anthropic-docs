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
- `tools` — provides callable tools.
- `resources` — provides readable resources, optionally with `subscribe`.
- `prompts` — provides prompt templates.
- `logging` — accepts client log messages.
- `completions` — provides argument completion for prompts/resource URIs.

**Client capabilities** (subset):
- `sampling` — server may request the client to sample from the host LLM.
- `roots` — server may request the list of filesystem roots, optionally with `listChanged`.
- `elicitation` — server may request structured input from the user.

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

**Resource not found** — [SEP-2164](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md)
(Draft) proposes standardising the error code for a missing resource on
`-32602` (Invalid Params). The current spec recommends `-32002`, but SDK
implementations vary (`-32602` in TypeScript, `0` in Python, `-32002` in C# /
Rust / Java / Go / PHP, `-32603` in Kotlin). Until SEP-2164 is Final, clients
SHOULD handle at least both `-32002` and `-32602` as resource-not-found
indicators.

## Tasks (experimental — spec 2025-11-25)

Tasks extend normal request–response with a durable asynchronous model.
Instead of blocking the connection, a receiver returns a `CreateTaskResult`
immediately and the requestor polls for the result.

Source: [`specification/2025-11-25/basic/utilities/tasks.md`](https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/tasks.md)
(experimental; design may evolve in future protocol versions).

### Capabilities

Both sides declare a `tasks` capability. Server example:

```json
{
  "capabilities": {
    "tasks": {
      "list": {},
      "cancel": {},
      "requests": { "tools": { "call": {} } }
    }
  }
}
```

Client adds `requests.sampling.createMessage` and/or `requests.elicitation.create`.

### Methods and notifications

| Message | Direction | Purpose |
|---|---|---|
| `tasks/get` | requestor → receiver | Poll task status (use `pollInterval`) |
| `tasks/result` | requestor → receiver | Retrieve result when terminal (blocking) |
| `tasks/list` | requestor → receiver | List tasks (paginated) |
| `tasks/cancel` | requestor → receiver | Request cooperative cancellation |
| `notifications/tasks/status` | receiver → requestor | Optional status-change push |

### Task statuses

`working` · `input_required` · `completed` · `failed` · `cancelled`

Terminal statuses are `completed`, `failed`, `cancelled`. Requestors MUST
poll via `tasks/get` and MUST NOT rely solely on the optional notification.

### Tool-level negotiation

Individual tools declare task support via `execution.taskSupport` in the
`tools/list` response (see [`SKILL-tools-resources-prompts.md`](SKILL-tools-resources-prompts.md)):
`"optional"`, `"required"`, or `"forbidden"` (absent = forbidden).

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

### Feature lifecycle and deprecation (SEP-2596)

[SEP-2596](https://modelcontextprotocol.io/seps/2596-spec-feature-lifecycle-and-deprecation.md)
(Draft) introduces a formal three-state lifecycle for individual spec features,
independent of the spec revision lifecycle:

| State | Meaning |
|---|---|
| **Active** | Feature is in the Current revision with no planned removal. |
| **Deprecated** | Feature remains in the spec but is scheduled for removal; migration path documented. |
| **Removed** | Feature deleted from `draft`; absent from the next Current revision. |

Key mechanics:
- Deprecating a feature requires its own SEP.
- The minimum deprecation window before a feature is *eligible* for removal is
  **12 months** from the revision in which it first becomes Deprecated.
- Removal itself is a Core Maintainer decision during release preparation; no
  second SEP is required.
- A formal `deprecated.mdx` registry will list all features in the Deprecated
  state with their earliest removal dates.
- Tier 1 SDKs (per SEP-1730) must mark the corresponding API surface deprecated
  using the language's native mechanism once the deprecating revision is Current.
- The term "soft-deprecated" is retired; existing uses are reclassified as
  Deprecated under this policy.

Under SEP-2596's transition clause, two already-informally-deprecated features
are grandfathered in when the SEP reaches Final: the **HTTP+SSE transport** and
the `includeContext: "thisServer"` / `"allServers"` values in
`sampling/createMessage`.

---

*Source pages: `learn/architecture.md`, `learn/versioning.md`,
`specification/2025-11-25/*` (multi-page subtree),
`community/sep-guidelines.md`, `seps/*`.*
