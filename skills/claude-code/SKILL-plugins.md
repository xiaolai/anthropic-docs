---
name: claude-code-plugins
description: |
  Deep reference for Claude Code plugins and marketplaces. Covers the
  plugin manifest (.claude-plugin/plugin.json) schema, marketplace
  manifest (marketplace.json) schema, marketplace source types
  (github / git / url / npm / file / directory / hostPattern / settings),
  install scopes (user / project / local), how plugins package
  commands / agents / skills / hooks / MCP servers, and the install /
  enable / disable / uninstall lifecycle. Read this file when the user
  asks about authoring or installing a plugin, plugin manifest fields,
  or marketplace setup.
source: https://code.claude.com/docs/en/plugins.md
---

# Claude Code — Plugins and Marketplaces

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for plugin questions.*

## Plugin directory structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json         # manifest (ONLY file inside .claude-plugin/)
├── skills/                 # <name>/SKILL.md directories
├── commands/               # flat .md files (legacy; use skills/ for new plugins)
├── agents/                 # custom agent definitions
├── hooks/
│   └── hooks.json          # event handlers
├── .mcp.json               # MCP server configurations
├── .lsp.json               # LSP server configurations
├── monitors/
│   └── monitors.json       # background monitor configurations
├── bin/                    # executables added to Bash PATH
└── settings.json           # default settings (limited keys)
```

## Plugin manifest: `.claude-plugin/plugin.json`

Source: [`plugins.md`](https://code.claude.com/docs/en/plugins.md) — audited 2026-05-18.

| Field | Required | Description |
|---|---|---|
| `name` | yes | Unique identifier and skill namespace (prefix for `/plugin-name:skill`). Lowercase kebab-case. |
| `description` | yes | Shown in plugin manager and marketplace listings |
| `version` | no | SemVer string. If set, users get updates only when bumped; if omitted, git commit SHA is used |
| `author` | no | Object with optional `name` field |
| `homepage` | no | URL |
| `repository` | no | URL |
| `license` | no | SPDX identifier (e.g. `MIT`, `Apache-2.0`) |
| `mcpServers` | no | Inline MCP server config (same format as `.mcp.json`) |
| `settings` | no | Default settings object |

Minimal valid manifest:

```json
{
  "name": "my-plugin",
  "version": "0.1.0",
  "description": "What this plugin does"
}
```

**Skills, commands, agents, hooks, and rules are auto-discovered** from convention paths — do NOT enumerate them in `plugin.json`. There is no `skills`, `commands`, `agents`, or `hooks` array in the manifest.

### `plugin.json` — `settings` field (limited keys)

```json
{
  "name": "security-reviewer",
  "description": "Runs as security-reviewer agent by default",
  "settings": {
    "agent": "security-reviewer"
  }
}
```

Only `agent` and `subagentStatusLine` are supported in the plugin `settings.json` / `settings` field.

## `hooks/hooks.json` format

Top-level optional `description` field, plus a `hooks` object identical to the `hooks` key in `settings.json`:

```json
{
  "description": "Format on save",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "npx prettier --write \"$(jq -r .tool_input.file_path)\"" }]
      }
    ]
  }
}
```

## `monitors/monitors.json` format

Array of monitor entries (each stdout line delivered to Claude as notification):

| Field | Required | Description |
|---|---|---|
| `name` | yes | Monitor name |
| `command` | yes | Command to run |
| `description` | yes | Description of what is being monitored |
| `when` | no | Trigger condition |

## `.lsp.json` format

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": { ".go": "go" }
  }
}
```

## What plugins can ship

| Resource | Discovery path | Notes |
|---|---|---|
| Skills | `skills/<name>/SKILL.md` | Namespaced as `/plugin-name:skill-name` |
| Commands | `commands/<name>.md` | Legacy; prefer skills for new plugins |
| Agents | `agents/<name>.md` | Custom subagent definitions |
| Hooks | `hooks/hooks.json` | Same format as `settings.json` hooks |
| MCP servers | `.mcp.json` or `mcpServers` in `plugin.json` | Inline or file-based |
| Executables | `bin/` | Added to Bash PATH when plugin enabled |
| LSP servers | `.lsp.json` | Language server configurations |
| Monitors | `monitors/monitors.json` | Background watchers |
| Rules | `rules/*.md` | Auto-correction rules |

## Install scopes

| Scope | Recorded in | Loads in |
|---|---|---|
| user | `~/.claude.json` | All projects |
| project | `.claude/settings.json` or `enabledPlugins` | Current project (shared) |
| local | `.claude/settings.local.json` | Current project (gitignored) |

## `enabledPlugins` in `settings.json`

```json
{
  "enabledPlugins": {
    "my-plugin@my-marketplace": true,
    "other-plugin@other-marketplace": false
  }
}
```

Key format: `"<plugin-name>@<marketplace-name>"`. Bare plugin names are silently ignored.

Managed settings `enabledPlugins` force-enables cannot be disabled by user/project settings.

## Marketplace manifest: `marketplace.json`

Marketplace source types for `extraKnownMarketplaces` and `strictKnownMarketplaces`:

| Type | Required field(s) | Description |
|---|---|---|
| `github` | `repo` | GitHub repository (`owner/repo` format) |
| `git` | `url` | Any Git URL |
| `url` | `url`, optional `headers` | Fetch from URL |
| `npm` | `package` | npm package name |
| `file` | `path` | Local file path |
| `directory` | `path` | Local directory path |
| `hostPattern` | `hostPattern` | URL host pattern matching |
| `settings` | `name`, `plugins` | Inline plugin list in settings |

## CLI commands

```bash
claude plugin install <name>              # install plugin
claude plugin install <name>@<marketplace> # install from specific marketplace
claude plugin list                        # list installed plugins
claude plugin enable <name>@<marketplace>
claude plugin disable <name>@<marketplace>
claude plugin uninstall <name>@<marketplace>
claude plugin marketplace add <url>       # add marketplace
claude plugin marketplace list            # list marketplaces
claude plugin marketplace remove <name>   # remove marketplace
```

### Testing plugins locally

```bash
claude --plugin-dir ./my-plugin           # load without installing (also accepts .zip)
claude --plugin-url https://example.com/plugin.zip  # fetch from URL for session
/reload-plugins                           # reload without restarting
```

## Common mistakes (auto-corrected by `rules/plugins.md`)

- `name` is required in `plugin.json`; `description` is also required.
- Do **not** add `skills`, `commands`, `agents`, or `hooks` arrays to `plugin.json` — those are auto-discovered from convention paths.
- `version` must be valid SemVer (e.g. `1.0.0`) — `v1.0.0`, `1.0`, or `latest` are not valid.
- `enabledPlugins` keys must be `"<plugin>@<marketplace>"` — bare plugin names silently fail.

---

*Source pages: [`plugins.md`](https://code.claude.com/docs/en/plugins.md), [`plugins-reference.md`](https://code.claude.com/docs/en/plugins-reference.md), [`plugin-marketplaces.md`](https://code.claude.com/docs/en/plugin-marketplaces.md), [`discover-plugins.md`](https://code.claude.com/docs/en/discover-plugins.md) — audited 2026-05-18.*
