---
name: claude-code-mcp
description: |
  Deep reference for configuring MCP (Model Context Protocol) servers
  in Claude Code. Covers `.mcp.json` schema, the three transports
  (stdio / http / streamable-http / sse), server config keys (command,
  args, url, env, headers, capabilities), the `mcp__<server>__<tool>`
  naming convention for invoking MCP tools, scope (local / project /
  user), managed MCP configuration, and troubleshooting. Read this
  file when the user asks about MCP setup, `.mcp.json`, MCP transports,
  or MCP tool naming.
source: https://code.claude.com/docs/en/mcp.md
---

# Claude Code — MCP server config (`.mcp.json`)

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for MCP questions.*

## Installation scopes

MCP servers can be configured at three scopes. Administrators can also deploy enterprise-wide via managed configuration.

| Scope | Loads in | Shared with team | Stored in |
|---|---|---|---|
| `local` (default) | Current project only | No | `~/.claude.json` (per-project entry) |
| `project` | Current project only | Yes (version control) | `.mcp.json` in project root |
| `user` | All your projects | No | `~/.claude.json` (global) |

```bash
# Add HTTP server (default scope = local)
claude mcp add --transport http stripe https://mcp.stripe.com

# Add project-scoped server (creates/updates .mcp.json)
claude mcp add --transport http paypal --scope project https://mcp.paypal.com/mcp

# Add user-scoped server (available in all projects)
claude mcp add --transport stdio --scope user myserver -- npx -y my-server
```

Source: `code.claude.com/docs/en/mcp.md`.

## Top-level shape of `.mcp.json`

`.mcp.json` has a single top-level key `mcpServers` mapping server names to configs:

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

The server name appears in tool calls as `mcp__<server>__<tool>`. The reserved name `workspace` is skipped at load time.

**Pin your MCP server versions.** `npx -y @scope/server` without a version resolves to the latest on every startup — a supply-chain compromise of any future release runs immediately.

## Transport: `stdio`

Local subprocess. `command` is required; `args` is optional.

```json
{
  "mcpServers": {
    "airtable": {
      "command": "npx",
      "args": ["-y", "airtable-mcp-server@1.2.3"],
      "env": {
        "AIRTABLE_API_KEY": "${AIRTABLE_API_KEY}"
      }
    }
  }
}
```

`CLAUDE_PROJECT_DIR` is set in the server's environment to the project root. All options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name when using `claude mcp add`; `--` separates the server name from the command.

## Transport: `http` (a.k.a. `streamable-http`)

Remote HTTP server. The `type` field accepts `"http"` or `"streamable-http"` (alias, from the MCP spec).

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

Claude Code retries HTTP/SSE server connections up to 5 times with exponential backoff (starting at 1 second). Initial connection retries up to 3 times on transient errors (v2.1.121+).

## Transport: `sse`

Server-Sent Events. **Deprecated** — use HTTP instead where available.

```json
{
  "mcpServers": {
    "asana": {
      "type": "sse",
      "url": "https://mcp.asana.com/sse",
      "headers": {
        "X-API-Key": "${ASANA_KEY}"
      }
    }
  }
}
```

## Server config fields

| Field | Transport | Notes |
|---|---|---|
| `command` | stdio | Executable to run |
| `args` | stdio | Array of arguments |
| `env` | stdio | Object of env vars injected into the server process. Values must be strings |
| `type` | http/sse | `"http"`, `"streamable-http"`, or `"sse"` |
| `url` | http/sse | Transport endpoint URL |
| `headers` | http/sse | Key-value HTTP headers; env var interpolation with `${VAR}` |
| `alwaysLoad` | all | If `true`, all tools from this server load into context at session start (bypassing tool search deferral). Blocks startup until server connects (capped at 5s). Requires v2.1.121+. Individual tools can also opt in via `"anthropic/alwaysLoad": true` in the tool's `_meta` object |

## Tool naming convention

MCP tools appear as `mcp__<server>__<tool>` where `<server>` is the key in `mcpServers`. Examples:
- `mcp__memory__create_entities`
- `mcp__filesystem__read_file`
- `mcp__github__search_repositories`

