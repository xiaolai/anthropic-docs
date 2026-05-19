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
| managed | `managed-settings.json` (OS system path), MDM/plist/registry, or server-managed | n/a (admin-set) | Enterprise policy, cannot be overridden |
| local | `<project>/.claude/settings.local.json` | gitignored | Personal overrides for this project only |
| project | `<project>/.claude/settings.json` | yes | Team-shared settings |
| user | `~/.claude/settings.json` | n/a | Personal defaults across all projects |

Priority order (highest first): `managed` > command-line args > `local` > `project` > `user`. Array-valued settings (like `permissions.allow`) **concatenate and deduplicate** across scopes rather than override.

The official JSON schema is at `https://json.schemastore.org/claude-code-settings.json` — add `"$schema"` to enable editor autocomplete.

Source: `code.claude.com/docs/en/settings.md`.

## Top-level keys

All keys for `settings.json`. Keys marked *(managed only)* are only honored in managed settings. Source: `code.claude.com/docs/en/settings.md#available-settings`.

| Key | Type | Default | Notes |
|---|---|---|---|
| `agent` | string | — | Run the main thread as a named subagent. Applies that subagent's system prompt, tool restrictions, and model. |
| `allowedChannelPlugins` | array | — | *(managed only)* Allowlist of channel plugins that may push messages. Requires `channelsEnabled: true`. |
| `allowedHttpHookUrls` | array | — | Allowlist of URL patterns (supports `*`) that HTTP hooks may target. Undefined = no restriction; empty array = block all. Arrays merge across scopes. |
| `allowedMcpServers` | array | — | *(managed only)* Allowlist of MCP servers users can configure. Undefined = no restriction; empty array = lockdown. |
| `allowManagedHooksOnly` | boolean | `false` | *(managed only)* Only managed hooks, SDK hooks, and hooks from force-enabled plugins are loaded. User/project/plugin hooks are blocked. |
| `allowManagedMcpServersOnly` | boolean | `false` | *(managed only)* Only `allowedMcpServers` from managed settings are respected. |
| `allowManagedPermissionRulesOnly` | boolean | `false` | *(managed only)* Prevent user/project settings from defining allow/ask/deny permission rules. |
| `alwaysThinkingEnabled` | boolean | `false` | Enable extended thinking by default for all sessions. |
| `apiKeyHelper` | string | — | Shell script (`/bin/sh`) to generate an auth value sent as `X-Api-Key` and `Authorization: Bearer` headers. |
| `attribution` | object | — | Customize git commit and PR attribution text. Keys: `commit` (string), `pr` (string). Empty string hides attribution. |
| `autoMemoryDirectory` | string | — | Custom directory for auto memory storage. Absolute or `~/`-prefixed path. Not accepted from project/local settings. |
| `autoMemoryEnabled` | boolean | `true` | When `false`, Claude does not read from or write to the auto memory directory. |
| `autoMode` | object | — | Customize auto mode classifier. Contains `environment`, `allow`, `soft_deny`, `hard_deny` arrays. Not read from shared project settings. |
| `autoScrollEnabled` | boolean | `true` | In fullscreen rendering, follow new output to the bottom of the conversation. |
| `autoUpdatesChannel` | string | `"latest"` | Release channel: `"stable"` (one week old, skips regressions) or `"latest"` (most recent). |
| `availableModels` | array | — | Restrict which models users can select via `/model`, `--model`, or `ANTHROPIC_MODEL`. |
| `awaySummaryEnabled` | boolean | `true` | Show a one-line session recap when you return after a few minutes away. |
| `awsAuthRefresh` | string | — | Script that modifies `.aws` directory for AWS credential refresh. |
| `awsCredentialExport` | string | — | Script that outputs JSON with AWS credentials. |
| `blockedMarketplaces` | array | — | *(managed only)* Blocklist of marketplace sources; enforced before any network/filesystem operations. |
| `channelsEnabled` | boolean | `false` | *(managed only)* Allow channels for the organization. Required for Team/Enterprise claude.ai plans. |
| `claudeMd` | string | — | *(managed only)* CLAUDE.md-style instructions injected as organization-managed memory. |
| `claudeMdExcludes` | array | — | Glob patterns or absolute paths of CLAUDE.md files to skip when loading memory. |
| `cleanupPeriodDays` | number | `30` | Session files older than this are deleted at startup (minimum 1; 0 is rejected). |
| `companyAnnouncements` | array | — | Announcements displayed at startup; cycled through at random if multiple provided. |
| `defaultShell` | string | `"bash"` | Default shell for input-box `!` commands. Accepts `"bash"` or `"powershell"`. |
| `deniedMcpServers` | array | — | *(managed only)* Denylist of MCP servers blocked at all scopes. Takes precedence over allowlist. |
| `disableAgentView` | boolean | `false` | Turn off background agents and agent view. |
| `disableAllHooks` | boolean | `false` | Disable all hooks and any custom status line. |
| `disableAutoMode` | string | — | Set to `"disable"` to prevent auto mode from being activated. |
| `disableDeepLinkRegistration` | string | — | Set to `"disable"` to prevent registration of the `claude-cli://` protocol handler. |
| `disabledMcpjsonServers` | array | — | List of specific MCP servers from `.mcp.json` files to reject. |
| `disableRemoteControl` | boolean | `false` | Disable Remote Control (requires v2.1.128+). |
| `disableSkillShellExecution` | boolean | `false` | Disable inline shell execution for `` !`...` `` blocks in user/project/plugin skills. |
| `editorMode` | string | `"normal"` | Key binding mode for the input prompt: `"normal"` or `"vim"`. |
| `effortLevel` | string | — | Persist effort level across sessions: `"low"`, `"medium"`, `"high"`, `"xhigh"`. |
| `enableAllProjectMcpServers` | boolean | `false` | Automatically approve all MCP servers defined in project `.mcp.json` files. |
| `enabledMcpjsonServers` | array | — | List of specific MCP servers from `.mcp.json` files to approve. |
| `enabledPlugins` | object | `{}` | Map of `"<plugin>@<marketplace>"` → boolean. See [`SKILL-plugins.md`](SKILL-plugins.md). |
| `env` | object | `{}` | Environment variables injected into every session. See `env` injection section below. |
| `extraKnownMarketplaces` | object | — | Additional marketplaces available for the repository. See plugin configuration. |
| `fastModePerSessionOptIn` | boolean | `false` | When `true`, fast mode does not persist across sessions. |
| `feedbackSurveyRate` | number | — | Probability (0–1) that the session quality survey appears when eligible. Set to `0` to suppress. |
| `fileSuggestion` | object | — | Custom script for `@` file autocomplete. Keys: `type` (`"command"`), `command` (string). |
| `forceLoginMethod` | string | — | `"claudeai"` restricts to Claude.ai accounts; `"console"` restricts to Console accounts. |
| `forceLoginOrgUUID` | string or array | — | Require login to belong to a specific organization UUID or list of UUIDs. |
| `forceRemoteSettingsRefresh` | boolean | `false` | *(managed only)* Block CLI startup until remote managed settings are freshly fetched. |
| `gcpAuthRefresh` | string | — | Script that refreshes GCP Application Default Credentials. |
| `hooks` | object | `{}` | Configure hook event handlers. Full reference in [`SKILL-hooks.md`](SKILL-hooks.md). |
| `httpHookAllowedEnvVars` | array | — | Allowlist of environment variable names HTTP hooks may interpolate into headers. Arrays merge across scopes. |
| `includeCoAuthoredBy` | boolean | `true` | **Deprecated** — use `attribution` instead. Whether to include co-authored-by byline. |
| `includeGitInstructions` | boolean | `true` | Include built-in commit/PR workflow instructions and git status snapshot in Claude's system prompt. |
| `language` | string | — | Claude's preferred response language (e.g. `"japanese"`, `"spanish"`). Also sets voice dictation language. |
| `maxSkillDescriptionChars` | number | `1536` | Per-skill character cap on description text Claude sees each turn (requires v2.1.105+). |
| `minimumVersion` | string | — | Prevents auto-updates from installing a version below this. Useful for pinning org-wide minimum. |
| `model` | string | (account default) | Override the default model. `--model` and `ANTHROPIC_MODEL` override for one session. Example: `"claude-sonnet-4-6"`. |
| `modelOverrides` | object | — | Map Anthropic model IDs to provider-specific IDs (e.g. Bedrock ARNs). |
| `otelHeadersHelper` | string | — | Script to generate dynamic OpenTelemetry headers at startup and periodically. |
| `outputStyle` | string | — | Configure an output style to adjust the system prompt. |
| `parentSettingsBehavior` | string | `"first-wins"` | *(managed only)* How embedder-supplied managed settings interact with admin-deployed tier. `"first-wins"` or `"merge"`. Requires v2.1.133+. |
| `permissions` | object | `{}` | Tool-permission rules. See `permissions` block section below. |
| `plansDirectory` | string | `~/.claude/plans` | Where plan files are stored. Relative to project root. |
| `pluginTrustMessage` | string | — | *(managed only)* Custom message appended to plugin trust warning before installation. |
| `policyHelper` | object | — | *(managed only)* Executable that computes managed settings dynamically at startup. Keys: `path`, `timeoutMs`, `refreshIntervalMs`. Requires v2.1.136+. |
| `preferredNotifChannel` | string | `"auto"` | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, `"iterm2_with_bell"`, `"kitty"`, `"ghostty"`, `"notifications_disabled"`. |
| `prefersReducedMotion` | boolean | `false` | Reduce or disable UI animations for accessibility. |
| `prUrlTemplate` | string | — | URL template for PR badge. Substitutes `{host}`, `{owner}`, `{repo}`, `{number}`, `{url}`. |
| `respectGitignore` | boolean | `true` | Whether the `@` file picker respects `.gitignore` patterns. |
| `showClearContextOnPlanAccept` | boolean | `false` | Show the "clear context" option on the plan accept screen. |
| `showThinkingSummaries` | boolean | `false` | Show extended thinking summaries in interactive sessions. |
| `showTurnDuration` | boolean | `true` | Show turn duration messages after responses. |
| `skillListingBudgetFraction` | number | `0.01` | Fraction of context window reserved for skill listing (requires v2.1.105+). |
| `skillOverrides` | object | — | Per-skill visibility overrides: `"on"`, `"name-only"`, `"user-invocable-only"`, or `"off"`. Requires v2.1.129+. |
| `skipWebFetchPreflight` | boolean | `false` | Skip WebFetch domain safety check (useful for Bedrock/Vertex/Foundry with restrictive egress). |
| `spinnerTipsEnabled` | boolean | `true` | Show tips in the spinner while Claude is working. |
| `spinnerTipsOverride` | object | — | Override spinner tips. Keys: `tips` (array of strings), `excludeDefault` (boolean). |
| `spinnerVerbs` | object | — | Customize action verbs in spinner. Keys: `mode` (`"replace"` or `"append"`), `verbs` (array). |
| `sshConfigs` | array | — | SSH connections for the Desktop environment dropdown. Read from managed and user settings only. |
| `statusLine` | object | — | Configure a custom status line. Keys: `type` (`"command"`), `command` (string). |
| `strictKnownMarketplaces` | array | — | *(managed only)* Allowlist of plugin marketplace sources. Undefined = no restriction; empty array = lockdown. |
| `syntaxHighlightingDisabled` | boolean | `false` | Disable syntax highlighting in diffs, code blocks, and file previews. |
| `teammateMode` | string | `"auto"` | How agent team teammates display: `"auto"`, `"in-process"`, or `"tmux"`. |
| `terminalProgressBarEnabled` | boolean | `true` | Show terminal progress bar in supported terminals. |
| `tui` | string | `"default"` | Terminal UI renderer: `"fullscreen"` (alt-screen) or `"default"` (classic). |
| `useAutoModeDuringPlan` | boolean | `true` | Whether plan mode uses auto mode semantics. Not read from shared project settings. |
| `viewMode` | string | `"default"` | Default transcript view mode: `"default"`, `"verbose"`, or `"focus"`. |
| `voice` | object | — | Voice dictation settings. Keys: `enabled` (boolean), `mode` (`"hold"` or `"tap"`), `autoSubmit` (boolean). |
| `voiceEnabled` | boolean | — | Legacy alias for `voice.enabled`. Prefer the `voice` object. |
| `wslInheritsWindowsSettings` | boolean | `false` | *(Windows managed only)* When `true`, Claude Code on WSL reads managed settings from the Windows policy chain. |

