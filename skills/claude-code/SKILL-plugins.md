---
name: claude-code-plugins
description: |
  Deep reference for Claude Code plugins and marketplaces. Covers the
  plugin manifest (.claude-plugin/plugin.json) schema, plugin directory
  structure, the seven marketplace source types (github / git / url /
  npm / file / directory / hostPattern / settings), install scopes
  (user / project / local), what plugins can ship (skills, agents,
  hooks, MCP servers, LSP servers, bin executables, monitors), and the
  install / enable / disable / uninstall lifecycle. Read this file when
  the user asks about authoring or installing a plugin, plugin manifest
  fields, plugin directory layout, or marketplace setup.
source: https://code.claude.com/docs/en/plugins.md
---

# Claude Code — Plugins and Marketplaces

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for plugin questions.*

## When to use plugins vs standalone configuration

| Approach | Skill names | Best for |
|---|---|---|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific customizations, quick experiments |
| **Plugins** (directories with `.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing with teammates, distributing to community, versioned releases |

Use plugins when you need the same functionality across multiple projects, want to distribute through a marketplace, or need version control for your extensions.

Source: `code.claude.com/docs/en/plugins.md`.

## Plugin manifest: `.claude-plugin/plugin.json`

A plugin manifest lives at `<plugin-root>/.claude-plugin/plugin.json`. The `.claude-plugin/` directory contains ONLY `plugin.json` — do NOT put `commands/`, `agents/`, `skills/`, or `hooks/` inside it.

| Field | Required | Notes |
|---|---|---|
| `name` | yes | Lowercase kebab-case identifier. Becomes the skill namespace prefix (e.g. `/my-plugin:hello`). |
| `version` | yes | SemVer string (e.g. `"1.0.0"`). If omitted for git-distributed plugins, commit SHA is used. |
| `description` | no | One-line summary shown in plugin manager and marketplace listings. |
| `author` | no | String or `{ name, email?, url? }` object. |
| `homepage` | no | URL. |
| `repository` | no | URL or `{ type, url }` object. |
| `license` | no | SPDX identifier (e.g. `"MIT"`, `"Apache-2.0"`). |
| `keywords` | no | Array of strings for marketplace search. |
| `mcpServers` | no | Inline MCP server definitions (alternative to `.mcp.json` at plugin root). |

Minimal valid manifest:

```json
{
  "name": "my-plugin",
  "version": "0.1.0"
}
```

Skills, commands, agents, hooks, and other components are **auto-discovered** from convention paths inside the plugin directory — they are NOT enumerated in `plugin.json`.

## Plugin directory structure

| Directory/file | Location | Purpose |
|---|---|---|
| `.claude-plugin/` | Plugin root | Contains `plugin.json` only |
| `skills/` | Plugin root | Skills as `<name>/SKILL.md` directories (preferred) |
| `commands/` | Plugin root | Skills as flat Markdown files (legacy; use `skills/` for new plugins) |
| `agents/` | Plugin root | Custom agent definitions |
| `hooks/` | Plugin root | Event handlers in `hooks.json` |
| `.mcp.json` | Plugin root | MCP server configurations |
| `.lsp.json` | Plugin root | LSP server configurations for code intelligence |
| `monitors/` | Plugin root | Background monitor configurations in `monitors.json` |
| `bin/` | Plugin root | Executables added to `PATH` while plugin is enabled |
| `settings.json` | Plugin root | Default settings applied when plugin is enabled |

**Common mistake:** Do NOT place `commands/`, `agents/`, `skills/`, or `hooks/` inside `.claude-plugin/`. They must be at the plugin root level.

## Plugin lifecycle

```bash
# Load a plugin for this session only (development/testing)
claude --plugin-dir ./my-plugin

# Load from a zip archive
claude --plugin-dir ./my-plugin.zip

# Load from URL
claude --plugin-url https://example.com/plugin.zip

# Install from marketplace (persistent)
claude plugin install my-plugin@my-marketplace

# Manage plugins interactively
/plugin
```

After enabling/disabling a plugin mid-session, run `/reload-plugins` to connect/disconnect its components.

## Marketplace manifest: `marketplace.json`

A marketplace is a collection of plugins. The `marketplace.json` file at the marketplace root:

```json
{
  "name": "my-marketplace",
  "owner": "acme-corp",
  "plugins": [
    {
      "name": "code-formatter",
      "source": {
        "source": "github",
        "repo": "acme-corp/code-formatter"
      }
    }
  ]
}
```

## Marketplace source types

Used in `marketplace.json` `plugins[].source` and in `extraKnownMarketplaces` in settings:

| Source type | Required fields | Notes |
|---|---|---|
| `github` | `repo` | GitHub repository. Optional: `ref` (branch/tag/SHA), `path` (subdirectory) |
| `git` | `url` | Any git URL. Optional: `ref`, `path` |
| `url` | `url` | Direct URL to `marketplace.json`. Optional: `headers` for auth. Plugins must use external sources (not relative paths) |
| `npm` | `package` | npm package (supports scoped packages `@scope/name`) |
| `file` | `path` | Absolute path to `marketplace.json` file |
| `directory` | `path` | Absolute path to directory containing `.claude-plugin/marketplace.json` |
| `hostPattern` | `hostPattern` | Regex matched against marketplace host. For allowing all marketplaces from a host |
| `pathPattern` | `pathPattern` | Regex matched against filesystem `path` for `file`/`directory` sources |
| `settings` | `name`, `plugins` | Inline marketplace declared directly in settings.json |

## Install scopes

| Scope | Where stored | Shared with team |
|---|---|---|
| `user` | `~/.claude/settings.json` `enabledPlugins` | No |
| `project` | `.claude/settings.json` `enabledPlugins` | Yes (committed) |
| `local` | `.claude/settings.local.json` `enabledPlugins` | No (gitignored) |

A plugin set to `false` in user settings does NOT override a project `settings.json` that enables it. Use `settings.local.json` to opt out of a project-enabled plugin.

Managed settings can force-enable plugins (`enabledPlugins` in managed settings) — these cannot be disabled by users.

## `extraKnownMarketplaces` and `enabledPlugins` in settings

Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) § *`extraKnownMarketplaces` and `enabledPlugins`*.

```json
{
  "enabledPlugins": {
    "code-formatter@acme-tools": true,
    "deployer@acme-tools": false
  },
  "extraKnownMarketplaces": {
    "acme-tools": {
      "source": { "source": "github", "repo": "acme-corp/claude-plugins" },
      "autoUpdate": true
    }
  }
}
```

`enabledPlugins` key format: `"<plugin-name>@<marketplace-name>"`.

`extraKnownMarketplaces`: when a repository includes this setting, team members are prompted to install the marketplace when they trust the folder. Optional `autoUpdate: true` to refresh at startup (default `false` for non-Anthropic marketplaces).

## Plugin MCP servers

Plugins can bundle MCP servers in `.mcp.json` at the plugin root or inline in `plugin.json`. Available environment variables in plugin MCP configs:
- `${CLAUDE_PLUGIN_ROOT}` — plugin installation directory
- `${CLAUDE_PLUGIN_DATA}` — persistent state directory (survives updates)
- `${CLAUDE_PROJECT_DIR}` — stable project root

Cross-reference: [`SKILL-mcp.md`](SKILL-mcp.md) § *Plugin-provided MCP servers*.

## CLI commands

```bash
# Install a plugin
claude plugin install my-plugin@my-marketplace

# List installed plugins
claude plugin list

# Enable/disable a plugin
claude plugin enable my-plugin@my-marketplace
claude plugin disable my-plugin@my-marketplace

# Add a marketplace
claude plugin marketplace add

# Update plugins
claude plugin update

# Interactive management
/plugin
```

## Managed marketplace restrictions

Administrators can use `strictKnownMarketplaces` in `managed-settings.json` to restrict which marketplace sources users may add. `blockedMarketplaces` provides a denylist.

Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) § *All documented settings keys* (`strictKnownMarketplaces`, `blockedMarketplaces`).

## Common mistakes (auto-corrected by `rules/plugins.md`)

See [`rules/plugins.md`](rules/plugins.md). Key pitfalls:
- `plugin.json` must have both `name` AND `version` (missing `version` fails schema validation)
- Do NOT put component directories inside `.claude-plugin/` — they go at plugin root
- `enabledPlugins` keys use `<plugin>@<marketplace>` format (not bare plugin name)
- Plugin skills are namespaced (`/plugin-name:skill`); standalone `.claude/` skills are bare (`/skill`)

---

*Source pages: `code.claude.com/docs/en/plugins.md`, `plugins-reference.md`.*
