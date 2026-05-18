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

Source: [`mcp.md`](https://code.claude.com/docs/en/mcp.md).

| Scope | Stored in | Loads in | Shared? |
|---|---|---|---|
| Local (default) | `~/.claude.json` (per-project entry) | Current project only | No |
| Project | `.mcp.json` at project root | Current project only | Yes (version control) |
| User | `~/.claude.json` (top-level) | All your projects | No |

**Scope precedence** (when same server name appears in multiple scopes): Local > Project > User > Plugin-provided > claude.ai connectors. Plugins and connectors match by endpoint, not name.

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

Runs a local subprocess. Default when no `type` field is set. Best for tools that need direct system access.

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "@scope/server@1.2.3", "--option"],
      "env": { "API_KEY": "${MY_API_KEY}" }
    }
  }
}
```

`CLAUDE_PROJECT_DIR` is set in the spawned process's environment to the project root. Use `${CLAUDE_PROJECT_DIR:-}` with a default when referencing it in `command`/`args` outside plugin-provided configs.

**Pin versions.** The bare `npx -y @scope/server` pattern (no version pin) resolves to latest on every startup — a supply-chain compromise runs with whatever capabilities the server requests. Always pin: `@scope/server@1.2.3`.

CLI: `claude mcp add [options] <name> -- <command> [args...]`

## Transport: `http`

Recommended for cloud-based services. The MCP specification calls this `streamable-http`; both `type: "http"` and `type: "streamable-http"` are accepted.

```json
{
  "mcpServers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp",
      "headers": { "Authorization": "Bearer ${NOTION_TOKEN}" }
    }
  }
}
```

Environment variable expansion supported in `url` and `headers`: `${VAR}` (required) and `${VAR:-default}` (with fallback). CLI: `claude mcp add --transport http <name> <url> [--header "Key: value"]`

Automatic reconnection with exponential backoff (up to 5 attempts, 1s initial delay, doubles each time) on disconnect. As of v2.1.121, initial connection also retries up to 3 times on transient errors.

## Transport: `sse`

**Deprecated** — use `http` instead where available. Still functional; same reconnection behavior as `http`.

```json
{
  "mcpServers": {
    "legacy-server": {
      "type": "sse",
      "url": "https://api.example.com/sse",
      "headers": { "X-API-Key": "${MY_KEY}" }
    }
  }
}
```

CLI: `claude mcp add --transport sse <name> <url>`

## Tool naming convention

MCP tools are exposed to Claude as `mcp__<server-name>__<tool-name>` (double-underscore separators). The server name comes from the key in `mcpServers`.

Examples:
- `mcp__memory__create_entities` — tool `create_entities` on the `memory` server
- `mcp__github__search_repositories` — tool `search_repositories` on the `github` server

Use this naming in permission rules, hook matchers, and `--allowedTools`:
```json
{ "permissions": { "allow": ["mcp__github__search_repositories"] } }
```

In hook matchers: `mcp__memory__.*` matches all tools from the `memory` server (the `.*` is required; bare `mcp__memory` is an exact string that matches nothing).

**Reserved server name:** `workspace` is reserved for internal use. If your config defines a server with that name, Claude Code skips it and warns you to rename it.

## Capabilities declaration and managed MCP configuration

**Dynamic tool updates:** Servers that send `list_changed` notifications let Claude Code refresh tools, prompts, and resources without reconnecting.

**OAuth:** For remote servers that require OAuth 2.0, run `/mcp` inside Claude Code to authenticate.

**MCP timeout:** Set `MCP_TIMEOUT=10000 claude` (ms) to control server startup timeout. `MAX_MCP_OUTPUT_TOKENS=50000` raises the 10k-token output warning threshold.

**Managed MCP (enterprise):** Admins can pre-configure servers in `managed-settings.json` via `allowedMcpServers` (allowlist), `deniedMcpServers` (denylist), and `allowManagedMcpServersOnly` (enforce allowlist). See [`settings.md`](https://code.claude.com/docs/en/settings.md) § *Managed-only settings* and [`SKILL-settings.md`](SKILL-settings.md).

## Worked examples

> *Populated by the research agent.* See also:
> [`templates/.mcp.json`](templates/.mcp.json).

## Common mistakes (auto-corrected by `rules/mcp.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/mcp.md`.*
