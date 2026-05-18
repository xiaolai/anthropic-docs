---
name: claude-code-mcp
description: |
  Deep reference for configuring MCP (Model Context Protocol) servers
  in Claude Code. Covers `.mcp.json` schema, the three transports
  (stdio / http / sse), server config keys (command, args, url, env,
  headers, oauth, alwaysLoad), the `mcp__<server>__<tool>` naming
  convention for invoking MCP tools, scope (project / user / local),
  managed MCP configuration, and CLI commands. Read this file when
  the user asks about MCP setup, `.mcp.json`, MCP transports, MCP
  tool naming, or managed MCP restrictions.
source: https://code.claude.com/docs/en/mcp.md
---

# Claude Code — MCP server config (`.mcp.json`)

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for MCP questions.*

## File scope

| Scope | File | Who it affects | Tracked in git? |
|---|---|---|---|
| Project | `.mcp.json` at repo root | All team members | Yes |
| User | `~/.claude.json` (mcpServers section) | You, all projects | No |
| Local | `~/.claude.json` (per-project section) | You, this project only | No |

Precedence for duplicate server names (first wins):
1. Local (`~/.claude.json`)
2. Project (`.mcp.json`)
3. User (`~/.claude.json`)
4. Plugin-provided servers
5. Claude.ai connectors

## Top-level `.mcp.json` shape

```json
{
  "mcpServers": {
    "<server-name>": { /* server config */ }
  }
}
```

`mcpServers` is the only top-level key. The server name becomes the prefix in tool names (`mcp__<server-name>__<tool>`).

**Security: always pin MCP server versions.** The bare `npx -y @scope/server` pattern resolves to the latest version on every startup — a supply-chain compromise of a future release runs immediately. MCP servers commonly request filesystem/network capabilities.

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

## Per-server config keys

| Key | Type | Required | Applies to | Notes |
|---|---|---|---|---|
| `type` | string | no | all | `"stdio"` (default when `command` set), `"http"` (or `"streamable-http"`), `"sse"` (deprecated) |
| `command` | string | yes (stdio) | stdio | Executable path |
| `args` | array | no | stdio | Command arguments |
| `url` | string | yes (http/sse) | http, sse | Transport endpoint URL |
| `env` | object | no | all | Extra environment variables for server process |
| `headers` | object | no | http, sse | Static request headers |
| `headersHelper` | string | no | http | Command to generate headers dynamically |
| `oauth` | object | no | http | OAuth 2.0 configuration (see below) |
| `alwaysLoad` | bool | no | all | Load tools at session start without lazy discovery. Requires v2.1.121+ |

### OAuth configuration (`oauth` key)

| Key | Notes |
|---|---|
| `clientId` | Pre-configured OAuth client ID |
| `clientSecret` | Pre-configured secret (stored in keychain, not config file) |
| `callbackPort` | Fixed port for OAuth callback |
| `authServerMetadataUrl` | Custom OAuth metadata endpoint URL |
| `scopes` | Space-separated OAuth scopes to request |

## Transport types

### `stdio` (default)

Local subprocess, spawned by Claude Code. Sets `CLAUDE_PROJECT_DIR` in the server process environment.

```json
{
  "mcpServers": {
    "my-server": {
      "command": "/usr/local/bin/my-mcp-server",
      "args": ["--port", "0"],
      "env": { "MY_API_KEY": "${MY_API_KEY}" }
    }
  }
}
```

### `http` (recommended for remote)

Streamable HTTP transport. Supports OAuth 2.0, auto-reconnection with backoff.

```json
{
  "mcpServers": {
    "remote-api": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": { "Authorization": "Bearer ${API_TOKEN}" },
      "oauth": { "clientId": "my-client", "scopes": "read write" }
    }
  }
}
```

### `sse` (deprecated)

Server-Sent Events transport. Use `http` for new servers.

```json
{
  "mcpServers": {
    "legacy": {
      "type": "sse",
      "url": "https://api.example.com/sse",
      "headers": { "Authorization": "Bearer ${TOKEN}" }
    }
  }
}
```

## Environment variable expansion

Syntax: `${VAR}` or `${VAR:-default}` in `command`, `args`, `env`, `url`, `headers`.

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github@1.0.0"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN:-}" }
    }
  }
}
```

## Tool naming convention

MCP tool names follow `mcp__<server-name>__<tool-name>` (double underscore separators).

Examples:
- Server `github`, tool `search_repositories` → `mcp__github__search_repositories`
- Server `filesystem`, tool `read_file` → `mcp__filesystem__read_file`

**In permission rules (allow/deny/ask):**
- `mcp__github` — all tools from the `github` server
- `mcp__github__search_repositories` — exact tool
- `mcp__github__.*` — all tools from `github` (regex)

## Managed MCP configuration

For enterprise deployments, admins can control MCP server access via managed settings or a separate `managed-mcp.json` file.

**`managed-mcp.json` paths:**
- macOS: `/Library/Application Support/ClaudeCode/`
- Linux/WSL: `/etc/claude-code/`
- Windows: `C:\Program Files\ClaudeCode\`

### Managed settings keys for MCP

| Key | Notes |
|---|---|
| `allowedMcpServers` | Array of allowlist entries. `undefined`=no restriction, `[]`=lockdown all |
| `deniedMcpServers` | Array of denylist entries. Applies to all scopes. Takes precedence over allowlist |
| `allowManagedMcpServersOnly` | Only managed allowlist respected; denylist still merges from all scopes |
| `disabledMcpjsonServers` | Array of specific `.mcp.json` server names to reject |
| `enabledMcpjsonServers` | Array of specific `.mcp.json` server names to approve |
| `enableAllProjectMcpServers` | Auto-approve all project `.mcp.json` servers |

### Allowlist/denylist entry structure

Exactly one of these fields per entry:

| Entry type | Example |
|---|---|
| By server name | `{"serverName": "github"}` |
| By command (exact array match) | `{"serverCommand": ["npx", "-y", "@scope/server@1.0.0", "/path"]}` |
| By URL pattern (`*` wildcard) | `{"serverUrl": "https://api.example.com/*"}` |

## CLI commands

```bash
# Add a stdio server
claude mcp add --transport stdio myserver /path/to/server --arg1 --arg2

# Add an HTTP server
claude mcp add --transport http myserver https://api.example.com/mcp

# Add from raw JSON
claude mcp add-json myserver '{"type":"http","url":"https://api.example.com/mcp"}'

# List servers
claude mcp list

# Get server details
claude mcp get myserver

# Remove a server
claude mcp remove myserver

# Reset project MCP choices (re-ask trust prompts)
claude mcp reset-project-choices
```

## Common mistakes (auto-corrected by `rules/mcp.md`)

Cross-reference: [`rules/mcp.md`](rules/mcp.md)

---

*Source pages: [`code.claude.com/docs/en/mcp.md`](https://code.claude.com/docs/en/mcp.md)*
