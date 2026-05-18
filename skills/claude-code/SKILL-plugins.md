---
name: claude-code-plugins
description: |
  Deep reference for Claude Code plugins and marketplaces. Covers the
  plugin manifest (`.claude-plugin/plugin.json`) schema, marketplace
  manifest (`marketplace.json`) schema, the marketplace source types
  (github / git / url / npm / file / directory / hostPattern),
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

Source: [code.claude.com/docs/en/plugins.md](https://code.claude.com/docs/en/plugins.md), [plugins-reference.md](https://code.claude.com/docs/en/plugins-reference.md)

## When to use plugins vs standalone `.claude/` config

| Approach | Skill names | Best for |
|---|---|---|
| Standalone (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| Plugin (`.claude-plugin/plugin.json`) | `/my-plugin:hello` | Sharing, distribution, versioned releases, multi-project reuse |

Use standalone for quick iteration; convert to a plugin when ready to share.

## Plugin manifest: `.claude-plugin/plugin.json`

The manifest lives at `<plugin-root>/.claude-plugin/plugin.json`.

**IMPORTANT:** Only `plugin.json` goes inside `.claude-plugin/`. All other directories (`skills/`, `agents/`, `hooks/`, etc.) must be at the **plugin root level**, not inside `.claude-plugin/`.

| Field | Required | Notes |
|---|---|---|
| `name` | yes | Unique identifier and skill namespace prefix. Skills are namespaced as `/name:skill-name`. Lowercase kebab-case |
| `version` | no | SemVer (e.g. `1.0.0`, `1.2.3-beta.1`). If omitted and distributed via git, commit SHA is used (every commit = new version) |
| `description` | no | One-line summary shown in plugin manager and marketplace listings |
| `author` | no | String or `{name, email?, url?}` object |
| `homepage` | no | URL |
| `repository` | no | URL or `{type, url}` object |
| `license` | no | SPDX identifier (e.g. `MIT`, `Apache-2.0`) |
| `keywords` | no | Array of strings for marketplace search |

Minimal valid manifest:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "A useful plugin"
}
```

## Plugin directory structure

```
my-plugin/                        ← plugin root
├── .claude-plugin/
│   └── plugin.json               ← manifest (only file here)
├── skills/                       ← skills as <name>/SKILL.md directories
│   └── hello/
│       └── SKILL.md
├── commands/                     ← legacy: flat Markdown skills (use skills/ for new plugins)
├── agents/                       ← custom agent definitions
├── hooks/
│   └── hooks.json                ← event handlers
├── .mcp.json                     ← MCP server configurations
├── .lsp.json                     ← LSP server configurations
├── monitors/
│   └── monitors.json             ← background monitor configs
├── bin/                          ← executables added to Bash tool's PATH
└── settings.json                 ← default settings when plugin is enabled
```

Skills are **auto-discovered** from convention paths — they are NOT enumerated in `plugin.json`.

## Plugin discovery: convention paths

| Directory | Content | How referenced |
|---|---|---|
| `skills/<name>/SKILL.md` | Skill definitions | `/plugin-name:name` |
| `commands/<name>.md` | Legacy flat skills | `/plugin-name:name` |
| `agents/<name>.md` | Custom subagent definitions | Referenced by name |
| `hooks/hooks.json` | Hook event handlers | Loaded when plugin enabled |
| `.mcp.json` | MCP server configs | Servers start when plugin enabled |
| `bin/` | Executables | Added to PATH in Bash tool |
| `settings.json` | Plugin default settings | Applied when plugin enabled |

## Marketplace manifest: `marketplace.json`

A marketplace is a collection of plugins distributed from a single source.

```json
{
  "name": "my-marketplace",
  "owner": "my-org",
  "plugins": [
    {
      "name": "code-review",
      "source": "github",
      "repo": "my-org/code-review-plugin"
    }
  ]
}
```

## Marketplace source types

| Type | Description | Example |
|---|---|---|
| `github` | Plugin from a GitHub repository | `{"source": "github", "repo": "owner/repo"}` |
| `git` | Plugin from any git repository URL | `{"source": "git", "url": "https://..."}` |
| `url` | Plugin from a `.zip` archive URL | `{"source": "url", "url": "https://.../plugin.zip"}` |
| `npm` | Plugin from an npm package | `{"source": "npm", "package": "@scope/pkg"}` |
| `file` | Plugin from a local file path | `{"source": "file", "path": "/path/to/plugin"}` |
| `directory` | Plugin from a local directory | `{"source": "directory", "path": "/path/to/dir"}` |
| `hostPattern` | Dynamically match plugin from URL pattern | `{"source": "hostPattern", "pattern": "..."}` |

## Install scopes

| Scope | Where recorded | Effect |
|---|---|---|
| `user` | `~/.claude/settings.json` | Available in all your projects |
| `project` | `.claude/settings.json` | Available to all project collaborators (committed) |
| `local` | `.claude/settings.local.json` | Available to you in this project only (gitignored) |

## CLI commands

```bash
# Install a plugin
claude plugin install code-review@claude-plugins-official

# List installed plugins
claude plugin list

# Enable/disable a plugin
claude plugin enable my-plugin
claude plugin disable my-plugin

# Uninstall a plugin
claude plugin uninstall my-plugin

# Add a marketplace
claude plugin marketplace add <url>

# List marketplaces
claude plugin marketplace list

# Test a plugin locally (session-only, not installed)
claude --plugin-dir ./my-plugin
claude --plugin-url https://example.com/plugin.zip

# Reload plugins in current session
/reload-plugins
```

## `enabledPlugins` in settings

Plugins are enabled/disabled via the `enabledPlugins` map in `settings.json`:

```json
{
  "enabledPlugins": {
    "code-review@claude-plugins-official": true,
    "my-plugin@my-marketplace": false
  }
}
```

Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) `enabledPlugins` section.

## Plugin-provided MCP servers

Plugin `.mcp.json` can use these substitution variables:
- `${CLAUDE_PLUGIN_ROOT}` — resolved to the plugin's root directory
- `${CLAUDE_PROJECT_DIR}` — resolved to the project root

```json
{
  "mcpServers": {
    "database-tools": {
      "command": "${CLAUDE_PLUGIN_ROOT}/servers/db-server",
      "args": ["--config", "${CLAUDE_PLUGIN_ROOT}/config.json"]
    }
  }
}
```

## Managed marketplace restrictions

Enterprise admins can control plugins via managed settings:

| Setting | Effect |
|---|---|
| `strictKnownMarketplaces` | Allowlist of allowed marketplace sources |
| `blockedMarketplaces` | Blocklist of marketplace sources |
| `pluginTrustMessage` | Custom message added to plugin trust warning |

Enforced on marketplace add and on plugin install, update, refresh, and auto-update.

## Plugin dependency version constraints

Plugins can declare version constraints on dependencies using the `plugin-dependencies.md` mechanism. See [plugin-dependencies.md](https://code.claude.com/docs/en/plugin-dependencies.md).

## Common mistakes (auto-corrected by `rules/plugins.md`)

- Putting `skills/`, `agents/`, `hooks/` inside `.claude-plugin/` — these must be at the plugin root.
- Using non-kebab-case `name` in `plugin.json` — names must be lowercase kebab-case.
- Omitting `version` when distributing via URL/npm — version is required for those sources.
- Trying to enumerate skills in `plugin.json` — skills are auto-discovered by convention path, not listed in the manifest.
- Using `plugin:name` format for plugin-namespaced commands — the correct format is `/plugin-name:command-name`.

---

*Source: [code.claude.com/docs/en/plugins.md](https://code.claude.com/docs/en/plugins.md), [plugins-reference.md](https://code.claude.com/docs/en/plugins-reference.md), [discover-plugins.md](https://code.claude.com/docs/en/discover-plugins.md)*
