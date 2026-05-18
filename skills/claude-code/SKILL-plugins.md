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

A marketplace aggregates plugins for discovery and installation. The `marketplace.json` lives at the marketplace repo root:

```json
{
  "name": "my-marketplace",
  "owner": "acme-corp",
  "plugins": [
    {
      "source": "github",
      "repo": "acme-corp/my-plugin"
    }
  ]
}
```

Fields: `name` (required), `owner` (required), `plugins` (array of plugin source objects).

Source: `code.claude.com/docs/en/plugin-marketplaces.md`.

## Marketplace source types

| Type | Example | Notes |
|---|---|---|
| `github` | `{"source": "github", "repo": "owner/repo"}` | Installs from a GitHub repo |
| `git` | `{"source": "git", "url": "https://..."}` | Any git URL |
| `url` | `{"source": "url", "url": "https://...plugin.zip"}` | Direct `.zip` download |
| `npm` | `{"source": "npm", "package": "@scope/pkg"}` | npm package |
| `file` | `{"source": "file", "path": "./local-plugin"}` | Local directory |
| `directory` | `{"source": "directory", "path": "./plugins/"}` | Scan a directory for plugins |
| `hostPattern` | `{"source": "hostPattern", "pattern": "*.example.com"}` | Match by URL hostname |

Source: `code.claude.com/docs/en/plugin-marketplaces.md`.

## Install scopes

| Scope | Where recorded | Shared with team? |
|---|---|---|
| `user` | `~/.claude/settings.json` → `enabledPlugins` | No |
| `project` | `.claude/settings.json` → `enabledPlugins` | Yes (git-committed) |
| `local` | `.claude/settings.local.json` → `enabledPlugins` | No (gitignored) |

`enabledPlugins` maps `"<name>@<marketplace>"` → boolean:
```json
{
  "enabledPlugins": {
    "code-review@claude-plugins-official": true,
    "my-internal-tool@acme-marketplace": true
  }
}
```

Source: `code.claude.com/docs/en/plugins.md`.

## What plugins can ship

| Directory | Purpose |
|---|---|
| `skills/` | Skills as `<name>/SKILL.md` directories (namespaced as `/<plugin>:<skill>`) |
| `commands/` | Skills as flat `.md` files (legacy; use `skills/` for new plugins) |
| `agents/` | Custom agent definitions |
| `hooks/hooks.json` | Event handlers (merged with user/project hooks when plugin is enabled) |
| `.mcp.json` | MCP server configs (auto-started when plugin is enabled) |
| `.lsp.json` | LSP server configs for code intelligence |
| `monitors/monitors.json` | Background monitor commands |
| `bin/` | Executables added to Bash tool's PATH |
| `settings.json` | Default settings (only `agent` and `subagentStatusLine` keys are applied) |

Skills, commands, agents, hooks, and rules are **auto-discovered** by convention path — they do NOT need to be listed in `plugin.json`.

**Common mistake**: do not put `commands/`, `agents/`, `skills/`, or `hooks/` inside the `.claude-plugin/` directory. Only `plugin.json` lives inside `.claude-plugin/`. All other directories go at the plugin root.

Source: `code.claude.com/docs/en/plugins.md`.

## Plugin discovery: convention paths

Claude Code discovers plugin components from these paths at the plugin root:

- `skills/<name>/SKILL.md` → skill `/plugin-name:name`
- `commands/<name>.md` → command `/plugin-name:name` (legacy)
- `agents/<name>.md` → subagent named `name`
- `hooks/hooks.json` → merged hook handlers
- `.mcp.json` → MCP servers
- `.lsp.json` → LSP servers
- `monitors/monitors.json` → background monitors
- `bin/` → added to Bash PATH

Plugin skills are namespaced: a skill named `hello` in plugin `my-plugin` is invoked as `/my-plugin:hello`.

Source: `code.claude.com/docs/en/plugins.md`.

## CLI commands

| Command | Description |
|---|---|
| `claude plugin install <name>@<marketplace>` | Install a plugin from a marketplace |
| `claude plugin list` | List installed plugins |
| `claude plugin update [name]` | Update plugins |
| `claude plugin uninstall <name>@<marketplace>` | Uninstall a plugin |
| `claude plugin marketplace add <url>` | Add a marketplace source |
| `claude plugin marketplace list` | List configured marketplaces |
| `claude plugin marketplace remove <name>` | Remove a marketplace |

Within a session:
- `/plugin install <name>@<marketplace>` — install interactively
- `/plugin` — open the plugin manager
- `/reload-plugins` — reload all active plugins without restarting

For development: `--plugin-dir ./my-plugin` or `--plugin-dir ./my-plugin.zip` loads a local plugin for one session. `--plugin-url https://example.com/plugin.zip` fetches from a URL.

Source: `code.claude.com/docs/en/plugins.md`, `code.claude.com/docs/en/plugins-reference.md`.

## Worked examples

> *Populated by the research agent.* See also:
> [`templates/.claude-plugin/plugin.json`](templates/.claude-plugin/plugin.json).

## Common mistakes (auto-corrected by `rules/plugins.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/plugins.md`.*
