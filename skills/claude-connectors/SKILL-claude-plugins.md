---
name: claude-plugins-user-facing
description: |
  Deep reference for user-facing Plugins in the Claude app — what
  plugins bundle (MCP connectors, Skills, slash commands, sub-agents),
  where they are available (Claude Code + Cowork), the plugin directory
  at claude.com/plugins-for/cowork, Anthropic's 11 open-sourced
  plugins, Community vs. Anthropic Verified distinction, how to submit
  a plugin, and installation scope.
source: https://claude.com/docs/plugins/overview.md
---

# Claude Plugins — User-Facing

> *Router lives in [`SKILL.md`](SKILL.md). For the Claude Code CLI
> side of plugins (manifest schema, marketplace.json, plugin
> authoring), see [`claude-code → SKILL-plugins.md`](../claude-code/SKILL-plugins.md).
> This surface covers what users see in the Claude app.*

## What plugins are (user view)

A plugin is a bundled package that combines:

- **MCP connectors** — action-taking integrations with external services
  (remote MCPs, local MCPs, and MCPBs all supported via `.mcp.json`).
- **Skills** — task-specific instructions Claude activates dynamically.
- **Slash commands** — user-invocable shortcut commands.
- **Sub-agents** — specialized agents the plugin makes available.

Once installed, all four are wired together — a single install gives the
user the connector + the skills that compose it + the commands that drive
it.

Plugins can also include a `SETUP.md` skill to guide Claude through
configuring and connecting any MCP servers bundled in the plugin.

## Where plugins are available

| Platform | Plugin support |
|---|---|
| **Claude Code** | Full plugin support — create, install, and use plugins |
| **Claude Cowork** | Full plugin support — plugins extend agentic, multi-step workflows |

Plugins are **not** available on Claude.ai web or Mobile.

> **Research preview**: Plugin support in Cowork is available as a
> research preview for all paid Claude users. Plugins are currently
> saved locally to your machine. Org-wide sharing and management are
> coming in future releases.

## Plugin directory

Anthropic maintains the official plugin directory at
[**claude.com/plugins-for/cowork**](https://claude.com/plugins-for/cowork).
Anthropic has **open-sourced 11 plugins** built and used internally as
starting points:

| Plugin | What it does |
|---|---|
| **Productivity** | Manage tasks, calendars, and daily workflows |
| **Enterprise search** | Find information across your company's tools and docs |
| **Sales** | Research prospects, prep deals, follow your sales process |
| **Finance** | Analyze financials, build models, track key metrics |
| **Data** | Query, visualize, and interpret datasets |
| **Legal** | Review documents, flag risks, track compliance |
| **Marketing** | Draft content, plan campaigns, manage launches |
| **Customer support** | Triage issues, draft responses, surface solutions |
| **Product management** | Write specs, prioritize roadmaps, track progress |
| **Biology research** | Search literature, analyze results, plan experiments |
| **Plugin Create** | Create and customize new plugins from scratch |

In Claude Code, this directory is surfaced as the `claude-plugins-official`
marketplace automatically available to all users.

## Community vs. Anthropic Verified

| Badge | Meaning |
|---|---|
| (none) | Community-submitted; Anthropic performs basic automated review |
| **Anthropic Verified** | Additional quality and safety review by Anthropic |

Always review a plugin's permissions, connected services, and data access
before installing. No guarantee that any community plugin becomes Verified.

## Plugin marketplaces

A marketplace is a directory of installable plugins identified by a URL
pointing at a `marketplace.json` file. Users can:

- Browse plugins from any marketplace they trust.
- Install plugins from a marketplace with one command.
- Update / remove installed plugins.

Organizations can run their own private marketplaces for internal-only
plugins (common in Cowork on 3P deployments — see
[`claude-cowork`](../claude-cowork/SKILL-cowork.md) for the "org-plugins
directory" pattern).

## Installation scope

| Scope | Where | When to use |
|---|---|---|
| **User-global** | `~/.claude/plugins/` | Plugins you use across all projects |
| **Project-local** | `<project>/.claude/plugins/` | Plugins specific to one codebase, committed to repo |
| **Org-managed** | MDM-distributed | Cowork on 3P deployments |

## Submitting a plugin to the directory

1. Build your plugin and run `claude plugin validate` to check formatting
   and structure.
2. Submit via one of the in-app forms:
   - **Claude.ai** — [claude.ai/settings/plugins/submit](https://claude.ai/settings/plugins/submit)
   - **Console** — [platform.claude.com/plugins/submit](https://platform.claude.com/plugins/submit)
3. The repo must be **public** — closed-source plugins are not accepted.
4. After publishing, updates pushed to your GitHub repo are picked up
   automatically; no need to re-submit.

Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

### Directory terms & conditions

All plugins must comply with:
- [Anthropic Software Directory Terms](https://support.claude.com/en/articles/13145338-anthropic-software-directory-terms)
- [Anthropic Software Directory Policy](https://support.claude.com/en/articles/13145358-anthropic-software-directory-policy)

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

- `overview.md` — this surface's primary source
- `submit.md` — submitting to the directory, terms, security

---

*Source pages: under `claude.com/docs/plugins/`.*