Source: `code.claude.com/docs/en/settings.md#available-settings`.

## `permissions` block

The `permissions` key is an object with sub-keys for tool-access control. Source: `code.claude.com/docs/en/settings.md#permission-settings`.

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run lint)",
      "Bash(npm run test *)",
      "Read(~/.zshrc)"
    ],
    "deny": [
      "Bash(curl *)",
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)"
    ],
    "ask": [
      "Bash(git push *)"
    ],
    "defaultMode": "acceptEdits",
    "additionalDirectories": ["../docs/"]
  }
}
```

**Permission sub-keys:**

| Key | Type | Description |
|---|---|---|
| `allow` | array of strings | Permission rules to allow tool use without prompting. Arrays concatenate across scopes. |
| `deny` | array of strings | Permission rules to deny tool use. Deny rules from any scope take precedence over hook `"allow"` decisions. Arrays concatenate across scopes. |
| `ask` | array of strings | Permission rules that always prompt the user for confirmation. |
| `additionalDirectories` | array of strings | Additional working directories for file access (e.g. `["../docs/"]`). |
| `defaultMode` | string | Default permission mode: `"default"`, `"acceptEdits"`, `"plan"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"`. As of v2.1.142, `"auto"` is ignored in project/local settings. |
| `disableBypassPermissionsMode` | string | Set to `"disable"` to prevent `bypassPermissions` mode from being activated. |
| `skipDangerousModePermissionPrompt` | boolean | Skip confirmation before entering bypass permissions mode. Ignored in project settings. |

