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

MCP servers can be configured at different scopes:

| Scope | Storage location | Who it affects |
|---|---|---|
| `local` (default) | `~/.claude.json` (per-project entry) | You, in this project only |
| `project` | `.mcp.json` in project root | All collaborators (committed to git) |
| `user` | `~/.claude.json` (global entry) | You, across all projects |

Use `--scope` flag with `claude mcp add` to pick scope. Old names `project` (was `local`) and `global` (was `user`) still accepted.

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

Local subprocess. The `command` field implies stdio (default when `type` is absent).

```bash
claude mcp add --transport stdio --env AIRTABLE_API_KEY=YOUR_KEY airtable \
  -- npx -y airtable-mcp-server
```

**Important**: all `--` options must come BEFORE the server name; `--` separates the server name from the subprocess command.

Claude Code sets `CLAUDE_PROJECT_DIR` in the spawned server's environment (the project root). In `.mcp.json` command/args, reference it as `${CLAUDE_PROJECT_DIR:-.}` (with default) since shell expansion may not be available.

## Transport: `http`

Remote HTTP (recommended for cloud services). `streamable-http` is accepted as an alias for `http` in JSON configs.

```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport http secure-api https://api.example.com/mcp \
  --header "Authorization: Bearer your-token"
```

Auto-reconnects on disconnect: up to 5 attempts with exponential backoff (starting at 1 s, doubling). After 5 failures, marked as failed.

## Transport: `sse`

⚠️ **Deprecated.** Use HTTP transport instead.

```bash
claude mcp add --transport sse asana https://mcp.asana.com/sse
```

## Tool naming convention

MCP tools are named `mcp__<server-name>__<tool-name>` (double-underscore separators). The server name comes from the key in `mcpServers`. Use this in permission rules:

```json
{ "permissions": { "allow": ["mcp__github__create_issue"] } }
```

MCP prompts appear as commands: `/mcp__<server>__<prompt-name>`.

## Managing MCP servers

```bash
claude mcp list          # list all configured servers
claude mcp get github    # details for a specific server
claude mcp remove github # remove a server
```

Inside a session, `/mcp` shows server status, tool count, and OAuth auth. The `/mcp` panel flags servers that advertise tools capability but expose no tools.

**Managed MCP configuration** (enterprise): Admins can allowlist/denylist servers via `allowedMcpServers`/`deniedMcpServers` in managed-settings.json, and set `allowManagedMcpServersOnly: true` to restrict users to admin-defined servers only.

Env vars: `MCP_TIMEOUT=10000` sets startup timeout (ms). `MAX_MCP_OUTPUT_TOKENS=50000` increases the 10k-token output limit.

## Worked examples

**stdio server with version pin (`.mcp.json`):**

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

**HTTP server with auth:**

```json
{
  "mcpServers": {
    "my-api": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": { "Authorization": "Bearer ${MY_TOKEN}" }
    }
  }
}
```

Source: `code.claude.com/docs/en/mcp.md`.

## Common mistakes (auto-corrected by `rules/mcp.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/mcp.md`.*
