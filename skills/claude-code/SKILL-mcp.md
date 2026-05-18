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

Source: [code.claude.com/docs/en/mcp.md](https://code.claude.com/docs/en/mcp.md)

## File scope

| Scope | Location | Who it affects |
|---|---|---|
| project | `.mcp.json` in repository root | All collaborators (shared in git) |
| user (all projects) | `~/.claude.json` | You, across all projects |
| user (per-project) | `~/.claude.json` (per-project entry) | You, in that project only |

`--scope` flag values: `local` (default, was called `project` in older versions), `project` (shared via `.mcp.json`), `user` (was called `global`).

## Top-level shape

`.mcp.json` has a single top-level key, `mcpServers`:

```json
{
  "mcpServers": {
    "<server-name>": {
      "type": "stdio|http|sse",
      ...server-specific fields
    }
  }
}
```

The server name is what surfaces in tool names (`mcp__<server>__<tool>`). The server name `workspace` is **reserved** — Claude Code skips any server with that name and shows a warning.

**Pin your MCP server versions.** Bare `npx -y @scope/server` (no version pin) resolves to latest on every startup — supply-chain risk. Use `@scope/server@0.6.2`.

## Transport: `stdio`

Runs a local subprocess. Default transport (implied when only `command` is set).

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem@0.6.2", "/Users/me/projects"],
      "env": {
        "MY_KEY": "value"
      }
    }
  }
}
```

CLI equivalent:
```bash
claude mcp add --transport stdio --env MY_KEY=value filesystem -- \
  npx -y @modelcontextprotocol/server-filesystem@0.6.2 /Users/me/projects
```

Claude Code sets `CLAUDE_PROJECT_DIR` in the spawned server's environment (project root path). Plugin-provided MCP configs also substitute `${CLAUDE_PLUGIN_ROOT}` and `${CLAUDE_PROJECT_DIR}` directly.

**Stdio fields:**

| Field | Required | Notes |
|---|---|---|
| `command` | yes | Executable to run |
| `args` | no | Array of arguments |
| `env` | no | Object of env vars for the server process |
| `type` | no | `"stdio"` (implied; can be omitted) |

Stdio servers are NOT automatically reconnected on failure — they are local processes.

## Transport: `http`

Remote HTTP (Streamable HTTP / HTTP+SSE). Recommended for cloud services. The MCP spec calls this `streamable-http`; both `"http"` and `"streamable-http"` are accepted in the `type` field.

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

CLI equivalent:
```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp \
  --header "Authorization: Bearer your-token"
```

**HTTP fields:**

| Field | Required | Notes |
|---|---|---|
| `type` | yes | `"http"` or `"streamable-http"` |
| `url` | yes | Transport endpoint URL |
| `headers` | no | Object of HTTP headers. Supports `${VAR}` interpolation |

HTTP/SSE servers are automatically reconnected with exponential backoff: up to 5 attempts, starting at 1 second, doubling each time. After 5 failures, marked as failed (retry from `/mcp`). Initial connection retries 3 times on 5xx/connection-refused/timeout errors.

## Transport: `sse`

Server-Sent Events transport. **Deprecated** — use `http` instead where available.

```json
{
  "mcpServers": {
    "asana": {
      "type": "sse",
      "url": "https://mcp.asana.com/sse",
      "headers": {
        "X-API-Key": "your-key"
      }
    }
  }
}
```

Same reconnection behavior as HTTP transport.

## Tool naming convention

MCP tools appear in Claude's tool list as `mcp__<server-name>__<tool-name>`.

Examples:
- `mcp__memory__create_entities` — `memory` server's `create_entities` tool
- `mcp__filesystem__read_file` — `filesystem` server's `read_file` tool
- `mcp__github__search_repositories` — `github` server's `search_repositories` tool

Double-underscore separator (`__`). Use this naming pattern in hook matchers:
- `mcp__memory__.*` — matches all tools from the `memory` server (requires `.*`)
- `mcp__.*__write.*` — matches any write tool from any server

**Permission rules** for MCP tools use the same `mcp__<server>__<tool>` format:
```json
{
  "permissions": {
    "allow": ["mcp__memory__create_entities"],
    "deny": ["mcp__filesystem__write_file"]
  }
}
```

## Capabilities declaration

Servers can declare capabilities. Claude Code displays the tool count for connected servers in `/mcp`. When a server advertises the tools capability but exposes no tools, a warning is shown.

## CLI commands for managing MCP

```bash
# List all configured servers
claude mcp list

# Get details for a specific server
claude mcp get github

# Remove a server
claude mcp remove github

# Add a server (stdio)
claude mcp add <name> -- <command> [args...]

# Add a server (http)
claude mcp add --transport http <name> <url>

# Add with auth header
claude mcp add --transport http <name> <url> --header "Authorization: Bearer token"

# Add with scope
claude mcp add --scope project <name> ...

# Add from JSON
claude mcp add-json <name> '{"type":"http","url":"..."}'

# Check status inside Claude Code
/mcp
```

The `/mcp` panel shows server status, tool counts, and lets you authenticate with OAuth 2.0 servers.

## Managed MCP configuration

Enterprise admins can control MCP via `managed-settings.json`:

| Setting | Effect |
|---|---|
| `allowedMcpServers` | Allowlist of servers users can configure. `[]` = lockdown |
| `deniedMcpServers` | Denylist (takes precedence over allowlist) |
| `allowManagedMcpServersOnly` | Only admin-defined servers are used |
| `disabledMcpjsonServers` | List of specific `.mcp.json` servers to reject |
| `enabledMcpjsonServers` | List of specific `.mcp.json` servers to approve |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` servers |

A `managed-mcp.json` file can also be deployed alongside `managed-settings.json` to provide org-wide MCP server configs.

## Plugin-provided MCP servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. When the plugin is enabled, its servers start automatically. Plugin servers use:
- `${CLAUDE_PLUGIN_ROOT}` — resolved to the plugin's root directory
- `${CLAUDE_PROJECT_DIR}` — resolved to the project root

## Dynamic tool updates

Claude Code supports MCP `list_changed` notifications — servers can update their available tools without disconnecting/reconnecting. Claude Code auto-refreshes when this notification is received.

## Environment variable tips

- `MCP_TIMEOUT` — set server startup timeout in ms (e.g. `MCP_TIMEOUT=10000 claude`)
- `MAX_MCP_OUTPUT_TOKENS` — increase MCP tool output limit beyond 10,000 tokens (e.g. `MAX_MCP_OUTPUT_TOKENS=50000`)

## Channels (MCP push notifications)

An MCP server can push messages into your session by declaring the `claude/channel` capability. Enable with `--channels plugin:<name>@<marketplace>` at startup. See [channels docs](https://code.claude.com/docs/en/channels.md).

## Common mistakes (auto-corrected by `rules/mcp.md`)

- Missing `type` field for HTTP/SSE servers — `type` is required for non-stdio transports.
- Using bare `npx -y @scope/server` without a version pin — supply-chain risk.
- Matching MCP tools with `mcp__memory` (no `.*`) in hook matchers — this is an exact string match that will never fire; use `mcp__memory__.*`.
- Using the reserved server name `workspace` — Claude Code skips it.
- Putting `--env` args after the `--` separator in the CLI — all options must come before the server name.

---

*Source: [code.claude.com/docs/en/mcp.md](https://code.claude.com/docs/en/mcp.md)*
