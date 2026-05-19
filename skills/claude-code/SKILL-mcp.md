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

MCP servers can be configured at three scopes. Choose based on who needs the server and whether credentials should be committed.

| Scope | Stored in | Shared with team | Loads in |
|---|---|---|---|
| `local` (default) | `~/.claude.json` (under the project's path) | No | Current project only |
| `project` | `.mcp.json` at project root | Yes, via version control | Current project only |
| `user` | `~/.claude.json` (global section) | No | All your projects |

- **Project scope** (`.mcp.json`): checked into git, shared with the whole team. Claude Code prompts for trust approval before loading project-scoped servers. Reset approvals with `claude mcp reset-project-choices`.
- **User scope** (`~/.claude.json`): personal servers available in every project.
- **Local scope** (`~/.claude.json`, per-project entry): personal servers for one project only; use when credentials must not be committed.

The reserved server name `workspace` is skipped at load time with a warning — rename any server with that name.

## Top-level shape

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

Stdio servers run as local child processes. They are ideal for tools that need direct system access or custom scripts. Claude Code sets `CLAUDE_PROJECT_DIR` in the spawned server's environment to the project root.

Full schema:

```json
{
  "mcpServers": {
    "<name>": {
      "command": "<executable>",
      "args": ["<arg1>", "<arg2>"],
      "env": {
        "KEY": "value",
        "SECRET": "${MY_SECRET_ENV_VAR}"
      }
    }
  }
}
```

Key fields:
- `command` — the executable to run (implies `stdio` transport when `type` is absent)
- `args` — array of command-line arguments passed to the server
- `env` — environment variables injected into the server process; supports `${VAR}` and `${VAR:-default}` expansion

The `type` field can be set to `"stdio"` explicitly but is optional when `command` is present.

CLI equivalent:
```bash
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

All options (`--transport`, `--env`, `--scope`) must come **before** the server name. The `--` separates the server name from the command and its own arguments.

Stdio servers are not auto-reconnected after a crash; restart the session to reconnect.

## Transport: `http`

HTTP (streamable-HTTP) is the recommended transport for remote/cloud services. The `type` field accepts both `"http"` and `"streamable-http"` (the MCP spec name) as aliases.

Full schema:

```json
{
  "mcpServers": {
    "<name>": {
      "type": "http",
      "url": "https://mcp.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${API_TOKEN}"
      },
      "oauth": {
        "clientId": "your-client-id",
        "callbackPort": 8080,
        "scopes": "read write",
        "authServerMetadataUrl": "https://auth.example.com/.well-known/openid-configuration"
      },
      "headersHelper": "/path/to/script-that-prints-json-headers.sh",
      "alwaysLoad": false
    }
  }
}
```

Key fields:
- `type` — `"http"` or `"streamable-http"` (equivalent)
- `url` — the MCP endpoint URL; supports `${VAR}` expansion
- `headers` — static headers merged into every request; supports `${VAR}` expansion
- `oauth` — optional OAuth 2.0 config (for servers requiring browser-based login via `/mcp`)
  - `clientId` — pre-registered client ID (omit for dynamic client registration)
  - `callbackPort` — fixed OAuth redirect port matching a pre-registered redirect URI
  - `scopes` — space-separated scope string (RFC 6749 format); overrides server-advertised scopes
  - `authServerMetadataUrl` — override the OAuth metadata discovery URL
- `headersHelper` — shell command run at connect time; must print a JSON object of `{"Header": "value"}` to stdout; used for Kerberos, short-lived tokens, or SSO
- `alwaysLoad` — when `true`, this server's tools load into context at startup instead of being deferred by tool search

HTTP servers reconnect automatically with exponential backoff (up to 5 attempts, starting at 1 second).

CLI equivalent:
```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_GITHUB_PAT"
```

## Transport: `sse`

> **SSE transport is deprecated.** Use HTTP servers where available.

SSE (Server-Sent Events) transport connects to a remote URL that streams events. Same structure as HTTP but with `"type": "sse"`.

```json
{
  "mcpServers": {
    "<name>": {
      "type": "sse",
      "url": "https://mcp.example.com/sse",
      "headers": {
        "X-API-Key": "${API_KEY}"
      }
    }
  }
}
```

Use SSE only when connecting to a legacy server that does not support the streamable-HTTP transport. For new deployments, prefer `"type": "http"`.

SSE servers also support automatic reconnection with exponential backoff (same policy as HTTP).

CLI equivalent:
```bash
claude mcp add --transport sse asana https://mcp.asana.com/sse
```

## Tool naming convention

MCP tools appear in Claude Code (and in permission rules) under the pattern:

```
mcp__<server-name>__<tool-name>
```

Two underscores separate each component. Server and prompt names are normalized — spaces become underscores.

Examples:
- Server `github`, tool `create_pull_request` → `mcp__github__create_pull_request`
- Server `my tools`, tool `search` → `mcp__my_tools__search`

The same pattern applies to:
- **Permission rules**: `mcp__puppeteer__puppeteer_navigate` (exact), `mcp__puppeteer` (all tools from server), `mcp__puppeteer__*` (wildcard equivalent)
- **Slash commands for MCP prompts**: `/mcp__github__list_prs`, `/mcp__jira__create_issue "Bug" high`

To skip the `mcp__<server>__` prefix in SDK-only usage, set `CLAUDE_AGENT_SDK_MCP_NO_PREFIX=1`.

## Capabilities declaration

The `capabilities` key is not directly set in `.mcp.json` by users. Instead, capabilities are declared by the MCP server itself in its `initialize` response. Claude Code reads and respects them automatically.

Notable capability behaviors in Claude Code:
- Servers that advertise the `tools` capability but expose no tools are flagged in the `/mcp` panel.
- Servers can push live updates via `list_changed` notifications — Claude Code auto-refreshes tool/prompt/resource lists without reconnecting.
- Servers that declare `claude/channel` capability can push messages into the session (see Channels docs); opt in with `--channels` at startup.
- Set `alwaysLoad: true` on a server entry to force all its tools into the upfront context regardless of tool search settings.

The `/mcp` panel in-session shows tool counts per server and connection status.

## Worked examples

**Connect to GitHub for code reviews (HTTP with static auth header):**
```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/ \
  --header "Authorization: Bearer YOUR_GITHUB_PAT"
