---
name: claude-code-plugins
description: |
  Deep reference for Claude Code plugins and marketplaces. Covers the
  plugin manifest (`.claude-plugin/plugin.json`) schema, marketplace
  manifest (`marketplace.json`) schema, the seven marketplace source
  types (github / git / url / npm / file / directory / hostPattern),
  install scopes (user / project / local), what plugins can ship
  (skills/commands/agents/hooks/MCP/LSP/monitors/bin), plugin
  discovery paths, and CLI management commands. Read this file when
  the user asks about authoring or installing a plugin, plugin manifest
  fields, or marketplace setup.
source: https://code.claude.com/docs/en/plugins.md
---

# Claude Code — Plugins and Marketplaces

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for plugin questions.*

Source: [`code.claude.com/docs/en/plugins.md`](https://code.claude.com/docs/en/plugins.md), [`code.claude.com/docs/en/plugins-reference.md`](https://code.claude.com/docs/en/plugins-reference.md)

## Standalone config vs plugins

| Approach | Skill names | Best for |
|---|---|---|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`<dir>/.claude-plugin/plugin.json`) | `/my-plugin:hello` | Sharing with teammates, versioned releases, cross-project reuse, marketplace distribution |

## Plugin manifest: `.claude-plugin/plugin.json`

Every plugin has a manifest at `<plugin-root>/.claude-plugin/plugin.json`. Only `plugin.json` goes inside `.claude-plugin/`; all other directories (skills/, agents/, etc.) go at the plugin root level.

| Field | Required | Notes |
|---|---|---|
| `name` | yes | Lowercase kebab-case. Becomes the skill namespace (e.g. `my-plugin:hello`). |
| `version` | no | SemVer string. If set, users only receive updates when you bump this. If omitted, commit SHA is used. |
| `description` | no | One-line summary, shown in plugin manager and marketplace listings. |
| `author` | no | String or `{ name, email?, url? }` object. |
| `homepage` | no | URL. |
| `repository` | no | URL or `{ type, url }` object. |
| `license` | no | SPDX identifier (e.g. `MIT`, `Apache-2.0`). |
| `keywords` | no | Array of strings for marketplace search. |
| `mcpServers` | no | Inline MCP server configurations (alternative to `.mcp.json` at plugin root). |

Minimal valid manifest:
```json
{
  "name": "my-plugin",
  "version": "0.1.0"
}
```

## Plugin discovery: convention paths

Claude Code auto-discovers components from these paths inside the plugin directory:

| Directory | Location | Purpose |
|---|---|---|
| `.claude-plugin/` | Plugin root | Contains `plugin.json` manifest only |
| `skills/` | Plugin root | Skills as `<name>/SKILL.md` directories |
| `commands/` | Plugin root | Skills as flat Markdown files (legacy; use `skills/` for new plugins) |
| `agents/` | Plugin root | Custom agent definitions |
| `hooks/` | Plugin root | Event handlers in `hooks.json` |
| `.mcp.json` | Plugin root | MCP server configurations |
| `.lsp.json` | Plugin root | LSP server configurations for code intelligence |
| `monitors/` | Plugin root | Background monitor configs in `monitors.json` |
| `bin/` | Plugin root | Executables added to Bash tool's `PATH` while plugin is enabled |
| `settings.json` | Plugin root | Default settings applied when plugin is enabled |

**Common mistake:** Do NOT put `commands/`, `agents/`, `skills/`, or `hooks/` inside `.claude-plugin/`. Only `plugin.json` goes there.

## What plugins can ship

### Skills / commands

- `skills/<name>/SKILL.md` — skill with YAML frontmatter and instructions
- `commands/<name>.md` — flat command file (legacy format)
- Skill names are prefixed: `/my-plugin:hello` for skill `hello` in plugin `my-plugin`

### Agents

- `agents/<name>.md` — custom agent with YAML frontmatter
- Accessible as `my-plugin:agent-name`

### Hooks

- `hooks/hooks.json` — event handlers. When plugin is enabled, its hooks merge with user and project hooks.
- Optional top-level `description` field in `hooks.json`.
- Use `${CLAUDE_PLUGIN_ROOT}` for bundled scripts, `${CLAUDE_PLUGIN_DATA}` for persistent data.

### MCP servers

Two locations:
1. `.mcp.json` at plugin root (separate file)
2. `"mcpServers"` key inline in `plugin.json`

Supported env var placeholders:
- `${CLAUDE_PLUGIN_ROOT}` — plugin's installation directory
- `${CLAUDE_PLUGIN_DATA}` — plugin's persistent data directory
- `${CLAUDE_PROJECT_DIR}` — stable project root

Run `/reload-plugins` after enabling/disabling a plugin to connect/disconnect its MCP servers.

### Executables (`bin/`)

Files in the plugin's `bin/` directory are added to the Bash tool's `PATH` while the plugin is enabled. Useful for custom CLI tools bundled with the plugin.

