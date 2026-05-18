---
name: claude-code-plugins
description: |
  Deep reference for Claude Code plugins and marketplaces. Covers the
  plugin manifest (plugin.json) schema, plugin directory convention
  paths (skills/, agents/, hooks/, .mcp.json), install scopes (user /
  project / local), what plugins can ship, the plugin lifecycle, and
  CLI commands. Read this file when the user asks about authoring or
  installing a plugin, plugin manifest fields, or marketplace setup.
source: https://code.claude.com/docs/en/plugins.md
---

# Claude Code — Plugins and Marketplaces

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for plugin questions.*

## Plugin manifest: `plugin.json`

A plugin manifest lives at `.claude-plugin/plugin.json` within the plugin root directory. `name` is required; all other fields are optional metadata.

| Field | Required | Type | Notes |
|---|---|---|---|
| `name` | yes | string | Unique identifier. Used as namespace prefix for skills/commands: `/name:skill` |
| `description` | no | string | One-line summary shown in `claude plugin list` and marketplace listings |
| `version` | no | string | SemVer (e.g., `0.1.0`). If omitted, uses git commit SHA |
| `author` | no | string \| object | String or `{ name, email?, url? }` |
| `homepage` | no | string | URL |
| `repository` | no | string \| object | URL or `{ type, url }` |
| `license` | no | string | SPDX identifier (e.g., `MIT`, `Apache-2.0`) |
| `keywords` | no | array | Strings for marketplace search |

Minimal valid manifest:

```json
{
  "name": "my-plugin",
  "version": "0.1.0"
}
```

Skills, commands, agents, hooks, and other components are **auto-discovered** from convention paths — they are NOT enumerated in `plugin.json`.

## Plugin directory structure (convention paths)

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          ← manifest (required)
├── skills/
│   └── my-skill/
│       └── SKILL.md         ← skill definition
├── commands/                ← legacy flat skill files
├── agents/                  ← custom agent definitions
├── hooks/
│   └── hooks.json           ← hook configurations (same format as settings.json hooks)
├── .mcp.json                ← MCP server configurations
├── .lsp.json                ← LSP server configurations
├── monitors/
│   └── monitors.json        ← background monitors
├── bin/                     ← executables added to Bash PATH
└── settings.json            ← default settings (agent, subagentStatusLine keys only)
```

### Environment variables available in plugin hooks/scripts

| Variable | Value |
|---|---|
| `CLAUDE_PLUGIN_ROOT` | Absolute path to plugin install directory |
| `CLAUDE_PLUGIN_DATA` | Plugin-private data directory |
| `CLAUDE_PROJECT_DIR` | Current project directory |

## What plugins can ship

| Component | Convention path | Notes |
|---|---|---|
| Skills | `skills/<name>/SKILL.md` | Namespaced as `/plugin-name:skill-name`. See [`SKILL-slash-commands.md`](SKILL-slash-commands.md) |
| Legacy commands | `commands/<name>.md` | Flat files; prefer `skills/` for new work |
| Agents | `agents/` | Custom subagent definitions |
| Hooks | `hooks/hooks.json` | Same format as `settings.json` hooks. Reloaded with `/reload-plugins` |
| MCP servers | `.mcp.json` | Auto-start when plugin enabled. Supports `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`, `${CLAUDE_PROJECT_DIR}` in server config |
| LSP servers | `.lsp.json` | Code intelligence |
| Background monitors | `monitors/monitors.json` | File/log watchers |
| Executables | `bin/` | Added to Bash PATH for the session |
| Default settings | `settings.json` | Only `agent` and `subagentStatusLine` keys honored |

## Install scopes

Plugins are installed per-scope. Scope is determined by where `enabledPlugins` is written:

| Scope | Settings file | Shared? |
|---|---|---|
| User | `~/.claude/settings.json` | No — your personal plugins |
| Project | `.claude/settings.json` | Yes — shared with team via git |
| Local | `.claude/settings.local.json` | No — gitignored personal override |

Force-enable or force-disable a plugin for all users: managed settings `enabledPlugins`. Cross-reference: [`SKILL-settings.md`](SKILL-settings.md).

## Plugin lifecycle

```bash
# Install from marketplace
claude plugin install <plugin-name>@<marketplace>

# Install locally during development
claude --plugin-dir ./my-plugin
claude --plugin-dir ./my-plugin.zip

# Install from URL
claude --plugin-url https://example.com/my-plugin.zip

# List installed plugins
claude plugin list

# Enable / disable
/plugin

# Reload hooks/skills after edits (no restart needed)
/reload-plugins

# Uninstall
claude plugin uninstall <plugin-name>
```

## Marketplace

A marketplace is a registry of plugins hosted on GitHub, git, npm, or other sources.

### Add a marketplace

```bash
claude plugin marketplace add <marketplace-url>
```

### Marketplace manifest (`marketplace.json`)

Hosted at the root of a marketplace repository:

```json
{
  "name": "My Org Plugins",
  "owner": "my-org",
  "plugins": [
    {
      "name": "my-plugin",
      "source": "github",
      "repo": "my-org/my-plugin"
    }
  ]
}
```

### Plugin source types in marketplace

| Type | Example |
|---|---|
| `github` | `{"source": "github", "repo": "owner/repo"}` |
| `git` | `{"source": "git", "url": "https://git.example.com/plugin.git"}` |
| `url` | `{"source": "url", "url": "https://example.com/plugin.zip"}` |
| `npm` | `{"source": "npm", "package": "@scope/plugin"}` |
| `file` | `{"source": "file", "path": "/absolute/path/to/plugin"}` |
| `directory` | `{"source": "directory", "path": "./relative/plugin"}` |
| `hostPattern` | Pattern-based host matching |

### Managed marketplace restrictions

Admins can restrict which marketplaces users can add via managed settings:

| Key | Notes |
|---|---|
| `strictKnownMarketplaces` | Allowlist of marketplace sources. `undefined`=no restrictions, `[]`=lockdown |
| `blockedMarketplaces` | Denylist of marketplace sources. Checked before downloading |
| `pluginTrustMessage` | Custom message appended to trust warning |

Both keys use entries like `{ "source": "github", "repo": "owner/plugins" }`.

## Common mistakes (auto-corrected by `rules/plugins.md`)

Cross-reference: [`rules/plugins.md`](rules/plugins.md)

---

*Source pages: [`code.claude.com/docs/en/plugins.md`](https://code.claude.com/docs/en/plugins.md), [`plugin-marketplaces.md`](https://code.claude.com/docs/en/plugin-marketplaces.md)*
