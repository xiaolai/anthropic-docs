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

## Plugin directory structure

Source: [`plugins.md`](https://code.claude.com/docs/en/plugins.md) and [`plugins-reference.md`](https://code.claude.com/docs/en/plugins-reference.md).

**Critical:** Only `plugin.json` goes inside `.claude-plugin/`. All other directories are at the plugin root:

| Directory/file | Plugin root location | Purpose |
|---|---|---|
| `.claude-plugin/plugin.json` | `.claude-plugin/` | Manifest (required) |
| `skills/` | root | Skills as `<name>/SKILL.md` subdirectories |
| `commands/` | root | Skills as flat `.md` files (legacy; prefer `skills/`) |
| `agents/` | root | Custom agent definitions |
| `hooks/hooks.json` | `hooks/` | Event hooks |
| `.mcp.json` | root | MCP server configurations |
| `.lsp.json` | root | LSP server configurations |
| `monitors/monitors.json` | `monitors/` | Background monitors |
| `bin/` | root | Executables added to Bash `PATH` while plugin is enabled |
| `settings.json` | root | Default settings applied when plugin is enabled |

**Skill namespacing:** Plugin skills are invoked as `/plugin-name:skill-name` (prevents conflicts with other plugins and standalone commands).

## Marketplace manifest: `marketplace.json`

A marketplace is a collection of plugin references. The marketplace JSON lives at the repo root (for github/git sources) or as the fetched file (for url/npm/file sources):

```json
{
  "name": "team-tools",
  "owner": "acme-corp",
  "plugins": [
    {
      "name": "code-formatter",
      "source": { "source": "github", "repo": "acme-corp/code-formatter" }
    },
    {
      "name": "deploy-helper",
      "source": { "source": "npm", "package": "@acme/deploy-helper" }
    }
  ]
}
```

## Marketplace source types

| Source type | Required field(s) | Optional fields |
|---|---|---|
| `github` | `repo` (e.g. `"acme/plugins"`) | `ref` (branch/tag/SHA), `path` (subdirectory) |
| `git` | `url` (any git URL, HTTPS or SSH) | `ref`, `path` |
| `url` | `url` (points to `marketplace.json`) | `headers` |
| `npm` | `package` (supports scoped packages) | — |
| `file` | `path` (absolute path to `marketplace.json`) | — |
| `directory` | `path` (absolute path to dir with `marketplace.json`) | — |
| `settings` | `name`, `plugins` array (inline marketplace in settings.json) | — |
| `hostPattern` | `hostPattern` (regex matched against host) | — |
| `pathPattern` | `pathPattern` (regex matched against path field) | — |

`url`-based marketplaces only download `marketplace.json`; plugins in them must reference external sources (github/npm/git), not relative paths.

To add a marketplace via CLI: `claude mcp add` / `claude plugin marketplace add`. To add via settings: use `extraKnownMarketplaces` in `settings.json`. See [`SKILL-settings.md`](SKILL-settings.md).

## Install scopes

| Scope | Stored in | Applies to |
|---|---|---|
| `user` | `~/.claude/settings.json` `enabledPlugins` | All your projects |
| `project` | `.claude/settings.json` `enabledPlugins` | This project (shared via git) |
| `local` | `.claude/settings.local.json` `enabledPlugins` | This project (you only, gitignored) |
| managed | `managed-settings.json` `enabledPlugins` | Org-wide (admin-deployed) |

**Precedence:** Project settings override user settings for a given `enabledPlugins` key. To opt out of a project-enabled plugin, set it to `false` in `settings.local.json`. Managed settings force-enable or force-disable a plugin and cannot be overridden.

## What plugins can ship

See the directory structure table above for the full list. Highlights:

- **Skills** (`skills/<name>/SKILL.md`): invoked as `/plugin-name:skill-name`
- **Commands** (`commands/<name>.md`): legacy flat-file skills; same namespace
- **Agents** (`agents/<name>.md`): custom subagent definitions
- **Hooks** (`hooks/hooks.json`): event handlers (fire when plugin is enabled)
- **MCP servers** (`.mcp.json` at plugin root, or `mcpServers` key in `plugin.json`): connect when plugin is enabled
- **Executables** (`bin/`): added to the Bash tool's `PATH` while the plugin is enabled
- **Default settings** (`settings.json` at plugin root): merged as lowest-priority settings when the plugin is enabled
- **Rules** (follow `.claude/rules/` convention): auto-correction rules

## Plugin discovery: convention paths

Claude Code auto-discovers plugin components by looking for these directories/files at the plugin root (the directory containing `.claude-plugin/`):

- `skills/<name>/SKILL.md` → `/plugin-name:name` skill
- `commands/<name>.md` → `/plugin-name:name` command (legacy)
- `agents/<name>.md` → subagent definition
- `hooks/hooks.json` → hook configuration
- `.mcp.json` → MCP server definitions
- `bin/` → executables on PATH
- `settings.json` → default settings

Nothing needs to be declared in `plugin.json`; presence of the directory/file is enough for auto-discovery. `plugin.json` can optionally include `mcpServers` inline as an alternative to `.mcp.json`.

## CLI commands

| Command | Description |
|---|---|
| `claude plugin install <name>@<marketplace>` | Install a plugin from a marketplace |
| `claude plugin list` | List installed plugins |
| `claude plugin uninstall <name>@<marketplace>` | Uninstall a plugin |
| `claude plugin update [<name>@<marketplace>]` | Update installed plugins |
| `claude plugin marketplace add <url-or-spec>` | Add a marketplace |
| `claude plugin marketplace list` | List configured marketplaces |
| `claude plugin marketplace remove <name>` | Remove a marketplace |
| `claude plugin info <name>@<marketplace>` | Show plugin details |
| `/plugin` | Interactive plugin manager (install/enable/disable/details) |
| `/reload-plugins` | Reload all plugins in current session after changes |
| `--plugin-dir <path>` | Load plugin from directory or `.zip` for this session only |
| `--plugin-url <url>` | Fetch plugin `.zip` from URL for this session only |

## Worked examples

> *Populated by the research agent.* See also:
> [`templates/.claude-plugin/plugin.json`](templates/.claude-plugin/plugin.json).

## Common mistakes (auto-corrected by `rules/plugins.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/plugins.md`.*
