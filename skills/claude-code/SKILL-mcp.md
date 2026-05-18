---
name: claude-code-mcp
description: |
  Deep reference for configuring MCP (Model Context Protocol) servers
  in Claude Code. Covers `.mcp.json` schema, the three transports
  (stdio / http / sse), server config keys (command, args, url, env,
  headers, capabilities), the `mcp__<server>__<tool>` naming
  convention for invoking MCP tools, scope (project / user), CLI
  commands (claude mcp add/list/get/remove), and troubleshooting.
  Read this file when the user asks about MCP setup, `.mcp.json`,
  MCP transports, or MCP tool naming.
source: https://code.claude.com/docs/en/mcp.md
---

# Claude Code — MCP server config (`.mcp.json`)

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for MCP questions.*

## File scope

| Scope | Config location | Description |
|---|---|---|
| project | `.mcp.json` in project root | Checked into git, shared with team |
| user | `~/.claude.json` (`mcpServers` key) | Personal MCP servers across all projects |
| local | `~/.claude.json` (per-project section) | Personal overrides for a specific project |
| managed | `managed-mcp.json` in system directory | Admin-deployed, cannot be overridden |

MCP servers from `.mcp.json` prompt for approval the first time (unless `enableAllProjectMcpServers: true` in settings). User/local servers added with `claude mcp add` are pre-approved.

Source: `code.claude.com/docs/en/mcp.md`

## Installing MCP servers (CLI)

```bash
# Add a remote HTTP server (recommended for cloud services)
claude mcp add --transport http notion https://mcp.notion.com/mcp

# Add with auth header
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"

# Add a remote SSE server (deprecated; prefer HTTP)
claude mcp add --transport sse asana https://mcp.asana.com/sse

# Add a local stdio server
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server

# Manage servers
claude mcp list
claude mcp get github
claude mcp remove github
```

**Option ordering:** All options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. The `--` separator separates the server name from the command and arguments.

**Server name `workspace`** is reserved — Claude Code skips a server with that name and shows a warning.

## `.mcp.json` schema

`.mcp.json` has a single top-level key `mcpServers` mapping server names to their config. The server name becomes the prefix in tool names (`mcp__<server>__<tool>`).

```json
{
  "mcpServers": {
    "<server-name>": { <server-config> }
  }
}
```

The `type` field determines the transport. Omitting `type` when `command` is present means stdio.

## Transport: `stdio`

Local subprocess transport. The server process runs locally and communicates via stdin/stdout.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem@0.6.2", "/Users/me/projects"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
```

| Field | Required | Description |
|---|---|---|
| `command` | yes | Executable to spawn |
| `args` | no | Arguments array |
| `env` | no | Environment variables (values must be strings) |
| `type` | no | Omit or `"stdio"` — implied when `command` is present without `url` |

**`CLAUDE_PROJECT_DIR`** is automatically set in the spawned server's environment to the project root. Reference it from inside the server: `process.env.CLAUDE_PROJECT_DIR` (Node) or `os.environ["CLAUDE_PROJECT_DIR"]` (Python).

**Pin versions.** Use exact version pins (e.g., `@0.6.2`) rather than `npx -y @scope/server` (no pin). Unpinned installs resolve to latest on every startup — a supply-chain compromise of any future release runs immediately.

## Transport: `http` (Streamable HTTP)

Remote HTTP transport, recommended for cloud services. `streamable-http` is an alias accepted by Claude Code (per the MCP spec).

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

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"http"` (or `"streamable-http"`) |
| `url` | yes | Transport endpoint URL |
| `headers` | no | HTTP headers as key-value pairs |
| `env` | no | Not applicable to HTTP transport |

## Transport: `sse`

Server-Sent Events transport. **Deprecated** — use HTTP transport where available.

```json
{
  "mcpServers": {
    "legacy-api": {
      "type": "sse",
      "url": "https://api.company.com/sse",
      "headers": {
        "X-API-Key": "your-key"
      }
    }
  }
}
```

## Tool naming convention

MCP tools appear in Claude Code as `mcp__<server-name>__<tool-name>`.

Examples:
- `mcp__memory__create_entities` — Memory server's create entities tool
- `mcp__filesystem__read_file` — Filesystem server's read file tool
- `mcp__github__search_repositories` — GitHub server's search tool

**Matching in permissions and hooks:** To match all tools from a server, use `mcp__<server>__.*` (the `.*` is required). A matcher like `mcp__memory` without `.*` is treated as exact-string and matches nothing.

Example permission rule: `Allow(mcp__memory__.*)`
Example hook matcher: `"mcp__memory__.*"`

## Capabilities declaration

MCP servers advertise capabilities (`tools`, `resources`, `prompts`). The `/mcp` panel shows tool count next to each server and flags servers that advertise tools capability but expose no tools.

Claude Code supports `list_changed` notifications — servers can dynamically update their tools without reconnecting.

## Managed MCP configuration

Administrators can deploy MCP servers via `managed-mcp.json` at the system managed-settings path. These servers are added to users' configs and cannot be removed.

**Managed settings keys for MCP:**
- `allowedMcpServers`: Allowlist of servers users can configure (undefined = no restriction, empty = lockdown)
- `deniedMcpServers`: Denylist (takes precedence over allowlist)
- `allowManagedMcpServersOnly`: Only admin-defined servers respected
- `disabledMcpjsonServers`: Specific `.mcp.json` servers to reject
- `enabledMcpjsonServers`: Specific `.mcp.json` servers to auto-approve

Cross-reference: managed settings → [`SKILL-settings.md`](SKILL-settings.md)

## Common mistakes (auto-corrected by `rules/mcp.md`)

See [`rules/mcp.md`](rules/mcp.md). Key pitfalls:
- Use `command` for stdio (not `cmd`, `exec`, or `path`)
- HTTP/SSE servers require explicit `"type"` field + `"url"`
- `env` values must be strings (`"PORT": "3000"`, not `"PORT": 3000`)
- Omitting version pin exposes to supply-chain risk on every startup

---

*Source pages: `code.claude.com/docs/en/mcp.md`.*
