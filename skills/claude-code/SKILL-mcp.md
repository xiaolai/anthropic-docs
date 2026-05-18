---
name: claude-code-mcp
description: |
  Deep reference for configuring MCP (Model Context Protocol) servers
  in Claude Code. Covers `.mcp.json` schema, the three transports
  (stdio / http / sse), server config keys (command, args, url, env,
  headers), the `mcp__<server>__<tool>` naming convention, scopes
  (local / project / user), managed MCP configuration, and
  troubleshooting. Read this file when the user asks about MCP setup,
  `.mcp.json`, MCP transports, tool naming, or MCP tool search.
source: https://code.claude.com/docs/en/mcp.md
---

# Claude Code — MCP server config (`.mcp.json`)

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for MCP questions.*

Source: [`code.claude.com/docs/en/mcp.md`](https://code.claude.com/docs/en/mcp.md)

## Installing MCP servers via CLI

Three transport options:

### Option 1: Remote HTTP server (recommended for cloud services)

```bash
# Basic syntax
claude mcp add --transport http <name> <url>

# With Bearer token
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

> **Note:** In `.mcp.json`, `"type"` field also accepts `"streamable-http"` as an alias for `"http"` (the MCP spec's name for this transport).

### Option 2: Remote SSE server (deprecated — use HTTP instead)

```bash
claude mcp add --transport sse <name> <url>
```

### Option 3: Local stdio server

```bash
# Basic syntax
claude mcp add [options] <name> -- <command> [args...]

# With API key in environment
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

> **Important:** All options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. `--` separates the server name from the command.

## MCP installation scopes

| Scope | Loads in | Shared with team | Stored in |
|---|---|---|---|
| `local` (default) | Current project only | No | `~/.claude.json` |
| `project` | Current project only | Yes, via version control | `.mcp.json` in project root |
| `user` | All your projects | No | `~/.claude.json` |

Use `--scope <scope>` with `claude mcp add` to specify. Older versions called `local` → `project` and `user` → `global`.

## `.mcp.json` top-level shape

`.mcp.json` has a single top-level key, `mcpServers`, mapping server names to their configs:

```json
{
  "mcpServers": {
    "<server-name>": {
      "command": "...",
      "args": ["..."],
      "env": {}
    }
  }
}
```

The server name appears in tool names as `mcp__<server-name>__<tool>`.

> **Reserved name:** `workspace` is reserved for internal use. If your config defines a server with that name, Claude Code skips it and shows a warning.

## Transport: stdio

Runs a local subprocess. Implied by `command` field (no `"type"` needed, or `"type": "stdio"`):

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem@0.6.2", "/Users/me/projects"],
      "env": {
        "OPTIONAL_VAR": "value"
      }
    }
  }
}
```

**Always pin MCP server versions.** The bare `npx -y @scope/server` pattern (no version) resolves to the latest on every startup — a supply-chain compromise runs immediately with all capabilities the server requests.

Claude Code sets `CLAUDE_PROJECT_DIR` in the spawned server's environment to the project root. Reference with `${CLAUDE_PROJECT_DIR:-.}` in `.mcp.json` `command`/`args` (needs default because variable isn't set in Claude Code's own environment, only in the spawned server). Plugin-provided MCP configs substitute `${CLAUDE_PROJECT_DIR}` directly.

## Transport: http (Streamable HTTP)

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

`"type"` can be `"http"` or `"streamable-http"` (alias).

**Automatic reconnection:** On disconnection, Claude Code reconnects with exponential backoff — up to 5 attempts, starting at 1 second, doubling each time. As of v2.1.121, also retries initial connection up to 3 times on transient errors (5xx, connection refused, timeout). Auth errors and 404s are not retried.

## Transport: sse (deprecated)

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

Use HTTP transport instead where available.

## Managed MCP configuration

Administrators can deploy MCP servers via managed settings in `managed-settings.json`:

```json
{
  "allowedMcpServers": [{"serverName": "github"}],
  "deniedMcpServers": [{"serverName": "filesystem"}],
  "allowManagedMcpServersOnly": true
}
```

| Setting | Description |
|---|---|
| `allowedMcpServers` | Allowlist of MCP servers users can configure. Empty = lockdown |
| `deniedMcpServers` | Denylist of MCP servers explicitly blocked. Takes precedence over allowlist |
| `allowManagedMcpServersOnly` | Only `allowedMcpServers` from managed settings are respected |

Managed MCP config can also be in `managed-mcp.json` in the same system directory as `managed-settings.json`.

Settings `disabledMcpjsonServers` (array) and `enabledMcpjsonServers` (array) can approve/reject specific servers from `.mcp.json`. `enableAllProjectMcpServers: true` auto-approves all project MCP servers.

## Tool naming convention

MCP tools appear as `mcp__<server>__<tool>`:

- `mcp__memory__create_entities`
- `mcp__filesystem__read_file`
- `mcp__github__search_repositories`

Use this format in permission rules (e.g. `"allow": ["mcp__memory__.*"]`) and hook matchers (e.g. `"matcher": "mcp__memory__.*"`).

In the `/mcp` panel, tool counts are shown next to each server. Servers advertising `tools` capability but exposing no tools are flagged.

## Managing MCP servers

```bash
claude mcp list                    # List all configured servers
claude mcp get <name>              # Get details for a specific server
claude mcp remove <name>           # Remove a server
# Within Claude Code:
/mcp                               # Check server status, authenticate with OAuth
```

Set environment variables with `--env KEY=value`. Configure startup timeout with `MCP_TIMEOUT` env var (e.g. `MCP_TIMEOUT=10000 claude`).

## Dynamic tool updates

Claude Code supports MCP `list_changed` notifications — servers can dynamically update their tools, prompts, and resources without reconnecting.

## Plugin-provided MCP servers

Plugins can bundle MCP servers. When a plugin is enabled, its servers start automatically. Run `/reload-plugins` to connect/disconnect plugin servers during a session.

Plugin env var placeholders:
- `${CLAUDE_PLUGIN_ROOT}` — plugin's installation directory
- `${CLAUDE_PLUGIN_DATA}` — plugin's persistent data directory
- `${CLAUDE_PROJECT_DIR}` — stable project root

Example plugin MCP config in `.mcp.json` at plugin root:
```json
{
  "mcpServers": {
    "database-tools": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"],
      "env": {"DB_URL": "${DB_URL}"}
    }
  }
}
```

## MCP tool search (deferred loading)

For large tool sets (hundreds of tools), Claude Code supports MCP tool search — tools are discovered but not loaded upfront, reducing context usage. Controlled by `ENABLE_TOOL_SEARCH` env var:

| Value | Behavior |
|---|---|
| unset | All MCP tools deferred by default; loaded upfront on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
| `true` | Always defer and send beta header. Supported on Vertex AI with Sonnet 4.5+ or Opus 4.5+ |
| `auto` | Threshold mode: load upfront if tools fit within 10% of context |
| `auto:N` | Custom threshold, e.g. `auto:5` for 5% |
| `false` | Load all upfront |

Per-tool output size limit override: servers can declare `anthropic/maxResultSizeChars` to set a character limit for text content from that tool. Otherwise `MAX_MCP_OUTPUT_TOKENS` applies (default: 25000 tokens; warning shown above 10,000).

## OAuth authentication

Run `/mcp` to authenticate with remote servers requiring OAuth 2.0. To use pre-configured credentials:
- `MCP_CLIENT_SECRET` — OAuth client secret (avoids interactive prompt with `--client-secret`)
- `MCP_OAUTH_CALLBACK_PORT` — Fixed port for OAuth redirect callback

## MCP server from Claude.ai

Set `ENABLE_CLAUDEAI_MCP_SERVERS=false` to disable claude.ai MCP servers in Claude Code. Enabled by default for logged-in users.

## Troubleshooting

| Issue | Solution |
|---|---|
| Server not connecting | Check `claude mcp get <name>` for errors, check `/mcp` for status |
| Timeout on startup | Increase `MCP_TIMEOUT` (default 30s) |
| Tool output too large | Set `MAX_MCP_OUTPUT_TOKENS` or use tool's `anthropic/maxResultSizeChars` |
| Connection refused at initial startup | As of v2.1.121, retries 3 times on transient errors |
| Non-first-party proxy disabling tool search | Set `ENABLE_TOOL_SEARCH=true` if proxy forwards `tool_reference` blocks |
| Stdio server inherits too many env vars | Set `CLAUDE_CODE_MCP_ALLOWLIST_ENV=1` to limit to safe baseline + configured env |

---

*Source page: [`code.claude.com/docs/en/mcp.md`](https://code.claude.com/docs/en/mcp.md)*
