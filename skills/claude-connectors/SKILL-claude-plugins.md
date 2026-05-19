---
name: claude-plugins-user-facing
description: |
  Deep reference for user-facing Plugins in the Claude app — how
  users discover, install, manage, and configure plugins. Plugins
  bundle MCP connectors, Skills, slash commands, and sub-agents into
  shareable capability packages. Covers the Anthropic open-sourced
  plugin library, the plugin directory, Cowork availability, and
  how each plugin component contributes.
source: https://claude.com/docs/plugins/overview.md
---

# Claude Plugins — User-Facing

> *Router lives in [`SKILL.md`](SKILL.md). For the Claude Code CLI
> side of plugins (manifest schema, marketplace.json, plugin
> authoring), see [`claude-code → SKILL-plugins.md`](../claude-code/SKILL-plugins.md).
> This surface covers what users see in the Claude app.*

## What plugins are (user view)

A plugin is a reusable capability package that extends Claude with
custom functionality. Plugins bundle together:

| Component | What it adds | Example |
|---|---|---|
| **MCP connectors** | Access to external tools and data | A connector to a CRM that lets Claude read and update deal records |
| **Skills** | Specialized instructions Claude follows when relevant tasks arise | A "brand voice" skill that activates when drafting external communications |
| **Slash commands** | Explicit, user-triggered workflows | `/sales:prospect-research` to kick off a structured research workflow |
| **Sub-agents** | Delegated workstreams that run in parallel | A sub-agent that handles competitive analysis while another drafts the proposal |

Once installed, all four are wired together — a single install
gives the user the connector + the skills that compose it + the
commands that drive it.

## Where plugins are available

| Platform | Plugin support |
|---|---|
| **Claude Code** | Full plugin support — create, install, and use plugins |
| **Claude Cowork** | Full plugin support — plugins extend agentic, multi-step workflows |

Plugins are **not** available on Claude.ai web or Claude Mobile
(as of this snapshot — check upstream for current state).

Plugin support in Cowork is available as a **research preview**
for all paid Claude users. Plugins are currently saved locally to
your machine. Org-wide sharing and management are coming.

## Plugin directory

Anthropic has open-sourced **11 plugins** built and used internally,
available at [claude.com/plugins-for/cowork](https://claude.com/plugins-for/cowork):

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

## Origins in Claude Code

Plugins originated in [Claude Code](https://code.claude.com/docs/en/plugins),
where developers create and distribute them as versioned, shareable
directories. A Claude Code plugin lives in a directory with a manifest
(`plugin.json`) that defines its identity, version, and available
components.

For technical details on plugin structure, manifests, and
configuration, see the
[Claude Code plugins reference](https://code.claude.com/docs/en/plugins-reference)
or [`claude-code → SKILL-plugins.md`](../claude-code/SKILL-plugins.md).

## Plugins in Cowork

Plugins are fully supported in
[Cowork](https://support.claude.com/en/articles/13345190-getting-started-with-cowork),
Anthropic's agentic workspace for complex multi-step knowledge work.
In Cowork, Claude runs inside an isolated VM, executes tasks in
parallel workstreams, and writes outputs directly to your file
system — plugins extend all of that capability.

A sales plugin, for example, could connect Claude to your CRM and
knowledge base, teach it your sales process, and give you slash
commands for everything from prospect research to call follow-ups.

## Submitting your plugin

See [`plugins/submit.md`](https://claude.com/docs/plugins/submit) for
the plugin submission process and requirements.

## Related surfaces

- [`SKILL-claude-skills.md`](SKILL-claude-skills.md) — skills (which
  plugins bundle).
- [`SKILL-connectors-overview.md`](SKILL-connectors-overview.md) —
  connectors (which plugins also bundle).
- [`claude-code → SKILL-plugins.md`](../claude-code/SKILL-plugins.md) —
  the plugin manifest schema, marketplace.json schema, CLI authoring
  flow.

## Page index

Source pages under
[`https://claude.com/docs/plugins/`](https://claude.com/docs/plugins/):

| Page | Topic |
|---|---|
| `overview.md` | This surface's source |
| `submit.md` | Plugin submission process |

---

*Source pages: under `claude.com/docs/plugins/`.*
