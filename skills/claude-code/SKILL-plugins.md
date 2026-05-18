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

The marketplace manifest lives at the root of a marketplace repository. Keys:

| Field | Notes |
|---|---|
| `name` | Marketplace identifier |
| `owner` | Owning org or user |
| `plugins` | Array of plugin entries, each with `name` and `source` |

Each `plugins` entry has a `source` object (same structure as `strictKnownMarketplaces` entries).

## Marketplace source types

Eight source types used in `extraKnownMarketplaces`, `strictKnownMarketplaces`, and marketplace plugin entries:

| Source type | Required field(s) | Notes |
|---|---|---|
| `github` | `repo` | Optional `ref` (branch/tag/SHA), `path` (subdirectory) |
| `git` | `url` | Optional `ref`, `path` |
| `url` | `url` | Downloads only `marketplace.json`; plugins must use external sources |
| `npm` | `package` | Scoped packages supported (`@scope/pkg`) |
| `file` | `path` | Absolute path to `marketplace.json` |
| `directory` | `path` | Absolute path to directory with `.claude-plugin/marketplace.json` |
| `hostPattern` | `hostPattern` | Regex against marketplace host (matches `github`, `git`, `url` types) |
| `pathPattern` | `pathPattern` | Regex against filesystem path (matches `file`, `directory` types) |
| `settings` | `name`, `plugins` | Inline marketplace in settings.json; plugins must reference external sources |

## Install scopes

| Scope | Recorded in | Notes |
|---|---|---|
| `user` | `~/.claude/settings.json` `enabledPlugins` | Available across all projects |
| `project` | `.claude/settings.json` `enabledPlugins` | Shared with team (committed) |
| `local` | `.claude/settings.local.json` `enabledPlugins` | Per-machine override, gitignored |

Managed settings can force-enable plugins via `enabledPlugins` — these cannot be disabled by users.

## What plugins can ship

Convention directories at plugin root (NOT inside `.claude-plugin/`):

| Directory/file | Purpose |
|---|---|
| `skills/` | Skills as `<name>/SKILL.md` directories |
| `commands/` | Legacy skills as flat `.md` files |
| `agents/` | Custom agent definitions |
| `hooks/hooks.json` | Event handlers |
| `.mcp.json` | MCP server configurations |
| `.lsp.json` | LSP server configurations |
| `monitors/monitors.json` | Background monitor configs |
| `bin/` | Executables added to Bash tool's PATH |
| `settings.json` | Default settings applied when plugin enabled |

## Plugin discovery: convention paths

Claude Code auto-discovers all content from convention paths — nothing is enumerated in `plugin.json`. Plugin skills are namespaced: skill `hello` in plugin `my-plugin` creates `/my-plugin:hello`.

## CLI commands

```bash
# Install a plugin
claude plugin install code-review@claude-plugins-official

# List installed plugins
claude plugin list

# Add a marketplace
claude plugin marketplace add acme-tools

# Remove a plugin
claude plugin uninstall code-review@claude-plugins-official

# Reload plugins without restarting
/reload-plugins
```

Interactive plugin management: `/plugin` in Claude Code session.

## Worked examples

See also: [`templates/.claude-plugin/plugin.json`](templates/.claude-plugin/plugin.json).

Development workflow:
```bash
# Test locally without installing
claude --plugin-dir ./my-plugin

# Load multiple plugins
claude --plugin-dir ./plugin-a --plugin-dir ./plugin-b.zip
```

## Common mistakes (auto-corrected by `rules/plugins.md`)

- Putting `skills/`, `agents/`, `hooks/`, or `commands/` inside `.claude-plugin/` — only `plugin.json` goes there.
- Forgetting plugin skill namespace: `/hello` won't work; use `/my-plugin:hello`.
- Not pinning plugin version in `marketplace.json` — omitting `version` means every commit triggers an update.
- Expecting short skill names from plugins — plugin skills are always namespaced.

---

*Source pages: `code.claude.com/docs/en/plugins.md`.*
