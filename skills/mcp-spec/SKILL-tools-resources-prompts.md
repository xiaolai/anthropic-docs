---
name: mcp-primitives
description: |
  Deep reference for the MCP primitives — tools (callable
  functions with input_schema / output_schema), resources
  (readable data with URI templates and MIME types), prompts
  (message templates with arguments), sampling (server asks
  client to LLM-sample), roots (filesystem scope), elicitation
  (server asks user for structured input), and completion
  (argument auto-complete for prompts and resource URIs).
source: https://modelcontextprotocol.io/specification/2025-11-25/server/
---

# MCP — Primitives (Tools, Resources, Prompts, Sampling, Roots, Elicitation, Completion)

> *Router lives in [`SKILL.md`](SKILL.md). For protocol framing of
> the requests below, see [`SKILL-protocol.md`](SKILL-protocol.md).
> For client-side handling, [`SKILL-clients.md`](SKILL-clients.md).
> For server-side implementation, [`SKILL-servers.md`](SKILL-servers.md).*

## Tools

A tool is a callable function the server exposes to the host LLM.

### Schema

```json
{
  "name": "search_files",
  "title": "Search Files",
  "description": "Search files matching a query",
  "inputSchema": {
    "type": "object",
    "properties": {
      "query": { "type": "string" },
      "maxResults": { "type": "integer", "minimum": 1, "maximum": 100 }
    },
    "required": ["query"]
  },
  "outputSchema": {
    "type": "object",
    "properties": {
      "results": {
        "type": "array",
        "items": { "type": "object", "properties": { "path": { "type": "string" } } }
      }
    }
  },
  "annotations": {
    "readOnlyHint": true,
    "destructiveHint": false,
    "idempotentHint": true,
    "openWorldHint": false
  },
  "execution": {
    "taskSupport": "optional"
  }
}
```

