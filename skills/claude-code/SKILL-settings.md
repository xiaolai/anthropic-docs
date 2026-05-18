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

Source: [`code.claude.com/docs/en/settings.md`](https://code.claude.com/docs/en/settings.md)

## Scope precedence

| Scope | Path | Tracked in git? | Use case |
|---|---|---|---|
| managed | Server-managed, MDM plist/registry, or system `managed-settings.json` | n/a (admin-set) | enterprise policy, cannot be overridden |
| (CLI args) | `--settings <file-or-json>` | n/a | temporary session overrides |
| local | `<project>/.claude/settings.local.json` | gitignored | personal overrides for this project |
| project | `<project>/.claude/settings.json` | yes | team-shared settings |
| user | `~/.claude/settings.json` | n/a | personal defaults across all projects |

Higher-priority scope overrides lower-priority for scalar values; **arrays concatenate and deduplicate** across scopes (e.g. `permissions.allow` entries from all scopes are merged). The `managed` scope is highest and cannot be overridden by any other level.

### Scope paths by platform

| Feature | User | Project | Local |
|---|---|---|---|
| Settings | `~/.claude/settings.json` | `.claude/settings.json` | `.claude/settings.local.json` |
| MCP servers | `~/.claude.json` | `.mcp.json` | `~/.claude.json` (per-project) |
| CLAUDE.md | `~/.claude/CLAUDE.md` | `CLAUDE.md` or `.claude/CLAUDE.md` | `CLAUDE.local.md` |

On Windows, `~/.claude` resolves to `%USERPROFILE%\.claude`.

### Managed settings delivery channels

* **Server-managed**: delivered via Claude.ai admin console
* **macOS MDM**: `com.anthropic.claudecode` managed preferences domain (Jamf, Kandji, etc.)
* **Windows registry**: `HKLM\SOFTWARE\Policies\ClaudeCode` (REG_SZ/REG_EXPAND_SZ containing JSON)
* **Windows user registry**: `HKCU\SOFTWARE\Policies\ClaudeCode` (lowest policy priority)
* **File-based**:
  * macOS: `/Library/Application Support/ClaudeCode/managed-settings.json`
  * Linux/WSL: `/etc/claude-code/managed-settings.json`
  * Windows: `C:\Program Files\ClaudeCode\managed-settings.json` (legacy `C:\ProgramData\ClaudeCode\` deprecated since v2.1.75)
* **Drop-in directory**: `managed-settings.d/*.json` alongside `managed-settings.json`; sorted alphabetically, merged on top. Use numeric prefixes like `10-telemetry.json` to control order.

## `$schema` validation

Add `"$schema": "https://json.schemastore.org/claude-code-settings.json"` to get autocomplete and inline validation in VS Code, Cursor, and any JSON-schema–aware editor.

## Top-level keys (settings.json)

| Key | Description | Example |
|---|---|---|
| `agent` | Run the main thread as a named subagent. Applies that subagent's system prompt, tool restrictions, and model | `"code-reviewer"` |
| `allowedChannelPlugins` | (Managed only) Allowlist of channel plugins. Replaces Anthropic default when set. Empty array = block all. Requires `channelsEnabled: true` | `[{"marketplace":"claude-plugins-official","plugin":"telegram"}]` |
| `allowedHttpHookUrls` | Allowlist of URL patterns for HTTP hooks. `*` wildcard. Empty = block all | `["https://hooks.example.com/*"]` |
| `allowedMcpServers` | (Managed only) Allowlist of MCP servers users can configure. Empty = lockdown | `[{"serverName":"github"}]` |
| `allowManagedHooksOnly` | (Managed only) Only managed hooks and plugins force-enabled in managed `enabledPlugins` are loaded | `true` |
| `allowManagedMcpServersOnly` | (Managed only) Only `allowedMcpServers` from managed settings respected | `true` |
| `allowManagedPermissionRulesOnly` | (Managed only) Prevent user/project from defining allow/ask/deny rules | `true` |
| `alwaysThinkingEnabled` | Enable extended thinking by default | `true` |
| `apiKeyHelper` | Script run in `/bin/sh` to generate auth value sent as `X-Api-Key` | `"/bin/generate_temp_api_key.sh"` |
| `attribution` | Customize git commit and PR attribution. `commit` and `pr` string fields. Empty string hides attribution | `{"commit":"Generated with AI","pr":""}` |
| `autoMemoryDirectory` | Custom directory for auto memory storage. Absolute or `~/`-prefixed path | `"~/my-memory-dir"` |
| `autoMemoryEnabled` | Enable/disable auto memory. Default: `true` | `false` |
| `autoMode` | Customize auto mode classifier. Contains `environment`, `allow`, `soft_deny`, `hard_deny` arrays. Include `"$defaults"` to inherit built-in rules | `{"soft_deny":["$defaults","Never run terraform apply"]}` |
| `autoScrollEnabled` | In fullscreen rendering, follow new output to bottom. Default: `true` | `false` |
| `autoUpdatesChannel` | Release channel: `"stable"` (1 week behind, skips regressions) or `"latest"` (default) | `"stable"` |
| `availableModels` | Restrict models selectable via `/model`, `--model`, or `ANTHROPIC_MODEL` | `["sonnet","haiku"]` |
| `awaySummaryEnabled` | Show one-line session recap when returning to terminal | `true` |
| `awsAuthRefresh` | Script to modify `.aws` directory for Bedrock credential refresh | `"aws sso login --profile myprofile"` |
| `awsCredentialExport` | Script outputting JSON with AWS credentials | `"/bin/generate_aws_grant.sh"` |
| `blockedMarketplaces` | (Managed only) Blocklist of marketplace sources | `[{"source":"github","repo":"untrusted/plugins"}]` |
| `channelsEnabled` | (Managed only) Allow channels for the organization | `true` |
| `claudeMd` | (Managed only) CLAUDE.md-style instructions as org-managed memory | `"Always run make lint before committing."` |
| `claudeMdExcludes` | Glob patterns of CLAUDE.md files to skip | `["**/vendor/**/CLAUDE.md"]` |
| `cleanupPeriodDays` | Session files older than N days deleted at startup. Default: 30, min: 1 | `20` |
| `companyAnnouncements` | Announcement(s) displayed at startup. Multiple announcements cycle randomly | `["Welcome to Acme Corp!"]` |
| `defaultShell` | Default shell for `!` commands. `"bash"` (default) or `"powershell"` | `"powershell"` |
| `deniedMcpServers` | (Managed only) Denylist of MCP servers. Takes precedence over allowlist | `[{"serverName":"filesystem"}]` |
| `disableAgentView` | Disable background agents/agent view. Equivalent to `CLAUDE_CODE_DISABLE_AGENT_VIEW=1` | `true` |
| `disableAllHooks` | Disable all hooks and custom status line | `true` |
| `disableAutoMode` | Set to `"disable"` to prevent auto mode activation | `"disable"` |
| `disableDeepLinkRegistration` | Set to `"disable"` to prevent `claude-cli://` protocol handler registration | `"disable"` |
| `disabledMcpjsonServers` | List of specific servers from `.mcp.json` to reject | `["filesystem"]` |
| `disableRemoteControl` | Disable Remote Control (requires v2.1.128+) | `true` |
| `disableSkillShellExecution` | Disable inline shell execution in skills/commands from user/project/plugin sources | `true` |
| `editorMode` | Key binding mode: `"normal"` (default) or `"vim"` | `"vim"` |
| `effortLevel` | Persist effort level across sessions: `"low"`, `"medium"`, `"high"`, `"xhigh"` | `"xhigh"` |
| `enableAllProjectMcpServers` | Auto-approve all MCP servers in project `.mcp.json` | `true` |
| `enabledMcpjsonServers` | List of specific servers from `.mcp.json` to approve | `["memory","github"]` |
| `enabledPlugins` | Map of `"<plugin>@<marketplace>"` → boolean. Controls plugin enable/disable | `{"formatter@acme-tools":true}` |
| `env` | Environment variables applied to every session | `{"FOO":"bar"}` |
| `extraKnownMarketplaces` | Additional marketplaces available for the repository. Prompts team members to install | `{"acme-tools":{"source":{"source":"github","repo":"acme/plugins"}}}` |
| `fastModePerSessionOptIn` | When `true`, fast mode does not persist across sessions | `true` |
| `feedbackSurveyRate` | Probability (0–1) that quality survey appears. Set `0` to suppress | `0.05` |
| `fileSuggestion` | Custom script for `@` file path autocomplete | `{"type":"command","command":"~/.claude/file-suggestion.sh"}` |
| `forceLoginMethod` | `"claudeai"` restricts to Claude.ai accounts; `"console"` to Console accounts | `"claudeai"` |
| `forceLoginOrgUUID` | Require login to belong to specific org UUID(s) | `"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"` |
| `forceRemoteSettingsRefresh` | (Managed only) Block CLI startup until remote settings freshly fetched | `true` |
| `gcpAuthRefresh` | Script that refreshes GCP Application Default Credentials | `"gcloud auth application-default login"` |
| `hooks` | Configure hook event handlers. See [`SKILL-hooks.md`](SKILL-hooks.md) for format | See hooks reference |
| `httpHookAllowedEnvVars` | Allowlist of env var names HTTP hooks may interpolate into headers | `["MY_TOKEN","HOOK_SECRET"]` |
| `includeCoAuthoredBy` | **Deprecated**: use `attribution`. Whether to include co-authored-by. Default: `true` | `false` |
| `includeGitInstructions` | Include built-in git commit/PR instructions in system prompt. Default: `true` | `false` |
| `language` | Claude's preferred response language | `"japanese"` |
| `maxSkillDescriptionChars` | Per-skill character cap on description+when_to_use text. Default: `1536`. Requires v2.1.105+ | `2048` |
| `minimumVersion` | Floor preventing auto-updates below this version | `"2.1.100"` |
| `model` | Override default model. Overridden by `--model` and `ANTHROPIC_MODEL` | `"claude-sonnet-4-6"` |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs (e.g. Bedrock ARNs) | `{"claude-opus-4-6":"arn:aws:bedrock:..."}` |
| `otelHeadersHelper` | Script to generate dynamic OpenTelemetry headers | `"/bin/generate_otel_headers.sh"` |
| `outputStyle` | Output style for system prompt adjustment. See output-styles docs | `"Explanatory"` |
| `parentSettingsBehavior` | (Managed only) Controls SDK/IDE-supplied managed settings when admin tier present. `"first-wins"` (default) or `"merge"`. Requires v2.1.133+ | `"merge"` |
| `permissions` | Tool-permission rules. See § *Permission settings* below | See below |
| `plansDirectory` | Customize where plan files are stored. Relative to project root. Default: `~/.claude/plans` | `"./plans"` |
| `pluginTrustMessage` | (Managed only) Custom message appended to plugin trust warning | `"All plugins from our marketplace are approved by IT"` |
| `policyHelper` | (Managed only, MDM/system file only) Executable that computes managed settings dynamically. Requires v2.1.136+ | `{"path":"/usr/local/bin/claude-policy"}` |
| `preferredNotifChannel` | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, `"iterm2_with_bell"`, `"kitty"`, `"ghostty"`, `"notifications_disabled"` | `"terminal_bell"` |
| `prefersReducedMotion` | Reduce/disable UI animations | `true` |
| `prUrlTemplate` | URL template for PR badge. Substitutes `{host}`, `{owner}`, `{repo}`, `{number}`, `{url}` | `"https://reviews.example.com/{owner}/{repo}/pull/{number}"` |
| `respectGitignore` | Whether `@` file picker respects `.gitignore`. Default: `true` | `false` |
| `showClearContextOnPlanAccept` | Show "clear context" option on plan accept screen. Default: `false` | `true` |
| `showThinkingSummaries` | Show extended thinking summaries in interactive sessions. Default: `false` | `true` |
| `showTurnDuration` | Show turn duration after responses. Default: `true` | `false` |
| `skillListingBudgetFraction` | Fraction of context window for skill listing. Default: `0.01`. Requires v2.1.105+ | `0.02` |
| `skillOverrides` | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"`. Requires v2.1.129+ | `{"legacy-context":"name-only","deploy":"off"}` |
| `skipWebFetchPreflight` | Skip WebFetch domain safety check (useful for Bedrock/Vertex/Foundry with restrictive egress) | `true` |
| `spinnerTipsEnabled` | Show tips in spinner. Default: `true` | `false` |
| `spinnerTipsOverride` | Override spinner tips. `tips` array, `excludeDefault` boolean | `{"excludeDefault":true,"tips":["Use our internal tool X"]}` |
| `spinnerVerbs` | Customize spinner verbs. `mode`: `"replace"` or `"append"` | `{"mode":"append","verbs":["Pondering"]}` |
| `sshConfigs` | SSH connections for Desktop environment dropdown. Each needs `id`, `name`, `sshHost` | `[{"id":"dev-vm","name":"Dev VM","sshHost":"user@dev.example.com"}]` |
| `statusLine` | Custom status line. See statusline docs | `{"type":"command","command":"~/.claude/statusline.sh"}` |
| `strictKnownMarketplaces` | (Managed only) Allowlist of plugin marketplace sources. Empty = lockdown | `[{"source":"github","repo":"acme-corp/plugins"}]` |
| `syntaxHighlightingDisabled` | Disable syntax highlighting in diffs and code blocks | `true` |
| `teammateMode` | Agent team display: `"auto"` (default), `"in-process"`, `"tmux"` | `"in-process"` |
| `terminalProgressBarEnabled` | Show terminal progress bar (ConEmu, Ghostty 1.2.0+, iTerm2 3.6.6+). Default: `true` | `false` |
| `tui` | TUI renderer: `"fullscreen"` (alt-screen, flicker-free) or `"default"` (classic) | `"fullscreen"` |
| `useAutoModeDuringPlan` | Whether plan mode uses auto mode semantics. Default: `true` | `false` |
| `viewMode` | Default transcript view: `"default"`, `"verbose"`, or `"focus"` | `"verbose"` |
| `voice` | Voice dictation settings: `enabled`, `mode` (`"hold"` or `"tap"`), `autoSubmit` | `{"enabled":true,"mode":"tap"}` |
| `wslInheritsWindowsSettings` | (Windows managed only) WSL reads managed settings from Windows policy chain | `true` |

## Global config settings (`~/.claude.json`, not `settings.json`)

> Adding these to `settings.json` triggers a schema validation error.

| Key | Description | Example |
|---|---|---|
| `autoConnectIde` | Auto-connect to running IDE on startup. Default: `false` | `true` |
| `autoInstallIdeExtension` | Auto-install Claude Code IDE extension from VS Code terminal. Default: `true` | `false` |
| `externalEditorContext` | Prepend Claude's previous response when opening external editor. Default: `false` | `true` |
| `teammateDefaultModel` | Default model for agent team teammates | `"sonnet"` |

> **Note:** Versions before v2.1.119 also stored `autoScrollEnabled`, `editorMode`, `showTurnDuration`, `teammateMode`, and `terminalProgressBarEnabled` in `~/.claude.json`.

## Worktree settings

| Key | Description | Example |
|---|---|---|
| `worktree.baseRef` | Branch new worktrees from: `"fresh"` (default, branches from `origin/<default>`) or `"head"` (from local HEAD) | `"head"` |
| `worktree.symlinkDirectories` | Directories to symlink from main repo into each worktree | `["node_modules",".cache"]` |
| `worktree.sparsePaths` | Directories to check out in each worktree via sparse-checkout | `["packages/my-app","shared/utils"]` |

## Permission settings

Nested under `permissions` key:

| Key | Description | Example |
|---|---|---|
| `allow` | Array of permission rules to allow tool use | `["Bash(git diff *)"]` |
| `ask` | Array of permission rules to ask for confirmation | `["Bash(git push *)"]` |
| `deny` | Array of permission rules to deny tool use | `["WebFetch","Bash(curl *)","Read(./.env)"]` |
| `additionalDirectories` | Additional working directories for file access | `["../docs/"]` |
| `defaultMode` | Default permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` | `"acceptEdits"` |
| `disableBypassPermissionsMode` | Set to `"disable"` to prevent `bypassPermissions` mode | `"disable"` |
| `skipDangerousModePermissionPrompt` | Skip confirmation prompt before bypass permissions mode | `true` |

### Permission rule syntax

Format: `Tool` or `Tool(specifier)`. Evaluation order: deny → ask → allow. First match wins.

| Rule | Effect |
|---|---|
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Read(./.env)` | Reading the `.env` file |
| `WebFetch(domain:example.com)` | Fetch requests to example.com |

## Sandbox settings

Nested under `sandbox` key. Controls sandboxed bash isolation:

| Key | Description | Default |
|---|---|---|
| `enabled` | Enable bash sandboxing (macOS, Linux, WSL2) | `false` |
| `failIfUnavailable` | Exit with error if sandbox cannot start | `false` |
| `autoAllowBashIfSandboxed` | Auto-approve bash commands when sandboxed | `true` |
| `excludedCommands` | Commands that run outside the sandbox | `[]` |
| `allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch | `true` |
| `filesystem.allowWrite` | Additional paths where sandboxed commands can write | `[]` |
| `filesystem.denyWrite` | Paths where sandboxed commands cannot write | `[]` |
| `filesystem.denyRead` | Paths where sandboxed commands cannot read | `[]` |
| `filesystem.allowRead` | Re-allow reading within `denyRead` regions | `[]` |
| `filesystem.allowManagedReadPathsOnly` | (Managed only) Only managed `allowRead` paths respected | `false` |
| `network.allowedDomains` | Domains allowed for outbound network traffic. Supports wildcards | `[]` |
| `network.deniedDomains` | Domains blocked for outbound network traffic | `[]` |
| `network.allowUnixSockets` | (macOS only) Unix socket paths accessible in sandbox | `[]` |
| `network.allowAllUnixSockets` | Allow all Unix socket connections | `false` |
| `network.allowLocalBinding` | Allow binding to localhost ports (macOS only) | `false` |
| `network.httpProxyPort` | HTTP proxy port (bring your own proxy) | (Claude runs its own) |
| `network.socksProxyPort` | SOCKS5 proxy port | (Claude runs its own) |
| `enableWeakerNestedSandbox` | Weaker sandbox for unprivileged Docker (Linux/WSL2). **Reduces security** | `false` |
| `bwrapPath` | (Managed, Linux/WSL2) Absolute path to `bwrap` binary | (auto-detected) |
| `socatPath` | (Managed, Linux/WSL2) Absolute path to `socat` binary | (auto-detected) |

### Sandbox path prefixes

| Prefix | Meaning |
|---|---|
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project settings) or `~/.claude` (user settings) |

## Plugin settings

Nested under `enabledPlugins` (format: `"plugin@marketplace"` → boolean) and `extraKnownMarketplaces`.

See [`SKILL-plugins.md`](SKILL-plugins.md) for full plugin lifecycle reference.

### `extraKnownMarketplaces` source types

| Source type | Fields |
|---|---|
| `github` | `repo` (required), `ref` (optional), `path` (optional) |
| `git` | `url` (required), `ref` (optional), `path` (optional) |
| `url` | `url` (required), `headers` (optional) |
| `npm` | `package` (required) |
| `file` | `path` (required, absolute path to `marketplace.json`) |
| `directory` | `path` (required, absolute path containing `.claude-plugin/marketplace.json`) |
| `hostPattern` | `hostPattern` (required, regex matched against host) |
| `settings` | `name` + `plugins` array (inline marketplace, no hosted repo needed) |

Each entry also accepts optional `autoUpdate: boolean`. Anthropic official marketplaces default `autoUpdate: true`; others default `false`.

## Attribution settings

| Key | Description |
|---|---|
| `attribution.commit` | Attribution text for git commits (supports git trailers). Empty = hide |
| `attribution.pr` | Attribution text for pull request descriptions. Empty = hide |

## Settings verification

Run `/status` inside Claude Code → "Setting sources" line shows which layers are active. Active layers appear only when loaded with at least one key.

---

*Source page: [`code.claude.com/docs/en/settings.md`](https://code.claude.com/docs/en/settings.md)*