**Permission rule syntax:** `Tool` or `Tool(specifier)`. Rules are evaluated: deny first, then ask, then allow. First matching rule wins.

| Rule | Effect |
|---|---|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Read(./.env)` | Matches reading the `.env` file |
| `WebFetch(domain:example.com)` | Matches fetch requests to example.com |
| `Read(./secrets/**)` | Matches all files under `secrets/` |

Source: `code.claude.com/docs/en/settings.md#permission-rule-syntax`.

## `env` injection

The `env` key injects environment variables into every session. Variables set here apply to every tool call (including Bash, WebFetch, etc.) and are visible to hooks.

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "NODE_ENV": "development",
    "MY_CUSTOM_VAR": "value"
  }
}
```

- Values must be strings.
- Variables set in `env` can be referenced by hooks using standard shell `$VAR` syntax.
- To disable a feature via env var, set it in `env` here rather than modifying shell profiles (which won't affect non-interactive hook processes).
- `env` can be placed at any scope (user, project, local, managed) and applies wherever that scope is active.

Example: disable auto-updates organization-wide via managed settings:
```json
{
  "env": {
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

Source: `code.claude.com/docs/en/settings.md#available-settings` (`env` row).

## `hooks` block

The `hooks` key maps event names to arrays of matcher groups, each containing an inner `hooks` array of handlers. Full event catalog, input/output shapes, matcher syntax, and worked examples are in [`SKILL-hooks.md`](SKILL-hooks.md).

Minimal structure:
```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "ToolName",
        "hooks": [
          { "type": "command", "command": "your-script.sh" }
        ]
      }
    ]
  }
}
```

Related settings that control hook behavior:
- `disableAllHooks` — disable all hooks globally
- `allowManagedHooksOnly` — *(managed only)* block user/project hooks
- `allowedHttpHookUrls` — restrict URLs HTTP hooks may POST to
- `httpHookAllowedEnvVars` — restrict env vars HTTP hooks may interpolate

## `model` selection and overrides

```json
{
  "model": "claude-sonnet-4-6"
}
```

- Override the default model for this scope.
- `--model` CLI flag and `ANTHROPIC_MODEL` environment variable override this for a single session.
- `availableModels` restricts which models users may select (does not affect the Default option).
- `modelOverrides` maps Anthropic model IDs to provider-specific IDs (e.g. Bedrock ARNs):

```json
{
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-1::foundation-model/anthropic.claude-opus-4-6"
  }
}
```

Source: `code.claude.com/docs/en/settings.md#available-settings`.

## `enabledPlugins`

Controls which plugins are active. Format: `"plugin-name@marketplace-name"` → boolean.

```json
{
  "enabledPlugins": {
    "code-formatter@team-tools": true,
    "deployment-tools@team-tools": true,
    "experimental-features@personal": false
  }
}
```

Project settings take precedence over user settings, so `false` in user settings cannot disable a plugin enabled in project settings. To opt out of a project-enabled plugin on your machine, set it to `false` in `.claude/settings.local.json`. Plugins force-enabled in managed `enabledPlugins` cannot be disabled at any lower scope.

Cross-reference: plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

## Worktree settings

Configure how `--worktree` creates and manages git worktrees (nested under `worktree`):

| Key | Default | Description |
|---|---|---|
| `worktree.baseRef` | `"fresh"` | Ref new worktrees branch from: `"fresh"` (origin default branch) or `"head"` (local HEAD). |
| `worktree.symlinkDirectories` | `[]` | Directories to symlink from main repo into each worktree (e.g. `["node_modules"]`). |
| `worktree.sparsePaths` | `[]` | Directories to check out via sparse-checkout (faster in large monorepos). |
| `worktree.bgIsolation` | `"worktree"` | Isolation mode for background sessions: `"worktree"` or `"none"`. Requires v2.1.143+. |

Source: `code.claude.com/docs/en/settings.md#worktree-settings`.

## Sandbox settings

Configure bash command sandboxing (nested under `sandbox`):

| Key | Default | Description |
|---|---|---|
| `sandbox.enabled` | `false` | Enable bash sandboxing (macOS, Linux, WSL2). |
| `sandbox.failIfUnavailable` | `false` | Exit with error at startup if sandbox cannot start. |
| `sandbox.autoAllowBashIfSandboxed` | `true` | Auto-approve bash commands when sandboxed. |
| `sandbox.excludedCommands` | `[]` | Commands that run outside the sandbox (e.g. `["docker *"]`). |
| `sandbox.allowUnsandboxedCommands` | `true` | Allow commands to escape sandbox via `dangerouslyDisableSandbox`. Set `false` for strict enforcement. |
| `sandbox.filesystem.allowWrite` | `[]` | Paths where sandboxed commands can write. Arrays merge across scopes. |
| `sandbox.filesystem.denyWrite` | `[]` | Paths where sandboxed commands cannot write. Arrays merge across scopes. |
| `sandbox.filesystem.denyRead` | `[]` | Paths where sandboxed commands cannot read. Arrays merge across scopes. |
| `sandbox.filesystem.allowRead` | `[]` | Re-allow reading within `denyRead` regions. Takes precedence over `denyRead`. |
| `sandbox.network.allowedDomains` | `[]` | Domains allowed for outbound traffic. Supports wildcards (`*.example.com`). |
| `sandbox.network.deniedDomains` | `[]` | Domains blocked for outbound traffic. Takes precedence over `allowedDomains`. |
| `sandbox.network.allowLocalBinding` | `false` | Allow binding to localhost ports (macOS only). |

Source: `code.claude.com/docs/en/settings.md#sandbox-settings`.

## Global config settings (`~/.claude.json`)

These keys are stored in `~/.claude.json`, not `settings.json`. Adding them to `settings.json` triggers a schema validation error.

| Key | Default | Description |
|---|---|---|
| `autoConnectIde` | `false` | Auto-connect to a running IDE when starting from an external terminal. |
| `autoInstallIdeExtension` | `true` | Auto-install Claude Code IDE extension when running from VS Code terminal. |
| `externalEditorContext` | `false` | Prepend Claude's previous response as context when opening external editor with `Ctrl+G`. |
| `teammateDefaultModel` | — | Default model for agent team teammates. |

Source: `code.claude.com/docs/en/settings.md#global-config-settings`.

## Common mistakes (auto-corrected by `rules/settings.md`)

- **Using `ignorePatterns`**: This key is deprecated. Use `permissions.deny` with `Read(path)` rules instead.
- **Setting `auto` defaultMode in project settings**: As of v2.1.142, `"auto"` is ignored in `.claude/settings.json` and `.claude/settings.local.json`. Set it in `~/.claude/settings.json` instead.
- **Using `includeCoAuthoredBy`**: Deprecated — use `attribution.commit` and `attribution.pr` instead.
- **Putting global config keys in `settings.json`**: Keys like `autoConnectIde` and `teammateDefaultModel` belong in `~/.claude.json`, not `settings.json`.
- **Expecting lower-scope array entries to be overridden**: Arrays like `permissions.allow`, `sandbox.filesystem.allowWrite` concatenate across scopes. A managed-settings entry and a user-settings entry both apply.
- **Committing `settings.local.json`**: Claude Code configures git to ignore `.claude/settings.local.json`. It is for personal/machine-specific overrides only.
- **Using `bypassPermissions` defaultMode in project settings**: This is a security risk. Claude Code will not allow a repository to grant itself bypass mode from project or local settings.

---

*Source pages: `code.claude.com/docs/en/settings.md`.*
