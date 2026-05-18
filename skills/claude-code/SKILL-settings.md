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

| Scope | Path | Shared? | Who sets it |
|---|---|---|---|
| **Managed** | OS policy / `managed-settings.json` / server-managed | Yes (IT-deployed) | Admins only; cannot be overridden |
| **User** | `~/.claude/settings.json` | No | Personal, all projects |
| **Project** | `.claude/settings.json` | Yes (committed) | Team-shared |
| **Local** | `.claude/settings.local.json` | No (gitignored) | Personal override for one project |

Priority (highest first): **Managed → CLI args → Local → Project → User**

For permission rules, scopes *merge* (all matching rules apply) rather than override. See [`SKILL-cli.md`](SKILL-cli.md) for `--permission-mode` flag.

### File locations

| Feature | User | Project | Local |
|---|---|---|---|
| Settings | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| MCP servers | `~/.claude.json` | `.mcp.json` | `~/.claude.json` (per-project) |
| Subagents | `~/.claude/agents/` | `.claude/agents/` | — |
| Plugins | via `settings.json` | via `settings.json` | via `settings.local.json` |
| CLAUDE.md | `~/.claude/CLAUDE.md` | `CLAUDE.md` or `.claude/CLAUDE.md` | `CLAUDE.local.md` |

On Windows, `~/.claude` resolves to `%USERPROFILE%\.claude`.

### Managed settings delivery mechanisms

