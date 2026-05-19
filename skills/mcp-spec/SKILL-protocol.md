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

### The `_meta` field

Requests and notifications MAY include a `_meta` key in `params` for
out-of-band metadata. The key is reserved — its values are not part of
the core message semantics.

**OpenTelemetry trace context** ([SEP-414](https://modelcontextprotocol.io/seps/414-request-meta.md) — Final):
W3C Trace Context keys `traceparent`, `tracestate`, and `baggage` MAY
appear directly in `_meta` (exception to the usual DNS-prefix convention
for `_meta` keys, for compatibility with existing OTel implementations).

```text
"_meta": { "traceparent": "00-0af7651916cd43dd8448eb211c80319c-00f067aa0ba902b7-01" }
```

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

> **Draft SEP — resource not found:** [SEP-2164](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md)
> proposes standardising `-32602` (Invalid Params) as the canonical JSON-RPC error code when a
> requested resource URI does not exist. Current SDK implementations are inconsistent (TypeScript
> uses `-32602`, most others use `-32002`). Until SEP-2164 is Final, clients SHOULD tolerate both
> `-32602` and `-32002` as resource-not-found indicators.

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

> **Draft SEP — feature lifecycle:** [SEP-2596](https://modelcontextprotocol.io/seps/2596-spec-feature-lifecycle-and-deprecation.md)
> proposes a formal lifecycle for individual spec features — **Active**, **Deprecated**, **Removed**
> — separate from the spec-revision lifecycle (Draft / Current / Final). Key points:
> - Deprecation requires a SEP; a minimum 12-month window before a feature is eligible for removal.
> - Removal is a Core Maintainer decision at release time (no second SEP needed).
> - Grandfathers the HTTP+SSE transport and `includeContext: "thisServer"/"allServers"` as already
>   Deprecated with a 3-month grace period once the SEP reaches Final.
> - Tier 1 SDKs must surface deprecated markers and runtime warnings within their next release.

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

Notable SEPs as of 2026-05-19:

**Final (normative):**

| SEP | Title | Topic |
|---|---|---|
| [SEP-414](https://modelcontextprotocol.io/seps/414-request-meta.md) | Document OpenTelemetry Trace Context Propagation Conventions | `traceparent`/`tracestate`/`baggage` in `_meta`; exception to DNS-prefix rule |

**Draft (not yet normative):**

| SEP | Title | Topic |
|---|---|---|
| [SEP-2596](https://modelcontextprotocol.io/seps/2596-spec-feature-lifecycle-and-deprecation.md) | Specification Feature Lifecycle and Deprecation Policy | Formal Active/Deprecated/Removed states for spec features; 12-month minimum window |
| [SEP-2164](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md) | Standardize Resource Not Found Error Code | Proposes `-32602` as canonical code; currently inconsistent across SDKs |
| [SEP-2106](https://modelcontextprotocol.io/seps/2106-json-schema-2020-12.md) | Tools `inputSchema` & `outputSchema` Conform to JSON Schema 2020-12 | Loosens schema restrictions; allows composition keywords and non-object `structuredContent` |

---

*Source pages: `learn/architecture.md`, `learn/versioning.md`,
`specification/2025-11-25/*` (multi-page subtree),
`community/sep-guidelines.md`, `seps/*`.*
