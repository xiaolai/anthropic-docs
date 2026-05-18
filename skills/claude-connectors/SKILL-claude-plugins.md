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

| Platform | Status |
|---|---|
| **Claude Code (CLI)** | Full plugin support — create, install, use |
| **Claude Cowork** | Full plugin support — research preview for all paid Claude users |
| **Claude.ai (web/Mobile)** | Not available as of this snapshot |

Source: [`plugins/overview.md`](https://claude.com/docs/plugins/overview.md).

## Plugin directory

The official plugin directory is at
[`claude.com/plugins-for/cowork`](https://claude.com/plugins-for/cowork).
Anthropic has open-sourced 11 plugins: Productivity, Enterprise search,
Sales, Finance, Data, Legal, Marketing, Customer support, Product
management, Biology research, and Plugin Create.

In Claude Code the directory surfaces as the `claude-plugins-official`
marketplace — automatically available to all users.

### Community vs. Anthropic Verified

Plugins are community-submitted; Anthropic performs basic automated
review. Plugins with an **Anthropic Verified** badge have undergone
additional quality and safety review. Review plugin permissions and
connected services before installing community plugins.

## Plugin marketplaces

A marketplace is a directory of installable plugins, identified by
a URL pointing at a `marketplace.json` file. Users can:

- Browse plugins from any marketplace they trust.
- Install plugins from a marketplace with one command.
- Update / remove installed plugins.

Anthropic operates the public plugin directory (above). Organizations
can run their own private marketplaces for internal-only plugins
(common in Cowork on 3P deployments).

## Installation scope

| Scope | Where | When to use |
|---|---|---|
| **User-global** | `~/.claude/plugins/` | Plugins you use across all projects |
| **Project-local** | `<project>/.claude/plugins/` | Plugins specific to one codebase, committed to repo |
| **Org-managed** | MDM-distributed | Cowork on 3P deployments |

## Submitting a plugin

Three paths to get a plugin to users:

1. **Direct install** — guide users to install it themselves (internal
   tools, small teams).
2. **Own marketplace** — serve your own `marketplace.json` for opted-in
   users (enterprise / community contexts).
3. **Plugin directory** — submit to the public directory for all
   Cowork and Claude Code users.

For the directory:
- Run `claude plugin validate` before submitting.
- Submit a **public** GitHub repo or zip file via:
  - Claude.ai: `https://claude.ai/settings/plugins/submit`
  - Console: `https://platform.claude.com/plugins/submit`
- Updates pushed to the repo are picked up automatically — no
  resubmission needed.
- See [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md)
  for full review criteria and terms.

## SETUP.md skill

Plugins can include a `SETUP.md` skill file to guide Claude through
configuring and connecting any MCP servers bundled in the plugin.
Claude follows this skill when the user installs or activates the
plugin.

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
