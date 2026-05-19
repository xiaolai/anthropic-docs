---
name: claude-plugins-user-facing
description: |
  Deep reference for user-facing Plugins in the Claude app — how
  users discover, install, and submit plugins; the plugin directory
  with Anthropic's 11 open-sourced plugins; the Anthropic Verified
  badge system; how plugins compose skills, MCP connectors, slash
  commands, and sub-agents; and the submission process (claude
  plugin validate, GitHub or ZIP upload).
source: https://claude.com/docs/plugins/overview.md
---

# Claude Plugins — User-Facing

> *Router lives in [`SKILL.md`](SKILL.md). For the Claude Code CLI
> side of plugins (manifest schema, marketplace.json, plugin
> authoring), see [`claude-code → SKILL-plugins.md`](../claude-code/SKILL-plugins.md).
> This surface covers the product-level plugin experience in Cowork
> and Claude Code.*

## What plugins are

A plugin is a **bundled capability package** that combines:

| Component | What it adds | Example |
|---|---|---|
| **Skills** | Specialized instructions Claude follows when relevant tasks arise | A "brand voice" skill that activates when drafting external communications |
| **MCP connectors** | Access to external tools and data | A CRM connector that lets Claude read and update deal records |
| **Slash commands** | User-triggered workflows | `/sales:prospect-research` to kick off structured research |
| **Sub-agents** | Delegated workstreams that run in parallel | A sub-agent that handles competitive analysis while another drafts a proposal |

Every component is file-based, so plugins are easy to build,
edit, and share.

Source: [`plugins/overview.md`](https://claude.com/docs/plugins/overview.md).

## Plugin directory

Anthropic has open-sourced 11 plugins built and used internally,
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

## Availability

Plugin support in Cowork is available as a **research preview
for all paid Claude users**. Plugins are currently saved locally
to your machine. Org-wide sharing and management are coming.

| Platform | Plugin support |
|---|---|
| **Claude Code** | Full plugin support — create, install, and use plugins |
| **Claude Cowork** | Full plugin support — plugins extend agentic, multi-step workflows |

## Getting your plugin to users

Three distribution paths:

1. **Direct install** — Install the plugin yourself or guide
   users directly. Simplest for internal tools or small teams.
2. **Your own plugin marketplace** — Host a
   [`marketplace.json`](https://code.claude.com/docs/en/plugin-marketplaces)
   file; opted-in users can access any plugin you share. Good
   for enterprises or communities with shared tasks.
3. **Submit to the Claude plugin directory** — Submit to the
   community directory, which is available to all Cowork and
   Claude Code users.

## Community vs. Anthropic Verified

Plugins in the directory come from the community. Anthropic
performs basic automated review before adding a plugin to the
directory.

Plugins with an **"Anthropic Verified"** badge have undergone
additional review for quality and safety. There are no
guarantees that a community plugin will become Anthropic
Verified.

> **Caution**: Always review a plugin's permissions, connected
> services, and data access before installing. Community plugins
> may install unverified third-party software.

## What makes a good plugin

The best plugins bundle related capabilities into a coherent
package that solves a specific job function or workflow end-to-
end. A good plugin combines skills, connectors, slash commands,
and sub-agents so Claude has everything it needs for a category
of work.

Plugins can include any MCP connector type: remote MCPs, local
MCPs, and MCPBs. Plugins can also include a `SETUP.md` skill
that guides Claude through configuring and connecting MCP
servers on first install.

## Directory terms & conditions

All plugins in the directory must comply with:

- [Anthropic Software Directory Terms](https://support.claude.com/en/articles/13145338-anthropic-software-directory-terms)
- [Anthropic Software Directory Policy](https://support.claude.com/en/articles/13145358-anthropic-software-directory-policy)

## Submitting your plugin

Before submitting:

```bash
claude plugin validate
```

Then submit via one of the in-app forms:

| Form | URL |
|---|---|
| Claude.ai | `https://claude.ai/settings/plugins/submit` |
| Console | `https://platform.claude.com/plugins/submit` |

Submit a public GitHub repo link or a ZIP file. **Closed-source
plugins are not accepted.** After publishing, updates pushed to
your GitHub repo are picked up automatically — no need to
re-submit.

Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

## Origins in Claude Code

Plugins originated in Claude Code, where developers create and
distribute them as versioned, shareable directories. A Claude
Code plugin lives in a directory with a `plugin.json` manifest.
See the [Claude Code plugins reference](https://code.claude.com/docs/en/plugins-reference)
for full technical specifications.

## Related surfaces

- [`SKILL-claude-skills.md`](SKILL-claude-skills.md) — skills
  (which plugins bundle).
- [`SKILL-connectors-overview.md`](SKILL-connectors-overview.md) —
  connectors (which plugins also bundle).
- [`claude-code → SKILL-plugins.md`](../claude-code/SKILL-plugins.md) —
  the plugin manifest schema, marketplace.json schema, CLI
  authoring flow.

## Page index

Source pages under
[`https://claude.com/docs/plugins/`](https://claude.com/docs/plugins/):

- `plugins/overview.md` — plugin components, directory, Cowork availability
- `plugins/submit.md` — submission process, community vs. verified

---

*Source pages: `claude.com/docs/plugins/overview.md` and
`claude.com/docs/plugins/submit.md`.*
