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

Source: [`code.claude.com/docs/en/mcp.md`](https://code.claude.com/docs/en/mcp.md)

| Scope | File | Who it affects |
|---|---|---|
| Project | `.mcp.json` in repo root | All collaborators (commit to git) |
| User | `~/.claude.json` (under `mcpServers` key) | You, across all projects |
| Local (project-specific) | `~/.claude.json` (per-project section) | You, in this project only |

Add servers with `claude mcp add --scope project` (`.mcp.json`), `--scope user`, or `--scope local` (default). Older docs called these `global` (now `user`) and `project` (now `local`).

The server name `workspace` is reserved — Claude Code skips it at load time and shows a warning.

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

Local subprocess — the default transport. Claude Code spawns the command as a child process and communicates via stdin/stdout:

```json
{
  "mcpServers": {
    "airtable": {
      "command": "npx",
      "args": ["-y", "airtable-mcp-server@1.2.3"],
      "env": { "AIRTABLE_API_KEY": "your-key" }
    }
  }
}
```

**Always pin versions** — bare `npx -y @scope/server` resolves to the latest version every startup, exposing you to supply-chain attacks.

Claude Code sets `CLAUDE_PROJECT_DIR` in the spawned server's environment (project root). Use `${CLAUDE_PROJECT_DIR:-.}` in user/project-scoped configs as a fallback — the substitution only happens inside plugin configs.

## Transport: `http`

Remote HTTP (Streamable HTTP / SSE-over-HTTP). The `type` field accepts `"http"` or `"streamable-http"` (they're aliases):

```json
{
  "mcpServers": {
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp",
      "headers": { "Authorization": "Bearer your-token" }
    }
  }
}
```

CLI: `claude mcp add --transport http notion https://mcp.notion.com/mcp`

Use `/mcp` in a session to authenticate HTTP servers that require OAuth 2.0.

Auto-reconnects on disconnect: up to 5 attempts with exponential backoff (1s, 2s, 4s, 8s, 16s). After 5 failures, server is marked failed; retry from `/mcp`.

## Transport: `sse`

Server-Sent Events — **deprecated**, use `http` instead where available:

```json
{
  "mcpServers": {
    "asana": {
      "type": "sse",
      "url": "https://mcp.asana.com/sse",
      "headers": { "X-API-Key": "your-key" }
    }
  }
}
```

## Tool naming convention

MCP tools appear in Claude Code as `mcp__<serverName>__<toolName>` (double-underscore separator).

Examples:
- `mcp__memory__create_entities` — Memory server's `create_entities` tool
- `mcp__filesystem__read_file` — Filesystem server's `read_file` tool
- `mcp__github__search_repositories` — GitHub server's `search_repositories` tool

Use these names in permission rules, hook matchers, and `--allowedTools`. To match all tools from a server in hook matchers: `mcp__memory__.*` (regex required — `mcp__memory` without `.*` matches nothing).

## CLI management commands

```bash
claude mcp add --transport http notion https://mcp.notion.com/mcp
claude mcp add --transport stdio airtable -- npx -y airtable-mcp-server
claude mcp add --scope project --env KEY=value myserver -- python server.py
claude mcp list
claude mcp get github
claude mcp remove github
```

**Scope flag:** `--scope local` (default, project-specific), `--scope project` (`.mcp.json`, committed), `--scope user` (all projects).

**`--env`**: inject env vars into the stdio server's environment.

Note: all options (`--transport`, `--env`, `--scope`, `--header`) must come **before** the server name. Use `--` to separate server name from its command and args.

## Channels (push notifications from MCP)

An MCP server can push messages into a session by declaring the `claude/channel` capability. Opt in per session with `--channels plugin:<name>@<marketplace>`. See [`code.claude.com/docs/en/channels.md`](https://code.claude.com/docs/en/channels.md).

## Managed MCP configuration

Admins can control MCP via managed settings:
- `allowedMcpServers`: allowlist (undefined = no restrictions, `[]` = lockdown)
- `deniedMcpServers`: denylist (takes precedence over allowlist)
- `allowManagedMcpServersOnly`: only admin allowlist respected
- `disabledMcpjsonServers`: list of specific `.mcp.json` servers to reject
- `enabledMcpjsonServers`: list of `.mcp.json` servers to auto-approve

## Common mistakes (auto-corrected by `rules/mcp.md`)

- Using `type: "sse"` for new servers — use `type: "http"` instead (SSE is deprecated).
- Forgetting to pin package versions (`npx -y @scope/server` without `@version`) — supply-chain risk.
- Using `mcp__memory` as a hook matcher without `.*` — this exact-matches the string and matches no real tool name.
- Putting all options after the server name instead of before it in `claude mcp add` — options after the name are treated as server command arguments.
- Not using `--scope project` when you want `.mcp.json` to be committed to git.

---

*Source pages: [`code.claude.com/docs/en/mcp.md`](https://code.claude.com/docs/en/mcp.md), [`channels.md`](https://code.claude.com/docs/en/channels.md).*

---

*Source pages: `code.claude.com/docs/en/mcp.md`.*
