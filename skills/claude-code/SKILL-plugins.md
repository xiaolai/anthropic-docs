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

A marketplace manifest lives at `marketplace.json` and declares the marketplace and its plugins.

```json
{
  "name": "my-marketplace",
  "owner": "my-org",
  "plugins": [
    {
      "name": "my-plugin",
      "source": { "type": "github", "repo": "my-org/my-plugin" }
    }
  ]
}
```

Source: `code.claude.com/docs/en/plugin-marketplaces.md`

## Marketplace source types

Seven source types for plugin entries in `marketplace.json`:

| Type | Example | Notes |
|---|---|---|
| `github` | `{"type":"github","repo":"owner/repo"}` | Fetches latest release zip from GitHub |
| `git` | `{"type":"git","url":"https://...","ref":"main"}` | Clone via git |
| `url` | `{"type":"url","url":"https://.../plugin.zip"}` | Download a zip archive |
| `npm` | `{"type":"npm","package":"@scope/plugin","version":"1.0.0"}` | Install from npm |
| `file` | `{"type":"file","path":"./plugins/my-plugin"}` | Local directory |
| `directory` | `{"type":"directory","path":"./plugins/"}` | Auto-discover all plugins in directory |
| `hostPattern` | `{"type":"hostPattern","pattern":"*.company.com"}` | Restrict access by hostname |

Source: `code.claude.com/docs/en/plugins.md`, `code.claude.com/docs/en/plugin-marketplaces.md`

## Install scopes

| Scope | Where installed | Tracked in git? |
|---|---|---|
| `user` | `~/.claude/plugins/` | No |
| `project` | `.claude/plugins/` | Yes (or gitignored) |
| `local` | `.claude/plugins/` (local only) | No |

Scope is set with `--scope user|project|local` on `claude plugin install`. Default is `user`.

## What plugins can ship

Plugins can bundle:
- **Skills** (`skills/<name>/SKILL.md`) — custom slash commands
- **Agents** (`agents/<name>.md`) — named subagents
- **Commands** (`commands/<name>.md`) — legacy slash commands
- **Hooks** (`hooks/hooks.json`) — hook handlers at plugin scope
- **Rules** (`rules/*.md`) — auto-correction rules
- **MCP servers** (`.mcp.json`) — MCP server configs loaded when plugin is active
- **Executables** (`bin/`) — available on PATH when plugin is active

## Plugin discovery: convention paths

Claude Code auto-discovers plugin components from these paths inside the plugin directory. No enumeration in `plugin.json` required:

```
<plugin-root>/
  .claude-plugin/
    plugin.json         ← manifest (required)
  skills/               ← skill directories
    <name>/
      SKILL.md
  agents/               ← agent definition files
    <name>.md
  commands/             ← legacy command files
    <name>.md
  hooks/
    hooks.json          ← hook handlers
  rules/                ← rules files
    <name>.md
  .mcp.json             ← MCP server configs
  bin/                  ← executables added to PATH
```

## CLI commands

```bash
# Install from a marketplace
claude plugin install <plugin>@<marketplace>

# Install from a local directory or zip
claude plugin install --from-dir ./my-plugin
claude plugin install --from-url https://example.com/plugin.zip

# List installed plugins
claude plugin list

# Enable/disable a plugin
claude plugin enable <plugin>@<marketplace>
claude plugin disable <plugin>@<marketplace>

# Add a marketplace
claude plugin marketplace add <marketplace-url>
claude plugin marketplace list

# Update plugins
claude plugin update

# Within a session: reload after changes
/reload-plugins
```

For session-only plugin loading (not installed): use `--plugin-dir ./my-plugin` or `--plugin-url https://example.com/plugin.zip` CLI flags.

## Worked examples

> *Populated by the research agent.* See also:
> [`templates/.claude-plugin/plugin.json`](templates/.claude-plugin/plugin.json).

## Common mistakes (auto-corrected by `rules/plugins.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/plugins.md`.*
