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

## Marketplace source types

Eight source types for `extraKnownMarketplaces` and `strictKnownMarketplaces`:

| Type | Key fields | Notes |
|---|---|---|
| `github` | `repo` (required), `ref` (optional), `path` (optional) | GitHub repository. Always matches against `github.com`. |
| `git` | `url` (required), `ref` (optional), `path` (optional) | Any git URL (HTTPS or SSH). |
| `url` | `url` (required), `headers` (optional) | Downloads only `marketplace.json`, not plugin files. Plugins must use external sources. |
| `npm` | `package` (required) | npm package (supports scoped). |
| `file` | `path` (required, absolute) | Local filesystem path to `marketplace.json`. |
| `directory` | `path` (required, absolute) | Directory containing `.claude-plugin/marketplace.json`. |
| `hostPattern` | `hostPattern` (required, regex) | Match all marketplaces on a hostname. Useful for GitHub Enterprise. |
| `pathPattern` | `pathPattern` (required, regex) | Match `file`/`directory` sources by path. |
| `settings` | `name`, `plugins` array | Inline marketplace declared directly in settings.json (no hosted repo). |

## Install scopes

| Scope | Where recorded | Who it affects |
|---|---|---|
| User | `~/.claude/settings.json` `enabledPlugins` | You, across all projects |
| Project | `.claude/settings.json` `enabledPlugins` | All collaborators (committed to git) |
| Local | `.claude/settings.local.json` `enabledPlugins` | You, in this project only (gitignored) |
| Managed | `managed-settings.json` `enabledPlugins` | All users; can force-enable or block |

Project settings override user settings for plugins. To disable a project-enabled plugin, set `false` in `.claude/settings.local.json`.

## What plugins can ship

Plugins auto-discover content via convention paths inside the plugin directory:

| Convention path | What it provides |
|---|---|
| `commands/` | Slash commands (`.md` files with YAML frontmatter) |
| `agents/` | Subagent definitions |
| `skills/` | Skill packs |
| `hooks/hooks.json` | Hook handlers |
| `rules/` | Rules files |
| `.mcp.json` | MCP server configs (auto-started when plugin enabled) |

These are NOT listed in `plugin.json` — they are auto-discovered.

## Plugin MCP servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Plugin MCP servers use `${CLAUDE_PLUGIN_ROOT}` to reference files relative to plugin root:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/main",
      "env": { "DB_URL": "${DB_URL}" }
    }
  }
}
```

## CLI commands

| Command | Description |
|---|---|
| `claude plugin install <name>@<marketplace>` | Install a plugin |
| `claude plugin list` | List installed plugins |
| `claude plugin enable <name>@<marketplace>` | Enable a plugin |
| `claude plugin disable <name>@<marketplace>` | Disable a plugin |
| `claude plugin uninstall <name>@<marketplace>` | Uninstall a plugin |
| `claude plugin marketplace add` | Add a marketplace |
| `claude plugin marketplace remove` | Remove a marketplace |
| `claude plugin marketplace list` | List marketplaces |
| `/plugin` | In-session plugin manager |
| `/reload-plugins` | Reload all active plugins (applies changes without restart) |

## `plugin.json` zip/url loading (v2.1.x+)

Plugins can also be loaded from `.zip` archives:
- `--plugin-dir ./my-plugin.zip` — load from zip for this session
- `--plugin-url https://example.com/plugin.zip` — fetch from URL for this session

Source: `code.claude.com/docs/en/plugins.md`, `code.claude.com/docs/en/plugins-reference.md`.

## Common mistakes (auto-corrected by `rules/plugins.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/plugins.md`.*