- **Server-managed**: delivered from Anthropic servers via Claude.ai admin console
- **macOS MDM**: `com.anthropic.claudecode` plist via Jamf/Kandji/similar
- **Windows GPO/Intune**: `HKLM\SOFTWARE\Policies\ClaudeCode` registry key (`Settings` REG_SZ/REG_EXPAND_SZ)
- **File-based**: `managed-settings.json` at `/Library/Application Support/ClaudeCode/` (macOS), `/etc/claude-code/` (Linux/WSL), `C:\Program Files\ClaudeCode\` (Windows)
  - Drop-in directory: `managed-settings.d/*.json` — sorted alphabetically, merged on top; scalars override, arrays concatenate/de-dup, objects deep-merge
  - Legacy Windows path `C:\ProgramData\ClaudeCode\managed-settings.json` removed as of v2.1.75

Starter MDM templates (Jamf, Kandji, Intune, Group Policy): https://github.com/anthropics/claude-code/tree/main/examples/mdm

`~/.claude.json` stores OAuth session, user/local MCP configs, per-project state (allowed tools, trust), and caches. JSON schema for autocomplete: https://json.schemastore.org/claude-code-settings.json

## Top-level settings keys

| Key | Type | Default | Notes |
|---|---|---|---|
| `agent` | string | — | Run main thread as named subagent; applies its system prompt, tool restrictions, and model |
| `allowedChannelPlugins` | array | — | *Managed only.* Allowlist of channel plugins. `undefined`=default, `[]`=block all. Requires `channelsEnabled: true` |
| `allowedHttpHookUrls` | array | — | URL patterns HTTP hooks may target. `*` wildcard. `undefined`=no restriction, `[]`=block all. Merges across scopes |
| `allowedMcpServers` | array | — | *Managed only.* MCP server allowlist. `undefined`=no restriction, `[]`=lockdown. Denylist takes precedence |
| `allowManagedHooksOnly` | bool | — | *Managed only.* Only managed/SDK/force-enabled plugin hooks load; user/project/other plugin hooks blocked |
| `allowManagedMcpServersOnly` | bool | — | *Managed only.* Only managed `allowedMcpServers` respected; users can still add but only allowlist applies |
| `allowManagedPermissionRulesOnly` | bool | — | *Managed only.* Prevent user/project from defining allow/ask/deny rules |
| `alwaysThinkingEnabled` | bool | false | Enable extended thinking by default. Prefer `/config`. Disable via `CLAUDE_CODE_DISABLE_THINKING` env var |
| `apiKeyHelper` | string | — | Shell script (`/bin/sh`) generating auth value sent as `X-Api-Key` and `Authorization: Bearer`. Refresh interval: `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` |
| `attribution` | object | — | Customize git commit/PR attribution. Keys: `commit` (string), `pr` (string). Replaces deprecated `includeCoAuthoredBy` |
| `autoMemoryDirectory` | string | — | Custom auto-memory path (absolute or `~/`-prefixed). Accepted from managed/user/`--settings` only; not project/local |
| `autoMemoryEnabled` | bool | true | Enable/disable auto memory. Toggle with `/memory`. Disable via `CLAUDE_CODE_DISABLE_AUTO_MEMORY` env var |
| `autoMode` | object | — | Customize auto mode classifier. Keys: `environment`, `allow`, `soft_deny`, `hard_deny` (arrays of prose rules). Include `"$defaults"` to inherit built-ins. Not read from shared project settings |
| `autoScrollEnabled` | bool | true | Follow new output in fullscreen rendering. Permission prompts still scroll into view when off |
| `autoUpdatesChannel` | string | `"latest"` | `"stable"` (≈1 week behind, skips regressions) or `"latest"`. Disable updates: set `DISABLE_AUTOUPDATER` in `env` |
| `availableModels` | array | — | Restrict models selectable via `/model`, `--model`, or `ANTHROPIC_MODEL`. Does not affect Default option |
| `awaySummaryEnabled` | bool | true | Show one-line recap on return after minutes away. Same as `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` |
| `awsAuthRefresh` | string | — | Script to modify `.aws` directory for credential refresh (Bedrock) |
| `awsCredentialExport` | string | — | Script outputting JSON with AWS credentials (Bedrock) |
| `blockedMarketplaces` | array | — | *Managed only.* Blocklist of marketplace sources. Checked before downloading |
| `channelsEnabled` | bool | — | *Managed only.* Allow channels. Team/Enterprise: blocked when unset/false. API key auth: allowed by default unless managed settings deployed |
| `claudeMd` | string | — | *Managed only.* CLAUDE.md-style instructions injected as org-managed memory |
| `claudeMdExcludes` | array | — | Glob patterns/absolute paths of CLAUDE.md files to skip. Only applies to user/project/local memory |
| `cleanupPeriodDays` | number | 30 | Session files older than N days deleted at startup (min 1, `0` rejected). Also controls orphaned subagent worktree age cutoff |
| `companyAnnouncements` | array | — | Messages shown at startup (cycled randomly) |
| `defaultShell` | string | `"bash"` | Default shell for `!` commands: `"bash"` or `"powershell"`. PowerShell requires `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` |
| `deniedMcpServers` | array | — | *Managed only.* MCP server denylist. Applies to all scopes including managed. Takes precedence over allowlist |
| `disableAgentView` | bool | false | Disable background agents and agent view. Same as `CLAUDE_CODE_DISABLE_AGENT_VIEW=1` |
| `disableAllHooks` | bool | false | Disable all hooks and custom status line |
| `disableAutoMode` | string | — | Set `"disable"` to prevent auto mode activation; removes from Shift+Tab cycle |
| `disableDeepLinkRegistration` | string | — | Set `"disable"` to prevent `claude-cli://` protocol handler registration |
| `disabledMcpjsonServers` | array | — | Specific `.mcp.json` servers to reject by name |
| `disableRemoteControl` | bool | — | Disable Remote Control. Requires v2.1.128+ |
| `disableSkillShellExecution` | bool | false | Disable inline `!`-shell in skills/commands from user/project/plugin sources. Bundled/managed skills unaffected |
| `editorMode` | string | `"normal"` | Input prompt key binding: `"normal"` or `"vim"` |
| `effortLevel` | string | — | Persist effort level across sessions: `"low"`, `"medium"`, `"high"`, `"xhigh"`. Written by `/effort`. Override: `--effort` or `CLAUDE_CODE_EFFORT_LEVEL` |
| `enableAllProjectMcpServers` | bool | false | Auto-approve all project `.mcp.json` servers |
| `enabledMcpjsonServers` | array | — | Specific `.mcp.json` servers to approve by name |
| `env` | object | `{}` | Environment variables injected into every session |
| `fastModePerSessionOptIn` | bool | false | Fast mode doesn't persist; each session starts with it off |
| `feedbackSurveyRate` | number | — | Probability (0–1) session quality survey appears. `0` suppresses entirely. Set `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` in `env` |
| `fileSuggestion` | object | — | Custom script for `@` autocomplete: `{"type": "command", "command": "~/.claude/file-suggestion.sh"}` |
| `forceLoginMethod` | string | — | `"claudeai"` (Claude.ai accounts only) or `"console"` (Console/API accounts only) |
| `forceLoginOrgUUID` | string \| array | — | Require login to specific org UUID(s). Empty array fails closed |
| `forceRemoteSettingsRefresh` | bool | — | *Managed only.* Block startup until remote managed settings freshly fetched |
| `gcpAuthRefresh` | string | — | Script to refresh GCP Application Default Credentials (Vertex AI) |
| `hooks` | object | `{}` | Hook event handlers. Full reference: [`SKILL-hooks.md`](SKILL-hooks.md) |
| `httpHookAllowedEnvVars` | array | — | Allowlist of env var names HTTP hooks may interpolate into headers. Merges across scopes |
| `includeCoAuthoredBy` | bool | true | **Deprecated.** Use `attribution` instead. Co-authored-by byline in git commits/PRs |
| `includeGitInstructions` | bool | true | Include built-in commit/PR workflow instructions and git status in system prompt |
| `language` | string | — | Claude's preferred response language (e.g., `"japanese"`). Also sets voice dictation language |
| `maxSkillDescriptionChars` | number | 1536 | Per-skill char cap on description+when_to_use text. Requires v2.1.105+ |
| `minimumVersion` | string | — | Floor version; prevents auto-updates/`claude update` from going below this |
| `model` | string | account default | Override default model. Override for one session: `--model` or `ANTHROPIC_MODEL` |
| `modelOverrides` | object | — | Map Anthropic model IDs to provider-specific IDs (e.g., Bedrock ARNs) |
| `otelHeadersHelper` | string | — | Script to generate dynamic OpenTelemetry headers. Refresh: `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS` |
| `outputStyle` | string | — | Output style name to adjust system prompt. See output-styles docs |
| `parentSettingsBehavior` | string | `"first-wins"` | *Managed only.* Controls SDK/IDE parent settings vs admin tier: `"first-wins"` or `"merge"`. Requires v2.1.133+ |
| `permissions` | object | `{}` | Tool permission rules (allow/ask/deny/additionalDirectories/defaultMode). See § *permissions block* |
| `plansDirectory` | string | `~/.claude/plans` | Where plan files are stored (relative to project root or absolute) |
| `pluginTrustMessage` | string | — | *Managed only.* Custom message appended to plugin trust warning |
| `policyHelper` | object | — | *Managed only.* Admin-deployed executable to compute managed settings dynamically. Only from MDM/system file. Requires v2.1.136+ |
| `preferredNotifChannel` | string | `"auto"` | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, `"iterm2_with_bell"`, `"kitty"`, `"ghostty"`, `"notifications_disabled"` |
| `prefersReducedMotion` | bool | false | Reduce UI animations for accessibility |
| `prUrlTemplate` | string | — | URL template for PR badge. Variables: `{host}`, `{owner}`, `{repo}`, `{number}`, `{url}` |
| `respectGitignore` | bool | true | `@` file picker respects `.gitignore` patterns |
| `showClearContextOnPlanAccept` | bool | false | Show "clear context" option on plan accept screen |
| `showThinkingSummaries` | bool | false | Show extended thinking summaries in interactive sessions (non-interactive always receives them) |
| `showTurnDuration` | bool | true | Show turn duration messages (e.g., "Cooked for 1m 6s") |
| `skillListingBudgetFraction` | number | 0.01 | Fraction of context window for skill listing. Requires v2.1.105+ |
| `skillOverrides` | object | — | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"`. Written by `/skills` menu. Requires v2.1.129+ |
| `skipWebFetchPreflight` | bool | false | Skip WebFetch domain safety check. Use in air-gapped Bedrock/Vertex/Foundry environments |
| `spinnerTipsEnabled` | bool | true | Show tips in spinner while Claude works |
| `spinnerTipsOverride` | object | — | Custom spinner tips: `{"tips": [...], "excludeDefault": bool}` |
| `spinnerVerbs` | object | — | Custom action verbs: `{"mode": "replace"|"append", "verbs": [...]}` |
| `sshConfigs` | array | — | SSH connections for Desktop env dropdown. Fields: `id`, `name`, `sshHost` (required); `sshPort`, `sshIdentityFile`, `startDirectory` (optional). Managed/user only |
| `statusLine` | object | — | Custom status line: `{"type": "command", "command": "path/to/script.sh"}` |
| `strictKnownMarketplaces` | array | — | *Managed only.* Allowlist of plugin marketplace sources. `undefined`=no restrictions, `[]`=lockdown |
| `syntaxHighlightingDisabled` | bool | false | Disable syntax highlighting in diffs/code blocks |
| `teammateMode` | string | `"auto"` | Agent team display: `"auto"`, `"in-process"`, or `"tmux"`. Override: `--teammate-mode` |
| `terminalProgressBarEnabled` | bool | true | Show terminal progress bar (ConEmu, Ghostty 1.2.0+, iTerm2 3.6.6+) |
| `tui` | string | `"default"` | TUI renderer: `"fullscreen"` (alt-screen, no flicker) or `"default"` (classic). Set via `/tui` or `CLAUDE_CODE_NO_FLICKER` |
| `useAutoModeDuringPlan` | bool | true | Plan mode uses auto mode semantics when available. Not read from shared project settings |
| `viewMode` | string | `"default"` | Default transcript view: `"default"`, `"verbose"`, `"focus"`. `--verbose` overrides for one session |
| `voice` | object | — | Voice dictation: `{"enabled": bool, "mode": "hold"|"tap", "autoSubmit": bool}`. Written by `/voice` |
| `voiceEnabled` | bool | — | **Deprecated.** Use `voice.enabled` |
| `wslInheritsWindowsSettings` | bool | — | *Windows managed only.* WSL reads managed settings from Windows policy chain |

### `worktree.*` settings

| Key | Default | Notes |
|---|---|---|
| `worktree.baseRef` | `"fresh"` | `"fresh"` (branch from `origin/<default>`) or `"head"` (branch from local HEAD). Applies to `--worktree`, `EnterWorktree`, subagent isolation |
| `worktree.symlinkDirectories` | `[]` | Directories to symlink from main repo into each worktree (e.g., `["node_modules"]`) |
| `worktree.sparsePaths` | `[]` | Directories for git sparse-checkout in each worktree |

To copy gitignored files (e.g., `.env`) into new worktrees, use a `.worktreeinclude` file at the project root.

### Global config keys (`~/.claude.json` only)

These go in `~/.claude.json`, NOT `settings.json`. Adding them to `settings.json` triggers a schema validation error.

| Key | Default | Notes |
|---|---|---|
| `autoConnectIde` | false | Auto-connect to running IDE on startup. Override: `CLAUDE_CODE_AUTO_CONNECT_IDE` |
| `autoInstallIdeExtension` | true | Auto-install IDE extension in VS Code terminals. Override: `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` |
| `externalEditorContext` | false | Prepend Claude's last response as `#`-comments when opening external editor via Ctrl+G |
| `teammateDefaultModel` | — | Default model for agent team teammates. E.g., `"sonnet"` or `null` to inherit lead's model |

*Note: Before v2.1.119, `autoScrollEnabled`, `editorMode`, `showTurnDuration`, `teammateMode`, and `terminalProgressBarEnabled` were stored in `~/.claude.json` instead.*

## `permissions` block

The `permissions` key in `settings.json` configures tool-use rules. Cross-reference: full permission mode semantics in [`SKILL-cli.md`](SKILL-cli.md).

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Read(~/.zshrc)"],
    "ask": ["Bash(git push *)"],
    "deny": ["WebFetch", "Bash(curl *)", "Read(./.env)"],
    "additionalDirectories": ["../docs/"],
    "defaultMode": "acceptEdits",
    "disableBypassPermissionsMode": "disable",
    "skipDangerousModePermissionPrompt": false
  }
}
```

| Key | Type | Notes |
|---|---|---|
| `allow` | array | Rules to auto-allow. See § *rule syntax* |
| `ask` | array | Rules to prompt for confirmation |
| `deny` | array | Rules to auto-deny |
| `additionalDirectories` | array | Extra working directories for file access. Configuration is not auto-discovered from these paths |
| `defaultMode` | string | Default permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. Override: `--permission-mode` |
| `disableBypassPermissionsMode` | string | Set `"disable"` to prevent `bypassPermissions` mode. Disables `--dangerously-skip-permissions` |
| `skipDangerousModePermissionPrompt` | bool | Skip confirmation before entering bypass mode. Ignored in project settings (prevents repo-supplied bypass) |

### Permission rule syntax

Format: `Tool` or `Tool(specifier)`

Evaluation order: **deny → ask → allow** (first match wins)

| Pattern | Matches |
|---|---|
| `Bash` | All Bash commands |
| `Bash(git *)` | Commands starting with `git ` |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Read(./.env)` | Reading exactly `.env` in project root |
| `Read(./secrets/**)` | All files under `secrets/` recursively |
| `Read(~/.zshrc)` | User's `.zshrc` |
| `WebFetch(domain:example.com)` | Fetches from example.com |
| `mcp__github` | All tools from `github` MCP server |
| `mcp__github__search_repositories` | Specific MCP tool |
| `Agent(code-reviewer)` | Named subagent |

**Path patterns (Read/Edit/Write):** use gitignore syntax. `//` = filesystem root, `~/` = home, `/` = project root, no prefix = current dir. `**` = recursive, `*` = single dir.

**Compound Bash commands:** each subcommand after `&&`, `||`, `;`, `|` must independently match.

**Protected paths** (never auto-approved except in `bypassPermissions`): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `commands/`, `agents/`, `skills/`, `worktrees/`), and files: `.gitconfig`, `.gitmodules`, `.bashrc`, `.zshrc`, `.profile`, `.mcp.json`, `.claude.json`, `.ripgreprc`.

## `env` injection

Environment variables set in `env` are injected into every tool call:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

`env` in `settings.json` merges across scopes (project + user both apply). The `env` block in a project `.claude/settings.json` is a common way to set project-specific environment variables for all team members.

## `hooks` block

Hooks are declared inline under the `hooks` key. Full event catalog, input/output shapes, and matcher syntax: [`SKILL-hooks.md`](SKILL-hooks.md).

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "~/.claude/hooks/log-bash.sh"}]
      }
    ]
  }
}
```

## `model` selection and overrides

- `model` key: override default model for all sessions in this scope
- `availableModels`: restrict which models users can pick
- `modelOverrides`: map Anthropic model IDs to provider-specific IDs (Bedrock ARNs, Vertex endpoints)

Example (`settings.json`):
```json
{
  "model": "claude-sonnet-4-6",
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-opus-4-6"
  }
}
```

## `enabledPlugins`

Plugins are enabled/disabled via the `/plugin` command. The `enabledPlugins` map is written automatically. Format:

```json
{
  "enabledPlugins": {
    "my-plugin@https://github.com/example/plugins": true
  }
}
```

Force-enable/disable a plugin for all users via managed settings `enabledPlugins`. Plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

## Minimal valid `settings.json`

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-6"
}
```

---

*Source pages: [`code.claude.com/docs/en/settings.md`](https://code.claude.com/docs/en/settings.md)*
