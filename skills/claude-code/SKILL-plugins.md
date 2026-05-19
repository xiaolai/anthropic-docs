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

Required top-level keys:

| Key | Type | Notes |
|---|---|---|
| `name` | string | Marketplace identifier |
| `owner` | object | Must contain at least `{ "name": "..." }` |
| `plugins` | array | Array of plugin source entries |

## Marketplace source types

Eight source types for `extraKnownMarketplaces` and `strictKnownMarketplaces`:

| Source type | Key field | Notes |
|---|---|---|
| `github` | `repo` | `"acme-corp/plugins"` |
| `git` | `url` | Any git URL |
| `url` | `url` | Direct URL to `marketplace.json` |
| `npm` | `package` | Scoped packages supported |
| `file` | `path` | Absolute path to `marketplace.json` |
| `directory` | `path` | Absolute path to directory with `.claude-plugin/marketplace.json` |
| `hostPattern` | `hostPattern` | Regex against marketplace host |
| `pathPattern` | `pathPattern` | Regex against filesystem path (`file`/`directory` sources) |
| `settings` | `name`, `plugins` | Inline marketplace in `settings.json` |

## Install scopes

| Scope | Where recorded | Notes |
|---|---|---|
| `user` | `~/.claude/settings.json` `enabledPlugins` | Personal, all projects |
| `project` | `.claude/settings.json` `enabledPlugins` | Team-shared |
| `local` | `.claude/settings.local.json` `enabledPlugins` | Per-machine, gitignored |

## What plugins can ship (convention paths)

Plugins auto-discover resources from convention paths — **not** via manifest arrays:

| Path inside plugin root | What it provides |
|---|---|
| `skills/<name>/SKILL.md` | Skill (invoked as `/<plugin>:<name>`) |
| `agents/<name>.md` | Subagent definition |
| `commands/<name>.md` | Slash command |
| `hooks/hooks.json` | Hook handlers |
| `rules/*.md` | Auto-correction rules |
| `.mcp.json` or MCP in `plugin.json` | MCP servers |
| `<executables>/` | Executables added to PATH |

## CLI commands

```bash
claude plugin install <name>@<marketplace>     # install a plugin
claude plugin list                              # list installed plugins
claude plugin marketplace add <url-or-source>  # register a marketplace
claude plugin marketplace list                  # list known marketplaces
claude plugin update [name@marketplace]         # update plugins
claude plugin enable <name>@<marketplace>       # enable a disabled plugin
claude plugin disable <name>@<marketplace>      # disable a plugin
claude plugin uninstall <name>@<marketplace>    # remove a plugin
```

Load a plugin for a single session without installing: `claude --plugin-dir ./my-plugin` or `claude --plugin-url https://example.com/plugin.zip`.

In-session: `/plugin` to browse, install, enable/disable, and manage marketplaces interactively.

## Common mistakes (auto-corrected by `rules/plugins.md`)

See [`rules/plugins.md`](rules/plugins.md) — covers: required fields; `marketplace.json` needs `owner`; `version` must be SemVer; no `commands`/`skills` arrays in `plugin.json`.

---

*Source pages: `code.claude.com/docs/en/plugins.md`.*
