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

> **Root-level SKILL.md shortcut:** A plugin with a `SKILL.md` at its root and no `skills/` subdirectory is automatically surfaced as a single skill. This lets simple single-skill plugins skip creating a `skills/<name>/` directory.

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

> **Plugin preview before install:** The `/plugin` Discover and Browse screens show a plugin's commands, agents, skills, hooks, and MCP/LSP servers before you install it (as of v2.1.153).

## Marketplace manifest: `marketplace.json`

A marketplace is a collection of plugins. The `marketplace.json` file at the marketplace root:

<!-- skip-validate -->
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
| `github` | `repo` | GitHub repository. Optional: `ref` (branch/tag/SHA), `path` (subdirectory), `skipLfs` (boolean — skip Git LFS downloads during clone/update) |
| `git` | `url` | Any git URL. Optional: `ref`, `path`, `skipLfs` (boolean — skip Git LFS downloads during clone/update) |
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

<!-- skip-validate -->
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

# Show a plugin's component inventory and projected per-session token cost
claude plugin details my-plugin@my-marketplace

# Enable/disable a plugin
claude plugin enable my-plugin@my-marketplace
claude plugin disable my-plugin@my-marketplace

# Add a marketplace
claude plugin marketplace add

# Update plugins
claude plugin update

# Interactive management (also lists LSP servers provided by each plugin)
/plugin
```

## Managed marketplace restrictions

Administrators can use `strictKnownMarketplaces` in `managed-settings.json` to restrict which marketplace sources users may add. `blockedMarketplaces` provides a denylist.

Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) § *All documented settings keys* (`strictKnownMarketplaces`, `blockedMarketplaces`).

## Recommending your plugin from a CLI tool

If you maintain a CLI or SDK that has a plugin in the official Anthropic marketplace, your tool can prompt Claude Code users to install that plugin. Write a one-line `<claude-code-hint />` marker to stderr; Claude Code strips it from command output before sending to the model (zero token cost), then shows the user a one-time install prompt.

Source: [`code.claude.com/docs/en/plugin-hints.md`](https://code.claude.com/docs/en/plugin-hints.md)

### How it works

Claude Code sets the [`CLAUDECODE`](SKILL-cli.md) environment variable to `1` for every Bash/PowerShell tool command. When your CLI detects that variable, write the hint tag to stderr:

```text
<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />
```

Claude Code then:
1. Removes the hint line before output reaches the model
2. Checks the plugin is in an official Anthropic marketplace (`claude-plugins-official`)
3. Checks the plugin is not already installed and has not been prompted before
4. Shows the user a named install prompt (user always confirms; no automatic install)

If the hint fails either condition (unofficial marketplace, already installed), it is silently dropped.

### Hint format

| Attribute | Required | Description |
|---|---|---|
| `v` | Yes | Protocol version. `1` is the only supported value |
| `type` | Yes | Hint kind. `plugin` is the only supported value |
| `value` | Yes | Plugin identifier in `name@marketplace` form |

The tag must occupy its own line (leading/trailing whitespace allowed). A tag embedded mid-line is ignored. Only `claude-plugins-official` (or other Anthropic-controlled marketplaces) are accepted — hints targeting other marketplaces are dropped.

### Emit the hint

Gate on `CLAUDECODE` so the tag never appears to users running your CLI outside Claude Code:

```javascript
// Node.js
if (process.env.CLAUDECODE) {
  process.stderr.write(
    '<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />\n',
  )
}
```

```python
# Python
import os, sys
if os.environ.get("CLAUDECODE"):
    print(
        '<claude-code-hint v="1" type="plugin" value="example-cli@claude-plugins-official" />',
        file=sys.stderr,
    )
