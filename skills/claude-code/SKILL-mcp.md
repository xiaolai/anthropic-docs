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

Source: [`code.claude.com/docs/en/mcp.md`](https://code.claude.com/docs/en/mcp.md)

| Scope | File | Notes |
|---|---|---|
| Project (shared) | `<project>/.mcp.json` | Committed to git; shared with team. Use `--scope project` with `claude mcp add` |
| User (all projects) | `~/.claude.json` (MCP section) | Personal, all projects. Use `--scope user` |
| Local (per-project, personal) | `~/.claude.json` (per-project) | Default scope (`local`; previously called `project`) |
| Managed | `managed-mcp.json` in system dir | Admin-controlled; cannot be overridden |

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

Local subprocess. Implied by the `command` key (no `type` needed).

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

Claude Code sets `CLAUDE_PROJECT_DIR` in the spawned server's environment. Keys: `command` (required), `args` (array), `env` (object, string values only).

## Transport: `http`

Recommended for remote servers. Add `"type": "http"` (or alias `"streamable-http"`) and a `url`. Supports `headers` for auth. Automatically reconnects on disconnect (exponential backoff, up to 5 attempts).

```json
{
  "mcpServers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp",
      "headers": { "Authorization": "Bearer ${NOTION_TOKEN}" }
    }
  }
}
```

## Transport: `sse`

**Deprecated** — use `http` instead where available. Set `"type": "sse"` + `url`.

```json
{
  "mcpServers": {
    "asana": { "type": "sse", "url": "https://mcp.asana.com/sse" }
  }
}
```

## Tool naming convention

MCP tools appear as `mcp__<server-name>__<tool-name>` (double-underscore separator). Use these exact strings in permission rules and hook matchers.

Examples:
- Server named `github` with tool `create_pr` → `mcp__github__create_pr`
- Match all tools from `memory` server → matcher `mcp__memory__.*` (regex)

The server name `workspace` is reserved and will be skipped at load time.

## CLI management commands

```bash
claude mcp add --transport http <name> <url>           # add HTTP server
claude mcp add --transport stdio <name> -- <cmd> [args] # add stdio server
claude mcp add-json <name> '<json>'                     # add via raw JSON
claude mcp list                                         # list configured servers
claude mcp get <name>                                   # show server details
claude mcp remove <name>                                # remove a server
```

In-session: `/mcp` shows connected servers, tool counts, and auth status. `MCP_TIMEOUT` env var sets startup timeout (ms). `MAX_MCP_OUTPUT_TOKENS` sets per-tool output token limit (default: 10 000).

## Common mistakes (auto-corrected by `rules/mcp.md`)

See [`rules/mcp.md`](rules/mcp.md) — covers: use `command` not `cmd`/`exec`; `type` required for non-stdio transports; `env` values must be strings.

---

*Source pages: `code.claude.com/docs/en/mcp.md`.*
