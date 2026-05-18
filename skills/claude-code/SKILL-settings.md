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
| managed | server/MDM/file-based (see below) | n/a (admin-set) | enterprise policy, highest priority, cannot be overridden |
| local | `<project>/.claude/settings.local.json` | no (gitignored) | personal overrides for this project |
| project | `<project>/.claude/settings.json` | yes | team-shared settings |
| user | `~/.claude/settings.json` | n/a | personal defaults across all projects |

Precedence (highest wins): **managed → command-line args → local → project → user**.

**Array-valued settings** (e.g. `permissions.allow`, `sandbox.filesystem.allowWrite`) **concatenate and deduplicate** across scopes rather than override — lower-priority arrays add entries without losing higher-priority ones.

**Managed settings** delivery options:
- **Server-managed**: via Anthropic admin console (`claude.ai`)
- **MDM/OS-level**: macOS plist (`com.anthropic.claudecode`); Windows registry (`HKLM\SOFTWARE\Policies\ClaudeCode`)
- **File-based**: `managed-settings.json` at `/Library/Application Support/ClaudeCode/` (macOS), `/etc/claude-code/` (Linux/WSL), `C:\Program Files\ClaudeCode\` (Windows); supports drop-in `managed-settings.d/*.json`

Source: `code.claude.com/docs/en/settings.md`.

## Settings files

- **User settings**: `~/.claude/settings.json`
- **Project settings**: `.claude/settings.json` (committed) and `.claude/settings.local.json` (gitignored)
- **Other config** (OAuth sessions, per-project state, user-level MCP): `~/.claude.json`

JSON schema validation (VS Code / Cursor autocomplete):
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json"
}
```

## Top-level keys

All keys belong in `settings.json` unless noted **Global config** (→ `~/.claude.json`) or **Managed only** (only honored when delivered via managed settings).

| Key | Type | Default | Scope | Notes |
|---|---|---|---|---|
| `agent` | string | — | any | Run main thread as a named subagent |
| `allowedChannelPlugins` | array | — | **Managed only** | Allowlist of channel plugins (`{marketplace, plugin}`). Undefined = default list; `[]` = block all |
| `allowedHttpHookUrls` | array | — | any | URL patterns HTTP hooks may target (`*` wildcard). Undefined = no restriction; `[]` = block all |
| `allowedMcpServers` | array | — | **Managed only** | Allowlist of MCP servers (`{serverName}`). Undefined = no restriction; `[]` = lockdown |
| `allowManagedHooksOnly` | bool | `false` | **Managed only** | Block all non-managed hooks (except force-enabled plugin hooks) |
| `allowManagedMcpServersOnly` | bool | `false` | **Managed only** | Only managed `allowedMcpServers` respected; `deniedMcpServers` still merges |
| `allowManagedPermissionRulesOnly` | bool | `false` | **Managed only** | Prevent user/project allow/ask/deny rules |
| `alwaysThinkingEnabled` | bool | `false` | any | Enable extended thinking by default |
| `apiKeyHelper` | string | — | any | Shell script to generate an auth value (`X-Api-Key` header). Set refresh with `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` |
| `attribution` | object | (see below) | any | Customize git commit and PR attribution. Keys: `commit`, `pr` (empty string hides it) |
| `autoMemoryDirectory` | string | — | user/managed | Custom directory for auto memory storage (absolute or `~/`-prefixed path) |
| `autoMemoryEnabled` | bool | `true` | any | Enable auto memory. Toggle with `/memory`. Disable via `CLAUDE_CODE_DISABLE_AUTO_MEMORY` |
| `autoMode` | object | — | any (not project) | Customize auto mode classifier: `environment`, `allow`, `soft_deny`, `hard_deny` arrays. Include `"$defaults"` to inherit built-in rules |
| `autoScrollEnabled` | bool | `true` | any | Follow new output to bottom in fullscreen rendering |
| `autoUpdatesChannel` | string | `"latest"` | any | Release channel: `"stable"` (≈1 week old) or `"latest"` |
| `availableModels` | array | — | any | Restrict models selectable via `/model`, `--model`, `ANTHROPIC_MODEL` |
| `awaySummaryEnabled` | bool | `true` | any | Show one-line session recap after being away |
| `awsAuthRefresh` | string | — | any | Script that modifies `.aws` directory (Bedrock) |
| `awsCredentialExport` | string | — | any | Script that outputs JSON with AWS credentials (Bedrock) |
| `blockedMarketplaces` | array | — | **Managed only** | Blocklist of marketplace sources. Enforced before download |
| `channelsEnabled` | bool | — | **Managed only** | Allow channels for the organization |
| `claudeMd` | string | — | **Managed only** | Org-wide CLAUDE.md instructions injected as managed memory |
| `claudeMdExcludes` | array | — | any | Glob patterns of CLAUDE.md files to skip when loading memory |
| `cleanupPeriodDays` | number | `30` | any | Delete session files older than N days (min 1). Also controls orphaned worktree cleanup |
| `companyAnnouncements` | array | — | any | Messages displayed at startup (cycled randomly) |
| `defaultShell` | string | `"bash"` | any | Default shell for `!` commands: `"bash"` or `"powershell"`. Requires `CLAUDE_CODE_USE_POWERSHELL_TOOL=1` |
| `deniedMcpServers` | array | — | **Managed only** | Denylist of MCP servers, including managed. Takes precedence over allowlist |
| `disableAgentView` | bool | `false` | any | Disable background agents and agent view. Same as `CLAUDE_CODE_DISABLE_AGENT_VIEW=1` |
| `disableAllHooks` | bool | `false` | any | Disable all hooks and custom status line |
| `disableAutoMode` | string | — | any | Set to `"disable"` to prevent auto mode activation |
| `disableDeepLinkRegistration` | string | — | any | Set to `"disable"` to prevent `claude-cli://` protocol handler registration |
| `disabledMcpjsonServers` | array | — | any | List of MCP servers from `.mcp.json` to reject |
| `disableRemoteControl` | bool | `false` | any | Disable Remote Control (requires v2.1.128+) |
| `disableSkillShellExecution` | bool | `false` | any | Disable inline shell execution in skills/commands from non-managed sources |
| `editorMode` | string | `"normal"` | any | Key binding mode: `"normal"` or `"vim"` |
| `effortLevel` | string | — | any | Persist effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"`. Written by `/effort` |
| `enableAllProjectMcpServers` | bool | `false` | any | Auto-approve all MCP servers in project `.mcp.json` files |
| `enabledMcpjsonServers` | array | — | any | List of MCP servers from `.mcp.json` files to approve |
| `env` | object | `{}` | any | Environment variables injected into every session |
| `extraKnownMarketplaces` | object | — | any | Additional marketplace sources. Keys are marketplace names; values have `source` and optional `autoUpdate` |
| `fastModePerSessionOptIn` | bool | `false` | any | Fast mode does not persist; each session starts off |
| `feedbackSurveyRate` | number | — | any | Probability (0–1) that session quality survey appears. `0` suppresses it |
| `fileSuggestion` | object | — | any | Custom command for `@` file autocomplete: `{type: "command", command: "..."}` |
| `forceLoginMethod` | string | — | managed | `"claudeai"` or `"console"` |
| `forceLoginOrgUUID` | string or array | — | managed | Require login to specific org(s) |
| `forceRemoteSettingsRefresh` | bool | `false` | **Managed only** | Block CLI startup until fresh settings fetched |
| `gcpAuthRefresh` | string | — | any | Script to refresh GCP Application Default Credentials (Vertex AI) |
| `hooks` | object | `{}` | any | Hook event handlers. Full reference: [`SKILL-hooks.md`](SKILL-hooks.md) |
| `httpHookAllowedEnvVars` | array | — | any | Allowlist of env var names HTTP hooks may interpolate into headers |
| `includeCoAuthoredBy` | bool | `true` | any | **Deprecated** — use `attribution` instead |
| `includeGitInstructions` | bool | `true` | any | Include built-in commit/PR workflow instructions in system prompt |
| `language` | string | — | any | Claude's preferred response language, e.g. `"japanese"`. Also sets voice dictation language |
| `maxSkillDescriptionChars` | number | `1536` | any | Per-skill char cap on description+when_to_use text (requires v2.1.105+) |
| `minimumVersion` | string | — | any | Floor version that prevents downgrade via auto-update or `claude update` |
| `model` | string | (account default) | any | Default model. Overridden by `--model` and `ANTHROPIC_MODEL` |
| `modelOverrides` | object | — | any | Map Anthropic model IDs to provider-specific IDs (Bedrock ARNs, etc.) |
| `otelHeadersHelper` | string | — | any | Script to generate dynamic OpenTelemetry headers at startup |
| `outputStyle` | string | — | any | Output style name to adjust system prompt |
| `parentSettingsBehavior` | string | `"first-wins"` | **Managed only** | How SDK-supplied managed settings interact with admin tier: `"first-wins"` or `"merge"` (requires v2.1.133+) |
| `permissions` | object | `{}` | any | See § *Permission settings* below |
| `plansDirectory` | string | `~/.claude/plans` | any | Where plan files are stored (relative to project root) |
| `pluginTrustMessage` | string | — | **Managed only** | Custom message appended to plugin trust warning |
| `policyHelper` | object | — | **Managed only** | Executable that computes managed settings dynamically: `{path, timeoutMs?, refreshIntervalMs?}` (requires v2.1.136+) |
| `preferredNotifChannel` | string | `"auto"` | any | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, `"iterm2_with_bell"`, `"kitty"`, `"ghostty"`, or `"notifications_disabled"` |
| `prefersReducedMotion` | bool | `false` | any | Reduce/disable UI animations |
| `prUrlTemplate` | string | — | any | URL template for PR badge. Substitutes `{host}`, `{owner}`, `{repo}`, `{number}`, `{url}` |
| `respectGitignore` | bool | `true` | any | `@` file picker respects `.gitignore` patterns |
| `showClearContextOnPlanAccept` | bool | `false` | any | Show "clear context" option on plan accept screen |
| `showThinkingSummaries` | bool | `false` | any | Show extended thinking summaries in interactive sessions |
| `showTurnDuration` | bool | `true` | any | Show turn duration messages after responses |
| `skillListingBudgetFraction` | number | `0.01` | any | Fraction of context window for skill listing (requires v2.1.105+) |
| `skillOverrides` | object | — | any | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"` (requires v2.1.129+) |
| `skipWebFetchPreflight` | bool | `false` | any | Skip WebFetch domain safety check (use for Bedrock/Vertex/Foundry with restrictive egress) |
| `spinnerTipsEnabled` | bool | `true` | any | Show tips in spinner while Claude works |
| `spinnerTipsOverride` | object | — | any | Override spinner tips: `{tips: [...], excludeDefault?: bool}` |
| `spinnerVerbs` | object | — | any | Custom verbs in spinner: `{mode: "replace"\|"append", verbs: [...]}` |
| `sshConfigs` | array | — | managed/user | SSH connections for Desktop environment dropdown |
| `statusLine` | object | — | any | Custom status line: `{type: "command", command: "..."}` |
| `strictKnownMarketplaces` | array | — | **Managed only** | Allowlist of marketplace sources. `[]` = complete lockdown |
| `syntaxHighlightingDisabled` | bool | `false` | any | Disable syntax highlighting in diffs and code blocks |
| `teammateMode` | string | `"auto"` | any | Agent team display mode: `"auto"`, `"in-process"`, or `"tmux"` |
| `terminalProgressBarEnabled` | bool | `true` | any | Show terminal progress bar in supported terminals |
| `tui` | string | `"default"` | any | TUI renderer: `"default"` or `"fullscreen"` |
| `useAutoModeDuringPlan` | bool | `true` | any (not project) | Use auto mode semantics in plan mode when available |
| `viewMode` | string | `"default"` | any | Default transcript view: `"default"`, `"verbose"`, or `"focus"` |
| `voice` | object | — | any | Voice dictation: `{enabled, mode: "hold"\|"tap", autoSubmit?}` |
| `voiceEnabled` | bool | — | any | **Legacy alias** for `voice.enabled` |
| `wslInheritsWindowsSettings` | bool | `false` | **Managed only** (HKLM/Program Files) | WSL inherits Windows managed settings |

### Global config settings (stored in `~/.claude.json`)

These go in `~/.claude.json`, not `settings.json`. Adding them to `settings.json` triggers schema validation errors.

| Key | Default | Notes |
|---|---|---|
| `autoConnectIde` | `false` | Auto-connect to running IDE on startup |
| `autoInstallIdeExtension` | `true` | Auto-install Claude Code IDE extension in VS Code terminal |
| `externalEditorContext` | `false` | Prepend Claude's last response as context when opening external editor |
| `teammateDefaultModel` | — | Default model for agent team teammates |

### Worktree settings

Nested under top-level `worktree` key:

| Key | Default | Notes |
|---|---|---|
| `worktree.baseRef` | `"fresh"` | Branch ref for new worktrees: `"fresh"` (origin/default-branch) or `"head"` (local HEAD) |
| `worktree.symlinkDirectories` | `[]` | Directories to symlink from main repo into each worktree |
| `worktree.sparsePaths` | `[]` | Directories for git sparse-checkout in each worktree |

## `permissions` block

Nested under the top-level `permissions` key:

| Key | Type | Notes |
|---|---|---|
| `allow` | array of strings | Permission rules to allow without prompting |
| `ask` | array of strings | Permission rules that always prompt |
| `deny` | array of strings | Permission rules that are blocked |
| `additionalDirectories` | array of strings | Extra working directories for file access |
| `defaultMode` | string | Default permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `disableBypassPermissionsMode` | string | Set `"disable"` to prevent bypassPermissions mode |
| `skipDangerousModePermissionPrompt` | bool | Skip confirmation before entering bypassPermissions |

**Permission rule syntax**: `Tool` or `Tool(specifier)`. See [`SKILL-cli.md`](SKILL-cli.md) § *Permission modes* and `code.claude.com/docs/en/permissions.md` for the full rule syntax.

Evaluation order: **deny → ask → allow**. First matching rule wins.

Quick examples:

| Rule | Effect |
|---|---|
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Read(./.env)` | Reading the `.env` file |
| `WebFetch(domain:example.com)` | Fetches to example.com |

## `sandbox` block

Nested under top-level `sandbox` key:

| Key | Default | Notes |
|---|---|---|
| `enabled` | `false` | Enable bash sandboxing (macOS, Linux, WSL2) |
| `failIfUnavailable` | `false` | Exit with error if sandbox cannot start |
| `autoAllowBashIfSandboxed` | `true` | Auto-approve bash when sandboxed |
| `excludedCommands` | `[]` | Commands that run outside the sandbox |
| `allowUnsandboxedCommands` | `true` | Allow `dangerouslyDisableSandbox` escape hatch |
| `filesystem.allowWrite` | `[]` | Paths sandboxed commands can write (merged across scopes) |
| `filesystem.denyWrite` | `[]` | Paths sandboxed commands cannot write |
| `filesystem.denyRead` | `[]` | Paths sandboxed commands cannot read |
| `filesystem.allowRead` | `[]` | Re-allow read within denyRead regions (takes precedence) |
| `filesystem.allowManagedReadPathsOnly` | `false` | **Managed only**: only managed allowRead paths honored |
| `network.allowedDomains` | `[]` | Domains allowed for outbound traffic (wildcard `*` supported) |
| `network.deniedDomains` | `[]` | Domains blocked (merged from all sources; takes precedence) |
| `network.allowManagedDomainsOnly` | `false` | **Managed only**: only managed allowedDomains honored |
| `network.allowUnixSockets` | `[]` | Unix socket paths accessible (macOS only) |
| `network.allowAllUnixSockets` | `false` | Allow all Unix sockets (Linux/WSL2 only way) |
| `network.allowLocalBinding` | `false` | Allow binding to localhost ports (macOS only) |
| `network.allowMachLookup` | `[]` | XPC/Mach service names (macOS only, supports trailing `*`) |
| `network.httpProxyPort` | — | HTTP proxy port (bring your own proxy) |
| `network.socksProxyPort` | — | SOCKS5 proxy port |
| `enableWeakerNestedSandbox` | `false` | Weaker sandbox for unprivileged Docker (Linux/WSL2) |
| `enableWeakerNetworkIsolation` | `false` | Allow TLS trust service in sandbox (macOS; reduces security) |
| `bwrapPath` | — | **Managed only** (Linux/WSL2): absolute path to `bwrap` binary |
| `socatPath` | — | **Managed only** (Linux/WSL2): absolute path to `socat` binary |

**Sandbox path prefixes**: `/` = absolute; `~/` = home-relative; `./` or no prefix = project-root-relative (project settings) or `~/.claude`-relative (user settings).

## `attribution` block

```json
{
  "attribution": {
    "commit": "🤖 Generated with [Claude Code](https://claude.com/claude-code)\n\n   Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>",
    "pr": "🤖 Generated with [Claude Code](https://claude.com/claude-code)"
  }
}
```

Set `"commit"` or `"pr"` to `""` to suppress attribution for that context.

## `enabledPlugins` block

Format: `"<plugin-name>@<marketplace-name>": true|false`

```json
{
  "enabledPlugins": {
    "code-formatter@team-tools": true,
    "experimental-features@personal": false
  }
}
```

- Project settings take precedence over user settings. To opt out of a project-enabled plugin, set `false` in `settings.local.json`.
- Plugins force-enabled by managed settings cannot be disabled.

## `extraKnownMarketplaces` block

Defines additional marketplace sources for the project:

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

Marketplace source types: `github` (uses `repo`), `git` (uses `url`), `url` (uses `url`), `npm` (uses `package`), `file` (uses `path`), `directory` (uses `path`), `hostPattern` (uses `hostPattern`, regex), `settings` (inline, uses `name` + `plugins`).

See also: `strictKnownMarketplaces` (managed only) in the settings keys table above.

## `env` injection

Variables under `env` are injected into every session, equivalent to shell exports. Example:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "NODE_ENV": "development"
  }
}
```

Precedence: `ANTHROPIC_*` / `CLAUDE_*` env vars set in the shell override `env` in `settings.json`. Use `env` in `settings.json` for team-wide defaults; use the shell for personal overrides.

Full env var reference: `code.claude.com/docs/en/env-vars.md`.

## Verify active settings

Run `/status` inside Claude Code → look for `Setting sources` line. Shows which layers are loaded and active. An empty list means no settings sources were found.

---

*Source pages: `code.claude.com/docs/en/settings.md`.*
