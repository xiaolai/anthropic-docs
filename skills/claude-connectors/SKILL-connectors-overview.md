---
name: claude-connectors-overview
description: |
  Deep reference for Claude Connectors — what they are, how the
  directory works, and the four first-party integrations (Google,
  GitHub, Microsoft 365, Slack). Covers connector lifecycle (enable,
  authenticate, scope, revoke), the difference between directory
  vs custom connectors, and platform availability (Claude.ai,
  Desktop, Mobile, Code, Cowork).
source: https://claude.com/docs/connectors/overview.md
---

# Claude Connectors — Overview & Directory

> *Router lives in [`SKILL.md`](SKILL.md). For *building* a custom
> connector, see [`SKILL-connectors-building.md`](SKILL-connectors-building.md).
> For Desktop MCPB packaging or MCP Apps design, see
> [`SKILL-mcp-apps.md`](SKILL-mcp-apps.md).*

## What connectors are

Connectors extend Claude by connecting it to external tools and data
via the [Model Context Protocol (MCP)](https://modelcontextprotocol.io)
— an open standard from Anthropic for AI ↔ tool interop.

A connector can do two things:

1. **Provide tools + information** — give Claude access to external
   data and the ability to take actions (search files, read emails,
   create issues, query databases).
2. **Surface UI components** — render interactive visual elements
   directly in the conversation via [MCP Apps](SKILL-mcp-apps.md).

## Connector types

| Type | Purpose | Source page |
|---|---|---|
| **Prebuilt integrations** | First-party Anthropic-maintained — Google Workspace, GitHub, M365, Slack | [`getting-started.md`](https://claude.com/docs/connectors/getting-started.md) |
| **Remote MCP servers** | Cloud-hosted MCP servers reachable over HTTPS | [`custom/remote-mcp.md`](https://claude.com/docs/connectors/custom/remote-mcp.md) |
| **MCP Apps** | MCP servers that render UI in the conversation | [`building/mcp-apps/getting-started.md`](https://claude.com/docs/connectors/building/mcp-apps/getting-started.md) |
| **MCP Bundles (MCPB)** | Local MCP servers packaged as Desktop extensions (.mcpb) | [`custom/desktop-extensions.md`](https://claude.com/docs/connectors/custom/desktop-extensions.md) |
| **Self-serve local MCP** | Local servers distributed via npm/PyPI (not directly directory-listable — package as MCPB or bundle in a plugin using `.mcp.json` for directory listing) | [`overview.md`](https://claude.com/docs/connectors/overview.md) |

## Connectors Directory

The [Connectors Directory](https://claude.com/docs/connectors/directory.md)
is the open catalog of Anthropic-vetted third-party MCP servers,
available across all Claude products. Each entry has been reviewed
for tool annotations, privacy policy, working examples, and test
credentials (where applicable).

To submit your own: see [`building/submission.md`](https://claude.com/docs/connectors/building/submission.md).

## First-party integrations

### Google Workspace

| Service | Source |
|---|---|
| Google Calendar | [`google/calendar.md`](https://claude.com/docs/connectors/google/calendar.md) |
| Google Drive | [`google/drive.md`](https://claude.com/docs/connectors/google/drive.md) |
| Gmail | [`google/gmail.md`](https://claude.com/docs/connectors/google/gmail.md) |

### GitHub

| Surface | Source |
|---|---|
| GitHub repos integration | [`github/index.md`](https://claude.com/docs/connectors/github/index.md) |

### Microsoft 365

| Surface | Source |
|---|---|
| M365 (Outlook, Teams, OneDrive, etc.) | [`microsoft/365.md`](https://claude.com/docs/connectors/microsoft/365.md) |

### Slack

| Surface | Source |
|---|---|
| Slack workspace integration | [`slack/index.md`](https://claude.com/docs/connectors/slack/index.md) |

## Enabling a connector

The user-facing setup flow for first-party integrations: see
[`getting-started.md`](https://claude.com/docs/connectors/getting-started.md).
General steps:

1. Open Claude → Settings → Connectors.
2. Select an integration.
3. Authenticate via the provider's OAuth flow.
4. Review and approve the requested scopes.
5. The connector becomes available in conversations; tools surface
   as `mcp__<connector>__<tool>` when invoked.

## Platform availability

Prebuilt integrations and directory connectors work across all
Claude products:

| Platform | Support |
|---|---|
| **Claude.ai (web)** | Full remote MCP + MCP Apps |
| **Claude Desktop** | Full MCP + local Desktop Extensions |
| **Claude Mobile** | Remote MCP access |
| **Claude Code (CLI)** | Remote MCP access + plugins |
| **Claude Cowork** | Full MCP + plugin support |

## Related: Plugins

Plugins bundle MCP connectors, Skills, slash commands, and sub-agents
into shareable capability packages. See
[`SKILL-claude-plugins.md`](SKILL-claude-plugins.md).

## Related: Skills

User-facing Agent Skills layer reusable task recipes on top of
connectors. See [`SKILL-claude-skills.md`](SKILL-claude-skills.md).

## Page index

All 12 source pages mirrored under
[`https://claude.com/docs/connectors/`](https://claude.com/docs/connectors/):

- `overview.md` — this surface's source
- `getting-started.md` — user-facing setup flow
- `directory.md` — directory catalog
- `custom/remote-mcp.md` — remote MCP background
- `custom/desktop-extensions.md` — MCPB background
- `google/{calendar,drive,gmail}.md` — Google Workspace integrations
- `github/index.md` — GitHub integration
- `microsoft/365.md` — M365 integration
- `slack/index.md` — Slack integration

---

*Source pages: 12 under `claude.com/docs/connectors/` (excluding the
`building/` subtree which is covered by `SKILL-connectors-building.md`
and `SKILL-mcp-apps.md`).*
