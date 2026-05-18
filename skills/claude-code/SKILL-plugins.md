---
name: claude-code-plugins
description: |
  Deep reference for Claude Code plugins and marketplaces. Covers the
  plugin manifest (`.claude-plugin/plugin.json`) schema, marketplace
  manifest (`marketplace.json`) schema, the marketplace source types
  (github / git / url / npm / file / directory / settings / hostPattern),
  install scopes (user / project / local), how plugins package
  commands / agents / skills / hooks / MCP servers, plugin discovery
  convention paths, and the install / enable / disable / uninstall
  lifecycle. Read this file when the user asks about authoring or
  installing a plugin, plugin manifest fields, or marketplace setup.
source: https://code.claude.com/docs/en/plugins.md
---

# Claude Code — Plugins and Marketplaces

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for plugin questions.*

## Plugin vs standalone configuration

| Approach | Skill names | Best for |
|---|---|---|
| **Standalone** (`.claude/` directory) | `/hello` | Personal workflows, project-specific, quick experiments |
| **Plugins** (`.claude-plugin/plugin.json`) | `/plugin-name:hello` | Sharing, distributing, cross-project reuse, versioned releases |

Skills from plugins are **namespaced** as `/<plugin>:<skill>` to prevent conflicts between plugins.

Source: `code.claude.com/docs/en/plugins.md`.

## Plugin manifest: `.claude-plugin/plugin.json`

A plugin manifest lives at `<plugin-root>/.claude-plugin/plugin.json`. All fields except `name` and `version` are optional metadata.

| Field | Required | Notes |
|---|---|---|
| `name` | yes | Lowercase kebab-case. Used as skill namespace (e.g. `my-plugin` → `/my-plugin:hello`). Should be unique within marketplace |
| `version` | no | SemVer string (e.g. `1.0.0`, `1.2.3-beta.1`). If omitted, git commit SHA is used — every commit is a new version |
| `description` | no | One-line summary in `claude plugin list` and marketplace listings |
| `author` | no | String or `{ name, email?, url? }` object |
| `homepage` | no | URL |
| `repository` | no | URL or `{ type, url }` object |
| `license` | no | SPDX identifier (e.g. `MIT`, `Apache-2.0`) |
| `keywords` | no | Array of strings for marketplace search |

Minimal valid manifest:

```json
{
  "name": "my-plugin",
  "version": "1.0.0"
}
```

Skills, commands, agents, hooks, and other components are **auto-discovered** from convention paths — not enumerated in `plugin.json`.

## Plugin discovery: convention paths

⚠️ **Common mistake**: Don't put `commands/`, `agents/`, `skills/`, or `hooks/` inside `.claude-plugin/`. Only `plugin.json` goes in `.claude-plugin/`. All other directories go at the **plugin root**.

| Directory | Purpose |
|---|---|
| `.claude-plugin/` | Plugin root only — contains `plugin.json` manifest |
| `skills/<name>/SKILL.md` | Skills (directory-style; prefer for new plugins) |
| `commands/<name>.md` | Commands/skills (flat file style; legacy) |
| `agents/<name>.md` | Custom agent definitions |
| `hooks/hooks.json` | Hook event handlers |
| `.mcp.json` | MCP server configurations |
| `.lsp.json` | LSP server configurations for code intelligence |
| `monitors/monitors.json` | Background monitor configurations |
| `bin/` | Executables added to Bash tool's `PATH` when plugin enabled |
| `settings.json` | Default settings applied when plugin enabled |

## What plugins can ship

- **Skills**: invocable as `/<plugin>:<skill>` or auto-invoked by Claude
- **Agents**: custom AI subagent definitions
- **Hooks**: event handlers (see [`SKILL-hooks.md`](SKILL-hooks.md))
- **MCP servers**: bundled server configs (start automatically when plugin enabled)
- **LSP servers**: code intelligence integrations
- **Background monitors**: persistent watchers
- **CLI executables**: added to Bash PATH
- **Settings**: default settings applied on enable
- **Rules**: auto-correction rules

## Install scopes

Plugin installations are recorded in the `enabledPlugins` section of settings files:

