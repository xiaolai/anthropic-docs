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

- **Claude Code (CLI)** — `/plugin` commands, plugin marketplaces.
- **Claude Cowork** — full plugin support (see
  [`claude-cowork → SKILL-cowork.md`](../claude-cowork/SKILL-cowork.md)).

Plugins are NOT available on Claude.ai web or Mobile (as of this
snapshot — check upstream for current state).

## Plugin directory

Anthropic hosts a public plugin directory at
[claude.com/plugins-for/cowork](https://claude.com/plugins-for/cowork).
It is also surfaced in Claude Code as the `claude-plugins-official`
marketplace. This is distinct from the **Connectors Directory** (MCP
connectors only). Source:
[`plugins/submit.md`](https://claude.com/docs/plugins/submit.md),
[`plugins/overview.md`](https://claude.com/docs/plugins/overview.md).

Anthropic has open-sourced 11 internally-used plugins as starting
points (Productivity, Sales, Finance, Data, Legal, Marketing, Customer
Support, Product Management, Biology Research, Enterprise Search,
Plugin Create).

Plugins carry either **Community** or **Anthropic Verified** status.
Verified plugins have passed additional quality + safety review.

## Plugin marketplaces

A marketplace is a directory of installable plugins, identified by
a URL pointing at a `marketplace.json` file. Users can:

- Browse plugins from any marketplace they trust.
- Install plugins from a marketplace with one command.
- Update / remove installed plugins.

Anthropic operates a public plugin marketplace for the broader
community. Organizations can run their own private marketplaces for
internal-only plugins (common in Cowork on 3P deployments — see
[`claude-cowork`](../claude-cowork/SKILL-cowork.md) for the "org-plugins
directory" pattern).

## Submitting a plugin

Source: [`plugins/submit.md`](https://claude.com/docs/plugins/submit.md).

**Before submitting:** run `claude plugin validate` to check formatting
and structure. The plugin source must live in a **public GitHub repo**
(closed-source is not accepted).

**Submission forms:**

| Surface | URL |
|---|---|
| Claude.ai | <https://claude.ai/settings/plugins/submit> |
| Console | <https://platform.claude.com/plugins/submit> |

After publishing, updates pushed to your GitHub repo are picked up
automatically — no re-submit required.

**Terms:** all plugins must comply with the
[Anthropic Software Directory Terms](https://support.claude.com/en/articles/13145338-anthropic-software-directory-terms)
and
[Anthropic Software Directory Policy](https://support.claude.com/en/articles/13145358-anthropic-software-directory-policy).

## SETUP.md pattern

Plugins can include a `SETUP.md` skill to guide Claude through
configuring MCP servers bundled in the plugin. Claude follows the
setup instructions when a user installs or activates the plugin.

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
