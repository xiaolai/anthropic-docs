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

```
my-plugin/
  .claude-plugin/
    plugin.json          ← manifest (only this goes inside .claude-plugin/)
  skills/                ← skills as <name>/SKILL.md directories
  commands/              ← skills as flat Markdown files (legacy; prefer skills/)
  agents/                ← custom agent definitions
  hooks/
    hooks.json           ← event handler config
  .mcp.json              ← MCP server configurations
  .lsp.json              ← LSP server configurations
  monitors/
    monitors.json        ← background monitor configurations
  bin/                   ← executables added to Bash tool PATH
  settings.json          ← default settings applied when plugin is enabled
```

> **Warning:** Don't put `commands/`, `agents/`, `skills/`, or `hooks/` **inside** `.claude-plugin/`. Only `plugin.json` goes in `.claude-plugin/`. All other dirs must be at the plugin root.

Source: `code.claude.com/docs/en/plugins.md`

## Loading a plugin (CLI flags)

| Flag | Description | Added |
|---|---|---|
| `--plugin-dir <path>` | Load a plugin from a local directory (existing behavior) | — |
| `--plugin-dir <path.zip>` | Load a plugin from a `.zip` archive | v2.1.128 |
| `--plugin-url <url>` | Fetch a plugin `.zip` archive from a URL and load it for the session | v2.1.128 |

```bash
# Load from local dir
claude --plugin-dir ./my-plugin

# Load from zip
claude --plugin-dir ./my-plugin.zip

# Fetch from URL (useful for internal artifact stores)
claude --plugin-url https://example.com/my-plugin.zip
```

Source: `code.claude.com/docs/en/whats-new/2026-w19.md`

## Marketplace manifest: `marketplace.json`

A marketplace lists plugins available for installation. The manifest lives at the root of the marketplace repository.

```json
{
  "name": "my-marketplace",
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

Seven source types for `plugins[].source`: `github`, `git`, `url`, `npm`, `file`, `directory`, `hostPattern`.

Source: `code.claude.com/docs/en/plugin-marketplaces.md`

## Install scopes

- **user** — installed to `~/.claude/plugins/`; available in all your projects
- **project** — recorded in `.claude/settings.json`; shared with the team
- **local** — recorded in `.claude/settings.local.json`; personal override

## Plugin settings

Plugins can ship a `settings.json` at the root that applies default settings when the plugin is enabled. These settings merge at a lower priority than user/project settings. Use this for default hooks, MCP server configs, or env vars the plugin needs.

## Common mistakes

1. **Putting components inside `.claude-plugin/`** — Only `plugin.json` belongs there; `commands/`, `agents/`, `skills/`, `hooks/` belong at the plugin root.
2. **Missing `name` or `version`** — Both are required in `plugin.json`.
3. **Using `commands/` for new plugins** — Prefer `skills/` (supports `SKILL.md` with frontmatter); `commands/` is the legacy flat-file path.
4. **Plugin not appearing** — Run `/doctor` to check if the plugin loaded. Check `claude plugin list` to see enabled plugins.

Source: `code.claude.com/docs/en/plugins.md`, `code.claude.com/docs/en/plugins-reference.md`

---

*Source pages: `code.claude.com/docs/en/plugins.md`.*
