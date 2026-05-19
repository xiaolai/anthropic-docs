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

MCP servers can be configured at three scopes:

| Scope | Location | Shareable |
|---|---|---|
| Project | `<project>/.mcp.json` | Yes (commit to git) |
| User | `~/.claude.json` (via `claude mcp add` default) or user-scope MCP config | No |
| Local | Added with `claude mcp add --scope local` | No |

Scope hierarchy: local → project → user. Servers at all three scopes are combined and presented to Claude; if the same server name appears in multiple scopes, local takes precedence.

`CLAUDE_PROJECT_DIR` is set in every spawned MCP server's environment, pointing to the project root.

Source: [code.claude.com/docs/en/mcp.md](https://code.claude.com/docs/en/mcp.md)

## Top-level shape

`.mcp.json` has a single top-level key `mcpServers`. Each key is the server name (used in tool naming):

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem@0.6.2", "/Users/me/projects"]
    },
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp"
    }
  }
}
```

**Pin your MCP server versions.** Bare `npx -y @scope/server` (no version pin) resolves to the latest version on every startup — a supply-chain risk if any future release is compromised.

## Transport: `stdio` (local process)

Omitting `type` (or setting `"type": "stdio"`) starts a local subprocess. Claude Code communicates over its stdin/stdout.

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["/path/to/server.js"],
      "env": {
        "MY_API_KEY": "..."
      }
    }
  }
}
```

| Field | Required | Notes |
|---|---|---|
| `command` | yes | Executable to run |
| `args` | no | Array of string arguments |
| `env` | no | Additional env vars for the process |

Add via CLI:
```bash
claude mcp add --transport stdio my-server node /path/to/server.js
```

## Transport: `http` (remote streamable HTTP)

Recommended for cloud-based services. `"type": "http"` or `"type": "streamable-http"` (alias, per MCP spec).

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

| Field | Required | Notes |
|---|---|---|
| `type` | yes | `"http"` or `"streamable-http"` |
| `url` | yes | Transport endpoint URL |
| `headers` | no | Static auth headers |

Add via CLI:
```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp \
  --header "Authorization: Bearer your-token"
```

## Transport: `sse` (Server-Sent Events)

> **Deprecated**: prefer HTTP transport where available.

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

MCP tools surface in Claude's tool list as `mcp__<server>__<tool>`:

- `mcp__memory__create_entities` — memory server's create entities tool
- `mcp__filesystem__read_file` — filesystem server's read file tool
- `mcp__github__search_repositories` — GitHub server's search tool

**Double-underscore separator** between server name and tool name.

To match all tools from a server in hooks or permission rules:
- `mcp__memory__.*` — all memory server tools (note: `.*` required; plain `mcp__memory` matches no tool)
- `mcp__.*__write.*` — any tool named `write*` from any server

## Capabilities and managed MCP settings

In managed settings (`managed-settings.json`), admins can control which MCP servers users can add:

| Setting key | Effect |
|---|---|
| `allowedMcpServers` | Allowlist of server names users can configure |
| `deniedMcpServers` | Denylist of server names explicitly blocked (takes precedence) |
| `allowManagedMcpServersOnly` | Only managed-settings allowlist is respected |

## Environment variable expansion in `.mcp.json`

`.mcp.json` supports `${ENV_VAR}` syntax for environment variable expansion in `url`, `headers`, and `env` fields:

```json
{
  "mcpServers": {
    "api": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": {
        "Authorization": "Bearer ${MY_API_TOKEN}"
      }
    }
  }
}
```

## CLI management commands

```bash
# Add a server
claude mcp add --transport http notion https://mcp.notion.com/mcp

# List configured servers
claude mcp list

# Remove a server
claude mcp remove notion

# Check server status (in-session)
/mcp

# Add from JSON
claude mcp add-json my-server '{"command":"node","args":["/path/server.js"]}'

# Import from Claude Desktop config
claude mcp import-from-claude-desktop
```

## OAuth authentication for remote servers

Run `claude mcp add --transport http <name> <url>` and Claude Code opens a browser for OAuth. Tokens are stored securely and refreshed automatically.

For a fixed callback port (when default fails):
```bash
claude mcp add --transport http --oauth-port 8080 my-server https://api.example.com/mcp
```

## Common mistakes (auto-corrected by `rules/mcp.md`)

- Using `mcp__memory` (no `.*`) as a matcher — matches nothing; must be `mcp__memory__.*`.
- Omitting version pin in `npx -y @scope/server` — resolves latest on every startup; pin with `@version`.
- Setting `type: "streamable-http"` when docs show `"http"` — both work (`streamable-http` is the MCP spec name).
- Confusing project `.mcp.json` (in project root) with user config (`~/.claude.json`).

---

*Source pages: [code.claude.com/docs/en/mcp.md](https://code.claude.com/docs/en/mcp.md).*
