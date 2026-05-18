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

Source: [code.claude.com/docs/en/settings.md](https://code.claude.com/docs/en/settings.md)

## Scope precedence

Settings are merged in priority order (highest wins, except permission rules which merge across scopes):

| Priority | Scope | Path | Tracked in git? |
|---|---|---|---|
| 1 (highest) | managed | server-managed settings, plist/registry, or system `managed-settings.json` | admin-deployed |
| 2 | command-line | `--settings` flag or `--permission-mode` etc. | per-invocation |
| 3 | local | `<project>/.claude/settings.local.json` | no (gitignored) |
| 4 | project | `<project>/.claude/settings.json` | yes |
| 5 (lowest) | user | `~/.claude/settings.json` | n/a |

**Managed delivery mechanisms:**
- **Server-managed**: via claude.ai admin console (see [server-managed settings](https://code.claude.com/docs/en/server-managed-settings.md))
- **macOS MDM**: `com.anthropic.claudecode` managed preferences domain (Jamf, Kandji, etc.)
- **Windows registry**: `HKLM\SOFTWARE\Policies\ClaudeCode` key with `Settings` value (REG_SZ JSON)
- **File-based**: `managed-settings.json` in `/Library/Application Support/ClaudeCode/` (macOS), `/etc/claude-code/` (Linux/WSL), `C:\Program Files\ClaudeCode\` (Windows)
- **Drop-in directory**: `managed-settings.d/` next to `managed-settings.json`; files merged alphabetically

**File locations by feature:**

| Feature | User | Project | Local |
|---|---|---|---|
| Settings | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| MCP servers | `~/.claude.json` | `.mcp.json` | `~/.claude.json` (per-project) |
| CLAUDE.md | `~/.claude/CLAUDE.md` | `CLAUDE.md` or `.claude/CLAUDE.md` | `CLAUDE.local.md` |
| Plugins | via `settings.json` `enabledPlugins` | same | same |

Claude Code automatically creates timestamped backups of config files, retaining the five most recent.

## Top-level settings keys

Full reference from [code.claude.com/docs/en/settings.md](https://code.claude.com/docs/en/settings.md). The JSON schema is published at `https://json.schemastore.org/claude-code-settings.json`.

| Key | Type | Notes |
|---|---|---|
| `agent` | string | Run the main thread as a named subagent with its system prompt, tool restrictions, and model |
| `allowedChannelPlugins` | array | (Managed only) Allowlist of channel plugins. Replaces default Anthropic allowlist when set |
| `allowedHttpHookUrls` | array | URL patterns HTTP hooks may target (`*` wildcard). Undefined = no restriction, `[]` = block all |
| `allowedMcpServers` | array | (Managed) Allowlist of MCP servers users can configure. `[]` = lockdown |
| `allowManagedHooksOnly` | boolean | (Managed) Only managed, SDK, and force-enabled plugin hooks run; all others blocked |
| `allowManagedMcpServersOnly` | boolean | (Managed) Only `allowedMcpServers` from managed settings are respected |
| `allowManagedPermissionRulesOnly` | boolean | (Managed) Prevent user/project from defining `allow`/`ask`/`deny` rules |
| `alwaysThinkingEnabled` | boolean | Enable extended thinking by default for all sessions |
| `apiKeyHelper` | string | Shell script to generate auth value sent as `X-Api-Key` and `Authorization: Bearer` |
| `attribution` | object | Customize git commit and PR attribution. Keys: `commit`, `pr` (strings; empty string hides) |
| `autoMemoryDirectory` | string | Custom directory for auto memory. Absolute or `~/`-prefixed path |
| `autoMemoryEnabled` | boolean | Enable auto memory. Default: `true`. Toggle with `/memory` |
| `autoMode` | object | Customize auto mode classifier. Keys: `environment`, `allow`, `soft_deny`, `hard_deny` (arrays). Use `"$defaults"` to inherit built-in rules |
| `autoScrollEnabled` | boolean | Follow new output to bottom in fullscreen rendering. Default: `true` |
| `autoUpdatesChannel` | string | `"latest"` (default) or `"stable"` (≈1 week old, skips major regressions) |
| `availableModels` | array | Restrict which models users can select via `/model`, `--model`, or `ANTHROPIC_MODEL` |
| `awaySummaryEnabled` | boolean | Show one-line session recap when returning to terminal after a few minutes |
| `awsAuthRefresh` | string | Script that modifies `.aws` directory for Bedrock credential refresh |
| `awsCredentialExport` | string | Script that outputs JSON with AWS credentials for Bedrock |
| `blockedMarketplaces` | array | (Managed) Blocklist of marketplace sources |
| `channelsEnabled` | boolean | (Managed) Allow channels for the org. Required on Team/Enterprise plans |
| `claudeMd` | string | (Managed) CLAUDE.md-style instructions injected as org-wide memory |
| `claudeMdExcludes` | array | Glob patterns of CLAUDE.md files to skip when loading memory |
| `cleanupPeriodDays` | number | Delete session files older than this (default: 30, min 1). Also controls orphaned worktree cleanup |
| `companyAnnouncements` | array | Startup announcements; cycled randomly when multiple provided |
| `defaultShell` | string | `"bash"` (default) or `"powershell"` for `!` commands. Requires `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` |
| `deniedMcpServers` | array | (Managed) Denylist of MCP servers; takes precedence over allowlist |
| `disableAgentView` | boolean | Turn off background agents and agent view (`claude agents`, `--bg`, `/background`) |
| `disableAllHooks` | boolean | Disable all hooks and custom status line |
| `disableAutoMode` | string | `"disable"` to remove auto mode from Shift+Tab cycle and reject `--permission-mode auto` |
| `disableDeepLinkRegistration` | string | `"disable"` to prevent `claude-cli://` protocol handler registration |
| `disabledMcpjsonServers` | array | List of specific MCP servers from `.mcp.json` to reject |
| `disableRemoteControl` | boolean | Disable Remote Control. Min version: v2.1.128 |
| `disableSkillShellExecution` | boolean | Disable `!`-prefixed shell execution in skills/commands from user/project/plugin sources |
| `editorMode` | string | `"normal"` (default) or `"vim"` key bindings for the input prompt |
| `effortLevel` | string | Persist effort level across sessions: `"low"`, `"medium"`, `"high"`, `"xhigh"` |
| `enableAllProjectMcpServers` | boolean | Auto-approve all MCP servers in project `.mcp.json` files |
| `enabledMcpjsonServers` | array | List of specific MCP servers from `.mcp.json` to approve |
| `env` | object | Environment variables injected into every session. Example: `{"FOO": "bar"}` |
| `fastModePerSessionOptIn` | boolean | When `true`, fast mode does not persist; each session starts with fast mode off |
| `feedbackSurveyRate` | number | Probability (0–1) that session quality survey appears. Set `0` to suppress |
| `fileSuggestion` | object | Custom script for `@` file autocomplete. See *File suggestion settings* below |
| `forceLoginMethod` | string | `"claudeai"` or `"console"` to restrict login method |
| `forceLoginOrgUUID` | string or array | Require login to belong to a specific organization UUID or list of UUIDs |
| `forceRemoteSettingsRefresh` | boolean | (Managed) Block CLI startup until remote managed settings freshly fetched |
| `gcpAuthRefresh` | string | Script that refreshes GCP Application Default Credentials |
| `hooks` | object | Hook event handlers. Full reference in [`SKILL-hooks.md`](SKILL-hooks.md) |
| `httpHookAllowedEnvVars` | array | Allowlist of env var names HTTP hooks may interpolate into headers |
| `includeCoAuthoredBy` | boolean | **Deprecated.** Use `attribution` instead |
| `includeGitInstructions` | boolean | Include built-in git workflow instructions in system prompt. Default: `true` |
| `language` | string | Claude's preferred response language (e.g. `"japanese"`, `"spanish"`) |
| `maxSkillDescriptionChars` | number | Per-skill char cap on description + when_to_use text (default: 1536). Min version: v2.1.105 |
| `minimumVersion` | string | Floor for auto-updates and `claude update`. Example: `"2.1.100"` |
| `model` | string | Override default model. Example: `"claude-sonnet-4-6"`, `"claude-opus-4-7"` |
| `modelOverrides` | object | Map Anthropic model IDs to provider-specific IDs (e.g. Bedrock ARNs) |
| `otelHeadersHelper` | string | Script to generate dynamic OpenTelemetry headers |
| `outputStyle` | string | Configure output style to adjust the system prompt. See [output styles](https://code.claude.com/docs/en/output-styles.md) |
| `parentSettingsBehavior` | string | (Managed) `"first-wins"` (default) or `"merge"` for SDK/IDE-supplied managed settings. Min version: v2.1.133 |
| `permissions` | object | Tool-permission rules. See *`permissions` block* below |
| `plansDirectory` | string | Where plan files are stored relative to project root. Default: `~/.claude/plans` |
| `pluginTrustMessage` | string | (Managed) Custom message appended to plugin trust warning |
| `policyHelper` | object | (Managed MDM/system only) Executable that computes managed settings dynamically. Min version: v2.1.136 |
| `preferredNotifChannel` | string | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, `"iterm2_with_bell"`, `"kitty"`, `"ghostty"`, `"notifications_disabled"` |
| `prefersReducedMotion` | boolean | Reduce/disable UI animations (spinners, shimmer, flash) for accessibility |
| `prUrlTemplate` | string | URL template for PR badge. Substitutes `{host}`, `{owner}`, `{repo}`, `{number}`, `{url}` |
| `respectGitignore` | boolean | Whether `@` file picker respects `.gitignore`. Default: `true` |
| `showClearContextOnPlanAccept` | boolean | Show "clear context" option on plan accept screen. Default: `false` |
| `showThinkingSummaries` | boolean | Show extended thinking summaries in interactive sessions. Default: `false` |
| `showTurnDuration` | boolean | Show turn duration messages. Default: `true` |
| `skillListingBudgetFraction` | number | Fraction of context window for skill listing (default: `0.01`). Min version: v2.1.105 |
| `skillOverrides` | object | Per-skill visibility overrides: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"`. Min version: v2.1.129 |
| `skipWebFetchPreflight` | boolean | Skip WebFetch domain safety check. Use on Bedrock/Vertex/Foundry with restrictive egress |
| `spinnerTipsEnabled` | boolean | Show tips in spinner while Claude works. Default: `true` |
| `spinnerTipsOverride` | object | `{tips: string[], excludeDefault: boolean}` — override spinner tips |
| `spinnerVerbs` | object | `{mode: "replace"|"append", verbs: string[]}` — customize action verbs |
| `sshConfigs` | array | SSH connections for Desktop environment dropdown. Each: `{id, name, sshHost, sshPort?, sshIdentityFile?, startDirectory?}` |
| `statusLine` | object | Custom status line config. See [statusline docs](https://code.claude.com/docs/en/statusline.md) |
| `strictKnownMarketplaces` | array | (Managed) Allowlist of plugin marketplace sources |
| `syntaxHighlightingDisabled` | boolean | Disable syntax highlighting in diffs and code blocks |
| `teammateMode` | string | Agent team display: `"auto"`, `"in-process"`, or `"tmux"` |
| `terminalProgressBarEnabled` | boolean | Show terminal progress bar in ConEmu, Ghostty 1.2.0+, iTerm2 3.6.6+. Default: `true` |
| `tui` | string | Terminal UI renderer: `"fullscreen"` (alt-screen) or `"default"` (classic) |
| `useAutoModeDuringPlan` | boolean | Whether plan mode uses auto mode semantics. Default: `true`. Not in project settings |
| `viewMode` | string | Default transcript view: `"default"`, `"verbose"`, or `"focus"` |
| `voice` | object | Voice dictation: `{enabled: boolean, mode: "hold"|"tap", autoSubmit?: boolean}` |
| `voiceEnabled` | boolean | Legacy alias for `voice.enabled`. Prefer the `voice` object |
| `wslInheritsWindowsSettings` | boolean | (Windows managed only) WSL reads managed settings from Windows policy chain |

### Global config settings (stored in `~/.claude.json`, NOT `settings.json`)

| Key | Notes |
|---|---|
| `autoConnectIde` | Auto-connect to running IDE when Claude Code starts from external terminal. Default: `false` |
| `autoInstallIdeExtension` | Auto-install Claude Code IDE extension from VS Code terminal. Default: `true` |
| `externalEditorContext` | Prepend Claude's previous response as `#`-comments when opening external editor. Default: `false` |
| `teammateDefaultModel` | Default model for agent team teammates. E.g. `"sonnet"`, or `null` to inherit lead's model |

### Worktree settings

| Key | Notes |
|---|---|
| `worktree.baseRef` | `"fresh"` (default, branches from `origin/<default>`) or `"head"` (branches from local HEAD) |
| `worktree.symlinkDirectories` | Directories to symlink from main repo into each worktree. Default: none |
| `worktree.sparsePaths` | Directories for git sparse-checkout in each worktree (faster in large monorepos) |

## `permissions` block

Nested under the top-level `permissions` key:

| Key | Type | Notes |
|---|---|---|
| `allow` | array | Permission rules to allow tool use without prompting |
| `ask` | array | Permission rules to prompt for confirmation |
| `deny` | array | Permission rules to block tool use |
| `additionalDirectories` | array | Additional working directories for file access |
| `defaultMode` | string | Default permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `disableBypassPermissionsMode` | string | `"disable"` to prevent `bypassPermissions` from being activated |
| `skipDangerousModePermissionPrompt` | boolean | Skip confirmation before entering bypass permissions mode |

### Permission rule syntax

Rules follow the format `Tool` or `Tool(specifier)`. **Deny rules win first, then ask, then allow. First match wins.**

| Rule | Effect |
|---|---|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Read(./.env)` | Matches reading `.env` |
| `Read(./secrets/**)` | Matches any file under `secrets/` |
| `WebFetch(domain:example.com)` | Matches fetch requests to example.com |
| `Edit(*.ts)` | Matches TypeScript file edits |

**Path prefix conventions for Read/Edit rules:**
- `//path` — absolute path
- `/path` — project-relative (from project root)
- `./path` or `path` — also project-relative

**Sandbox path prefix conventions (different from Read/Edit):**
- `/path` — absolute
- `~/path` — relative to home
- `./path` or no prefix — relative to project root (project settings) or `~/.claude` (user settings)

### Sandbox settings (under `sandbox` key)

| Key | Notes |
|---|---|
| `sandbox.enabled` | Enable bash sandboxing. Default: `false` |
| `sandbox.failIfUnavailable` | Exit with error if sandbox requested but unavailable. Default: `false` |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash when sandboxed. Default: `true` |
| `sandbox.excludedCommands` | Commands to run outside sandbox. Example: `["docker *"]` |
| `sandbox.allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch. Default: `true` |
| `sandbox.filesystem.allowWrite` | Additional paths sandboxed commands can write |
| `sandbox.filesystem.denyWrite` | Paths sandboxed commands cannot write |
| `sandbox.filesystem.denyRead` | Paths sandboxed commands cannot read |
| `sandbox.filesystem.allowRead` | Re-allow reading within `denyRead` regions |
| `sandbox.filesystem.allowManagedReadPathsOnly` | (Managed) Only managed `allowRead` paths respected. Default: `false` |
| `sandbox.network.allowedDomains` | Allow outbound traffic to these domains. Wildcards supported |
| `sandbox.network.deniedDomains` | Block outbound traffic to these domains. Takes precedence over `allowedDomains` |
| `sandbox.network.allowManagedDomainsOnly` | (Managed) Only managed `allowedDomains` respected. Default: `false` |
| `sandbox.network.allowUnixSockets` | (macOS only) Unix socket paths accessible in sandbox |
| `sandbox.network.allowAllUnixSockets` | Allow all Unix socket connections. Default: `false` |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost ports (macOS only). Default: `false` |
| `sandbox.network.httpProxyPort` | HTTP proxy port for bring-your-own proxy |
| `sandbox.network.socksProxyPort` | SOCKS5 proxy port |
| `sandbox.enableWeakerNestedSandbox` | Enable weaker sandbox for unprivileged Docker (Linux/WSL2). Default: `false` |
| `sandbox.bwrapPath` | (Managed, Linux/WSL2) Absolute path to `bwrap` binary |
| `sandbox.socatPath` | (Managed, Linux/WSL2) Absolute path to `socat` binary |

## `env` injection

Env vars in `settings.json`'s `env` object are injected into every session. Example:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp"
  }
}
```

To disable a feature via env var in settings: add `"CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1"` etc. See [env-vars reference](https://code.claude.com/docs/en/env-vars.md) for the full list.

## `hooks` block

Cross-reference: full hook event reference in [`SKILL-hooks.md`](SKILL-hooks.md).

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/lint.sh"
          }
        ]
      }
    ]
  }
}
```

## `model` selection and overrides

Override the default model at any scope:

```json
{
  "model": "claude-opus-4-7"
}
```

Model aliases: `sonnet`, `opus`, `haiku` resolve to the latest respective versions. Full model IDs like `claude-sonnet-4-6` pin to a specific version.

For Bedrock, use `modelOverrides` to map Anthropic model IDs to inference profile ARNs:

```json
{
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-1::foundation-model/..."
  }
}
```

## Attribution settings

```json
{
  "attribution": {
    "commit": "🤖 Generated with [Claude Code](https://claude.com/claude-code)\n\nCo-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>",
    "pr": "🤖 Generated with [Claude Code](https://claude.com/claude-code)"
  }
}
```

Empty string hides attribution. `attribution` supersedes the deprecated `includeCoAuthoredBy`.

## File suggestion settings

Configure a custom `@` file autocomplete command:

```json
{
  "fileSuggestion": {
    "type": "command",
    "command": "~/.claude/file-suggestion.sh"
  }
}
```

The script receives `{"query": "src/comp"}` on stdin and outputs newline-separated file paths (max 15).

## Minimal valid `settings.json`

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-6",
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(npm run test *)"],
    "deny": ["Bash(curl *)", "Read(./.env)"]
  }
}
```

## `enabledPlugins`

Cross-reference: plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

```json
{
  "enabledPlugins": {
    "code-review@claude-plugins-official": true
  }
}
```

## Common mistakes (auto-corrected by `rules/settings.md`)

- Putting `autoConnectIde`, `autoInstallIdeExtension`, etc. in `settings.json` instead of `~/.claude.json` — those are global config keys that live only in `~/.claude.json`.
- Using `includeCoAuthoredBy` — deprecated; use `attribution` object instead.
- Using single-slash `/path` in Read/Edit permission rules intending absolute path — use `//path` for absolute, `/path` for project-relative in rule syntax.

---

*Source: [code.claude.com/docs/en/settings.md](https://code.claude.com/docs/en/settings.md), [permissions.md](https://code.claude.com/docs/en/permissions.md), [permission-modes.md](https://code.claude.com/docs/en/permission-modes.md)*
