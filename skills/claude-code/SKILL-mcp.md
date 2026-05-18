---
name: claude-code-mcp
description: |
  Deep reference for configuring MCP (Model Context Protocol) servers
  in Claude Code. Covers `.mcp.json` schema, the three transports
  (stdio / http / sse), server config keys (command, args, url, env,
  headers, capabilities), the `mcp__<server>__<tool>` naming
  convention for invoking MCP tools, scope (project / user / local),
  managed MCP configuration, and troubleshooting. Read this file when
  the user asks about MCP setup, `.mcp.json`, MCP transports, or MCP
  tool naming.
source: https://code.claude.com/docs/en/mcp.md
---

# Claude Code — MCP server config (`.mcp.json`)

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for MCP questions.*

## File scope

MCP servers can be configured at three scopes:

| Scope | Storage | Who sees it |
|---|---|---|
| `project` | `.mcp.json` in project root (committed) | All collaborators |
| `local` | `~/.claude.json` (per-project entry) | You, this project only (was called `project` in older versions) |
| `user` | `~/.claude.json` (global entry) | You, all projects (was called `global` in older versions) |

**Tip**: Use `--scope project` to store in `.mcp.json`; `--scope local` (default) for your machine only; `--scope user` for all your projects.

The reserved server name `workspace` is skipped at load time with a warning — rename any server with that name.

Source: `code.claude.com/docs/en/mcp.md`.

## Top-level shape

`.mcp.json` has a single top-level key, `mcpServers`, mapping server name → config. The server name appears in tool names as `mcp__<server>__<tool>`.

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.github.com/mcp"
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem@0.6.2", "/Users/me/projects"]
    }
  }
}
```

**Pin your MCP server versions.** Bare `npx -y @scope/server` (no version) resolves to latest on every startup — a supply-chain compromise runs immediately. Use `@0.6.2`-style version pins.

## Transport: `stdio` (local subprocess)

Omit `type` or set `"type": "stdio"`. Required field: `command`. Optional: `args`, `env`.

```json
{
  "mcpServers": {
    "airtable": {
      "command": "npx",
      "args": ["-y", "airtable-mcp-server@1.2.3"],
      "env": {
        "AIRTABLE_API_KEY": "your-key"
      }
    }
  }
}
```

Claude Code sets `CLAUDE_PROJECT_DIR` in the spawned server's environment to the project root.

**CLI**: `claude mcp add [--transport stdio] --env KEY=value <name> -- <command> [args...]`

All `--transport`, `--env`, `--scope`, `--header` options must come **before** the server name; `--` separates the server name from the command and its args.

## Transport: `http` (remote HTTP, recommended)

Set `"type": "http"` (or `"streamable-http"` — accepted alias matching the MCP spec). Required field: `url`. Optional: `headers`.

```json
{
  "mcpServers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_TOKEN"
      }
    }
  }
}
```

**CLI**: `claude mcp add --transport http <name> <url> [--header "Key: value"]`

HTTP/SSE servers reconnect automatically with exponential backoff (up to 5 attempts, starting 1s, doubling). After 5 failures the server is marked failed; retry manually from `/mcp`. As of v2.1.121, initial connection retries up to 3 times on transient errors (5xx, connection refused, timeout).

## Transport: `sse` (Server-Sent Events, deprecated)

⚠️ **Deprecated** — use `http` instead where available.

```json
{
  "mcpServers": {
    "legacy": {
      "type": "sse",
      "url": "https://api.example.com/sse"
    }
  }
}
```

**CLI**: `claude mcp add --transport sse <name> <url>`

## Tool naming convention

MCP tools are named `mcp__<server>__<tool>` with double-underscore separators:

| Example | Server | Tool |
|---|---|---|
| `mcp__memory__create_entities` | `memory` | `create_entities` |
| `mcp__filesystem__read_file` | `filesystem` | `read_file` |
| `mcp__github__search_repositories` | `github` | `search_repositories` |

This name is used in:
- **Permission rules**: `"allow": ["mcp__github__*"]`
- **Hook matchers**: `"matcher": "mcp__memory__.*"` (regex; the `.*` is required for wildcard matching)
- **`--allowedTools`** flag

## Capabilities declaration

MCP servers advertise capabilities via the standard MCP protocol. Claude Code checks the `tools` capability; the `/mcp` panel shows the tool count next to each server and flags servers that advertise `tools` but expose none.

## Managing servers

```bash
claude mcp list                # List all configured servers
claude mcp get github          # Details for a specific server
claude mcp remove github       # Remove a server
claude mcp add-json <name> <json>  # Add via JSON blob
/mcp                           # In-session: check status, authenticate OAuth servers
```

**Dynamic tool updates**: Claude Code supports `list_changed` notifications — servers can update available tools without reconnecting.

## Plugin-provided MCP servers

Plugins can bundle MCP servers via `.mcp.json` at plugin root or inline in `plugin.json`. When a plugin is enabled, its MCP servers start automatically alongside manually configured servers. Managed via plugin installation, not `/mcp` commands.

## Managed MCP configuration

Administrators can control MCP servers via managed settings in `managed-settings.json`:

| Setting | Effect |
|---|---|
| `allowedMcpServers` | Allowlist of MCP servers users can configure. Undefined = no restriction; `[]` = lockdown |
| `deniedMcpServers` | Denylist, applies to all scopes including managed. Takes precedence over allowlist |
| `allowManagedMcpServersOnly` | Only `allowedMcpServers` from managed settings respected |
| `disabledMcpjsonServers` | List of specific `.mcp.json` servers to reject |
| `enabledMcpjsonServers` | List of specific `.mcp.json` servers to auto-approve |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` servers |

## Use MCP prompts as commands

MCP servers can expose prompts that appear as Claude Code commands using the format `/mcp__<server>__<prompt>`. These are dynamically discovered from connected servers.

## Worked examples

Minimal `project`-scoped `.mcp.json` with one stdio and one HTTP server:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem@0.6.2", "/Users/me/projects"]
    },
    "github": {
      "type": "http",
      "url": "https://api.github.com/mcp",
      "headers": {
        "Authorization": "Bearer ${GITHUB_TOKEN}"
      }
    }
  }
}
```

With authentication via env var (use `--env` flag or `env` field, not `${}` expansion in values for `local`/`user` scope `~/.claude.json` entries):

```bash
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server@1.2.3
```

## Common mistakes (auto-corrected by `rules/mcp.md`)

See [`rules/mcp.md`](rules/mcp.md) for auto-correction rules:
- Use `command` for stdio (not `cmd` or `exec`)
- HTTP/SSE require explicit `type` field
- `env` values must be strings (not numbers/booleans)

---

*Source pages: `code.claude.com/docs/en/mcp.md`.*
