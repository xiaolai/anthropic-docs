---
name: claude-code-plugins
description: |
  Deep reference for Claude Code plugins and marketplaces. Covers the
  plugin manifest (`.claude-plugin/plugin.json`) schema, marketplace
  manifest (`marketplace.json`) schema, the seven marketplace source
  types (github / git / url / npm / file / directory / hostPattern),
  install scopes (user / project / local), how plugins package
  commands / agents / skills / hooks, and the install / enable /
  disable / uninstall lifecycle. Read this file when the user asks
  about authoring or installing a plugin, plugin manifest fields, or
  marketplace setup.
source: https://code.claude.com/docs/en/plugins.md
---

# Claude Code — Plugins and Marketplaces

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for plugin questions.*

## Plugin manifest: `.claude-plugin/plugin.json`

<!-- seed: replace on first real research pass -->

A plugin manifest lives at `<plugin-root>/.claude-plugin/plugin.json` and declares the plugin's identity. Required: `name`, `version`. The remaining fields (`description`, `author`, `homepage`, `repository`, `license`, `keywords`) are optional metadata used for display in `claude plugin list`, marketplace search, and attribution.

| Field | Required | Notes |
|---|---|---|
| `name` | yes | Lowercase kebab-case identifier. Should be unique within the marketplace. |
| `version` | yes | SemVer string (e.g., `0.1.0`, `1.2.3-beta.1`). |
| `description` | no | One-line summary, surfaced in `claude plugin list` and marketplace listings. |
| `author` | no | String or `{ name, email?, url? }` object. |
| `homepage` | no | URL. |
| `repository` | no | URL or `{ type, url }` object. |
| `license` | no | SPDX identifier (e.g., `MIT`, `Apache-2.0`). |
| `keywords` | no | Array of strings, for marketplace search. |

Minimal valid manifest:

```json
{
  "name": "my-plugin",
  "version": "0.1.0"
}
```

Skills, commands, agents, hooks, and rules shipped by a plugin are **auto-discovered** from convention paths inside the plugin directory — they are NOT enumerated in `plugin.json`. See § *Plugin discovery: convention paths* below.

Source: `code.claude.com/docs/en/plugins.md`.

## Marketplace manifest: `marketplace.json`

A marketplace is a collection of plugins hosted in a git repo. Its `marketplace.json` declares the marketplace and its plugins.

```json
{
  "name": "acme-tools",
  "owner": { "name": "Acme Corp", "url": "https://acme.com" },
  "plugins": [
    {
      "name": "code-formatter",
      "description": "Auto-format code on save",
      "source": { "source": "github", "repo": "acme-corp/code-formatter" }
    }
  ]
}
```

Required fields: `name`, `owner` (object with at least `name`). The `plugins` array lists available plugins.

## Marketplace source types

Marketplaces and plugins can be sourced in multiple ways:

| Source type | Key field | Use case |
|---|---|---|
| `github` | `repo: "owner/repo"` | GitHub-hosted plugin |
| `git` | `url: "https://..."` | Any git URL |
| `url` | `url: "https://..."` | Direct URL to `.zip` archive |
| `npm` | `package: "@scope/name"` | npm package |
| `file` | `path: "/abs/path"` | Local filesystem (dev only) |
| `directory` | `path: "/abs/path"` | Local directory (dev only) |
| `hostPattern` | `hostPattern: "*.example.com"` | Regex for marketplace host matching |
| `settings` | inline `name` + `plugins` | Inline marketplace in `settings.json` (no hosted repo needed) |

## Install scopes

| Scope | Recorded in | Notes |
|---|---|---|
| `user` | `~/.claude/settings.json` `enabledPlugins` | Personal, applies to all projects |
| `project` | `.claude/settings.json` `enabledPlugins` | Shared with team via git |
| `local` | `.claude/settings.local.json` `enabledPlugins` | Personal override for this project; gitignored |

Managed settings can force-enable plugins that cannot be disabled by users.

## What plugins can ship

A plugin directory can contain any of these by convention (no manifest enumeration needed):

| Path | Content |
|---|---|
| `commands/*.md` | Slash commands (e.g. `/plugin-name:command`) |
| `agents/*.md` | Subagent definitions |
| `skills/*/SKILL.md` | Skill routers |
| `.claude/hooks/**` | Hook scripts |
| `rules/*.md` | Auto-correction rules |
| `.mcp.json` | MCP server configurations |
| `bin/` | Executables added to PATH during plugin activation |

## Plugin discovery: convention paths

Claude Code auto-discovers all the above resource types from the plugin root. You do **not** list them in `plugin.json`. The plugin manifest only declares identity (`name`, `version`).

## CLI commands

```bash
claude plugin install code-review@claude-plugins-official   # install from marketplace
claude plugin install --url https://example.com/plugin.zip  # install from URL
claude plugin install --dir ./my-local-plugin               # install from local dir
claude plugin list                                           # list installed plugins
claude plugin enable my-plugin@marketplace                   # enable a plugin
claude plugin disable my-plugin@marketplace                  # disable a plugin
claude plugin uninstall my-plugin@marketplace               # uninstall
claude plugin marketplace add https://...                   # add a marketplace
claude plugin marketplace list                              # list configured marketplaces
claude plugin update                                        # update all plugins
```

Inside a session: `/plugin` to manage plugins, `/reload-plugins` to hot-reload after changes.

Source: [plugins.md](https://code.claude.com/docs/en/plugins.md), [plugins-reference.md](https://code.claude.com/docs/en/plugins-reference.md).

## Worked examples

> *Populated by the research agent.* See also:
> [`templates/.claude-plugin/plugin.json`](templates/.claude-plugin/plugin.json).

## Common mistakes (auto-corrected by `rules/plugins.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/plugins.md`.*
