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

### MCP configuration in plugins

A plugin's MCP connectors are declared in `.mcp.json` within the
plugin directory. Plugins can include remote MCPs, local MCPs, and
MCPBs.

### SETUP.md skill

Plugins can include a `SETUP.md` skill to guide Claude through
configuring and connecting any MCP servers bundled in the plugin.
Claude follows the setup instructions when a user installs or
activates the plugin.

### MCP connector guidance

Use connectors already in the [Connectors Directory](https://claude.com/docs/connectors/directory.md)
or from well-known developers — this increases the likelihood of
Anthropic Verified status and reduces user warnings.

## Where plugins are available

| Platform | Plugin support |
|---|---|
| **Claude Code** | Full — create, install, use plugins |
| **Claude Cowork** | Full — extends agentic multi-step workflows |

Plugins are **not** available on Claude.ai web or Mobile.

> **Research preview:** Plugin support in Cowork is a research preview
> for all paid Claude users. Plugins are currently saved locally to
> the user's machine. Org-wide sharing and management are coming soon.

Source: [`plugins/overview.md`](https://claude.com/docs/plugins/overview.md)

## Plugin directory

Anthropic open-sourced 11 reference plugins at
[claude.com/plugins-for/cowork](https://claude.com/plugins-for/cowork):

| Plugin | Purpose |
|---|---|
| Productivity | Tasks, calendars, daily workflows |
| Enterprise search | Information across company tools/docs |
| Sales | Prospect research, deal prep |
| Finance | Financials, modeling, key metrics |
| Data | Query, visualize, interpret datasets |
| Legal | Document review, risk flagging, compliance |
| Marketing | Content drafting, campaign planning |
| Customer support | Issue triage, response drafting |
| Product management | Specs, roadmaps, progress tracking |
| Biology research | Literature search, experiment planning |
| Plugin Create | Create and customize new plugins |

**Anthropic Verified** badge: plugins that have undergone additional
quality and safety review beyond basic automated screening.

## Plugin marketplaces

A marketplace is a directory of installable plugins identified by a URL
pointing at a `marketplace.json` file. Getting plugins to users:

1. **Direct install** — simplest for internal tools or small teams.
2. **Your own marketplace** — host a `marketplace.json`; opted-in users
   browse and install. See Claude Code docs for setup.
3. **Claude plugin directory** — submit to reach all Cowork + Code users.

Submission forms:
- Claude.ai: `https://claude.ai/settings/plugins/submit`
- Console: `https://platform.claude.com/plugins/submit`

Validate before submitting: `claude plugin validate`. After the first
submission, CI auto-mirrors updates from your public GitHub repo — no
re-submission needed for updates.

Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md)

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
