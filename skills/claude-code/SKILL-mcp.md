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

| Scope | Location | Command |
|---|---|---|
| Project (shared) | `.mcp.json` in repo root | `claude mcp add --scope project ...` |
| Local (per-user, per-project) | `~/.claude.json` project section | `claude mcp add --scope local ...` (default) |
| User (global) | `~/.claude.json` global section | `claude mcp add --scope user ...` |
| Managed | `managed-mcp.json` in system dir | Admin-deployed, cannot be overridden |

`local` was called `project` and `user` was called `global` in older CLI versions.

Source: `code.claude.com/docs/en/mcp.md`.

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

Local subprocess. Use when the server runs on the same machine.

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "@scope/server@1.2.3", "--config", "path/to/config.json"],
      "env": {
        "MY_API_KEY": "your-key"
      }
    }
  }
}
```

CLI: `claude mcp add --transport stdio --env KEY=value myserver -- npx -y @scope/server@1.2.3`

**Pin versions.** The bare `npx -y @scope/server` (no version) resolves latest on every startup — a supply-chain risk.

`CLAUDE_PROJECT_DIR` is set in the spawned server's environment to the project root.

## Transport: `http`

Remote HTTP (recommended for cloud services). Also accepts `streamable-http` as alias for the `type` field.

```json
{
  "mcpServers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp",
      "headers": {
        "Authorization": "Bearer your-token"
      }
    }
  }
}
```

CLI: `claude mcp add --transport http --header "Authorization: Bearer token" notion https://mcp.notion.com/mcp`

HTTP servers support automatic reconnection with exponential backoff (up to 5 attempts). Use `/mcp` inside a session to authenticate servers requiring OAuth 2.0.

## Transport: `sse`

Server-Sent Events. **Deprecated** — use HTTP where available.

```json
{
  "mcpServers": {
    "asana": {
      "type": "sse",
      "url": "https://mcp.asana.com/sse"
    }
  }
}
```

CLI: `claude mcp add --transport sse asana https://mcp.asana.com/sse`

## Tool naming convention

MCP tools appear as `mcp__<server-name>__<tool-name>` in permission rules and hook matchers. Double-underscore separates each component.

Examples:
- `mcp__memory__create_entities` — Memory server's `create_entities` tool
- `mcp__filesystem__read_file` — Filesystem server's `read_file` tool
- `mcp__github__search_repositories` — GitHub server's `search_repositories` tool

To match all tools from a server in a hook matcher or permission rule, use `mcp__<server>__.*` (the `.*` is required since a bare server name like `mcp__memory` is treated as an exact string and matches nothing).

The server name `workspace` is reserved; Claude Code skips a server with that name and shows a warning.

## Managing servers

```bash
claude mcp list             # List all configured servers
claude mcp get github       # Details for a specific server
claude mcp remove github    # Remove a server
```

In-session: `/mcp` shows server status, tool count, OAuth flows.

**Dynamic tool updates:** Claude Code supports MCP `list_changed` notifications — servers can update their tools without reconnecting.

**Output size:** Claude Code warns when MCP tool output exceeds 10,000 tokens. Override with `MAX_MCP_OUTPUT_TOKENS` env var.

**Timeout:** Set `MCP_TIMEOUT` env var for server startup timeout (e.g. `MCP_TIMEOUT=10000` for 10 seconds).

## Common mistakes (auto-corrected by `rules/mcp.md`)

> *Populated by the research agent from issue tracker.*

---

*Source pages: `code.claude.com/docs/en/mcp.md`.*
