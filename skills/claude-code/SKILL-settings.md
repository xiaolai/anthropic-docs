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
| user | `~/.claude/settings.json` | n/a | personal defaults across all projects |
| project | `<project>/.claude/settings.json` | yes | team-shared settings |
| local | `<project>/.claude/settings.local.json` | gitignored | personal overrides for this project |
| managed | per-OS managed-settings path | n/a (admin-set) | enterprise policy, cannot be overridden |

Higher-priority scope overrides lower-priority. Read this chain left-to-right: `managed` overrides `local`, `local` overrides `project`, `project` overrides `user`.

## Top-level keys (selected)

The authoritative key table is in `code.claude.com/docs/en/settings.md`. High-signal keys:

| Key | Type | Default | Notes |
|---|---|---|---|
| `model` | string | account default | Override model. Examples: `claude-sonnet-4-6`, `claude-opus-4-7`. Also overridable with `ANTHROPIC_MODEL` env var. |
| `permissions` | object | `{}` | Tool-permission rules (`allow`, `deny`, `ask`, `defaultMode`, `additionalDirectories`). See § *`permissions` block*. |
| `env` | object | `{}` | Environment variables injected into every session. |
| `hooks` | object | `{}` | Hook event handlers. Full reference in [`SKILL-hooks.md`](SKILL-hooks.md). |
| `enabledPlugins` | object | `{}` | `"plugin@marketplace"` → boolean. See [`SKILL-plugins.md`](SKILL-plugins.md). |
| `autoMemoryEnabled` | boolean | `true` | Enable/disable auto memory. Also togglable with `/memory` or `CLAUDE_CODE_DISABLE_AUTO_MEMORY`. |
| `autoUpdatesChannel` | string | `"latest"` | `"stable"` or `"latest"`. Stable is ~1 week behind but skips regressions. |
| `availableModels` | array | (unrestricted) | Restrict which models users can select via `/model`, `--model`, or `ANTHROPIC_MODEL`. |
| `cleanupPeriodDays` | number | `30` | Session files older than this are deleted at startup. Min `1`. |
| `companyAnnouncements` | array | `[]` | Messages shown at startup, cycled randomly. |
| `defaultShell` | string | `"bash"` | `"bash"` or `"powershell"`. PowerShell requires `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. |
| `disableAllHooks` | boolean | `false` | Disable all hooks and custom status line. |
| `disableAutoMode` | string | — | Set `"disable"` to remove auto mode from Shift+Tab cycle. Managed settings only for enforcement. |
| `editorMode` | string | `"normal"` | `"normal"` or `"vim"`. Key binding mode for the input prompt. |
| `effortLevel` | string | — | Persist effort across sessions: `"low"`, `"medium"`, `"high"`, `"xhigh"`. |
| `language` | string | — | Claude's preferred response language, e.g. `"japanese"`. Also sets voice dictation language. |
| `model` | string | — | Override default model. `--model` and `ANTHROPIC_MODEL` override for one session. |
| `outputStyle` | string | — | Output style to adjust system prompt. See [output styles docs](https://code.claude.com/docs/en/output-styles.md). |
| `preferredNotifChannel` | string | `"auto"` | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, `"kitty"`, `"ghostty"`, `"notifications_disabled"`. |
| `spinnerTipsEnabled` | boolean | `true` | Show tips while Claude is working. |
| `statusLine` | object | — | Custom status line config. `{"type":"command","command":"~/.claude/statusline.sh"}`. |
| `tui` | string | — | Terminal UI renderer: `"fullscreen"` (alt-screen, flicker-free) or `"default"`. |
| `viewMode` | string | — | Default transcript view: `"default"`, `"verbose"`, or `"focus"`. |
| `voice` | object | — | Voice dictation: `{"enabled":true,"mode":"hold"\|"tap","autoSubmit":true}`. |

Minimal valid `settings.json`:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-6"
}
```

The `$schema` line enables IDE autocomplete and validation. Source: `code.claude.com/docs/en/settings.md`.

## `permissions` block

Permission rules under `settings.json` → `permissions`:

