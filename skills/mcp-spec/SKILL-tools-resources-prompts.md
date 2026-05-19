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
  "icons": [
    { "src": "https://example.com/search-icon.png", "mimeType": "image/png", "sizes": ["48x48"] }
  ],
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

- `name` — unique identifier within the server (1–128 chars;
  allowed chars: `A-Za-z0-9_-.`; no spaces or commas). Source:
  [SEP-986](https://modelcontextprotocol.io/seps/986-specify-format-for-tool-names.md).
- `title` — optional human-readable display name distinct from `name`
  (top-level field, **not** inside `annotations`). Source: [SEP-973](https://modelcontextprotocol.io/seps/973-expose-additional-metadata-for-implementations-res.md).
- `inputSchema` — JSON Schema 2020-12 by default (omit `$schema` to use
  the default; add `"$schema": "http://json-schema.org/draft-07/schema#"`
  to override). MUST be a valid object schema; for no-param tools use
  `{"type":"object","additionalProperties":false}`.
- `outputSchema` — optional. When present, the response's
  `structuredContent` MUST conform to this schema.
- `icons` — optional array of `{src, mimeType, sizes}` for UI display.
  Applies to tools, resources, resource templates, and prompts. Source: [SEP-973](https://modelcontextprotocol.io/seps/973-expose-additional-metadata-for-implementations-res.md).
- `annotations` — *non-binding* hints for clients (UI rendering,
  permission prompts). All Boolean fields default to safe-pessimistic
  values when absent.
- `execution.taskSupport` — declares task-augmented execution support.
  Values: `"forbidden"` (default), `"optional"`, `"required"`. Source:
  [SEP-1686](https://modelcontextprotocol.io/seps/1686-tasks.md).

### Calling

```
→ tools/call { name, arguments }
← { content: [...], structuredContent?: {...}, isError?: false }
```

`content` is an array of content blocks:

- `{type: "text", text: "..."}`
- `{type: "image", data: "<base64>", mimeType: "image/png"}`
- `{type: "audio", data: "<base64>", mimeType: "audio/wav"}`
- `{type: "resource", resource: {...}}` — embed a resource by reference.

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
  "title": "Data File",
  "description": "Application configuration",
  "mimeType": "application/json",
  "icons": [
    { "src": "https://example.com/file-icon.png", "mimeType": "image/png", "sizes": ["48x48"] }
  ]
}
```

- `title` — optional human-readable display name (top-level, same as tools). Source: [SEP-973](https://modelcontextprotocol.io/seps/973-expose-additional-metadata-for-implementations-res.md).
- `icons` — optional array of icons for UI display. Source: [SEP-973](https://modelcontextprotocol.io/seps/973-expose-additional-metadata-for-implementations-res.md).

### Schema (resource template)

```json
{
  "uriTemplate": "github://repos/{owner}/{repo}/issues/{number}",
  "name": "GitHub issue",
  "title": "GitHub Issue",
  "description": "Fetch an issue by owner/repo/number",
  "mimeType": "application/json"
}
```

Clients use templates with argument completion (see Completion below)
to construct concrete URIs.

### Reading

```
→ resources/read { uri }
← { contents: [{ uri, mimeType, text? | blob? }, ...] }
```

Text resources use `text`; binary resources use `blob` (base64).

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
    tools?: [...],
    toolChoice?: { type: "auto" | "any" | "tool", name? }
  }
→ {
    role: "assistant",
    content: { type: "text", text: "..." } | { type: "tool_use", ... },
    model, stopReason
  }
```

The client typically asks the user for permission before fulfilling
sampling requests — servers can effectively spend the user's tokens
otherwise.

### Sampling capabilities

```json
{ "capabilities": { "sampling": {} } }                      // basic
{ "capabilities": { "sampling": { "tools": {} } } }         // with tool use (SEP-1577)
```

Clients MUST declare `sampling.tools` to receive sampling requests
that include a `tools` array. `includeContext` values `"thisServer"` and
`"allServers"` are **soft-deprecated** — servers should omit `includeContext`
(defaults to `"none"`).

Source: [`client/sampling.md`](https://modelcontextprotocol.io/specification/2025-11-25/client/sampling.md),
[SEP-1577](https://modelcontextprotocol.io/seps/1577--sampling-with-tools.md).

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
`docs/learn/{client,server}-concepts.md`.*