- `name` — unique identifier within the server (1–128 chars; allowed: `A-Za-z0-9_-.`; no spaces).
- `title` — optional human-readable display name for UI (distinct from `annotations.title`, which is deprecated in favor of this field).
- `description` — human-readable description for the LLM.
- `icons` — optional array of `{ src, mimeType, sizes[] }` objects for client UI display.
- `inputSchema` — JSON Schema defining expected parameters. Defaults to JSON Schema 2020-12 when no `$schema` field is present. For tools with no parameters, use `{ "type": "object", "additionalProperties": false }`.
- `outputSchema` — optional JSON Schema for the `structuredContent` field of the response.
- `annotations` — *non-binding* hints for clients (UI rendering, permission prompts). All Boolean fields default to safe-pessimistic values when absent.
- `execution.taskSupport` — optional. Values: `"forbidden"` (default), `"optional"`, `"required"`. Indicates whether this tool supports [task-augmented execution](https://modelcontextprotocol.io/specification/2025-11-25/basic/utilities/tasks) (experimental feature in `2025-11-25`).

> **JSON Schema 2020-12 is now the spec default** (as of `2025-11-25`):
> When no `$schema` field is present, `inputSchema` and `outputSchema` are interpreted
> as JSON Schema 2020-12. Servers that need draft-07 behaviour must include
> `"$schema": "http://json-schema.org/draft-07/schema#"` explicitly.
> Always include a `TextContent` fallback in `content` for backwards compatibility
> with clients that do not yet process `structuredContent`.

### Calling

```
→ tools/call { name, arguments }
← { content: [...], structuredContent?: {...}, isError?: false }
```

`content` is an array of content blocks:

- `{type: "text", text: "..."}`
- `{type: "image", data: "<base64>", mimeType: "image/png"}`
- `{type: "audio", data: "<base64>", mimeType: "audio/wav"}`
- `{type: "resource_link", uri, name?, description?, mimeType?}` — a *reference* to a resource (URI only; client fetches via `resources/read` if needed). Not guaranteed to appear in `resources/list`.
- `{type: "resource", resource: {...}}` — an *embedded* resource (full contents inline).

Errors at the *tool* level set `isError: true` with an error
description in `content` (client surfaces to LLM). Errors at the
*protocol* level (bad params, server crash) return a JSON-RPC
error response.

## Resources

A resource is readable data identified by a URI. The client lists,
optionally subscribes, and reads.

### Schema (static resource)

```json
{
  "uri": "file:///path/to/data.json",
  "name": "Data file",
  "title": "Application Data File",
  "description": "Application configuration",
  "mimeType": "application/json",
  "size": 4096
}
```

- `uri` — absolute URI (required).
- `name` — machine-friendly identifier.
- `title` — optional human-readable display name for UI.
- `description` — optional human-readable description.
- `mimeType` — optional MIME type.
- `size` — optional size in bytes.
- `icons` — optional array of `{ src, mimeType, sizes[] }` objects for client UI.

### Schema (resource template)

```json
{
  "uriTemplate": "github://repos/{owner}/{repo}/issues/{number}",
  "name": "GitHub issue",
  "title": "GitHub Issue Viewer",
  "description": "Fetch an issue by owner/repo/number",
  "mimeType": "application/json"
}
```

Resource templates also support `title` and `icons` fields.

Clients use templates with argument completion (see Completion below)
to construct concrete URIs.

### Reading

```
→ resources/read { uri }
← { contents: [{ uri, mimeType, text? | blob? }, ...] }
```

Text resources use `text`; binary resources use `blob` (base64).

### Error handling

If the requested resource does not exist, servers should return a
JSON-RPC error. The spec currently recommends `-32002`; however
[SEP-2164](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md)
(Draft) proposes changing this to `-32602` (Invalid Params) to align
with the TypeScript SDK and standard JSON-RPC semantics. Clients
should defensively handle both `-32002` and `-32602` as resource-not-found.
An empty `contents` array MUST NOT be used to signal non-existence.

### Subscriptions

If server declared `resources.subscribe`, clients can subscribe to a
resource and receive `notifications/resources/updated { uri }` when
its contents change.

## Prompts

A prompt is a server-provided message template the user can invoke.

### Schema

```json
{
  "name": "review_pr",
  "description": "Review a pull request",
  "arguments": [
    { "name": "owner", "description": "Repo owner", "required": true },
    { "name": "repo", "description": "Repo name", "required": true },
    { "name": "number", "description": "PR number", "required": true }
  ]
}
```

### Getting

```
→ prompts/get { name, arguments: { owner: "anthropic", repo: "claude-code", number: "1234" } }
← {
    description: "Review of anthropic/claude-code PR #1234",
    messages: [
      { role: "user", content: { type: "text", text: "..." } },
      ...
    ]
  }
```

The client renders the returned messages into the host's
conversation, typically as if the user had typed them.

## Sampling

`sampling/createMessage` — server asks the client to sample from
the host's LLM. Lets MCP servers leverage the host's model without
their own API key.

```
← sampling/createMessage {
    messages: [...],
    modelPreferences?: { hints: [...], costPriority, speedPriority, intelligencePriority },
    systemPrompt?, includeContext?, temperature?, maxTokens?, stopSequences?, metadata?,
    tools?: [...],        // optional: tool definitions for agentic sampling (SEP-1577)
    toolChoice?: { mode: "auto" | "none" }  // default: "auto"
  }
→ {
    role: "assistant",
    content: { type: "text", text: "..." },
    model, stopReason
  }
```

The client typically asks the user for permission before fulfilling
sampling requests — servers can effectively spend the user's tokens
otherwise.

**Sampling with tools (SEP-1577, `2025-11-25`+):** Servers may include `tools` and
`toolChoice` to enable agentic multi-turn sampling where the LLM can call tools, receive
results, and continue — all within the sampling flow. Clients MUST declare
`capabilities.sampling.tools: {}` to receive tool-enabled sampling requests.
`toolChoice.mode: "none"` forces a final text response without tool calls.
Source: [`specification/2025-11-25/client/sampling.md`](https://modelcontextprotocol.io/specification/2025-11-25/client/sampling.md)

## Roots

A root is a filesystem scope the host is operating in. Server uses
roots to know where to look without hardcoding paths.

```
← roots/list
→ { roots: [{ uri: "file:///path", name?: "My project" }, ...] }
```

If the client declared `roots.listChanged`, it can notify when
roots change:

```
→ notifications/roots/list_changed
```

## Elicitation

`elicitation/create` — server asks the user for structured input
via the host's UI.

```
← elicitation/create {
    message: "Which environment should I deploy to?",
    requestedSchema: {
      type: "object",
      properties: {
        env: { type: "string", enum: ["staging", "production"] },
        confirm: { type: "boolean" }
      }
    }
  }
→ { action: "accept" | "decline" | "cancel", content?: { env: "staging", confirm: true } }
```

The host renders an appropriate UI (form, dialog).

### URL mode elicitation (SEP-1036, `2025-11-25`+)

For out-of-band interactions (OAuth flows, payment, sensitive data entry) that must
**not** pass through the MCP client, servers use `mode: "url"`:

```
← elicitation/create {
    mode: "url",
    message: "Please authorize access to your GitHub account",
    url: "https://github.com/login/oauth/authorize?...",
    elicitationId: "550e8400-e29b-41d4-a716-446655440000"
  }
→ { action: "accept" | "decline" | "cancel" }
```

The client shows the URL to the user; the user opens it externally. When the server
detects completion it MAY send `notifications/elicitation/complete { elicitationId }`.
This is **not** for authorizing MCP client access (that uses OAuth); it is for the
server obtaining user authorization on behalf of itself.

Source: [`specification/2025-11-25/client/elicitation.md`](https://modelcontextprotocol.io/specification/2025-11-25/client/elicitation.md)

## Completion

Argument completion for prompts and resource URI templates:

```
→ completion/complete {
    ref: { type: "ref/prompt" | "ref/resource", name | uri },
    argument: { name, value: "<partial>" }
  }
← { completion: { values: [...], total?, hasMore? } }
```

The client uses this to populate auto-complete UI when the user is
filling in prompt arguments or resource URI parameters.

## Server vs client primitives

The spec splits primitives by who initiates:

| Initiated by | Primitives |
|---|---|
| **Client → Server** | tools, resources, prompts, completion |
| **Server → Client** | sampling, roots, elicitation, logging |

A given server may use both directions; each requires the
corresponding capability declaration.

## Source pages

| Path | Topic |
|---|---|
| [`specification/2025-11-25/server/tools.md`](https://modelcontextprotocol.io/specification/2025-11-25/server/) | Tools spec |
| [`specification/2025-11-25/server/resources.md`](https://modelcontextprotocol.io/specification/2025-11-25/server/) | Resources spec |
| [`specification/2025-11-25/server/prompts.md`](https://modelcontextprotocol.io/specification/2025-11-25/server/) | Prompts spec |
| [`specification/2025-11-25/client/sampling.md`](https://modelcontextprotocol.io/specification/2025-11-25/client/) | Sampling spec |
| [`specification/2025-11-25/client/roots.md`](https://modelcontextprotocol.io/specification/2025-11-25/client/) | Roots spec |
| [`specification/2025-11-25/client/elicitation.md`](https://modelcontextprotocol.io/specification/2025-11-25/client/) | Elicitation spec |
| [`specification/2025-11-25/server/utilities/completion.md`](https://modelcontextprotocol.io/specification/2025-11-25/server/) | Completion spec |

Plus the conceptual overviews:

- [`learn/server-concepts.md`](https://modelcontextprotocol.io/docs/learn/server-concepts.md)
- [`learn/client-concepts.md`](https://modelcontextprotocol.io/docs/learn/client-concepts.md)

---

*Source pages: `specification/2025-11-25/{client,server}/*`,
`specification/2025-11-25/basic/utilities/tasks.md`,
`docs/learn/{client,server}-concepts.md`,
`seps/2164-resource-not-found-error.md`.*
