---
name: claude-code-settings
description: |
  Deep reference for Claude Code's settings.json and settings.local.json
  files. Covers every documented key, its type, default value, allowed
  values, scope semantics (user / project / local / managed), and
  worked examples. Read this file when the user asks about settings
  keys, permissions config, model selection, env injection via
  settings, or settings file precedence.
source: https://code.claude.com/docs/en/settings.md
---

# Claude Code — `settings.json` and `settings.local.json`

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for settings questions.*

## Scope precedence

| Scope | Path | Tracked in git? | Use case |
|---|---|---|---|
| managed | server-delivered, MDM policy, or system `managed-settings.json` | n/a (admin-set) | enterprise policy, cannot be overridden |
| command-line | `--settings` / `--permission-mode` etc. | n/a | session-only overrides |
| local | `<project>/.claude/settings.local.json` | gitignored | personal overrides for this project |
| project | `<project>/.claude/settings.json` | yes | team-shared settings |
| user | `~/.claude/settings.json` | n/a | personal defaults across all projects |

Higher-priority scope overrides lower-priority: **managed > command-line > local > project > user**.
Permission rules (allow/deny/ask) **merge** across scopes rather than override.

**Other config locations:**
- `~/.claude.json`: OAuth session, user/local MCP configs, per-project tool trust, various caches
- `.mcp.json`: project-scoped MCP server configs (separate from settings.json)

