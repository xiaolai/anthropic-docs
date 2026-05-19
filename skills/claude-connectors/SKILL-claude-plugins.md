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

| Platform | Plugin support |
|---|---|
| **Claude Code (CLI)** | Full plugin support — create, install, and use plugins |
| **Claude Cowork** | Full plugin support (research preview for all paid users — see below) |

Plugins are NOT available on Claude.ai web or Mobile (as of this
snapshot — check upstream for current state).

## Availability note (Cowork)

Plugin support in Cowork is available as a **research preview for all
paid Claude users**. Plugins are currently saved locally to the user's
machine. Org-wide sharing and management are in development.

Source: [`plugins/overview.md`](https://claude.com/docs/plugins/overview.md).

## Anthropic open-source plugin directory

Anthropic has open-sourced 11 plugins built and used internally,
browsable at [claude.com/plugins-for/cowork](https://claude.com/plugins-for/cowork):

| Plugin | Purpose |
|---|---|
| Productivity | Tasks, calendars, daily workflows |
| Enterprise search | Find information across company tools and docs |
| Sales | Prospect research, deal prep, sales process |
| Finance | Financials, models, key metrics |
| Data | Query, visualize, interpret datasets |
| Legal | Document review, risk flagging, compliance |
| Marketing | Content drafting, campaigns, launches |
| Customer support | Triage, draft responses, surface solutions |
| Product management | Specs, roadmaps, progress tracking |
| Biology research | Literature search, results analysis, experiment planning |
| Plugin Create | Create and customize new plugins from scratch |

## Plugin marketplaces

A marketplace is a directory of installable plugins, identified by
a URL pointing at a `marketplace.json` file. Users can:

- Browse plugins from any marketplace they trust.
- Install plugins from a marketplace with one command.
- Update / remove installed plugins.

Anthropic operates a public plugin marketplace for the broader
community. Organizations can run their own private marketplaces for
internal-only plugins (common in Cowork on 3P deployments — see
[`claude-cowork`](../claude-cowork/SKILL-cowork.md) for the "org-plugins
directory" pattern).

## Installation scope

| Scope | Where | When to use |
|---|---|---|
| **User-global** | `~/.claude/plugins/` | Plugins you use across all projects |
| **Project-local** | `<project>/.claude/plugins/` | Plugins specific to one codebase, committed to repo |
| **Org-managed** | MDM-distributed | Cowork on 3P deployments |

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
