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

Plugins originated in Claude Code; the Claude Code plugin guide at
[code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins)
covers the manifest schema and authoring workflow.

Source: [`plugins/overview.md`](https://claude.com/docs/plugins/overview.md).

## Where plugins are available

| Platform | Support |
|---|---|
| **Claude Code (CLI)** | Full — create, install, use plugins |
| **Claude Cowork** | Full — extends agentic, multi-step workflows |

Plugin support in Cowork is a **research preview for all paid Claude
users**. Plugins are currently saved locally; org-wide sharing is
coming. Plugins are NOT available on Claude.ai web or Mobile.

## Plugin directory

Anthropic has open-sourced 11 plugins at
[claude.com/plugins-for/cowork](https://claude.com/plugins-for/cowork):

| Plugin | Purpose |
|---|---|
| Productivity | Tasks, calendars, daily workflows |
| Enterprise search | Find info across company tools and docs |
| Sales | Prospect research, deal prep, sales process |
| Finance | Financials, models, key metrics |
| Data | Query, visualize, and interpret datasets |
| Legal | Document review, risk flagging, compliance |
| Marketing | Content, campaigns, launches |
| Customer support | Triage, responses, solutions |
| Product management | Specs, roadmaps, tracking |
| Biology research | Literature search, results analysis |
| Plugin Create | Create and customize new plugins from scratch |

## Plugin composition details

Plugins can include a `SETUP.md` skill to guide Claude through
configuring any bundled MCP servers on first use.

MCP configuration inside a plugin uses `.mcp.json` (supports remote
MCPs, local MCPs, and MCPBs).

Strong recommendation: use connectors from the
[Connectors Directory](https://claude.com/docs/connectors/directory.md)
or well-known developers — reduces user-facing warnings and increases
chance of Anthropic Verified status.

## Plugin marketplaces

A marketplace is a directory of installable plugins, identified by
a URL pointing at a `marketplace.json` file. Users can:

- Browse plugins from any marketplace they trust.
- Install plugins from a marketplace with one command.
- Update / remove installed plugins.

Anthropic operates a public plugin marketplace. In Claude Code, the
official `claude-plugins-official` marketplace is automatically
available to all users. Organizations can run private marketplaces.

## Installation scope

| Scope | Where | When to use |
|---|---|---|
| **User-global** | `~/.claude/plugins/` | Plugins you use across all projects |
| **Project-local** | `<project>/.claude/plugins/` | Plugins specific to one codebase, committed to repo |
| **Org-managed** | MDM-distributed | Cowork on 3P deployments |

## Submitting a plugin to the directory

The plugin directory ([claude.com/plugins-for/cowork](https://claude.com/plugins-for/cowork))
is separate from the Connectors Directory (which is MCP-connector-only).

**Requirements:**
- Public GitHub repo (closed-source not accepted)
- Pass `claude plugin validate` before submitting
- Comply with [Anthropic Software Directory Terms](https://support.claude.com/en/articles/13145338-anthropic-software-directory-terms)
  and [Policy](https://support.claude.com/en/articles/13145358-anthropic-software-directory-policy)

**Submission forms:**
- Claude.ai: [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit)
- Console: [platform.claude.com/plugins/submit](https://platform.claude.com/plugins/submit)

Submit a GitHub link or ZIP file. After publish, updates pushed to
your GitHub repo are picked up automatically — no re-submission needed.

**Anthropic Verified badge:** plugins that pass additional quality and
safety review. Community plugins have basic automated review only.

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
