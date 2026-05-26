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

> **Deprecation notice:** [SEP-2577](https://modelcontextprotocol.io/seps/2577-deprecate-roots-sampling-and-logging.md) (Final) marks `logging/setLevel` and `notifications/message` for deprecation in the next spec revision (expected June 2026). Wire-level behavior is unchanged until removal.

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
| `sampling/createMessage` | Ask client to LLM-sample (uses host's API key) *(deprecated — see SEP-2577)* |
| `roots/list` | Ask client for filesystem roots *(deprecated — see SEP-2577)* |
| `elicitation/create` | Ask user for structured input via the host |

## Build with Agent Skills

[`develop/build-with-agent-skills.md`](https://modelcontextprotocol.io/docs/develop/build-with-agent-skills.md)
covers using agent skills to guide AI coding assistants through
MCP server design and implementation. The
[`mcp-server-dev` plugin](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/mcp-server-dev)
provides three composing skills:

| Skill | Purpose |
|---|---|
| `build-mcp-server` | Entry point — picks deployment model, routes to specialized skills |
| `build-mcp-app` | Adds interactive UI widgets via MCP Apps extension |
| `build-mcpb` | Packages a local stdio server as a redistributable `.mcpb` bundle |

**Four deployment paths** the skill recommends:
- **Remote Streamable HTTP** — default for cloud API wrappers (zero install, OAuth-friendly).
- **MCP Apps** — adds interactive UI (forms, dashboards, pickers) rendered in chat.
- **[MCP Bundles (MCPB)](https://github.com/modelcontextprotocol/mcpb)** — packages a local server with its Node/Python runtime into a single `.mcpb` archive; users install without setting up a runtime environment.
- **Local stdio** — prototyping and dev; upgrade path to MCPB for distribution.

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

### MCP Tasks (experimental, `2025-11-25`)

MCP Tasks is an **experimental** core protocol feature (as of `2025-11-25`) that lets
servers return a **durable task handle** instead of blocking on long-running operations
(CI pipelines, batch jobs, human-approval gates).

**Capability declaration (initialization time):**

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

**How it works:**

1. Client and server exchange `tasks` capabilities at initialization (see
   [`SKILL-protocol.md`](SKILL-protocol.md#capability-negotiation)).
2. Client includes `task: { ttl: <ms> }` in the request params to opt in to
   task execution (e.g., inside `tools/call` params).
3. Server returns `CreateTaskResult` containing a `task` object:
   `{ taskId, status, statusMessage?, createdAt, lastUpdatedAt, ttl, pollInterval? }`.
4. Client polls via `tasks/get { taskId }` for status updates.
5. Client calls `tasks/result { taskId }` to retrieve the final result (blocks
   until a terminal status is reached).
6. If status is `input_required`, server sends a request to the client with
   `io.modelcontextprotocol/related-task` in `_meta`; client calls
   `tasks/result` preemptively to receive the associated request.
7. Client may cancel via `tasks/cancel { taskId }` (cooperative — server may ignore).

**Task lifecycle states:**

| Status | Meaning |
|---|---|
| `working` | Operation in progress |
| `input_required` | Server paused; waiting for client to fulfill an associated request |
| `completed` | Done; retrieve result via `tasks/result` |
| `failed` | Error; `tasks/result` returns a JSON-RPC error response |
| `cancelled` | Cancelled (not guaranteed) |

`completed`, `failed`, and `cancelled` are terminal — task state does not
change after reaching them.

**Task association:** All requests, responses, and notifications related to a
task MUST include `io.modelcontextprotocol/related-task: { taskId }` in their
`_meta` field (except `tasks/get`, `tasks/result`, `tasks/cancel` which use the
`taskId` param directly).

**Push notifications (optional):** Servers MAY push status updates via
`notifications/tasks/status { taskId, status, statusMessage? }`. Clients opt into
these via the `subscriptions/listen` mechanism. Polling via `tasks/get` is the
default; notifications are an optimization that eliminates the need for an extra
`tasks/get` round-trip.

Source: [`specification/2025-11-25/basic/utilities/tasks.md`](https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/tasks.md).

### Tasks Extension (`io.modelcontextprotocol/tasks`) — distinct from above

The **Tasks Extension** (SEP-2663, Final) is **separate** from the core protocol
Tasks utility above. It uses the extensions framework with a different opt-in mechanism
and different polling API:

| Aspect | Core protocol Tasks (above) | Tasks Extension |
|---|---|---|
| Opt-in | `task: { ttl }` in request params | Per-request `_meta.io.modelcontextprotocol/clientCapabilities.extensions` |
| Get result | `tasks/result` (blocking) | `tasks/get` (returns result when `completed`) |
| Mid-flight input | Server sends request with `io.modelcontextprotocol/related-task` | `tasks/update { taskId, inputResponses }` |
| Result shape | Native request result shape | `CreateTaskResult` with `resultType: "task"` discriminator |

The extension is specified in [`experimental-ext-tasks`](https://github.com/modelcontextprotocol/experimental-ext-tasks).
Source: [`extensions/tasks/overview.md`](https://modelcontextprotocol.io/extensions/tasks/overview.md).

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
