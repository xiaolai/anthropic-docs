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

- **MCP connectors** — action-taking integrations with external services (remote MCPs, local MCPs, MCPBs; configured in `.mcp.json`).
- **Skills** — reusable task recipes.
- **Slash commands** — user-invocable shortcut commands.
- **Sub-agents** — specialized agents the plugin makes available.
- **`SETUP.md` skill** (optional) — guides Claude through configuring and connecting MCP servers at install time.

Once installed, all components are wired together — a single install
gives the user the connector + the skills that compose it + the
commands that drive it.

Source: [`plugins/overview.md`](https://claude.com/docs/plugins/overview.md),
[`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

## Where plugins are available

| Platform | Support |
|---|---|
| **Claude Code (CLI)** | Full — create, install, use plugins |
| **Claude Cowork** | Full — research preview for all paid users; plugins currently saved locally (org-wide sharing coming) |

Plugins are not available on Claude.ai web or Mobile.

## Plugin directory

Anthropic maintains a public plugin directory at
[`claude.com/plugins-for/cowork`](https://claude.com/plugins-for/cowork).
Anthropic has open-sourced 11 plugins built and used internally:

Productivity, Enterprise search, Sales, Finance, Data, Legal, Marketing,
Customer support, Product management, Biology research, Plugin Create.

### Community vs Anthropic Verified

Plugins submitted by the community undergo basic automated review.
Plugins with an **"Anthropic Verified"** badge have had additional
quality and safety review by Anthropic. Prefer Verified plugins for
production workflows; review any community plugin's source and
permissions before installing.

## Plugin marketplaces

A marketplace is a directory of installable plugins, identified by
a URL pointing at a `marketplace.json` file. Users can:

- Browse plugins from any marketplace they trust.
- Install plugins from a marketplace with one command.
- Update / remove installed plugins.

Organizations can run private marketplaces for internal plugins
(common in Cowork on 3P deployments). See
[Claude Code plugin-marketplaces docs](https://code.claude.com/docs/en/plugin-marketplaces)
for setup.

## Installation scope

| Scope | Where | When to use |
|---|---|---|
| **User-global** | `~/.claude/plugins/` | Plugins you use across all projects |
| **Project-local** | `<project>/.claude/plugins/` | Plugins specific to one codebase, committed to repo |
| **Org-managed** | MDM-distributed | Cowork on 3P deployments |

## Submitting to the directory

1. Run `claude plugin validate` to check structure and formatting.
2. Submit via one of the in-app forms (GitHub link or ZIP upload; repo must be public):
   - Claude.ai: [`claude.ai/settings/plugins/submit`](https://claude.ai/settings/plugins/submit)
   - Console: [`platform.claude.com/plugins/submit`](https://platform.claude.com/plugins/submit)
3. After publishing, GitHub repo updates are picked up automatically — no re-submission needed.

All submissions must comply with
[Anthropic Software Directory Terms](https://support.claude.com/en/articles/13145338-anthropic-software-directory-terms)
and [Policy](https://support.claude.com/en/articles/13145358-anthropic-software-directory-policy).

> **Note:** The plugin directory is separate from and complementary to
> the [Connectors Directory](https://claude.com/docs/connectors/directory.md)
> (which lists MCP connectors only).

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
