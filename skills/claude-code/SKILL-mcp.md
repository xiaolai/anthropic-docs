---
name: claude-code-mcp
description: |
  Deep reference for configuring MCP (Model Context Protocol) servers
  in Claude Code. Covers `.mcp.json` schema, the three transports
  (stdio / http / sse), server config keys (command, args, url, env,
  headers, capabilities), the `mcp__<server>__<tool>` naming
  convention for invoking MCP tools, scope (project / user), and
  troubleshooting. Read this file when the user asks about MCP setup,
  `.mcp.json`, MCP transports, or MCP tool naming.
source: https://code.claude.com/docs/en/mcp.md
---

# Claude Code — MCP server config (`.mcp.json`)

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for MCP questions.*

## File scope

`.mcp.json` at project root = project-scoped servers (shared via git). User-level servers and local (per-project private) servers are stored in `~/.claude.json`. Environment variable expansion is supported in `command`, `args`, `env`, `url`, and `headers` using `${VAR}` or `${VAR:-default}` syntax.

## Top-level shape

<!-- seed: replace on first real research pass -->

`.mcp.json` has a single top-level key, `mcpServers`, whose value is an object mapping a server name to its config. The server name is what surfaces in tool names (`mcp__<server>__<tool>`).

Minimal example — one stdio server (with an exact version pin, recommended):

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem@0.6.2", "/Users/me/projects"]
    }
  }
}
```

The `command` field implies stdio transport (the default). For remote transports, add `"type": "http"` or `"type": "sse"` plus a `url` field whose value is the transport endpoint. See § *Transport: `http`* and § *Transport: `sse`* below for full per-transport schemas, including auth headers and capability declarations.

**Pin your MCP server versions.** The bare `npx -y @scope/server` pattern (no version pin) resolves to the latest version on every startup — a supply-chain compromise of any future release runs immediately with whatever capabilities the server requests. MCP servers commonly request filesystem or network capabilities, so this is a real blast radius. See [`templates/MCP-PINNING.md`](templates/MCP-PINNING.md) for the rationale and the canonical pattern.

Source: `code.claude.com/docs/en/mcp.md`.

## Transport: `stdio`

Local subprocess. `command` implies stdio (no `type` field needed, or `"type": "stdio"`):

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem@0.6.2", "/Users/me/projects"],
      "env": { "MY_KEY": "value" }
    }
  }
}
```

Fields: `command` (required), `args` (array), `env` (object).  
`CLAUDE_PROJECT_DIR` is set in the spawned server's environment automatically.

## Transport: `http`

Remote HTTP (MCP spec calls this `streamable-http`; both names accepted):

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": { "Authorization": "Bearer ${GITHUB_PAT}" },
      "alwaysLoad": false
    }
  }
}
```

Fields: `type: "http"` or `"streamable-http"`, `url` (required), `headers` (object), `oauth` (object, for OAuth config), `headersHelper` (script path), `alwaysLoad` (boolean — skip deferral).

OAuth sub-fields in `oauth`: `clientId`, `callbackPort`, `scopes`, `authServerMetadataUrl`.

## Transport: `sse`

Deprecated; prefer `http`. Format mirrors `http` but with `"type": "sse"`.

## Tool naming convention

MCP tools appear as `mcp__<server>__<tool>` in tool names, permission rules, and hook matchers. The `<server>` part is the key from `mcpServers`. Examples:

- `mcp__memory__create_entities` — Memory server's create_entities tool
- `mcp__filesystem__read_file` — Filesystem server's read_file tool

Matcher for all tools from a server: `mcp__memory__.*` (requires `.*`; bare `mcp__memory` is an exact match and matches nothing).

MCP prompts surface as slash commands: `/mcp__servername__promptname`.

## Capabilities declaration

Set `alwaysLoad: true` on a server config to bypass tool-search deferral — that server's tools load into context at session start. Use sparingly (each upfront tool consumes context). Requires Claude Code v2.1.121+.

Set `_meta["anthropic/alwaysLoad"]: true` on an individual tool in `tools/list` for per-tool always-load.

## Scopes

| Scope | Stored in | Shared |
|---|---|---|
| `local` (default) | `~/.claude.json` (per-project entry) | No |
| `project` | `.mcp.json` in project root | Yes (git) |
| `user` | `~/.claude.json` (global) | No |

CLI: `claude mcp add --scope project --transport http name url`

## Worked examples

See also: [`templates/.mcp.json`](templates/.mcp.json).

```bash
# Add remote HTTP server
claude mcp add --transport http notion https://mcp.notion.com/mcp

# Add local stdio server with env var
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server

# Add project-scoped server
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp

# List, get, remove
claude mcp list
claude mcp get github
claude mcp remove github
```

## Common mistakes (auto-corrected by `rules/mcp.md`)

- Bare package name without version pin: `npx -y @scope/server` resolves to latest on every startup — a supply-chain risk. Pin with `@0.6.2`.
- Matcher `mcp__memory` with no trailing `__.*` — matches nothing; use `mcp__memory__.*`.
- Server named `workspace` — reserved for internal use; rename it.
- Putting `${CLAUDE_PROJECT_DIR}` in `command`/`args` of a project `.mcp.json` without a default: use `${CLAUDE_PROJECT_DIR:-.}` as fallback.

---

*Source pages: `code.claude.com/docs/en/mcp.md`.*