```

**Query a PostgreSQL database (stdio):**
```bash
claude mcp add --transport stdio db -- npx -y @bytebase/dbhub \
  --dsn "postgresql://readonly:pass@prod.db.com:5432/analytics"
```

**Monitor errors with Sentry (HTTP with OAuth):**
```bash
claude mcp add --transport http sentry https://mcp.sentry.dev/mcp
# Then authenticate in-session:
/mcp
```

**Project-scoped `.mcp.json` with env var expansion:**
```json
{
  "mcpServers": {
    "api-server": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    },
    "local-tools": {
      "command": "npx",
      "args": ["-y", "my-mcp-server@1.2.3"],
      "env": {
        "PROJECT_ROOT": "${CLAUDE_PROJECT_DIR:-.}"
      }
    }
  }
}
```

**Managed enterprise deployment (`managed-mcp.json`):**
```json
{
  "mcpServers": {
    "github": { "type": "http", "url": "https://api.githubcopilot.com/mcp/" },
    "company-internal": {
      "type": "stdio",
      "command": "/usr/local/bin/company-mcp-server",
      "args": ["--config", "/etc/company/mcp-config.json"]
    }
  }
}
```
System paths: macOS `/Library/Application Support/ClaudeCode/managed-mcp.json`, Linux/WSL `/etc/claude-code/managed-mcp.json`.

## Common mistakes (auto-corrected by `rules/mcp.md`)

1. **Options after the server name for stdio servers.** All flags (`--transport`, `--env`, `--scope`, `--header`) must come _before_ the server name. The `--` separator must precede the command and its arguments. Wrong: `claude mcp add myserver --env KEY=val -- npx srv`. Right: `claude mcp add --env KEY=val myserver -- npx srv`.

2. **Using the `workspace` server name.** This name is reserved for internal use. Claude Code silently skips any server named `workspace` at load time and displays a warning. Rename it to something else.

3. **Missing `type` field for remote servers.** When writing `.mcp.json` by hand for HTTP or SSE servers, omitting `"type"` causes Claude Code to treat the entry as stdio and try to spawn it as a process. Always include `"type": "http"` or `"type": "sse"` for remote servers.

4. **Unset required env vars without defaults.** If a `${VAR}` reference in `.mcp.json` has no value in the environment and no `:-default`, Claude Code fails to parse the config entirely. Either set the variable in your shell before launching or provide a default: `${VAR:-fallback}`.

5. **Not pinning stdio server versions.** Using `npx -y @scope/server` without a version tag silently upgrades to the latest published version on every startup, which can introduce breaking changes or supply-chain risks. Pin with `npx -y @scope/server@1.2.3`.

---

*Source pages: `code.claude.com/docs/en/mcp.md`.*
