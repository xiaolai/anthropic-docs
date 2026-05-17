---
paths: "**/*agent*.ts"
description: Auto-corrections for Claude Agent SDK v0.2.77
---

# Claude Agent SDK Rules

## Package
- Package: `@anthropic-ai/claude-agent-sdk` (NOT `@anthropic-ai/claude-code`)
- Latest: v0.2.77

## Common Mistakes

### Hooks are callback matchers, not direct functions
```typescript
// WRONG
hooks: { PreToolUse: async (input) => { ... } }

// CORRECT
hooks: { PreToolUse: [{ matcher: 'Bash', hooks: [myCallback] }] }
```

### canUseTool returns PermissionResult, not simple objects
```typescript
// WRONG — missing updatedInput causes silent failure
canUseTool: async (tool, input) => ({ behavior: "allow" })

// CORRECT — always include updatedInput when allowing
canUseTool: async (tool, input, { signal }) => ({
  behavior: "allow", updatedInput: input
})
```

### Structured outputs use outputFormat.schema directly
```typescript
// WRONG (old pattern)
outputFormat: { type: "json_schema", json_schema: { name: "...", strict: true, schema: ... } }

// CORRECT
outputFormat: { type: "json_schema", schema: myJsonSchema }
```

### Zod schema conversion
```typescript
// WRONG (old library)
import { zodToJsonSchema } from "zod-to-json-schema";

// CORRECT (built-in Zod v3.24.1+ / v4+)
const jsonSchema = z.toJSONSchema(myZodSchema, { target: "draft-07" });
```

### Structured output with Zod requires draft-07 target
```typescript
// WRONG — Claude requires JSON Schema draft-07, but Zod defaults to draft-2020-12
outputFormat: {
  type: "json_schema",
  schema: z.toJSONSchema(MySchema)  // Missing target parameter
}

// CORRECT — specify draft-07 target
outputFormat: {
  type: "json_schema",
  schema: z.toJSONSchema(MySchema, { target: "draft-07" })
}
```

### URL-based MCP servers require type field
```typescript
// WRONG — causes cryptic "exit code 1"
mcpServers: { api: { url: "https://example.com/mcp" } }

// CORRECT
mcpServers: { api: { type: "http", url: "https://example.com/mcp" } }
```

### No default system prompt or settings
```typescript
// SDK v0.1.0+ defaults: no system prompt, no filesystem settings
// Add explicitly if needed:
systemPrompt: { type: 'preset', preset: 'claude_code' },
settingSources: ['project']
```

### Subagents require Task in allowedTools
```typescript
// WRONG — subagents won't be invocable
allowedTools: ["Read", "Write"],
agents: { reviewer: { ... } }

// CORRECT
allowedTools: ["Read", "Write", "Task"],
agents: { reviewer: { ... } }
```

### allowedTools doesn't work with bypassPermissions mode
```typescript
// WRONG — allowedTools is ignored, Claude can still use Edit/Write/Bash
options: {
  allowedTools: ["Read", "Glob", "Grep"],
  permissionMode: "bypassPermissions",
  allowDangerouslySkipPermissions: true
}

// CORRECT — use default or acceptEdits mode for allowedTools to work
options: {
  allowedTools: ["Read", "Glob", "Grep"],
  permissionMode: "default"
}
```

### thinking: { type: 'adaptive' } — now fixed (v0.2.40+)
```typescript
// CORRECT (v0.2.40+) — adaptive thinking works as expected
thinking: { type: 'adaptive' }, effort: 'medium'

// Also valid — explicit budget for older models or fine-grained control
thinking: { type: 'enabled', budgetTokens: 10000 }

// Deprecated but functional
maxThinkingTokens: 10000, effort: 'medium'
```

### permissionDecision: 'deny' causes API 400 error
```typescript
// WRONG — breaks conversation history, causes "tool_use ids without tool_result" error
return {
  hookSpecificOutput: {
    hookEventName: 'PreToolUse',
    permissionDecision: 'deny',
    permissionDecisionReason: 'Not allowed'
  }
};

// CORRECT — use 'allow' with modified input that blocks the action
return {
  hookSpecificOutput: {
    hookEventName: 'PreToolUse',
    permissionDecision: 'allow',
    updatedInput: { command: `echo "BLOCKED: ${reason}"` }
  }
};
```

### Sanitize MCP tool responses for Unicode line separators
```typescript
// WRONG — U+2028/U+2029 in tool results corrupts SDK JSON protocol
async (args) => ({
  content: [{ type: "text", text: rawOutput }]
})

// CORRECT — sanitize before returning
async (args) => ({
  content: [{ type: "text", text: rawOutput.replace(/[\u2028\u2029]/g, ' ') }]
})
```

### Don't use ANTHROPIC_LOG=debug with SDK
```typescript
// WRONG — corrupts JSON protocol between SDK and CLI
env: { ANTHROPIC_LOG: 'debug' }

// CORRECT — use SDK's built-in debug options
options: { debug: true, debugFile: '/tmp/agent.log' }
```

### MCP server type: "url" is not a valid transport type
```typescript
// WRONG — type: "url" doesn't exist, causes silent failure (no error, no output)
mcpServers: {
  "my-server": { type: "url", url: "https://mcp.example.com/mcp" }
}

// CORRECT — use "http" for HTTP/Streamable HTTP servers
mcpServers: {
  "my-server": { type: "http", url: "https://mcp.example.com/mcp" }
}

// Valid MCP server types: (none/'stdio'), 'http', 'sse', 'sdk', 'claudeai-proxy'
```

### tool() requires ZodRawShape, not ZodObject
```typescript
// WRONG — passing ZodObject makes inputSchema undefined, handler receives only metadata
import { z } from 'zod';
const MySchema = z.object({ query: z.string() });
const myTool = tool("search", "Search", MySchema, handler);
// handler receives: (args={signal, _meta, requestId}, extra=undefined)

// CORRECT — pass the shape property, not the ZodObject instance
const MySchema = z.object({ query: z.string() });
const myTool = tool("search", "Search", MySchema.shape, handler);
// handler receives: (args={query: "..."}, extra=transportContext)

// ALSO CORRECT — define shape inline
const myTool = tool("search", "Search", { query: z.string() }, handler);
```
