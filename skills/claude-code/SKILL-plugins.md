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

## What plugins can ship

Source: `code.claude.com/docs/en/plugins.md`.

Plugins bundle any combination of:
- **Skills** (`skills/<name>/SKILL.md`) — slash commands/skills invoked as `/plugin-name:skill-name`
- **Agents** (`agents/<name>.md`) — subagent definitions
- **Hooks** (`hooks/hooks.json`) — hook handlers that activate when the plugin is enabled
- **MCP servers** (`.mcp.json` at plugin root, or inline in `plugin.json`) — auto-start when plugin is enabled
- **Rules** (`rules/*.md`) — auto-correction rules
- **CLAUDE.md** — injected into context when plugin is enabled

All plugin skills are namespaced as `plugin-name:skill-name` to prevent conflicts.

## Plugin discovery: convention paths

Claude Code auto-discovers all of the above from their conventional paths inside the plugin directory. They are NOT enumerated in `plugin.json` — just follow the path conventions.

## Marketplace manifest: `marketplace.json`

A marketplace is a JSON file (served from GitHub, a URL, npm, etc.) listing available plugins:

```json
{
  "name": "acme-tools",
  "owner": "acme-corp",
  "plugins": [
    {
      "name": "code-formatter",
      "description": "Auto-formats code",
      "source": { "source": "github", "repo": "acme-corp/code-formatter" }
    }
  ]
}
```

## Marketplace source types

Seven source types (used in `extraKnownMarketplaces` and `strictKnownMarketplaces`; see [`SKILL-settings.md`](SKILL-settings.md)):

| Type | Key field | Notes |
|---|---|---|
| `github` | `repo` (e.g. `"acme-corp/plugins"`) | Also accepts `ref`, `path` |
| `git` | `url` (HTTPS or SSH git URL) | Also accepts `ref`, `path` |
| `url` | `url` (direct URL to `marketplace.json`) | Also accepts `headers`; plugins must use external sources |
| `npm` | `package` (e.g. `"@acme-corp/plugins"`) | Scoped packages supported |
| `file` | `path` (absolute path to `marketplace.json`) | |
| `directory` | `path` (absolute path to plugin dir with `.claude-plugin/`) | |
| `hostPattern` | `hostPattern` (regex against host) | Allows all marketplaces from a host |
| `pathPattern` | `pathPattern` (regex against path) | Allows file/directory sources matching path |
| `settings` | `name`, `plugins` (inline list) | Inline marketplace in settings; no hosted repo needed |

## Install scopes

Plugins are recorded in `settings.json` under `enabledPlugins: { "plugin-name@marketplace-name": true }`. The scope follows the settings file used:
- `~/.claude/settings.json` — user scope (all projects)
- `.claude/settings.json` — project scope (shared with team)
- `.claude/settings.local.json` — local scope (gitignored)
- `managed-settings.json` — managed scope (org-wide, cannot override)

Project settings take precedence over user settings. To opt out of a project-enabled plugin, set it to `false` in `.claude/settings.local.json`.

## CLI commands

```bash
claude plugin list                            # List installed plugins
claude plugin install <name>@<marketplace>    # Install a plugin
/plugin                                       # Interactive plugin manager (in-session)
/plugin install mcp-server-dev@claude-plugins-official  # Install by slash command
/reload-plugins                               # Reload plugins in current session
claude --plugin-dir ./my-plugin               # Load plugin from local dir (session only)
claude --plugin-url https://example.com/p.zip # Load plugin from URL (session only)
```

## Worked examples

Minimal plugin structure:
```text
my-plugin/
├── .claude-plugin/
│   └── plugin.json        # Required manifest
├── skills/
│   └── my-skill/
│       └── SKILL.md       # Creates /my-plugin:my-skill
├── agents/
│   └── reviewer.md        # Subagent definition
├── hooks/
│   └── hooks.json         # Hook definitions
└── .mcp.json              # MCP server config (optional)
```

## Common mistakes (auto-corrected by `rules/plugins.md`)

> *Populated by the research agent from issue tracker.*

---

*Source pages: `code.claude.com/docs/en/plugins.md`.*