| Key | Type | Notes |
|---|---|---|
| `allow` | array | Tool calls that auto-approve. E.g. `["Bash(npm run test *)","Read(~/.zshrc)"]`. |
| `deny` | array | Tool calls that auto-deny. E.g. `["Bash(curl *)","Read(./.env)","Read(./secrets/**)"]`. |
| `ask` | array | Tool calls that always prompt. E.g. `["Bash(git push *)"]`. |
| `defaultMode` | string | Starting permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. As of v2.1.142, `auto` is ignored in project/local settings. |
| `additionalDirectories` | array | Extra directories Claude can read/edit. E.g. `["../docs/"]`. |
| `disableBypassPermissionsMode` | string | Set `"disable"` to block `bypassPermissions` mode. |

Deny rules are evaluated first, then ask, then allow. The first matching rule wins.

**Permission rule syntax**: `Tool` or `Tool(specifier)`.

| Rule | Effect |
|---|---|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Read(./.env)` | Matches reading `.env` |
| `WebFetch(domain:example.com)` | Matches fetch to example.com |

Source: `code.claude.com/docs/en/settings.md#permission-rule-syntax`.

## `env` injection

Set environment variables for every session:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp"
  }
}
```

Precedence: env var in shell > `settings.local.json` > `settings.json` (project) > `settings.json` (user).

## `hooks` block

> Cross-reference: full hook event reference lives in [`SKILL-hooks.md`](SKILL-hooks.md).

## `model` selection and overrides

`model` in settings sets the default. Override for one session with `--model` flag or `ANTHROPIC_MODEL` env var.

`modelOverrides` maps Anthropic model IDs to provider-specific IDs (e.g. Bedrock ARNs):
```json
{ "modelOverrides": { "claude-opus-4-6": "arn:aws:bedrock:us-east-1::..." } }
```

`availableModels` restricts the `/model` picker: `["sonnet", "haiku"]`.

## `enabledPlugins`

Controls which plugins are active. Format: `"plugin-name@marketplace-name": true/false`.

- **User settings** (`~/.claude/settings.json`): personal plugin preferences.
- **Project settings** (`.claude/settings.json`): project plugins shared with team.
- **Managed settings**: can force-enable or force-disable at org level.

Project settings override user settings, so disabling in `~/.claude/settings.json` does NOT disable a plugin the project enables. Use `.claude/settings.local.json` to opt out locally.

Cross-reference: plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

## Sandbox settings (`sandbox.*`)

Enabled in `settings.json` → `sandbox`:

| Key | Default | Notes |
|---|---|---|
| `enabled` | `false` | Enable bash sandboxing (macOS, Linux, WSL2). |
| `autoAllowBashIfSandboxed` | `true` | Auto-approve bash commands when sandboxed. |
| `excludedCommands` | `[]` | Commands that run outside the sandbox. |
| `filesystem.allowWrite` | `[]` | Extra paths where sandboxed commands can write. |
| `filesystem.denyRead` | `[]` | Paths sandboxed commands cannot read. |
| `network.allowedDomains` | `[]` | Domains allowed for outbound traffic. Supports wildcards. |
| `network.deniedDomains` | `[]` | Domains blocked for outbound traffic. Takes precedence over allowedDomains. |

## Worktree settings (`worktree.*`)

| Key | Default | Notes |
|---|---|---|
| `worktree.baseRef` | `"fresh"` | `"fresh"` = branch from `origin/<default>`, `"head"` = branch from local HEAD. |
| `worktree.symlinkDirectories` | `[]` | Dirs to symlink into each worktree (e.g. `["node_modules"]`). |
| `worktree.sparsePaths` | `[]` | Sparse-checkout paths for large monorepos. |
| `worktree.bgIsolation` | `"worktree"` | Background session isolation: `"worktree"` (default) or `"none"`. Requires v2.1.143+. |

## Common mistakes (auto-corrected by `rules/settings.md`)

> *Populated by the research agent from `anthropics/claude-code` issues.*

---

*Source pages: `code.claude.com/docs/en/settings.md`.*
