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
| managed | per-OS managed-settings path | n/a (admin-set) | enterprise policy, cannot be overridden |
| local | `<project>/.claude/settings.local.json` | gitignored | personal overrides for this project |
| project | `<project>/.claude/settings.json` | yes | team-shared settings |
| user | `~/.claude/settings.json` | n/a | personal defaults across all projects |

Higher-priority scope overrides lower-priority. Read this chain left-to-right: `managed` overrides `local`, `local` overrides `project`, `project` overrides `user`.

## Top-level settings keys

All keys are optional. Unrecognized keys are ignored.

### Core model and behavior

| Key | Notes |
|---|---|
| `model` | Override the default model. Examples: `"claude-sonnet-4-6"`, `"claude-opus-4-7"`, `"claude-haiku-4-5"`. `--model` flag and `ANTHROPIC_MODEL` env var take precedence. |
| `agent` | Run the main thread as a named subagent (applies its system prompt, tool restrictions, and model). |
| `effortLevel` | Persist effort level across sessions: `"low"`, `"medium"`, `"high"`, `"xhigh"`. |
| `alwaysThinkingEnabled` | `true` = enable extended thinking by default. |
| `outputStyle` | Configure an output style preset (see output-styles docs). |
| `language` | Preferred response language (e.g. `"japanese"`, `"spanish"`). |
| `availableModels` | Restrict which models appear in `/model` picker; does not affect `--model` flag. |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs (e.g. Bedrock ARNs). |
| `fallbackModel` | Model to use when the primary model is unavailable. |

### Permissions block

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": ["Bash(git diff *)", "Read(./.env)"],
    "deny": ["WebFetch", "Bash(curl *)"],
    "ask": ["Bash(git push *)"],
    "additionalDirectories": ["../docs/"],
    "disableBypassPermissionsMode": "disable",
    "disableAutoMode": "disable"
  }
}
```

| Key | Notes |
|---|---|
| `permissions.allow` | Array of tool rules auto-approved. See § *Permission rule syntax* below. |
| `permissions.ask` | Array of rules that prompt before running. |
| `permissions.deny` | Array of rules that are blocked. |
| `permissions.additionalDirectories` | Extra working directories for file access. Note: most `.claude/` config is NOT discovered from these dirs. |
| `permissions.defaultMode` | Default permission mode: `"default"`, `"acceptEdits"`, `"plan"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"`. |
| `permissions.disableBypassPermissionsMode` | `"disable"` = block `bypassPermissions` mode. Managed-settings use. |
| `permissions.disableAutoMode` | `"disable"` = block auto mode for users. Managed-settings use. |
| `permissions.autoMode` | Sub-object to configure auto mode behavior (allow/deny rules, environment config). |
| `permissions.autoMode.hard_deny` | Array of rules blocked unconditionally in auto mode, even if broader allow rules apply (v2.1.128+). |

### Permission rule syntax

```
"Bash(git diff *)"         ← allow/deny specific Bash commands (glob match)
"Read(./.env)"             ← allow/deny a specific file
"Read(./secrets/**)"       ← allow/deny a directory tree
"WebFetch"                 ← allow/deny an entire tool
"mcp__myserver__mytool"    ← allow/deny a specific MCP tool
```

Rules in `allow` override matching `deny` rules. Rules in `deny` override `ask`.

### Hooks

```json
{ "hooks": { "PreToolUse": [{ "matcher": "Bash", "hooks": [{ "type": "command", "command": "my-hook.sh" }] }] } }
```

Full reference in [`SKILL-hooks.md`](SKILL-hooks.md).

### Environment injection

```json
{ "env": { "NODE_ENV": "development", "MY_VAR": "value" } }
```

Variables in `env` are injected into every tool call. Merges across scopes (lower-priority envs are merged first, then overridden by higher-priority scopes).

### Worktree settings

| Key | Default | Notes |
|---|---|---|
| `worktree.baseRef` | `"fresh"` | `"fresh"` = branch from `origin/<default>`. `"head"` = branch from local HEAD (v2.1.128+). Applies to `--worktree`, `EnterWorktree`, subagent isolation. |
| `worktree.symlinkDirectories` | `[]` | Dirs to symlink from main repo into each worktree (avoids duplicating large dirs). |
| `worktree.sparsePaths` | (none) | Dirs to check out via sparse-checkout (faster in large monorepos). |

### Plugin settings

| Key | Notes |
|---|---|
| `enabledPlugins` | `{ "<plugin>@<marketplace>": true/false }` — enable/disable specific plugins. |
| `extraKnownMarketplaces` | Array of additional marketplace sources to recognize. |
| `strictKnownMarketplaces` | (Managed) allowlist of marketplace sources; empty = block all unknown. |
| `blockedMarketplaces` | (Managed) blocklist of marketplace sources. |
| `allowedChannelPlugins` | (Managed) allowlist of channel plugins that may push messages. |
| `pluginTrustMessage` | (Managed) custom message appended to plugin trust warning. |

### Memory settings

| Key | Notes |
|---|---|
| `autoMemoryEnabled` | `true` = enable auto memory (Claude accumulates learnings). `false` = disable. |
| `autoMemoryDirectory` | Custom directory for auto memory storage. |
| `claudeMd` | (Managed) CLAUDE.md-style instructions injected as organization-managed memory. |
| `claudeMdExcludes` | Glob patterns / absolute paths of CLAUDE.md files to skip. |

