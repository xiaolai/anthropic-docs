---
name: claude-code-mcp
description: |
  Deep reference for configuring MCP (Model Context Protocol) servers
  in Claude Code. Covers `.mcp.json` schema, the three transports
  (stdio / http / sse), server config keys (command, args, url, env,
  headers, capabilities), the `mcp__<server>__<tool>` naming
  convention for invoking MCP tools, scope (project / user / local),
  managed MCP, and troubleshooting. Read this file when the user asks
  about MCP setup, `.mcp.json`, MCP transports, or MCP tool naming.
source: https://code.claude.com/docs/en/mcp.md
---

# Claude Code — MCP server config (`.mcp.json`)

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for MCP questions.*

## File scope

| Scope | Stored in | Loads in |
|---|---|---|
| `local` (default) | `~/.claude.json`, per-project entry | Current project only |
| `project` | `.mcp.json` in project root | Current project (shared via git) |
| `user` | `~/.claude.json` global section | All projects |

CLI commands use `--scope local|project|user` to choose scope. `local` is the default.

## Top-level shape

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

**Pin your MCP server versions.** Using `npx -y @scope/server` without a version pin resolves to latest on every startup — a supply-chain compromise of any future release runs with whatever capabilities the server requests. See templates for the rationale and canonical pattern.

## Server config fields (common)

| Field | Required | Notes |
|---|---|---|
| `type` | yes | Transport: `"stdio"`, `"http"` (alias `"streamable-http"`), or `"sse"` |
| `alwaysLoad` | no | Boolean; always load tools into context at session start. Requires v2.1.121 |
| `oauth` | no (http/sse) | OAuth configuration object |
| `headersHelper` | no (http) | Script/command that outputs JSON of headers |

## Transport: `stdio`

Local subprocess. Default when `command` is present.

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"stdio"` |
| `command` | yes | Executable path |
| `args` | no | Array of command arguments |
| `env` | no | Object of environment variable key-value pairs (strings only) |

```json
{
  "mcpServers": {
    "myserver": {
      "type": "stdio",
      "command": "/usr/local/bin/my-mcp-server",
      "args": ["--port", "stdio"],
      "env": { "API_KEY": "${MY_API_KEY}" }
    }
  }
}
```

## Transport: `http`

Remote HTTP (Streamable HTTP). Preferred over `sse` for new servers.

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"http"` or `"streamable-http"` |
| `url` | yes | Server URL |
| `headers` | no | Object of HTTP headers |
| `oauth` | no | OAuth config object |
| `headersHelper` | no | Shell command or inline command to generate headers dynamically |

```json
{
  "mcpServers": {
    "remote": {
      "type": "http",
      "url": "https://mcp.example.com/v1",
      "headers": {
        "Authorization": "Bearer ${MY_TOKEN}"
      }
    }
  }
}
```

### `headersHelper` env vars

| Variable | Value |
|---|---|
| `CLAUDE_CODE_MCP_SERVER_NAME` | Name of the MCP server |
| `CLAUDE_CODE_MCP_SERVER_URL` | URL of the MCP server |

## Transport: `sse` (deprecated)

Server-Sent Events. Deprecated in favor of `http`.

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"sse"` |
| `url` | yes | Server URL |
| `headers` | no | Object of HTTP headers |

## `oauth` object fields

| Field | Description |
|---|---|
| `clientId` | Pre-configured OAuth client ID |
| `callbackPort` | Fixed port for OAuth callback |
| `authServerMetadataUrl` | Override OAuth metadata discovery URL (`https://` required); v2.1.64+ |
| `scopes` | Space-separated scope string (RFC 6749 §3.3 format) |

## Environment variable expansion

Supported in: `command`, `args`, `env`, `url`, `headers`.

| Syntax | Behavior |
|---|---|
| `${VAR}` | Substitute env var value |
| `${VAR:-default}` | Substitute with fallback if VAR unset |

## Tool naming convention

MCP tools are named `mcp__<server>__<tool>` (double-underscore separator).

Examples:
- `mcp__filesystem__read_file` — `read_file` tool on the `filesystem` server
- `mcp__puppeteer__puppeteer_navigate`
- `mcp__memory__create_entities`

In permission rules and hook matchers:
- `mcp__puppeteer` — all tools from the `puppeteer` server
- `mcp__memory__.*` — all tools from `memory` (regex)
- `mcp__.*__write.*` — write-prefixed tools across all servers

## MCP output limits

| Setting | Value |
|---|---|
| Warning threshold | 10,000 tokens |
| Default max | 25,000 tokens |
| Override | `MAX_MCP_OUTPUT_TOKENS` env var |
| Per-tool override | `_meta["anthropic/maxResultSizeChars"]` in `tools/list` response (up to 500,000 chars) |

## Tool search (`ENABLE_TOOL_SEARCH`)

| Value | Behavior |
|---|---|
| (unset) | All MCP tools deferred; falls back to upfront on Vertex AI |
| `true` | All deferred, forces beta header |
| `auto` | Threshold mode: upfront if fits in 10% of context window |
| `auto:N` | Custom percentage threshold |
| `false` | All loaded upfront |

## Managed MCP configuration

**Option 1 — `managed-mcp.json`:** takes exclusive control; same format as `.mcp.json`.

**Option 2 — settings fields in `managed-settings.json`:**
- `allowedMcpServers` — allowlist
- `deniedMcpServers` — denylist

Each entry has exactly one of:
- `serverName` — matches configured server name
- `serverCommand` — array; exact match of command + args for stdio servers
- `serverUrl` — URL pattern with `*` wildcard

## Plugin MCP variables

When MCP config is inside a plugin:

| Variable | Value |
|---|---|
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |
| `${CLAUDE_PROJECT_DIR}` | Stable project root |

## CLI commands

```bash
claude mcp add --transport http <name> <url>
claude mcp add --transport sse <name> <url>
claude mcp add [options] <name> -- <command> [args...]
claude mcp add-json <name> '<json>'
claude mcp add-from-claude-desktop
claude mcp list
claude mcp get <name>
claude mcp remove <name>
claude mcp reset-project-choices
claude mcp serve   # run Claude Code as MCP server
```

Flags: `--scope local|project|user` (default `local`), `--env KEY=value`, `--header "Key: value"`, `--client-id`, `--client-secret`, `--callback-port`.

## Common mistakes (auto-corrected by `rules/mcp.md`)

- Use `command` for stdio servers, not `cmd`, `exec`, or `path`.
- HTTP / SSE servers require explicit `"type": "http"` or `"type": "sse"` plus a `url`.
- `env` values must be **strings** — numbers/booleans should be quoted.
- MCP server names in `.mcp.json` must not contain spaces or special chars (they become part of the tool name `mcp__<server>__<tool>`).

---

*Source pages: [`mcp.md`](https://code.claude.com/docs/en/mcp.md) — audited 2026-05-18.*
