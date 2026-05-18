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

`.mcp.json` is the **project-scoped** MCP config (committed to git, shared with team). User-scoped MCP config lives in `~/.claude.json` (per-user, not committed).

`claude mcp add` writes to the local scope by default (personal, project-specific, not in `.mcp.json`). Use `--scope project` to write to `.mcp.json`, or `--scope user` to write to `~/.claude.json`.

Scope aliases: `local` (default, was `project` in older versions), `project` (→ `.mcp.json`), `user` (global, was `global` in older versions).

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

Local subprocess transport — the default when no `type` is specified. Claude Code spawns the process and communicates via stdin/stdout.

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "@scope/server@1.2.3", "--flag"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

Fields: `command` (required), `args` (array), `env` (object of key→value strings).

`CLAUDE_PROJECT_DIR` is automatically set in the server's environment to the project root.

Source: `code.claude.com/docs/en/mcp.md`.

## Transport: `http`

Remote HTTP (Streamable HTTP) transport. Recommended for cloud-based services.

```json
{
  "mcpServers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp",
      "headers": {
        "Authorization": "Bearer ${NOTION_TOKEN}"
      }
    }
  }
}
```

Also accepts `"type": "streamable-http"` (the official MCP spec name — useful when copying server docs). Fields: `type` (required: `"http"` or `"streamable-http"`), `url` (required), `headers` (optional).

Claude Code retries failed HTTP connections with exponential backoff (up to 5 attempts starting at 1 second).

Source: `code.claude.com/docs/en/mcp.md`.

## Transport: `sse`

**Deprecated** — use HTTP transport where available. Server-Sent Events transport for remote servers.

```json
{
  "mcpServers": {
    "legacy-server": {
      "type": "sse",
      "url": "https://api.example.com/sse",
      "headers": {
        "X-API-Key": "${API_KEY}"
      }
    }
  }
}
```

Source: `code.claude.com/docs/en/mcp.md`.

## Tool naming convention

MCP tools are named `mcp__<server-name>__<tool-name>` using double underscores. The server name is the key in `mcpServers`.

Examples:
- `mcp__github__search_repositories` — `search_repositories` tool from the `github` server
- `mcp__memory__create_entities` — `create_entities` from the `memory` server

In permission rules, match all tools from a server with a regex: `mcp__memory__.*` (the trailing `.*` is required — bare `mcp__memory` is treated as an exact string and matches no tool).

MCP prompts appear as slash commands: `/mcp__<server>__<prompt>`.

Source: `code.claude.com/docs/en/mcp.md`, `code.claude.com/docs/en/hooks.md`.

## Capabilities declaration

Plugin-provided MCP configs can include a `--channels` capability to push messages into sessions (see [Channels](/code.claude.com/docs/en/channels.md)). Servers that support dynamic tool updates send `list_changed` notifications, and Claude Code auto-refreshes tools without a reconnect.

The reserved server name `workspace` is skipped at load time — rename any server with that name.

Source: `code.claude.com/docs/en/mcp.md`.

## Worked examples

> *Populated by the research agent.* See also:
> [`templates/.mcp.json`](templates/.mcp.json).

## Managed MCP configuration

Enterprise admins can control MCP server availability via managed settings:

| Setting | Effect |
|---|---|
| `allowedMcpServers` | Allowlist: `[{ "serverName": "github" }]`. Undefined = no restrictions, `[]` = lockdown. |
| `deniedMcpServers` | Denylist: `[{ "serverName": "filesystem" }]`. Takes precedence over allowlist. |
| `allowManagedMcpServersOnly` | When `true`, only `allowedMcpServers` are respected. `deniedMcpServers` still merges from all sources. |

Source: `code.claude.com/docs/en/mcp.md`, `code.claude.com/docs/en/settings.md`.

## Common mistakes (auto-corrected by `rules/mcp.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/mcp.md`.*
