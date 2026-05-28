---
name: claude-code-mcp-edits
description: Auto-correction rules that fire when Claude edits .mcp.json. Catches transport-mismatch errors, missing capability fields, malformed env injection, and common mistakes from the upstream issue tracker.
appliesTo:
  - "**/.mcp.json"
---

# Rules: editing `.mcp.json`

> *This file is auto-updated. The research agent adds rules as it
> finds common mistakes in `anthropics/claude-code` issues.*

## Cross-reference

For the full MCP schema, see [`SKILL-mcp.md`](../SKILL-mcp.md).

## Rules

<!-- seed: replace on first real research pass -->

### Use `command` for stdio servers, not `cmd` or `exec`

The stdio transport uses the `command` key (with optional `args` array). `cmd`, `exec`, or `path` are silently ignored.

### HTTP / SSE servers require explicit `type` field

For non-stdio transports, set `"type": "http"` or `"type": "sse"` and supply a `url`. Omitting `type` while supplying `url` is ambiguous — older Claude Code versions treated it as stdio.

### Use `mcpServers` as the top-level key, not `servers`

Claude Code's `.mcp.json` requires the top-level key `"mcpServers"` (camelCase). Some tools — including VS Code's MCP config and some server docs — use `"servers"` instead. A file with the wrong top-level key silently provides no servers. As of v2.1.153, `claude mcp list` shows a configuration error instead of silently ignoring the file.

### `env` values must be strings

`env` is an object mapping env-var names to **string** values. Numbers and booleans should be quoted: `"PORT": "3000"`, not `"PORT": 3000`.
