---
name: claude-plugins-user-facing
description: |
  Deep reference for user-facing Plugins in the Claude app —
  Cowork and Claude Code. Covers the 11 pre-built Anthropic
  plugins, how plugins compose skills/connectors/slash-commands/
  sub-agents, platform availability (Cowork + Code only, research
  preview), submitting to the plugin directory, and the
  "Anthropic Verified" review tier.
source: https://claude.com/docs/plugins/overview.md
---

# Claude Plugins — User-Facing

> *Router lives in [`SKILL.md`](SKILL.md). For the Claude Code CLI
> side of plugins (manifest schema, marketplace.json, plugin
> authoring), see [`claude-code → SKILL-plugins.md`](../claude-code/SKILL-plugins.md).
> This surface covers what users see in Cowork and Claude Code.*

## What plugins are

A plugin is a reusable capability package that bundles together:

| Component | What it adds | Example |
|---|---|---|
| **Skills** | Specialized instructions Claude follows when relevant tasks arise | A "brand voice" skill that activates when drafting external communications |
| **MCP connectors** | Access to external tools and data | A connector to a CRM that lets Claude read and update deal records |
| **Slash commands** | Explicit, user-triggered workflows | `/sales:prospect-research` to kick off a structured research workflow |
| **Sub-agents** | Delegated workstreams that run in parallel | A sub-agent that handles competitive analysis while another drafts the proposal |

Once installed, all components are wired together — a single install
gives the user the connector + the skills that compose it + the
commands that drive it.

## Platform availability

Plugin support is available as a **research preview** for all paid
Claude users. Plugins are currently saved locally to the user's machine.
Org-wide sharing and management are coming.

| Platform | Plugin support |
|---|---|
| **Claude Code** | Full plugin support — create, install, and use plugins |
| **Claude Cowork** | Full plugin support — plugins extend agentic, multi-step workflows |

Plugins are **not** available on Claude.ai web or Claude Mobile.

## Plugin directory

Anthropic has open-sourced 11 plugins built and used internally:

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

Browse the full collection at [claude.com/plugins-for/cowork](https://claude.com/plugins-for/cowork)
or use the Plugin Create plugin to build your own.

## Plugin directory tiers

Plugins are submitted by developers and reviewed by Anthropic before
listing. Two tiers:

- **Community** — Basic automated review before listing.
- **Anthropic Verified** — Additional quality + safety review by Anthropic.
  Only install community plugins from developers you trust.

## Origins

Plugins originated in [Claude Code](https://code.claude.com/docs/en/plugins),
where developers create and distribute them as versioned, shareable
directories. A Claude Code plugin lives in a directory with a manifest
(`plugin.json`) that defines its identity, version, and available
components.

## Plugins in Cowork

Plugins are fully supported in
[Cowork](https://support.claude.com/en/articles/13345190-getting-started-with-cowork),
Anthropic's agentic workspace. In Cowork, Claude runs inside an
isolated virtual machine environment, executes tasks in parallel
workstreams, and writes outputs directly to your file system — and
plugins extend all of that capability.

For Cowork on 3P deployments, org-wide plugin distribution happens
via MDM — see [`claude-cowork`](../claude-cowork/SKILL-cowork.md).

## Installation scope

| Scope | Where | When to use |
|---|---|---|
| **User-global** | `~/.claude/plugins/` | Plugins you use across all projects |
| **Project-local** | `<project>/.claude/plugins/` | Plugins specific to one codebase, committed to repo |
| **Org-managed** | MDM-distributed | Cowork on 3P deployments |

## Submitting a plugin

To submit a plugin to the directory, share a GitHub link (repo must
be public — closed-source plugins are not accepted) or upload a zip.

Validate before submitting:
```bash
claude plugin validate
```

Submission forms:
- **Claude.ai** — [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit)
- **Console** — [platform.claude.com/plugins/submit](https://platform.claude.com/plugins/submit)

After publishing, updates pushed to your GitHub repo are picked up
automatically — no need to re-submit.

## Related surfaces

- [`SKILL-claude-skills.md`](SKILL-claude-skills.md) — skills (which
  plugins bundle).
- [`SKILL-connectors-overview.md`](SKILL-connectors-overview.md) —
  connectors (which plugins also bundle).
- [`claude-code → SKILL-plugins.md`](../claude-code/SKILL-plugins.md) —
  the plugin manifest schema, marketplace.json schema, CLI authoring
  flow.

## Page index

| Page | Topic |
|---|---|
| [`plugins/overview.md`](https://claude.com/docs/plugins/overview.md) | Overview, directory, Cowork integration |
| [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md) | Submission process, review tiers, terms |

---

*Source pages: 2 under `claude.com/docs/plugins/`.*
