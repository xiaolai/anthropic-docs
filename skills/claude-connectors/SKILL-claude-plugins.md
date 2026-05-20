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

- **Claude Code (CLI)** — full plugin creation, distribution, and
  installation via `/plugin` commands.
- **Claude Cowork** — full plugin support (research preview for paid
  users); see
  [`claude-cowork → SKILL-cowork.md`](../claude-cowork/SKILL-cowork.md).

Plugins are NOT available on Claude.ai web or Mobile (as of this
snapshot — check upstream for current state).

## Plugin directory

Anthropic's public plugin directory is browsable at
[**claude.com/plugins-for/cowork**](https://claude.com/plugins-for/cowork)
and via the plugin settings in Claude Code / Cowork. Anthropic has also
open-sourced **11 internally-developed plugins**:

| Plugin | What it does |
|---|---|
| **Productivity** | Manage tasks, calendars, and daily workflows |
| **Enterprise search** | Find information across your company's tools and docs |
| **Sales** | Research prospects, prep deals, and follow your sales process |
| **Finance** | Analyze financials, build models, and track key metrics |
| **Data** | Query, visualize, and interpret datasets |
| **Legal** | Review documents, flag risks, and track compliance |
| **Marketing** | Draft content, plan campaigns, and manage launches |
| **Customer support** | Triage issues, draft responses, and surface solutions |
| **Product management** | Write specs, prioritize roadmaps, and track progress |
| **Biology research** | Search literature, analyze results, and plan experiments |
| **Plugin Create** | Create and customize new plugins from scratch |

Source: [`plugins/overview.md`](https://claude.com/docs/plugins/overview.md).

Directory tiers:

| Tier | Review process |
|---|---|
| **Community** | Basic automated review |
| **Anthropic Verified** | Additional quality and safety scrutiny by Anthropic |

Install only plugins from developers you trust — Anthropic cannot
exhaustively review every submission.

> **Exercise caution with community plugins.** Best practices before installing:
> - Review the plugin's source code before installing.
> - Check which MCP connectors are included and what permissions they request.
> - Prefer Anthropic Verified plugins for production workflows.
> - Report any suspicious activity to Anthropic.
>
> Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

## Plugin marketplaces

A marketplace is a directory of installable plugins, identified by
a URL pointing at a `marketplace.json` file (see
[`code.claude.com/docs/en/plugin-marketplaces`](https://code.claude.com/docs/en/plugin-marketplaces)).
Three distribution paths are available:

| Path | Best for |
|---|---|
| **Direct installation** | Internal tools or small teams |
| **Custom marketplace** | Enterprises/communities with domain-specific needs |
| **Claude plugin directory** | Broad reach across all Cowork + Code users |

Organizations can run private marketplaces for internal-only plugins
(see [`claude-cowork`](../claude-cowork/SKILL-cowork.md) for the
"org-plugins directory" pattern).

> **Note:** Plugins are currently saved locally to your machine.
> Org-wide sharing and management are coming in the weeks ahead.
> Source: [`plugins/overview.md`](https://claude.com/docs/plugins/overview.md).

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

## Submitting to the directory

To submit a plugin to the Claude plugin directory:

1. Share a **public GitHub repo link** OR upload a **zip file** containing
   your plugin. The plugin (or repo) must be open — closed-source plugins
   are not accepted.
2. Run `claude plugin validate` — all checks must pass.
3. Submit via [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit)
   or [platform.claude.com/plugins/submit](https://platform.claude.com/plugins/submit).
4. After publication, updates pushed to your GitHub repo sync automatically.

Plugins must comply with Anthropic's Software Directory Terms and
Policy. Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

## MCP configuration in plugins (`.mcp.json`)

Plugins configure their bundled MCP connectors via a `.mcp.json` file
inside the plugin directory. A plugin can include any MCP type — remote
MCPs, local MCPs, and MCPBs. Anthropic recommends using connectors already
in the [Connectors Directory](https://claude.com/docs/connectors/directory)
or from well-known developers; this increases the likelihood of Verified
status and reduces warnings shown to users.

Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

## SETUP.md — guided MCP configuration

Plugins can include a `SETUP.md` skill to guide Claude through
configuring and connecting any MCP servers bundled in the plugin. This
lets you define step-by-step setup instructions that Claude follows when
a user installs or activates your plugin.

Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

## Post-publication auto-updates

After a plugin is published to the directory, updates pushed to the
plugin's **public GitHub repo are picked up automatically** — CI mirrors
changes to the public marketplace and runs automated screening on each
update. Re-submitting the form is not required for updates.

Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

## Page index

All source pages under
[`https://claude.com/docs/plugins/`](https://claude.com/docs/plugins/):

- `overview.md` — plugin components, Anthropic's open-sourced plugins, platform support
- `submit.md` — submission requirements, tiers, and review process

---

*Source pages: under `claude.com/docs/plugins/`.*