## Install scopes

| Scope | Where recorded | Shared |
|---|---|---|
| `user` | `~/.claude/settings.json` `enabledPlugins` | No (personal) |
| `project` | `.claude/settings.json` `enabledPlugins` | Yes (committed to git) |
| `local` | `.claude/settings.local.json` `enabledPlugins` | No (gitignored) |
| managed | `managed-settings.json` `enabledPlugins` | Yes (admin-controlled; cannot be disabled by users) |

> **Note:** Project settings take precedence over user settings for `enabledPlugins`. To opt out of a project-enabled plugin on your machine, set `false` in `.claude/settings.local.json`. Plugins force-enabled by managed settings cannot be overridden.

## CLI commands

| Command | Description |
|---|---|
| `claude plugin install <plugin>@<marketplace>` | Install a plugin from a marketplace |
| `claude plugin list` | List installed plugins |
| `claude plugin uninstall <plugin>@<marketplace>` | Uninstall a plugin |
| `claude plugin marketplace add <name> <source>` | Add a marketplace |
| `claude plugin marketplace list` | List configured marketplaces |
| `claude plugin marketplace remove <name>` | Remove a marketplace |
| `/plugin` | Interactive plugin manager within Claude Code |
| `/reload-plugins` | Reload all plugins during a session |

Session-only loading (no installation):
```bash
claude --plugin-dir ./my-plugin           # Load from directory or .zip archive
claude --plugin-url https://example.com/plugin.zip  # Fetch from URL
```

## Marketplace manifest: `marketplace.json`

A marketplace is a collection of plugins. The manifest at `marketplace.json` (or `.claude-plugin/marketplace.json`) lists available plugins.

| Field | Required | Description |
|---|---|---|
| `name` | yes | Marketplace display name |
| `owner` | no | Owner/author of the marketplace |
| `plugins` | yes | Array of plugin entries |

Each plugin entry in `plugins` array:
- `name` — plugin name
- `source` — how to fetch: `{ "source": "github", "repo": "..." }` or other source types

## Marketplace source types

Used in both `extraKnownMarketplaces` (settings) and `strictKnownMarketplaces` (managed policy):

| Source type | Required fields | Notes |
|---|---|---|
| `github` | `repo` | Optional: `ref` (branch/tag/SHA), `path` (subdirectory) |
| `git` | `url` | Optional: `ref`, `path` |
| `url` | `url` | Downloads only `marketplace.json`. Plugins must use external sources (GitHub/npm/git). |
| `npm` | `package` | Scoped packages supported |
| `file` | `path` | Absolute path to `marketplace.json` file |
| `directory` | `path` | Absolute path to directory containing `.claude-plugin/marketplace.json` |
| `hostPattern` | `hostPattern` | Regex matched against marketplace host. Not for `npm`, `file`, `directory`. |
| `pathPattern` | `pathPattern` | Regex matched against `path` field of `file`/`directory` sources |
| `settings` | `name` + `plugins` | Inline marketplace declared in settings.json; no hosted repo needed |

Each marketplace entry also accepts optional `autoUpdate: boolean`. Anthropic official marketplaces default `true`; others default `false`.

## `strictKnownMarketplaces` (managed policy)

Only available in managed settings. Controls which marketplaces users can add. Unlike `extraKnownMarketplaces`, this is a policy gate:

| Value | Behavior |
|---|---|
| `undefined` | No restrictions |
| `[]` (empty) | Complete lockdown — no new marketplaces allowed |
| Array of sources | Only matching sources allowed |

Exact matching for git-based sources (repo/url, ref, path must all match). `hostPattern` and `pathPattern` use regex.

## Plugin dependencies

Use `plugin-dependencies.md` or settings to declare version constraints on plugin dependencies. See [`code.claude.com/docs/en/plugin-dependencies.md`](https://code.claude.com/docs/en/plugin-dependencies.md).

## Finding plugins

Browse the [official plugin marketplace](https://github.com/anthropics/claude-plugins-official) or use `/plugin` → Browse. Plugins can be installed with:
```
/plugin install <plugin-name>@claude-plugins-official
```

## Worked examples

Load a local plugin for development:
```bash
claude --plugin-dir ./my-plugin
```

Install from the official marketplace:
```bash
claude plugin install code-review@claude-plugins-official
```

Declare project plugins in `.claude/settings.json`:
```json
{
  "extraKnownMarketplaces": {
    "team-tools": {
      "source": {"source": "github", "repo": "acme/claude-plugins"}
    }
  },
  "enabledPlugins": {
    "formatter@team-tools": true
  }
}
```

---

*Source pages: [`code.claude.com/docs/en/plugins.md`](https://code.claude.com/docs/en/plugins.md), [`code.claude.com/docs/en/plugins-reference.md`](https://code.claude.com/docs/en/plugins-reference.md)*
