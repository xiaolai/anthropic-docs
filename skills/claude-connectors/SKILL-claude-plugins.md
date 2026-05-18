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

- **Claude Code (CLI)** — `/plugin` commands, plugin marketplaces.
- **Claude Cowork** — full plugin support (see
  [`claude-cowork → SKILL-cowork.md`](../claude-cowork/SKILL-cowork.md)).

Plugins are **not** available on Claude.ai web or Claude Mobile.

## Anthropic's open-sourced plugins

Anthropic has open-sourced 11 reference plugins covering areas
including: productivity, sales, finance, legal, marketing, customer
support, product management, biology research, and data analysis.

Browse the public plugin directory at
[claude.com/plugins-for/cowork](https://claude.com/plugins-for/cowork).

> **Status note (as of 2026-05):** Plugin support in Cowork is a
> research preview available to all paid Claude users. Installed
> plugins currently save locally; org-wide sharing is coming.

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

## SETUP.md — guiding Claude through MCP setup

A plugin can include a `SETUP.md` skill to give Claude step-by-step
instructions for configuring and connecting any MCP servers bundled
in the plugin. When a user installs or activates your plugin, Claude
follows `SETUP.md` to complete the setup automatically.

Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

## Skills are not a standalone directory type

Skills cannot be submitted to the connector or plugin directory on
their own — **plugins are the distribution mechanism for skills**.
To publish a skill publicly, bundle it inside a plugin and submit
the plugin to the directory. See
[`SKILL-claude-skills.md`](SKILL-claude-skills.md).

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