| Scope | Settings file | Who it affects |
|---|---|---|
| `user` | `~/.claude/settings.json` | You, across all projects |
| `project` | `.claude/settings.json` | All collaborators (committed) |
| `local` | `.claude/settings.local.json` | You, this project only (gitignored) |
| Managed | `managed-settings.json` | Organization-wide (admin-controlled, highest priority) |

**Important**: Project settings take precedence over user settings. To opt out of a project-enabled plugin on your machine, set it to `false` in `.claude/settings.local.json`. Plugins force-enabled by managed settings cannot be disabled.

## CLI commands

```bash
claude plugin install <name>@<marketplace>   # Install a plugin
claude plugin list                           # List installed plugins
claude plugin uninstall <name>@<marketplace> # Remove a plugin
claude plugin enable <name>@<marketplace>    # Enable a disabled plugin
claude plugin disable <name>@<marketplace>   # Disable without uninstalling
claude plugin marketplace add <name> <source> # Add a marketplace
claude plugin marketplace list               # List configured marketplaces
claude plugin marketplace remove <name>      # Remove a marketplace
```

**In-session**: `/plugin` opens an interactive manager to browse, install, enable/disable, and view plugin details.
**Reload without restart**: `/reload-plugins` (picks up changes to enabled plugins).

**Testing a local plugin** (session-only, no install):
```bash
claude --plugin-dir ./my-plugin
claude --plugin-url https://example.com/plugin.zip
```

## Marketplace manifest: `marketplace.json`

A marketplace is a collection of plugins with a `marketplace.json` file:

```json
{
  "name": "acme-tools",
  "owner": "acme-corp",
  "plugins": [
    {
      "name": "code-formatter",
      "source": {
        "source": "github",
        "repo": "acme-corp/code-formatter"
      }
    },
    {
      "name": "deployment-tools",
      "source": {
        "source": "git",
        "url": "https://git.example.com/acme/deploy-tools.git"
      }
    }
  ]
}
```

## Marketplace source types

Used in both `marketplace.json` plugin entries and `extraKnownMarketplaces`/`strictKnownMarketplaces` settings:

| Source type | Required fields | Notes |
|---|---|---|
| `github` | `repo` (e.g. `"acme/plugins"`) | Optional: `ref` (branch/tag/SHA), `path` (subdirectory) |
| `git` | `url` | Optional: `ref`, `path` |
| `url` | `url` (points to `marketplace.json`) | Optional: `headers`. Plugins must use external sources (not relative paths) |
| `npm` | `package` (e.g. `"@acme/plugins"`) | Supports scoped packages |
| `file` | `path` (absolute path to `marketplace.json`) | |
| `directory` | `path` (absolute path containing `.claude-plugin/`) | |
| `hostPattern` | `hostPattern` (regex matching host) | For GHE/GitLab; applies to `github`/`git`/`url` sources |
| `pathPattern` | `pathPattern` (regex matching path) | For `file`/`directory` sources |
| `settings` | `name` + `plugins` (inline list) | Inline marketplace in settings.json; plugins must use external sources |

## Configure marketplaces in settings

### `extraKnownMarketplaces` (any settings file)

Pre-register a marketplace for the team. Users are prompted to install it when they trust the folder:

```json
{
  "extraKnownMarketplaces": {
    "acme-tools": {
      "source": {
        "source": "github",
        "repo": "acme-corp/claude-plugins"
      },
      "autoUpdate": true
    }
  }
}
```

### `strictKnownMarketplaces` (managed settings only)

Allowlist for managed environments. `[]` = complete lockdown. See [`SKILL-settings.md`](SKILL-settings.md) §`strictKnownMarketplaces`.

## Load plugins from `.zip` archives (v2.1.115+)

Load a plugin from a `.zip` archive for a session (no install needed):

```bash
claude --plugin-dir my-plugin.zip
claude --plugin-url https://example.com/plugin.zip
```

## User configuration in plugins

Plugins can declare user-configurable values in `plugin.json` under a `config` key. Users set these via `/plugin`. Values are accessible in hook commands as `${user_config.key}`.

## Common mistakes

See [`rules/plugins.md`](rules/plugins.md) for auto-correction rules.

---

*Source pages: `code.claude.com/docs/en/plugins.md`, `code.claude.com/docs/en/plugins-reference.md`.*
