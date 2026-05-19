---
name: claude-code-plugins
description: |
  Deep reference for Claude Code plugins and marketplaces. Covers the
  plugin manifest (`.claude-plugin/plugin.json`) schema, marketplace
  manifest (`marketplace.json`) schema, install scopes (user / project /
  local), how plugins package commands / agents / skills / hooks / MCP
  servers / LSP servers / monitors, the plugin directory structure, and
  the install / enable / disable / uninstall lifecycle. Read this file
  when the user asks about authoring or installing a plugin, plugin manifest
  fields, or marketplace setup.
source: https://code.claude.com/docs/en/plugins.md
---

# Claude Code — Plugins and Marketplaces

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for plugin questions.*

## Plugin manifest: `.claude-plugin/plugin.json`

A plugin manifest lives at `<plugin-root>/.claude-plugin/plugin.json`. Only `name` and `version` are required; everything else is optional metadata.

| Field | Required | Notes |
|---|---|---|
| `name` | yes | Lowercase kebab-case identifier; unique within marketplace. |
| `version` | yes | SemVer string (e.g., `0.1.0`, `1.2.3-beta.1`). |
| `description` | no | One-line summary in `claude plugin list` and marketplace listings. |
| `author` | no | String or `{ name, email?, url? }` object. |
| `homepage` | no | URL. |
| `repository` | no | URL or `{ type, url }` object. |
| `license` | no | SPDX identifier (e.g., `MIT`, `Apache-2.0`). |
| `keywords` | no | Array of strings for marketplace search. |

Minimal valid manifest:

```json
{
  "name": "my-plugin",
  "version": "0.1.0"
}
```

> ⚠️ **Common mistake**: Do NOT put `commands/`, `agents/`, `skills/`, or `hooks/` inside `.claude-plugin/`. Only `plugin.json` goes inside `.claude-plugin/`. All other directories go at the plugin root level.

Source: [code.claude.com/docs/en/plugins.md](https://code.claude.com/docs/en/plugins.md)

## Plugin discovery: convention paths

Claude Code auto-discovers plugin components from conventional directories at the plugin root:

| Directory | Purpose |
|---|---|
| `.claude-plugin/` | Contains `plugin.json` manifest only |
| `skills/` | Skills as `<name>/SKILL.md` directories |
| `commands/` | Skills as flat Markdown files (legacy; use `skills/` for new plugins) |
| `agents/` | Custom agent definitions |
| `hooks/` | Event handlers in `hooks.json` |
| `.mcp.json` | MCP server configurations |
| `.lsp.json` | LSP server configurations for code intelligence |
| `monitors/` | Background monitor configurations in `monitors.json` |
| `bin/` | Executables added to Bash tool's `PATH` while plugin is enabled |
| `settings.json` | Default settings applied when plugin is enabled |

Components are **not** enumerated in `plugin.json` — they are discovered automatically from these paths.

## Plugin namespacing

Skills and commands shipped by a plugin use `plugin-name:skill-name` namespace:
- Install: `claude plugin install my-plugin@my-marketplace`
- Invoke: `/my-plugin:my-skill`

This prevents conflicts between plugins and standalone skills.

## Install scopes

Plugins can be installed at three scopes:

| Scope | Where install is recorded | Shareable |
|---|---|---|
| User | `~/.claude/settings.json` `enabledPlugins` | No (personal only) |
| Project | `<project>/.claude/settings.json` `enabledPlugins` | Yes (commit to git) |
| Local | `<project>/.claude/settings.local.json` `enabledPlugins` | No (gitignored) |

In `settings.json`, the `enabledPlugins` map records installed plugins:

```json
{
  "enabledPlugins": {
    "my-plugin@my-marketplace": true
  }
}
```

## Marketplace manifest: `marketplace.json`

A marketplace is a curated list of plugins. The manifest lives at `marketplace.json` in a hosted location.

Minimal structure:

```json
{
  "name": "my-marketplace",
  "owner": "my-org",
  "plugins": [
    {
      "name": "my-plugin",
      "source": {
        "type": "github",
        "repo": "my-org/my-plugin",
        "tag": "v1.0.0"
      }
    }
  ]
}
```

Plugin source types supported by marketplaces:

| Type | Description |
|---|---|
| `github` | GitHub repository with optional `tag` or `sha` |
| `git` | Any git repository URL |
| `url` | Direct URL to a `.zip` archive |
| `npm` | npm package name and version |
| `file` | Local file path (development only) |
| `directory` | Local directory path (development only) |
| `hostPattern` | Pattern for self-hosted plugin resolution |

## CLI commands

```bash
# Install a plugin from a marketplace
claude plugin install my-plugin@my-marketplace

# Install a plugin from a directory (testing)
claude --plugin-dir ./my-plugin

# Install a plugin from a URL (.zip archive)
claude --plugin-url https://example.com/my-plugin.zip

# List installed plugins
claude plugin list

# Enable/disable a plugin
claude plugin enable my-plugin@my-marketplace
claude plugin disable my-plugin@my-marketplace

# Uninstall a plugin
claude plugin uninstall my-plugin@my-marketplace

# Manage marketplaces
claude plugin marketplace add https://example.com/marketplace.json
claude plugin marketplace list
claude plugin marketplace remove my-marketplace

# Reload plugins in current session (after install)
/reload-plugins
```

## Load a plugin for one session only

```bash
# From a local directory
claude --plugin-dir ./my-plugin

# From a .zip archive
claude --plugin-dir ./my-plugin.zip

# From a URL
claude --plugin-url https://example.com/my-plugin-v1.zip
```

## Common mistakes (auto-corrected by `rules/plugins.md`)

- Putting skill/agent/hook directories inside `.claude-plugin/` — only `plugin.json` goes there; everything else goes at plugin root.
- Using `claude plugin install` with a directory path — use `--plugin-dir` flag for local development instead.
- Forgetting to run `/reload-plugins` after installing a plugin in a running session.
- Naming a plugin skill the same as a standalone skill without considering the `plugin-name:skill-name` namespace — they won't conflict, but users invoke them differently.

---

*Source pages: [code.claude.com/docs/en/plugins.md](https://code.claude.com/docs/en/plugins.md), [plugins-reference.md](https://code.claude.com/docs/en/plugins-reference.md), [discover-plugins.md](https://code.claude.com/docs/en/discover-plugins.md).*