```

### Recommended touchpoints

| Placement | Why it works |
|---|---|
| `--help` output | Claude often runs help when exploring an unfamiliar CLI |
| Unknown-subcommand errors | Reaches the moment Claude is confused about your interface |
| Login or auth success | User is in a setup mindset |
| First-run welcome message | Natural onboarding moment |

Claude Code deduplicates by plugin, so emitting on every invocation has no downside.

### Prompt frequency limits

- **Once per plugin** — after the prompt is shown (any answer), Claude Code never prompts for it again.
- **Once per session** — at most one hint prompt appears per Claude Code session across all CLIs on the machine.

The user can permanently disable all hint prompts by selecting "No, and don't show plugin installation hints again".

### Getting into the official marketplace

The hint protocol only works for plugins in the official Anthropic marketplace (`claude-plugins-official`). The in-app `/plugin` submission forms add plugins to the community marketplace, not the official one. Contact an Anthropic partner contact to coordinate an official-marketplace listing.

## Official Anthropic plugins

### security-guidance

Automatically reviews Claude's own code changes for security vulnerabilities and fixes them in the same session. Requires Claude Code v2.1.144+ and Python 3.8+ on `PATH`.

Source: `code.claude.com/docs/en/security-guidance.md`

**Install:**
```text
/plugin install security-guidance@claude-plugins-official
/reload-plugins
```

To enable in cloud sessions or for everyone in a repository, add to `.claude/settings.json`:
<!-- skip-validate -->
```json
{
  "enabledPlugins": {
    "security-guidance@claude-plugins-official": true
  }
}
```

**Review layers:**

| Layer | Trigger | Depth |
|---|---|---|
| Per-edit pattern match | Every file write | Deterministic string match; no model call; no cost |
| End-of-turn diff review | After each turn | Background model review of all changed files (up to 30) |
| Commit/push review | Claude runs `git commit`/`git push` via Bash | Deeper agentic review reading surrounding code; capped at 20/hour |

**Custom rules:**
- `.claude/claude-security-guidance.md` — plain-language guidance for model-backed reviews (8 KB cap; loads from user, project, and `*.local.md` scopes)
- `.claude/security-patterns.yaml` (or `.json`) — additional regex/substring rules for the per-edit layer (up to 50 rules)

**Environment variables:**

| Variable | Effect |
|---|---|
| `ENABLE_PATTERN_RULES=0` | Disable per-edit pattern check |
| `ENABLE_STOP_REVIEW=0` | Disable end-of-turn diff review |
| `ENABLE_COMMIT_REVIEW=0` | Disable commit/push review |
| `ENABLE_CODE_SECURITY_REVIEW=0` | Disable all model-backed reviews |
| `SECURITY_GUIDANCE_DISABLE=1` | Disable plugin entirely |
| `SECURITY_REVIEW_MODEL` | Override model for end-of-turn review (default: Claude Opus 4.7) |
| `SG_AGENTIC_MODEL` | Override model for commit review |

**Disable / uninstall:**
```text
/plugin disable security-guidance@claude-plugins-official
/plugin uninstall security-guidance@claude-plugins-official
```
If the plugin was enabled via project settings, disabling writes an override to `.claude/settings.local.json` (personal opt-out without affecting teammates).

## Common mistakes (auto-corrected by `rules/plugins.md`)

See [`rules/plugins.md`](rules/plugins.md). Key pitfalls:
- `plugin.json` must have both `name` AND `version` (missing `version` fails schema validation)
- Do NOT put component directories inside `.claude-plugin/` — they go at plugin root
- `enabledPlugins` keys use `<plugin>@<marketplace>` format (not bare plugin name)
- Plugin skills are namespaced (`/plugin-name:skill`); standalone `.claude/` skills are bare (`/skill`)
- `skills:` entries in the manifest must point at a **directory**, not a file — `claude plugin validate` flags file paths and suggests the parent directory
- Skills using `context: fork` must not invoke themselves; doing so causes an infinite re-invocation loop

---

*Source pages: `code.claude.com/docs/en/plugins.md`, `plugins-reference.md`, `plugin-hints.md`.*