Use these names in permission rules and hook matchers. To match all tools from a server, use a regex: `mcp__memory__.*` (bare `mcp__memory` is an exact-string matcher and matches nothing).

Cross-reference: [`SKILL-hooks.md`](SKILL-hooks.md) § *Matcher syntax*.

## Management commands

```bash
# List configured servers
claude mcp list

# Get details for a server
claude mcp get github

# Remove a server
claude mcp remove github

# From inside a session
/mcp
```

`/mcp` shows the tool count per server and flags servers that advertise tools but expose none. Use `/mcp` to authenticate with OAuth 2.0 servers.

## Plugin-provided MCP servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Plugin servers start automatically when the plugin is enabled. Run `/reload-plugins` to reconnect after enabling/disabling a plugin mid-session.

Plugin-provided servers support these environment variables:
- `${CLAUDE_PLUGIN_ROOT}` — plugin installation directory
- `${CLAUDE_PLUGIN_DATA}` — persistent state directory
- `${CLAUDE_PROJECT_DIR}` — project root

Cross-reference: [`SKILL-plugins.md`](SKILL-plugins.md).

## Managed MCP configuration

Administrators can deploy MCP servers via `managed-settings.json` alongside `managed-mcp.json`. Control settings:

| Setting | Effect |
|---|---|
| `allowedMcpServers` | Allowlist of servers users can configure (undefined = no restriction; empty = lockdown) |
| `deniedMcpServers` | Denylist of explicitly blocked servers (takes precedence over allowlist) |
| `allowManagedMcpServersOnly` | Only managed-settings servers apply; denylist still merges from all sources |
| `disabledMcpjsonServers` | List of specific `.mcp.json` servers to reject |
| `enabledMcpjsonServers` | List of specific `.mcp.json` servers to approve |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` servers |

Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) § *All documented settings keys*.

## Dynamic features

- **`list_changed` notifications:** When an MCP server sends this, Claude Code automatically refreshes available tools/prompts/resources without reconnecting.
- **Tool search:** Claude Code defers MCP tool schemas and discovers them on demand via `ToolSearch`. Control with `ENABLE_TOOL_SEARCH`:
  | Value | Behavior |
  |---|---|
  | (unset) | All tools deferred; falls back to upfront loading on Vertex AI or non-first-party `ANTHROPIC_BASE_URL` |
  | `true` | All tools deferred; forces deferral even on Vertex AI/proxies (requests fail on unsupported models) |
  | `auto` | Threshold mode: load upfront if tools fit within 10% of context window, defer overflow |
  | `auto:N` | Custom threshold: `N`% (0–100), e.g. `ENABLE_TOOL_SEARCH=auto:5` |
  | `false` | All tools loaded upfront; no deferral |
  Use `alwaysLoad: true` on a specific server to exempt it from deferral. Requires Sonnet 4+ or Opus 4+ (not Haiku).
- **MCP tool output size:** Warning at >10,000 tokens. Override with `MAX_MCP_OUTPUT_TOKENS` env var.
- **Startup timeout:** Set `MCP_TIMEOUT` env var (milliseconds, e.g. `MCP_TIMEOUT=10000`).

## Channels (push messages from MCP servers)

An MCP server can push messages into your session by declaring the `claude/channel` capability. Opt in with `--channels plugin:<name>@<marketplace>` at startup.

Cross-reference: `code.claude.com/docs/en/channels.md`.

## Common mistakes (auto-corrected by `rules/mcp.md`)

See [`rules/mcp.md`](rules/mcp.md). Key pitfalls:
- Use `command` for stdio servers (not `cmd`, `exec`, or `path`)
- HTTP/SSE servers require explicit `"type": "http"` or `"type": "sse"` plus a `url`
- `env` values must be **strings** (`"PORT": "3000"`, not `"PORT": 3000`)
- The server name `workspace` is reserved and will be skipped

---

*Source pages: `code.claude.com/docs/en/mcp.md`.*
