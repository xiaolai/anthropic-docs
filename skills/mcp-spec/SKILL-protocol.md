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

### `clientInfo` / `serverInfo` fields (as of `2025-11-25`)

Both `clientInfo` (sent by client) and `serverInfo` (returned by server) share the same
shape:

| Field | Type | Description |
|---|---|---|
| `name` | string (required) | Machine-friendly identifier |
| `version` | string (required) | Implementation version |
| `title` | string (optional) | Human-readable display name for UI |
| `description` | string (optional) | Human-readable description |
| `icons` | array (optional) | `[{ src, mimeType, sizes[] }]` for display in client UI |
| `websiteUrl` | string (optional) | URL for the implementation's website |

Source: [`specification/2025-11-25/basic/lifecycle.md`](https://modelcontextprotocol.io/specification/2025-11-25/basic/lifecycle.md)

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
- `tasks` *(experimental, `2025-11-25`)* — supports task-augmented requests from clients. Sub-capabilities: `tasks.list` (supports `tasks/list`), `tasks.cancel` (supports `tasks/cancel`), `tasks.requests.tools.call` (clients may augment `tools/call` with a task). See also `execution.taskSupport` on individual tools in [`SKILL-tools-resources-prompts.md`](SKILL-tools-resources-prompts.md#tools). Source: [`specification/2025-11-25/basic/utilities/tasks.md`](https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/tasks.md).
- `extensions` — declares supported optional extensions (see below).

**Client capabilities** (subset):
- `sampling` — server may request the client to sample from the host LLM. Sub-capability: `tools` — declare `{ "sampling": { "tools": {} } }` to receive tool-enabled sampling requests (SEP-1577; see [`SKILL-tools-resources-prompts.md`](SKILL-tools-resources-prompts.md#sampling)).
- `roots` — server may request the list of filesystem roots, optionally with `listChanged`.
- `elicitation` — server may request input from the user. Sub-capabilities: `form` (structured data, flat JSON schema) and/or `url` (out-of-band URL navigation for sensitive flows). Empty `{}` is treated as `form`-only for backwards compatibility.
- `tasks` *(experimental, `2025-11-25`)* — supports task-augmented requests from servers. Sub-capabilities: `tasks.list`, `tasks.cancel`, `tasks.requests.sampling.createMessage` (servers may augment `sampling/createMessage` with a task), `tasks.requests.elicitation.create` (servers may augment `elicitation/create` with a task). Source: [`specification/2025-11-25/basic/utilities/tasks.md`](https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/tasks.md).
- `extensions` — declares supported optional extensions (see below).

### Extension capability field

Both clients and servers may advertise optional protocol extensions in an
`extensions` object within their capabilities during the `initialize`
handshake. Extension identifiers use the format `{vendor-prefix}/{name}`,
where official extensions use the `io.modelcontextprotocol` prefix
(e.g., `io.modelcontextprotocol/ui`). Third-party extensions should use a
reversed domain name you own as the prefix.

```json
{
  "capabilities": {
    "roots": { "listChanged": true },
    "extensions": {
      "io.modelcontextprotocol/ui": {
        "mimeTypes": ["text/html;profile=mcp-app"]
      }
    }
  }
}
```

Extensions are always **disabled by default** and require explicit opt-in.
If one side supports an extension but the other doesn't, the supporting
side must either fall back to core protocol behavior or reject the
connection with an appropriate error if the extension is mandatory.

#### Per-request capabilities

Some extension implementations use **per-request** capability declarations via
an `io.modelcontextprotocol/clientCapabilities` key inside the request's `_meta`
object. This pattern was used by earlier drafts of MCP Tasks, but is not used
by the `2025-11-25` core-protocol Tasks implementation, which uses initialization-time
capability negotiation instead.

> **Note on MCP Tasks:** As of `2025-11-25`, Tasks are a core protocol feature
> (not an extension). Clients opt in per-request by including `task: { ttl }` in
> request params, not via `_meta` extension capabilities. See
> [`SKILL-servers.md`](SKILL-servers.md#mcp-tasks-experimental-2025-11-25).

Official extensions and their identifiers:

| Identifier | Extension | Description |
|---|---|---|
| `io.modelcontextprotocol/ui` | [MCP Apps](https://modelcontextprotocol.io/extensions/apps/overview.md) | Interactive HTML UI in clients |
| `io.modelcontextprotocol/oauth-client-credentials` | [OAuth Client Credentials](https://modelcontextprotocol.io/extensions/auth/oauth-client-credentials.md) | Machine-to-machine auth |
| `io.modelcontextprotocol/enterprise-managed-authorization` | [Enterprise Auth](https://modelcontextprotocol.io/extensions/auth/enterprise-managed-authorization.md) | Centralized IdP access control |
| `io.modelcontextprotocol/tasks` | [MCP Tasks](https://modelcontextprotocol.io/extensions/tasks/overview.md) | Async long-running task handles — **now a core protocol feature in `2025-11-25`** (not just an extension); see [`SKILL-servers.md`](SKILL-servers.md#mcp-tasks-experimental-2025-11-25) |

Source: [`extensions/overview.md`](https://modelcontextprotocol.io/extensions/overview.md),
[`extensions/client-matrix.md`](https://modelcontextprotocol.io/extensions/client-matrix.md).

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
| -32042 | `URLElicitationRequiredError` — server cannot proceed until user completes a URL-mode elicitation (opens the provided URL out-of-band). Client should retry the request after the user completes the flow. |
| -32003 | `MissingRequiredClientCapabilityError` — server requires a client capability (e.g. Tasks) that the client did not declare. *(draft spec only, not in `2025-11-25`)* |
| -32004 | `UnsupportedProtocolVersionError` — the client's requested protocol version is not supported by the server. *(draft spec only; stable `2025-11-25` uses `-32602` for this case per [SEP-2575](https://modelcontextprotocol.io/seps/2575-stateless-mcp.md))* |
| -32000…-32099 | Implementation-defined server errors (range also used for MCP-reserved codes above) |

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

Notable recently-tracked SEPs (as of 2026-05-21):

| SEP | Title | Status | Affects |
|---|---|---|---|
| [SEP-2106](https://modelcontextprotocol.io/seps/2106-json-schema-2020-12.md) | JSON Schema 2020-12 as default dialect — now incorporated in spec `2025-11-25` | Final (incorporated) | Tools primitive — `inputSchema`, `outputSchema`, `structuredContent` |
| [SEP-2164](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md) | Standardize resource-not-found error code to `-32602` | Draft | Error codes, Resources error handling |
| [SEP-2575](https://modelcontextprotocol.io/seps/2575-stateless-mcp.md) | Make MCP Stateless — introduces `-32004` (UNSUPPORTED_PROTOCOL_VERSION) in draft spec | Accepted | Draft error codes; sessionless and stateless operation |
| [SEP-2577](https://modelcontextprotocol.io/seps/2577-deprecate-roots-sampling-and-logging.md) | Deprecate Roots, Sampling, and Logging — effective in next spec revision (expected July 2026) | **Final** | Roots (`roots/list`), Sampling (`sampling/createMessage`), Logging (`logging/setLevel`, `notifications/message`) |
| [SEP-2596](https://modelcontextprotocol.io/seps/2596-spec-feature-lifecycle-and-deprecation.md) | Specification feature lifecycle and deprecation policy | Draft | Governance process; grandfathers HTTP+SSE transport and `includeContext: "thisServer"/"allServers"` as formally Deprecated |
| [SEP-2322](https://modelcontextprotocol.io/seps/2322-MRTR.md) | Multi Round-Trip Requests — replaces SSE for server-initiated requests (elicitation, sampling) during a client call; breaking change | Accepted | Transport; elicitation and sampling in tool-call context |
| [SEP-2549](https://modelcontextprotocol.io/seps/2549-TTL-for-list-results.md) | TTL for List Results — adds `ttlMs` and `cacheScope` fields to `tools/list`, `resources/list`, `prompts/list`, and `resources/read` responses | Accepted | List response schema; caching |
| [SEP-2567](https://modelcontextprotocol.io/seps/2567-sessionless-mcp.md) | Sessionless MCP via Explicit State Handles — removes `Mcp-Session-Id` and session-scoped state; complements SEP-2575 | **Final** | Session handling; transport headers |
| [SEP-2663](https://modelcontextprotocol.io/seps/2663-tasks-extension.md) | Tasks Extension — formally defines the async-task extension (`tasks/get`, `tasks/update`, `tasks/cancel`; `resultType: "task"` discriminator) as an Extensions Track SEP | **Final** | MCP Tasks extension (already tracked in [`SKILL-tools-resources-prompts.md`](SKILL-tools-resources-prompts.md#tools)) |

SEP-2596 also introduces the concept of a **deprecated registry** (`deprecated.mdx`) listing
every feature in the Deprecated state, their migration targets, and earliest removal dates.
When it reaches Final, the minimum deprecation window is 12 months measured from the revision
release in which the feature is first marked Deprecated.

**SEP-2549 schema additions (Accepted, not yet in `2025-11-25`):** The following fields will be added to list and read responses when SEP-2549 is incorporated:
- `ttlMs` (integer, optional) — how many milliseconds the response may be cached before re-fetching.
- `cacheScope` (`"session"` | `"user"` | `"global"`, optional) — controls who may cache the response.

---

*Source pages: `learn/architecture.md`, `learn/versioning.md`,
`specification/2025-11-25/*` (multi-page subtree),
`community/sep-guidelines.md`, `seps/*`
(including `seps/2106-json-schema-2020-12.md`,
`seps/2164-resource-not-found-error.md`,
`seps/2322-MRTR.md`,
`seps/2549-TTL-for-list-results.md`,
`seps/2567-sessionless-mcp.md`,
`seps/2596-spec-feature-lifecycle-and-deprecation.md`,
`seps/2663-tasks-extension.md`).*
