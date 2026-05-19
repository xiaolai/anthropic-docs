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

## Plugin components

| Component | What it adds |
|---|---|
| **Skills** | Specialized instructions that activate dynamically |
| **MCP connectors** | Access to external tools and data (remote MCPs, local MCPs, MCPBs) |
| **Slash commands** | User-triggered workflows (e.g. `/sales:prospect-research`) |
| **Sub-agents** | Delegated workstreams that run in parallel |
| **`SETUP.md` skill** | Guides Claude through configuring + connecting any bundled MCP servers on install |

A `SETUP.md` skill inside the plugin lets you define step-by-step MCP setup instructions
that Claude follows when a user installs or activates the plugin.

Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

## Where plugins are available

- **Claude Code (CLI)** — `/plugin` commands, plugin marketplaces.
- **Claude Cowork** — full plugin support, available as a **research
  preview for all paid Claude users** (see
  [`claude-cowork → SKILL-cowork.md`](../claude-cowork/SKILL-cowork.md)).

Plugins are NOT available on Claude.ai web or Mobile (as of this
snapshot — check upstream for current state).

## Plugin marketplaces

A marketplace is a directory of installable plugins, identified by
a URL pointing at a `marketplace.json` file. Users can:

- Browse plugins from any marketplace they trust.
- Install plugins from a marketplace with one command.
- Update / remove installed plugins.

Anthropic operates a public plugin marketplace at
[claude.com/plugins](https://claude.com/plugins-for/cowork) for
the broader community. Anthropic has open-sourced **11 internal
plugins** spanning: Productivity, Enterprise Search, Sales,
Finance, Data, Legal, Marketing, Customer Support, Product
Management, Biology Research, and Plugin Create. Organizations
can run their own private marketplaces for internal-only plugins
(common in Cowork on 3P deployments — see
[`claude-cowork`](../claude-cowork/SKILL-cowork.md) for the
"org-plugins directory" pattern).

> **Note:** Plugins are currently saved locally to your machine.
> Organization-wide sharing and centralized management are
> forthcoming.

## Installation scope

| Scope | Where | When to use |
|---|---|---|
| **User-global** | `~/.claude/plugins/` | Plugins you use across all projects |
| **Project-local** | `<project>/.claude/plugins/` | Plugins specific to one codebase, committed to repo |
| **Org-managed** | MDM-distributed | Cowork on 3P deployments |

## Plugin directory: Community vs. Anthropic Verified

The [plugin directory](https://claude.com/plugins-for/cowork) is the community-driven
catalog. Anthropic performs basic automated review on all submissions. Plugins with an
**"Anthropic Verified"** badge have undergone additional quality and safety review.

> Only install plugins from developers you trust. Community plugins may install
> unverified, third-party software.

## Submitting a plugin

Before submitting:

```bash
claude plugin validate
```

Submit via one of the in-app forms:

- **Claude.ai** — `https://claude.ai/settings/plugins/submit`
- **Console** — `https://platform.claude.com/plugins/submit`

Provide a public GitHub repo or upload a ZIP file (must be public; closed-source
plugins are not accepted). After initial publication, updates pushed to the GitHub repo
are picked up automatically — CI mirrors changes and runs automated screening. No
re-submission required for updates.

Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

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
