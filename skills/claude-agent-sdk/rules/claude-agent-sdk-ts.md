---
name: claude-agent-sdk-ts
description: Edit-time correctness rules for code using @anthropic-ai/claude-agent-sdk in TypeScript. Catches the mistakes most commonly logged in the upstream issue tracker — wrong hook shape, missing tool annotations, MCP transport-type confusion, Zod / structured-output pitfalls, and permission-mode interactions. Pairs with SKILL-typescript.md (the deep reference).
appliesTo:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
---

# Claude Agent SDK Rules — TypeScript

> *Edit-time corrections. For the full type definitions, options table,
> message-type catalog, and worked examples, see
> [`SKILL-typescript.md`](../SKILL-typescript.md). This file lists only
> the patterns Claude should rewrite on sight.*

## Package

- Package: `@anthropic-ai/claude-agent-sdk` (NOT `@anthropic-ai/claude-code`).
- Latest version is tracked in `state.json.registry.packages[]`; the
  daily research agent updates SKILL-typescript.md when it changes.

## Common Mistakes

### Hooks must be callback matchers, not direct functions

```typescript
// WRONG — direct function: silently never fires
hooks: { PreToolUse: async (input) => { ... } }

// CORRECT — matcher + hooks array
hooks: { PreToolUse: [{ matcher: 'Bash', hooks: [myCallback] }] }
```