### MCP settings

| Key | Notes |
|---|---|
| `allowedMcpServers` | (Managed) allowlist of MCP servers users can configure. |
| `deniedMcpServers` | (Managed) denylist of MCP servers explicitly blocked. |
| `allowManagedMcpServersOnly` | (Managed) only managed-settings MCP servers are used. |
| `enableAllProjectMcpServers` | `true` = auto-approve all MCP servers in project `.mcp.json`. |
| `enabledMcpjsonServers` | List of specific `.mcp.json` servers to approve. |
| `disabledMcpjsonServers` | List of specific `.mcp.json` servers to reject. |
| `allowedHttpHookUrls` | Allowlist of URL patterns for HTTP hooks. `*` wildcard supported. |
| `httpHookAllowedEnvVars` | Allowlist of env var names HTTP hooks may interpolate into headers. |

### UI and display

| Key | Notes |
|---|---|
| `tui` | `"fullscreen"` = alt-screen flicker-free renderer. |
| `editorMode` | `"normal"` (default) or `"vim"` key bindings for the input prompt. |
| `viewMode` | Default transcript view: `"default"`, `"verbose"`, or `"focus"`. |
| `syntaxHighlightingDisabled` | `true` = disable syntax highlighting in diffs and code blocks. |
| `autoScrollEnabled` | Follow new output to the bottom. Default: `true`. |
| `showTurnDuration` | Show turn duration after responses. Default: `true`. |
| `showThinkingSummaries` | Show extended thinking summaries. Default: `true`. |
| `prefersReducedMotion` | Reduce/disable UI animations for accessibility. |
| `terminalProgressBarEnabled` | Show terminal progress bar (ConEmu, Ghostty, iTerm2). |
| `spinnerTipsEnabled` | Show tips while Claude works. Default: `true`. |
| `spinnerTipsOverride` | Custom spinner tips: `{ "tips": [...], "excludeDefault": true }`. |
| `spinnerVerbs` | Customize action verbs in spinner/turn duration messages. |

### Session management

| Key | Notes |
|---|---|
| `cleanupPeriodDays` | Delete session files older than N days at startup. Default: 30. Min: 1. |
| `awaySummaryEnabled` | Show session recap when returning to terminal after absence. |
| `showClearContextOnPlanAccept` | Show "clear context" option on plan accept screen. Default: `false`. |
| `fastModePerSessionOptIn` | `true` = fast mode off by default; must enable per-session. |

### Authentication and access control

| Key | Notes |
|---|---|
| `forceLoginMethod` | `"claudeai"` or `"console"` to restrict login method. |
| `forceLoginOrgUUID` | Require login to a specific org UUID. |
| `minimumVersion` | Floor that prevents auto-updates below this version. |
| `companyAnnouncements` | Announcement text shown at startup. Multiple = cycled. |
| `apiKeyHelper` | Script executed in `/bin/sh` to generate an auth token. |
| `otelHeadersHelper` | Script to generate dynamic OTEL headers. |

### Other notable keys

| Key | Notes |
|---|---|
| `defaultShell` | `"bash"` (default) or `"powershell"` for input `!` commands. |
| `includeGitInstructions` | Include built-in commit/PR instructions in system prompt. |
| `statusLine` | Custom status line config (see statusline docs). |
| `voice` | Voice dictation settings: `{ "enabled": true, "mode": "hold" / "toggle" }`. |
| `attribution` | Customize git commit co-author attribution. |
| `prUrlTemplate` | URL template for PR badges in footer. |
| `outputStyle` | Output style preset (see output-styles docs). |
| `parentSettingsBehavior` | (Managed, v2.1.133+) Controls whether SDK `managedSettings` merge with org policy. |
| `policyHelper` | (Admin, v2.1.136+) Executable that computes managed settings dynamically. |
| `forceRemoteSettingsRefresh` | (Managed) Block CLI startup until remote managed settings are freshly fetched. |

## Minimal valid `settings.json`

```json
{
  "model": "claude-sonnet-4-6"
}
```

## Worked examples

### Allow common Git read-only Bash + auto-approve file edits

```json
{
  "permissions": {
    "defaultMode": "acceptEdits",
    "allow": [
      "Bash(git log *)",
      "Bash(git diff *)",
      "Bash(git status)"
    ],
    "deny": [
      "Bash(git push *)",
      "WebFetch"
    ]
  }
}
```

### Enterprise managed settings lockdown

```json
{
  "permissions": {
    "disableBypassPermissionsMode": "disable",
    "disableAutoMode": "disable",
    "allowManagedPermissionRulesOnly": true
  },
  "minimumVersion": "2.1.100",
  "allowedMcpServers": [
    { "name": "internal-tools" }
  ]
}
```

### Inject env vars and set model for a project

```json
{
  "model": "claude-opus-4-7",
  "env": {
    "NODE_ENV": "development",
    "API_BASE_URL": "http://localhost:3000"
  }
}
```

Source: `code.claude.com/docs/en/settings.md`

---

*Source pages: `code.claude.com/docs/en/settings.md`, `permissions.md`, `permission-modes.md`.*
