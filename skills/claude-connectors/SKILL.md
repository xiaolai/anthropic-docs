---
name: claude-connectors
description: |
  Router skill for Claude Connectors (the user-facing MCP integration
  surface on claude.com), Claude Desktop extensions (MCPB packaging),
  MCP Apps for Claude Desktop with their visual + interaction design
  guidelines, the directory of pre-built integrations (GitHub, Google
  Workspace, Microsoft 365, Slack, …), the user-facing Agent Skills
  surface, and the user-facing Plugins surface.

  Use when the user asks about: enabling a connector in the Claude
  app, building a custom connector, packaging a Desktop extension
  (MCPB), MCP Apps visual / interaction design rules, submitting to
  the connectors directory, OAuth + token handling for connectors,
  the GitHub / Google / Microsoft / Slack connector integrations,
  authoring user-installable Skills, or installing plugins via the
  Claude app.

  Skip: low-level MCP protocol spec (use mcp-spec), MCP servers run
  by Claude Code CLI (use claude-code), MCP connector exposed by
  the API (use anthropic-platform-features → SKILL-agents-and-tools).
user-invocable: true
---

# Claude Connectors + Desktop + Design — Router

| Field | Value |
|---|---|
| **Source docs** | [claude.com/docs/en/connectors](https://claude.com/docs/en/connectors) |

> **This skill is auto-updated daily.** A pipeline reads the upstream
> docs and rewrites the per-surface files below. Section structure is
> stable; content drifts to track upstream.

## Dispatch table

| Surface file | Read when the user asks about… |
|---|---|
| [`SKILL-connectors-overview.md`](SKILL-connectors-overview.md) | what connectors are, enabling them, the directory listing, the GitHub / Google / Microsoft / Slack first-party connectors |
| [`SKILL-connectors-building.md`](SKILL-connectors-building.md) | building a custom connector, OAuth / token handling, submission process, testing & debugging connectors |
| [`SKILL-mcp-apps.md`](SKILL-mcp-apps.md) | MCPB packaging for Claude Desktop, MCP Apps visual & interaction design guidelines, app surface conventions |
| [`SKILL-claude-skills.md`](SKILL-claude-skills.md) | user-facing Agent Skills (`.skill` packages), installing / managing skills in the Claude app |
| [`SKILL-claude-plugins.md`](SKILL-claude-plugins.md) | user-facing plugins in the Claude app, plugin marketplaces, plugin install / scope |

---

*This skill is auto-updated daily by a maintainer-run pipeline. File
issues at [xiaolai/claude-code-documentation-knowledge-autoupdated](https://github.com/xiaolai/claude-code-documentation-knowledge-autoupdated).*
