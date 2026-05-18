---
name: claude-plugins-user-facing
description: |
  Deep reference for user-facing Plugins in the Claude app — how
  users discover, install, manage, and configure plugins, and how
  plugin marketplaces work. Plugins bundle MCP connectors, Skills,
  slash commands, and sub-agents into shareable capability packages.
source: https://claude.com/docs/plugins/overview.md
---

# Claude Plugins — User-Facing

> *Router lives in [`SKILL.md`](SKILL.md). For the Claude Code CLI
> side of plugins (manifest schema, marketplace.json, plugin
> authoring), see [`claude-code → SKILL-plugins.md`](../claude-code/SKILL-plugins.md).
> This surface covers what users see in the Claude app.*

## What plugins are (user view)

A plugin is a bundled package that combines:

- **MCP connectors** — action-taking integrations with external services.
- **Skills** — reusable task recipes.
- **Slash commands** — user-invocable shortcut commands.
- **Sub-agents** — specialized agents the plugin makes available.

Once installed, all four are wired together — a single install
gives the user the connector + the skills that compose it + the
commands that drive it.

## Where plugins are available

- **Claude Code (CLI)** — full plugin support (create, install, use).
- **Claude Cowork** — full plugin support; research preview for all
  paid Claude users (Pro, Max, Team, Enterprise). Org-wide sharing
  coming.

Plugins are **not** available on Claude.ai web or Mobile.

## Plugin directory

Anthropic has open-sourced 11 reference plugins available at
[`claude.com/plugins-for/cowork`](https://claude.com/plugins-for/cowork):
Productivity, Enterprise search, Sales, Finance, Data, Legal,
Marketing, Customer support, Product management, Biology research,
and Plugin Create.

Community plugins can be submitted; Anthropic performs basic automated
review. Plugins with an **"Anthropic Verified"** badge have additional
quality/safety review.

## Plugin marketplaces (Claude Code)

A marketplace is a directory of installable plugins, identified by
a URL pointing at a `marketplace.json` file. Users can:

- Browse plugins from any marketplace they trust.
- Install plugins from a marketplace with one command.
- Update / remove installed plugins.

Reference: [`code.claude.com/docs/en/plugin-marketplaces`](https://code.claude.com/docs/en/plugin-marketplaces).

## Installation scope

| Scope | Where | When to use |
|---|---|---|
| **User-global** | `~/.claude/plugins/` | Plugins you use across all projects |
| **Project-local** | `<project>/.claude/plugins/` | Plugins specific to one codebase, committed to repo |
| **Org-managed** | MDM-distributed | Cowork on 3P deployments |

## Plugin manifest (`plugin.json`) and composition

Plugins are file-based directories with a `plugin.json` manifest.
Components:

| Component | Config file | Notes |
|---|---|---|
| Skills | `SKILL.md` files in skills subdirs | Activate dynamically by context |
| MCP connectors | `.mcp.json` | Remote MCPs, local MCPs, or MCPBs |
| Slash commands | defined in `plugin.json` | User-triggered workflows |
| Sub-agents | defined in `plugin.json` | Delegated parallel workstreams |

**`SETUP.md`**: A special skill in a plugin that guides Claude through
configuring and connecting bundled MCP servers on install/activation.

**Validation**: `claude plugin validate` (before submission).

**Submission forms**:
- Claude.ai: `https://claude.ai/settings/plugins/submit`
- Console: `https://platform.claude.com/plugins/submit`

GitHub-linked submissions auto-update when you push; no re-submission
needed. Repo must be public. Closed-source plugins are not accepted.

Full technical reference: [`code.claude.com/docs/en/plugins-reference`](https://code.claude.com/docs/en/plugins-reference).

## Related surfaces

- [`SKILL-claude-skills.md`](SKILL-claude-skills.md) — skills (which
  plugins bundle).
- [`SKILL-connectors-overview.md`](SKILL-connectors-overview.md) —
  connectors (which plugins also bundle).
- [`claude-code → SKILL-plugins.md`](../claude-code/SKILL-plugins.md) —
  the plugin manifest schema, marketplace.json schema, CLI authoring
  flow.

## Page index

All source pages under
[`https://claude.com/docs/plugins/`](https://claude.com/docs/plugins/)
— see the directory listing for the current set.

---

*Source pages: under `claude.com/docs/plugins/`.*
