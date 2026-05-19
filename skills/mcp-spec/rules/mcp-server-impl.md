---
name: mcp-spec-server-impl
description: Edit-time rules for MCP server implementations using @modelcontextprotocol/sdk (TypeScript) or mcp (Python). Catches capability negotiation omissions, tool annotation mistakes, transport mismatches, and protocol-version pinning errors.
appliesTo:
  - "**/mcp-server*.ts"
  - "**/mcp_server*.py"
  - "**/server.ts"
  - "**/server.py"
  - "**/*mcp*server*.ts"
  - "**/*mcp*server*.py"
---

# MCP Server Implementation Rules

## Rule 1 — Declare capabilities you actually implement

The server's `capabilities` object during the `initialize` response
MUST list exactly what handlers you registered. Clients only invoke
methods you advertise.

**WRONG (advertised but not implemented):**
```typescript
server.setRequestHandler(InitializeRequestSchema, async () => ({
  protocolVersion: "2025-11-25",
  capabilities: { tools: {}, resources: {}, prompts: {} },  // ← claims all three
  serverInfo: { name: "my-server", version: "1.0.0" }
}));
// ... only implements tools/* handlers — resources and prompts requests crash
```

**RIGHT:**
```typescript
// Only advertise what you handle:
capabilities: { tools: {} }
```

## Rule 2 — Use the SDK's helpers, not raw JSON-RPC

Both SDKs provide `Server` / `McpServer` classes that handle framing,
lifecycle, and capability advertisement. Writing raw JSON-RPC is
both more code and more bug-prone (especially around the
`notifications/initialized` handshake).

```typescript
// PREFER
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
const server = new Server({ name: "my-server", version: "1.0.0" }, { capabilities: { tools: {} } });

// vs writing your own readline+JSON.parse loop
```

```python
# PREFER
from mcp.server import Server
from mcp.server.stdio import stdio_server
```

## Rule 3 — Tool annotations and display name: declare safety properties explicitly

Tool annotations default to safe-pessimistic when absent (`destructive`
treated as true, `readOnly` treated as false). Clients use these to
decide permission prompts. Set them explicitly for accurate UX.

Since spec `2025-11-25`, use the top-level `title` field (not
`annotations.title`) as the human-readable display name:

```typescript
tools: [{
  name: "search_files",
  title: "Search Files",            // ← top-level title (spec-preferred, 2025-11-25+)
  description: "Search files by name",
  inputSchema: { type: "object", properties: { query: { type: "string" } } },
  annotations: {
    // annotations.title is deprecated in favour of the top-level title field
    readOnlyHint: true,
    destructiveHint: false,
    idempotentHint: true,
    openWorldHint: false
  }
}]
```

`openWorldHint: true` means "operates on the public internet" (search,
public APIs). False = "scoped to the user's local / private resources."

## Rule 4 — Pin the protocol version, accept negotiation

Hardcode the protocol version you tested against:

```typescript
const PROTOCOL_VERSION = "2025-11-25";
```

The server's `initialize` response includes this; the client may send
a different version and the SDK handles negotiation. **Don't echo
the client's version back blindly** — declare what you support.

## Rule 5 — stdio servers use stdin/stdout only

stderr is for logs (human-readable). stdin/stdout are JSON-RPC ONLY.
Any `console.log` / `print` to stdout will corrupt the protocol stream.

```typescript
// WRONG — corrupts stdout
console.log("Server starting");

// RIGHT — log to stderr
console.error("Server starting");
```

```python
# WRONG
print("Server starting")

# RIGHT
import sys
print("Server starting", file=sys.stderr)
```

## Rule 6 — Resource URIs must be absolute and use a real scheme

Resources are identified by URIs. The URI must be absolute and use a
real scheme. Common patterns:

- `file:///absolute/path/to/file`
- `https://api.example.com/resource/123`
- `your-app://entity/12345` (custom scheme — fine, must be consistent)

Relative paths (`./foo.json`) and bare strings (`foo.json`) are
rejected by spec-compliant clients.

## Rule 7 — `tools/call` errors: tool-level vs protocol-level

Two error patterns:

- **Tool-level** (the tool ran, but produced an error result):
  ```json
  { "content": [{"type": "text", "text": "Error: file not found"}], "isError": true }
  ```
  Client surfaces this to the LLM, which can react and retry.

- **Protocol-level** (the call itself failed — bad params, server crash):
  ```json
  { "error": { "code": -32602, "message": "Invalid params" } }
  ```
  Client treats this as a hard failure.

Don't conflate — throwing exceptions from a tool handler typically
maps to protocol-level errors, but business-logic failures should
return `isError: true` with a useful text content.

## Rule 8 — Subscriptions require `resources.subscribe` capability

`resources/subscribe` only works if the server declared
`capabilities.resources.subscribe = true`. The SDK doesn't warn you
if you implement the handler without declaring the capability — the
client just never sends subscribe requests.

```typescript
capabilities: {
  resources: { subscribe: true, listChanged: true }
}
```

---

*Source: modelcontextprotocol.io/specification/2025-11-25 +
modelcontextprotocol/typescript-sdk + modelcontextprotocol/python-sdk
issue trackers.*
