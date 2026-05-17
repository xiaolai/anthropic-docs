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

> *Populated by the research agent.* The `name`, `owner`, and
> `plugins` array structure.

## Marketplace source types

> *Populated by the research agent.* Seven source types:
> `github`, `git`, `url`, `npm`, `file`, `directory`, `hostPattern`.

## Install scopes

> *Populated by the research agent.* `user` / `project` / `local` —
> what each means and where the install is recorded.

## What plugins can ship

> *Populated by the research agent.* Commands, agents, skills, hooks,
> rules, MCP server configs.

## Plugin discovery: convention paths

> *Populated by the research agent.* How Claude Code finds
> `commands/`, `agents/`, `skills/`, etc. inside a plugin.

## CLI commands

> *Populated by the research agent.* `claude plugin install`,
> `claude plugin list`, `claude plugin marketplace add`, etc.

## Worked examples

> *Populated by the research agent.* See also:
> [`templates/.claude-plugin/plugin.json`](templates/.claude-plugin/plugin.json).

## Common mistakes (auto-corrected by `rules/plugins.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/plugins.md`.*
