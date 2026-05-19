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
| **Claude Code** | Full — create, install, and use plugins |
| **Claude Cowork** | Full — research preview for all paid Claude users |

Plugin support in Cowork is currently in **research preview**; plugins
are saved locally per machine. Org-wide sharing is coming. Plugins are
not available on Claude.ai web or Claude Mobile.

Source: [`plugins/overview.md`](https://claude.com/docs/plugins/overview.md).

## Plugin directory

The official plugin directory is at
[`claude.com/plugins-for/cowork`](https://claude.com/plugins-for/cowork).
Anthropic has open-sourced 11 plugins built and used internally:

| Plugin | Purpose |
|---|---|
| Productivity | Tasks, calendars, daily workflows |
| Enterprise search | Find info across company tools and docs |
| Sales | Prospect research, deal prep, sales process |
| Finance | Financial analysis, models, key metrics |
| Data | Query, visualize, and interpret datasets |
| Legal | Document review, risk flagging, compliance |
| Marketing | Content drafts, campaigns, launches |
| Customer support | Triage, draft responses, surface solutions |
| Product management | Specs, roadmaps, progress |
| Biology research | Literature search, results analysis |
| Plugin Create | Create and customize new plugins |

In Claude Code, this directory is surfaced as the `claude-plugins-official`
marketplace, automatically available to all users.

**Community vs Anthropic Verified:** Community plugins receive basic
automated review. "Anthropic Verified" plugins have passed additional
quality and safety review. Only install plugins from developers you trust.

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

## SETUP.md skill

Plugins can include a `SETUP.md` skill to guide Claude through
configuring and connecting any MCP servers bundled in the plugin.
Define step-by-step setup instructions that Claude follows when a
user installs or activates the plugin.

Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

## Submitting a plugin

Before submitting, run `claude plugin validate` to check structure.
The repo must be **public** (closed-source plugins not accepted).

Submission forms:

- **Claude.ai** — <https://claude.ai/settings/plugins/submit>
- **Console** — <https://platform.claude.com/plugins/submit>

After publishing, updates to your GitHub repo are picked up
automatically via CI — no re-submission needed for updates.

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
