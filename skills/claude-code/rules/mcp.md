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

### `env` values must be strings

`env` is an object mapping env-var names to **string** values. Numbers and booleans should be quoted: `"PORT": "3000"`, not `"PORT": 3000`.

### Pin MCP server versions — never use bare `npx -y @scope/server`

The bare `npx -y @scope/server` pattern resolves to the latest npm version at every Claude Code startup. A supply-chain compromise of any future release runs immediately with whatever filesystem/network capabilities the server requests. Always pin: `npx -y @scope/server@1.2.3`. Pin with the exact version tag, not a semver range (`^1.0.0` is not safe).

### `allowedMcpServers` / `deniedMcpServers` only work in managed settings

These two keys are managed-only. Setting them in user or project `settings.json` has no effect. They must be in `managed-settings.json`, delivered via MDM plist/registry, or via server-managed settings.

### Environment variable syntax is `${VAR}` or `${VAR:-default}` — not `$VAR`

The MCP config env-var expansion only recognises the braced form: `${MY_TOKEN}`. Bare `$MY_TOKEN` is not expanded and will be passed literally as the string `"$MY_TOKEN"` to the server.
