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

| Scope | File | Committed to git? |
|---|---|---|
| Project | `<project>/.mcp.json` | Yes — shared with team |
| User | `~/.claude.json` (under `mcpServers` key) | No — personal, all projects |
| Local per-project | `~/.claude.json` (per-project entry) | No |

Use `claude mcp add --scope project` (default) for `.mcp.json`, or `--scope user` for `~/.claude.json`. Managed MCP config can be deployed via `managed-mcp.json` in the system directory alongside `managed-settings.json`.

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

Local subprocess. Claude Code spawns the process and communicates via stdin/stdout. Default when `type` is omitted.

```json
{
  "mcpServers": {
    "airtable": {
      "command": "npx",
      "args": ["-y", "airtable-mcp-server@1.2.3"],
      "env": { "AIRTABLE_API_KEY": "your-key" }
    }
  }
}
```

Fields: `command` (required), `args` (array), `env` (object of string→string).

Claude Code sets `CLAUDE_PROJECT_DIR` in the server process's environment to the project root.

## Transport: `http`

Recommended for remote servers (replaces SSE). `streamable-http` is also accepted as an alias for `http`.

```json
{
  "mcpServers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp",
      "headers": { "Authorization": "Bearer your-token" }
    }
  }
}
```

CLI: `claude mcp add --transport http notion https://mcp.notion.com/mcp --header "Authorization: Bearer token"`

## Transport: `sse`

Server-Sent Events (deprecated — prefer `http` where available).

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

## Tool naming convention

MCP tools appear as `mcp__<server-name>__<tool-name>` in permission rules and hook matchers. Double-underscore separators.

Examples:
- `mcp__github__create_pull_request`
- `mcp__filesystem__read_file`

In `permissions.allow`: `"mcp__github__*"` allows all GitHub MCP tools.

## CLI management commands

```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp   # add HTTP server
claude mcp add --transport stdio airtable -- npx -y airtable-mcp-server  # add stdio server
claude mcp list           # list all configured servers
claude mcp get github     # show details for a server
claude mcp remove github  # remove a server
```

Inside a session, use `/mcp` to see connection status and tool count per server.

The server name `workspace` is reserved — Claude Code skips any server with that name.

## File scope

`.mcp.json` in the project root → project-scoped servers (all team members, committed to git).

`~/.claude.json` → user-scoped servers (personal, all projects) and local per-project overrides.

Use `claude mcp add --scope user` to add to `~/.claude.json`, or default (`--scope project`) for `.mcp.json`.

## Worked examples

Version-pinned local server:
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

Source: [mcp.md](https://code.claude.com/docs/en/mcp.md).

## Common mistakes (auto-corrected by `rules/mcp.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/mcp.md`.*