**Managed settings delivery mechanisms:**
- Server-managed via Claude.ai admin console
- macOS MDM: `com.anthropic.claudecode` plist domain (Jamf, Kandji)
- Windows MDM: `HKLM\SOFTWARE\Policies\ClaudeCode` registry `Settings` key (JSON)
- File-based: `managed-settings.json` at `/Library/Application Support/ClaudeCode/` (macOS), `/etc/claude-code/` (Linux/WSL), `C:\Program Files\ClaudeCode\` (Windows)
- Drop-in directory `managed-settings.d/*.json` alongside `managed-settings.json` for separate team fragments

Source: `code.claude.com/docs/en/settings.md`

## Top-level keys (settings.json)

The official JSON Schema is at `https://json.schemastore.org/claude-code-settings.json`.
Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` to enable editor autocomplete.

Key settings (selected most-referenced; full list at source page):

| Key | Type | Default | Notes |
|---|---|---|---|
| `agent` | string | — | Run main thread as a named subagent. Applies that subagent's system prompt, tool restrictions, model. |
| `alwaysThinkingEnabled` | boolean | `false` | Enable extended thinking by default. |
| `apiKeyHelper` | string | — | Shell script to generate an auth value (sent as `X-Api-Key` and `Authorization: Bearer`). |
| `attribution` | object | — | Customize git commit/PR attribution. E.g. `{"commit": "🤖 Generated with Claude Code", "pr": ""}`. |
| `autoMemoryEnabled` | boolean | `true` | Enable/disable auto-memory. |
| `autoMode` | object | — | Configure auto mode classifier rules (`environment`, `allow`, `soft_deny`, `hard_deny` arrays). Use `"$defaults"` to inherit built-in rules. Not read from project settings. |
| `autoUpdatesChannel` | string | `"latest"` | `"stable"` for ~1-week-old releases; `"latest"` for newest. |
| `availableModels` | string[] | — | Restrict which models users can select via `/model`, `--model`, or `ANTHROPIC_MODEL`. |
| `cleanupPeriodDays` | number | `30` | Delete session files older than N days at startup. Minimum 1. |
| `companyAnnouncements` | string[] | — | Startup messages cycled at random. |
| `defaultShell` | string | `"bash"` | `"bash"` or `"powershell"` for `!`-prefixed commands. |
| `disableAgentView` | boolean | `false` | Disable background agents and agent view. |
| `disableAllHooks` | boolean | `false` | Disable all hooks and custom status line. |
| `disableAutoMode` | string | — | `"disable"` to prevent auto mode activation. |
| `editorMode` | string | `"normal"` | `"normal"` or `"vim"` for input prompt key bindings. |
| `effortLevel` | string | — | Persist effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"`. |
| `enableAllProjectMcpServers` | boolean | `false` | Auto-approve all MCP servers from project `.mcp.json`. |
| `env` | object | `{}` | Environment variables injected into every session. See § *`env` injection*. |
| `forceLoginMethod` | string | — | `"claudeai"` or `"console"` to restrict login method. |
| `forceLoginOrgUUID` | string\|string[] | — | Require login to belong to a specific org UUID(s). |
| `hooks` | object | `{}` | Hook event handlers. Full reference in [`SKILL-hooks.md`](SKILL-hooks.md). |
| `includeCoAuthoredBy` | boolean | `true` | **Deprecated** — use `attribution` instead. |
| `includeGitInstructions` | boolean | `true` | Include built-in git workflow instructions in system prompt. |
| `language` | string | — | Claude's preferred response language (e.g., `"japanese"`, `"spanish"`). |
| `maxSkillDescriptionChars` | number | `1536` | Per-skill char cap on combined `description`+`when_to_use`. |
| `minimumVersion` | string | — | Floor for auto-updates. E.g. `"2.1.100"`. |
| `model` | string | (account default) | Override default model. E.g. `"claude-sonnet-4-6"`, `"claude-opus-4-7"`. |
| `modelOverrides` | object | — | Map Anthropic model IDs to provider-specific IDs (Bedrock ARNs, etc.). |
| `outputStyle` | string | — | Configure an output style to adjust the system prompt. See `/config` or output styles docs. |
| `parentSettingsBehavior` | string | `"first-wins"` | (Managed only, v2.1.133+) `"first-wins"` or `"merge"` for SDK/IDE parent settings under admin tier. |
| `permissions` | object | `{}` | Tool-permission rules. See § *`permissions` block* below. |
| `plansDirectory` | string | `"~/.claude/plans"` | Customize where plan files are stored (relative to project root or absolute). |
| `policyHelper` | object | — | (Managed only, v2.1.136+) Admin executable that computes managed settings dynamically. `{"path": "/usr/local/bin/claude-policy"}`. |
| `preferredNotifChannel` | string | `"auto"` | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, `"kitty"`, `"ghostty"`, `"notifications_disabled"`. |
| `showThinkingSummaries` | boolean | `false` | Show extended thinking summaries in interactive mode. |
| `skillListingBudgetFraction` | number | `0.01` | Fraction of context window for skill listing (1% default). |
| `skillOverrides` | object | — | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"`. E.g. `{"legacy-context": "name-only"}`. |
| `spinnerTipsEnabled` | boolean | `true` | Show tips in spinner while Claude works. |
| `statusLine` | object | — | Custom status line config. E.g. `{"type": "command", "command": "~/.claude/statusline.sh"}`. |
| `tui` | string | — | TUI renderer: `"fullscreen"` or `"default"`. |
| `viewMode` | string | — | Default transcript view: `"default"`, `"verbose"`, or `"focus"`. |
| `voice` | object | — | Voice dictation settings: `enabled`, `mode` (`"hold"` or `"tap"`), `autoSubmit`. |
| `worktree.baseRef` | string | `"fresh"` | Worktree base: `"fresh"` (origin/<default>) or `"head"` (local HEAD). |
| `worktree.symlinkDirectories` | string[] | `[]` | Dirs to symlink from main repo into each worktree. E.g. `["node_modules"]`. |
| `worktree.sparsePaths` | string[] | `[]` | Sparse-checkout paths per worktree. |

**Managed-only keys:** `allowedChannelPlugins`, `allowedMcpServers`, `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `blockedMarketplaces`, `channelsEnabled`, `claudeMd`, `deniedMcpServers`, `forceRemoteSettingsRefresh`, `pluginTrustMessage`, `strictKnownMarketplaces`, `wslInheritsWindowsSettings`.

### Global config settings (`~/.claude.json` only — not in settings.json)

| Key | Default | Notes |
|---|---|---|
| `autoConnectIde` | `false` | Auto-connect to running IDE on startup. |
| `autoInstallIdeExtension` | `true` | Auto-install IDE extension when running from VS Code terminal. |
| `externalEditorContext` | `false` | Prepend Claude's last response when opening external editor with Ctrl+G. |
| `teammateDefaultModel` | — | Default model for agent team teammates. |

## `permissions` block

Lives under the top-level `permissions` key in `settings.json`.

| Key | Type | Notes |
|---|---|---|
| `allow` | string[] | Rules that auto-approve tool use without prompting. |
| `ask` | string[] | Rules that always prompt for confirmation. |
| `deny` | string[] | Rules that block tool use outright. |
| `additionalDirectories` | string[] | Extra directories for file access (file-access only, not `.claude/` config). |
| `defaultMode` | string | Default permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. |
| `disableBypassPermissionsMode` | string | `"disable"` to prevent `bypassPermissions` activation. |
| `skipDangerousModePermissionPrompt` | boolean | Skip confirmation before entering bypass mode (ignored in project settings). |

Rule evaluation order: **deny → ask → allow** (first match wins).

### Permission rule syntax

Rules follow `Tool` or `Tool(specifier)`. Wildcards (`*`) match any sequence including spaces.

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(git commit *)", "Read(~/.zshrc)"],
    "deny":  ["Bash(curl *)", "Read(./.env)", "Read(./secrets/**)"],
    "defaultMode": "acceptEdits"
  }
}
```

- `Bash(npm run *)` — matches commands starting with `npm run `
- `Read(./.env)` — matches reading the `.env` file
- `WebFetch(domain:example.com)` — matches fetches to example.com
- `Bash(ls *)` vs `Bash(ls*)`: space before `*` enforces word boundary
- `:*` suffix is equivalent to trailing ` *`: `Bash(ls:*)` = `Bash(ls *)`
- Compound commands: each subcommand must independently match a rule
- Process wrappers `timeout`, `time`, `nice`, `nohup`, `stdbuf`, bare `xargs` are stripped before matching

**Read-only auto-approved Bash commands** (no prompt in any mode): `ls`, `cat`, `echo`, `pwd`, `head`, `tail`, `grep`, `find`, `wc`, `which`, `diff`, `stat`, `du`, `cd`, and read-only git forms.

Cross-reference: permission modes → [`SKILL-cli.md`](SKILL-cli.md) § *Permission modes*.

## `env` injection

Environment variables set here are applied to every session. Useful for enabling telemetry, setting default flags, or injecting project-specific values without exporting from the shell.

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

Values must be strings. The env block merges across scopes (managed, user, project, local) — later scopes can add keys but not remove managed keys.

## `hooks` block

Cross-reference: full hook event reference lives in [`SKILL-hooks.md`](SKILL-hooks.md).

Hooks are defined under the `hooks` key as `{ "<EventName>": [<matcher-group>, ...] }`. See `SKILL-hooks.md` for the complete schema.

## `model` selection and overrides

```json
{
  "model": "claude-opus-4-7",
  "effortLevel": "xhigh"
}
```

Model aliases: `sonnet` (latest Sonnet), `opus` (latest Opus). Full model IDs also accepted.
Override precedence: `--model` flag > `ANTHROPIC_MODEL` env var > `model` in settings.

## `enabledPlugins`

Map of `"<plugin>@<marketplace>"` → `true/false` to enable/disable plugins by scope.
Cross-reference: plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

## Common mistakes (auto-corrected by `rules/settings.md`)

See [`rules/settings.md`](rules/settings.md) for the authoritative list. Key pitfalls:
- `permissions.allow` / `deny` / `ask` must be arrays of strings, not objects
- Hook event names are PascalCase: `PreToolUse`, not `pre_tool_use`
- `enabledPlugins` keys use `<plugin>@<marketplace>` format, not bare names

---

*Source pages: `code.claude.com/docs/en/settings.md`, `permissions.md`, `permission-modes.md`.*