See [`SKILL-typescript.md` § Hooks](../SKILL-typescript.md#hooks) for the
full `HookCallbackMatcher` type and the per-event matcher behavior
(some events ignore `matcher`).

### `canUseTool` allow-result MUST include `updatedInput`

```typescript
// WRONG — returns no input shape, silent failure
canUseTool: async (tool, input) => ({ behavior: "allow" })

// CORRECT
canUseTool: async (tool, input, { signal }) => ({
  behavior: "allow", updatedInput: input
})
```

Full `PermissionResult` union type:
[`SKILL-typescript.md` § Permissions § canUseTool](../SKILL-typescript.md#canusetool).

### `permissionDecision: 'deny'` causes API 400 — use `'allow'` with sentinel input

```typescript
// WRONG — breaks conversation history with "tool_use ids without tool_result"
return {
  hookSpecificOutput: {
    hookEventName: 'PreToolUse',
    permissionDecision: 'deny',
    permissionDecisionReason: 'Not allowed'
  }
};

// CORRECT — allow with modified input that no-ops the action
return {
  hookSpecificOutput: {
    hookEventName: 'PreToolUse',
    permissionDecision: 'allow',
    updatedInput: { command: `echo "BLOCKED: ${reason}"` }
  }
};
```

Background: SKILL-typescript.md § Hooks § Hook Return Values + KI #12.

### `allowedTools` is ignored under `bypassPermissions` mode

```typescript
// WRONG — allowedTools restriction is silently dropped
options: {
  allowedTools: ["Read", "Glob", "Grep"],
  permissionMode: "bypassPermissions",
  allowDangerouslySkipPermissions: true
}

// CORRECT — use default or acceptEdits mode for allowedTools to take effect
options: { allowedTools: [...], permissionMode: "default" }
```

Note in [`SKILL-typescript.md` § Permissions § PermissionMode](../SKILL-typescript.md#permissionmode).

### Subagents require `Agent` in `allowedTools`

```typescript
// WRONG — subagents won't be invocable
allowedTools: ["Read", "Write"],
agents: { reviewer: { ... } }

// CORRECT — subagents are invoked via the Agent tool (renamed from Task in earlier versions)
allowedTools: ["Read", "Write", "Agent"],
agents: { reviewer: { ... } }

// ALSO: never include "Agent" in a subagent's own tools — subagents cannot spawn subagents
```

See [`SKILL-typescript.md` § Subagents](../SKILL-typescript.md#subagents).

### MCP server config: `type` field is required for non-stdio transports

The only valid transport types are `'http'`, `'sse'`, `'sdk'`,
`'claudeai-proxy'` (and `'stdio'` which is the implicit default when
`type` is omitted and `command` is present). Common mistake: using
`type: "url"` (not a real type) or omitting `type` on URL servers.

```typescript
// WRONG — opaque "exit code 1" or silent no-op
mcpServers: { api: { url: "https://example.com/mcp" } }
mcpServers: { api: { type: "url", url: "https://example.com/mcp" } }

// CORRECT
mcpServers: { api: { type: "http", url: "https://example.com/mcp" } }
```

Full transport type table:
[`SKILL-typescript.md` § MCP Servers § Config Types](../SKILL-typescript.md#config-types).
Other MCP gotchas (Unicode sanitization, 5-min timeout, corporate
proxy issues) are catalogued at
[`SKILL-typescript.md` § MCP Gotchas](../SKILL-typescript.md#mcp-gotchas)
— consult that section for the full set of MCP failure modes.

### Sanitize MCP tool responses for Unicode line separators

```typescript
// WRONG — U+2028 / U+2029 corrupt the JSON protocol
async (args) => ({ content: [{ type: "text", text: rawOutput }] })

// CORRECT — strip before returning
async (args) => ({
  content: [{ type: "text", text: rawOutput.replace(/[  ]/g, ' ') }]
})
```

See KI #5 in [`SKILL-typescript.md` § MCP Gotchas](../SKILL-typescript.md#mcp-gotchas).

### Structured outputs: `outputFormat.schema` directly, not wrapped

```typescript
// WRONG — the old json_schema wrapper pattern
outputFormat: {
  type: "json_schema",
  json_schema: { name: "...", strict: true, schema: ... }
}

// CORRECT
outputFormat: { type: "json_schema", schema: myJsonSchema }
```

### Zod → JSON Schema must target draft-07

Claude requires JSON Schema draft-07; Zod defaults to draft-2020-12.

```typescript
// WRONG — schema rejected
outputFormat: { type: "json_schema", schema: z.toJSONSchema(MySchema) }

// CORRECT
outputFormat: { type: "json_schema",
  schema: z.toJSONSchema(MySchema, { target: "draft-07" }) }
```

Also: do NOT use the deprecated `zod-to-json-schema` package — Zod
v3.24.1+ / v4+ have built-in `z.toJSONSchema()`.

### `tool()` expects `AnyZodRawShape` (shape object), not a `ZodObject`

`tool()` accepts both Zod 3 and Zod 4 shape objects (`AnyZodRawShape`).
Pass `MySchema.shape` or an inline object literal — **not** the `ZodObject` itself.

```typescript
import { z } from 'zod';

// WRONG — handler receives only metadata, args is empty
const MySchema = z.object({ query: z.string() });
const myTool = tool("search", "Search", MySchema, handler);

// CORRECT — pass `.shape`
const myTool = tool("search", "Search", MySchema.shape, handler);

// ALSO CORRECT — define shape inline (works with Zod 3 and Zod 4)
const myTool = tool("search", "Search", { query: z.string() }, handler);
```

### No default system prompt or filesystem settings

SDK v0.1.0+ defaults: empty system prompt, no filesystem settings load.
Add explicitly when needed:

```typescript
options: {
  systemPrompt: { type: 'preset', preset: 'claude_code' },
  settingSources: ['project']
}
```

### Don't use `ANTHROPIC_LOG=debug` with the SDK

```typescript
// WRONG — corrupts the JSON protocol between SDK and CLI subprocess
env: { ANTHROPIC_LOG: 'debug' }

// CORRECT — use the SDK's built-in debug option
options: { debug: true, debugFile: '/tmp/agent.log' }
```

### `bun build --compile`: use `extractFromBunfs` instead of hardcoding `pathToClaudeCodeExecutable`

When bundling with `bun build --compile`, the CLI binary lives in the virtual filesystem
(`$bunfs`). Setting `pathToClaudeCodeExecutable` to a literal path fails. Use the dedicated
extract export instead (available since v0.3.158):

```typescript
// WRONG — path points to virtual bunfs, not a real file
options: { pathToClaudeCodeExecutable: "/bunfs/root/cli.js" }

// CORRECT — extract native binary at runtime
import { extractFromBunfs } from "@anthropic-ai/claude-agent-sdk/extract";
import nativeBin from "@anthropic-ai/claude-agent-sdk/claude-code-native" with { type: "file" };

const execPath = await extractFromBunfs(nativeBin);
const q = query({ prompt: "...", options: { pathToClaudeCodeExecutable: execPath } });
```

See KI #17 in [`SKILL-typescript.md`](../SKILL-typescript.md#17-sdk-fails-to-discover-cli-when-bundled-with-bun-build).

---

*This file lists edit-time correctable patterns. Background, full
types, and complete examples live in
[`SKILL-typescript.md`](../SKILL-typescript.md). When that surface and
this file disagree, the surface is canonical and this file is stale
— file an issue at
[xiaolai/anthropic-docs](https://github.com/xiaolai/anthropic-docs).*
