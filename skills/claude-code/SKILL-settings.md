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

| Scope | Path | Shared? | Override level |
|---|---|---|---|
| **Managed** | Server-managed settings, plist/registry, or system `managed-settings.json` | Yes (admin-deployed) | Cannot be overridden |
| **Command line** | `--settings <file-or-json>` or flags | No | Overrides file-based settings for session |
| **Local** | `<project>/.claude/settings.local.json` | No (gitignored) | Overrides project + user |
| **Project** | `<project>/.claude/settings.json` | Yes (committed) | Overrides user |
| **User** | `~/.claude/settings.json` | No | Base defaults |

Managed settings are delivered via: (1) server-managed settings from the admin console; (2) MDM/OS-level policies (macOS plist `com.anthropic.claudecode`, Windows `HKLM\SOFTWARE\Policies\ClaudeCode`); (3) file-based at macOS `/Library/Application Support/ClaudeCode/`, Linux/WSL `/etc/claude-code/`, Windows `C:\Program Files\ClaudeCode\`. The file-based tier also supports drop-in `managed-settings.d/*.json` fragments merged alphabetically.

**Array settings merge across scopes** (concatenate + deduplicate). Scalar settings: higher-priority scope wins.

Source: `code.claude.com/docs/en/settings.md`.

The JSON schema is published at `https://json.schemastore.org/claude-code-settings.json`. Add `"$schema"` to get editor autocomplete.

Minimal valid `settings.json`:

```json
{
  "model": "claude-sonnet-4-6"
}
```

## All documented settings keys

| Key | Type | Notes |
|---|---|---|
| `agent` | string | Run the main thread as a named subagent |
| `allowedChannelPlugins` | array | (Managed only) Allowlist of channel plugins |
| `allowedHttpHookUrls` | array | URL patterns HTTP hooks may target; `*` wildcard supported |
| `allowedMcpServers` | array | (Managed only) Allowlist of MCP servers users can configure |
| `allowManagedHooksOnly` | boolean | (Managed only) Block all non-managed hooks |
| `allowManagedMcpServersOnly` | boolean | (Managed only) Only managed-settings MCP servers apply |
| `allowManagedPermissionRulesOnly` | boolean | (Managed only) Block user/project allow/ask/deny rules |
| `alwaysThinkingEnabled` | boolean | Enable extended thinking by default |
| `apiKeyHelper` | string | Shell script to generate auth value (sent as `X-Api-Key`) |
| `attribution` | object | Customize git commit / PR attribution; keys: `commit`, `pr` |
| `autoMemoryDirectory` | string | Custom path for auto memory storage |
| `autoMemoryEnabled` | boolean | Enable/disable auto memory (default: `true`) |
| `autoMode` | object | Customize auto mode classifier rules (`environment`, `allow`, `soft_deny`, `hard_deny`). Not read from shared project settings |
| `autoScrollEnabled` | boolean | Follow new output in fullscreen renderer (default: `true`) |
| `autoUpdatesChannel` | string | `"stable"` or `"latest"` (default) |
| `availableModels` | array | Restrict model choices in `/model`, `--model`, `ANTHROPIC_MODEL` |
| `awaySummaryEnabled` | boolean | Show session recap when returning to terminal |
| `awsAuthRefresh` | string | Script to refresh `.aws` directory for Bedrock |
| `awsCredentialExport` | string | Script that outputs JSON AWS credentials |
| `blockedMarketplaces` | array | (Managed only) Blocklist of marketplace sources |
| `channelsEnabled` | boolean | (Managed only) Allow channels for the organization |
| `claudeMd` | string | (Managed only) Org-wide CLAUDE.md injected as memory |
| `claudeMdExcludes` | array | Glob patterns for CLAUDE.md files to skip |
| `cleanupPeriodDays` | number | Session files older than N days deleted at startup (default: 30, min: 1) |
| `companyAnnouncements` | array | Messages displayed at startup (cycled randomly) |
| `defaultShell` | string | `"bash"` (default) or `"powershell"` for `!` commands |
| `deniedMcpServers` | array | (Managed only) Denylist of MCP servers (takes precedence over allowlist) |
| `disableAgentView` | boolean | Disable background agents and agent view |
| `disableAllHooks` | boolean | Disable all hooks and custom status line |
| `disableAutoMode` | string | `"disable"` to prevent auto mode from being activated |
| `disableDeepLinkRegistration` | string | `"disable"` to prevent `claude-cli://` protocol handler registration |
| `disabledMcpjsonServers` | array | Specific MCP servers from `.mcp.json` to reject |
| `disableRemoteControl` | boolean | Disable Remote Control (v2.1.128+) |
| `disableSkillShellExecution` | boolean | Disable `!` shell execution in skills/commands |
| `editorMode` | string | `"normal"` or `"vim"` for the input prompt |
| `effortLevel` | string | Persist effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"` |
| `enableAllProjectMcpServers` | boolean | Auto-approve all project `.mcp.json` servers |
| `enabledMcpjsonServers` | array | Specific MCP servers from `.mcp.json` to approve |
| `env` | object | Environment variables applied to every session |
| `extraKnownMarketplaces` | object | Additional plugin marketplaces (team onboarding) |
| `fastModePerSessionOptIn` | boolean | Require per-session fast mode opt-in |
| `feedbackSurveyRate` | number | Probability (0–1) that session quality survey appears |
| `fileSuggestion` | object | Custom script for `@` file autocomplete |
| `forceLoginMethod` | string | `"claudeai"` or `"console"` |
| `forceLoginOrgUUID` | string or array | Require login to belong to specific org(s) |
| `forceRemoteSettingsRefresh` | boolean | (Managed only) Block startup until remote settings fetched |
| `gcpAuthRefresh` | string | Script to refresh GCP Application Default Credentials |
| `hooks` | object | Hook event handlers. See [`SKILL-hooks.md`](SKILL-hooks.md) |
| `httpHookAllowedEnvVars` | array | Allowlist of env vars HTTP hooks may interpolate into headers |
| `includeCoAuthoredBy` | boolean | **Deprecated**: use `attribution` instead |
| `includeGitInstructions` | boolean | Include built-in git workflow instructions in system prompt (default: `true`) |
| `language` | string | Claude's preferred response language (e.g. `"japanese"`) |
| `maxSkillDescriptionChars` | number | Per-skill character cap on description+when_to_use text (default: 1536; v2.1.105+) |
| `minimumVersion` | string | Floor for auto-updates; prevents downgrade below this version |
| `model` | string | Override default model (e.g. `"claude-sonnet-4-6"`) |
| `modelOverrides` | object | Map Anthropic model IDs to provider-specific IDs (e.g. Bedrock ARNs) |
| `otelHeadersHelper` | string | Script to generate dynamic OpenTelemetry headers |
| `outputStyle` | string | Output style preset (e.g. `"Explanatory"`) |
| `parentSettingsBehavior` | string | (Managed only) `"first-wins"` (default) or `"merge"` for embedding host policy (v2.1.133+) |
| `permissions` | object | Permission rules. See § *`permissions` block* below |
| `plansDirectory` | string | Where plan files are stored (default: `~/.claude/plans`) |
| `pluginTrustMessage` | string | (Managed only) Custom message appended to plugin trust warning |
| `policyHelper` | object | (Managed only) Admin executable for dynamic managed settings (v2.1.136+). Keys: `path` (string, absolute path to helper), `timeoutMs` (number, wait limit before treating run as failed), `refreshIntervalMs` (number, re-run interval; `0` = disable, minimum `60000`) |
| `preferredNotifChannel` | string | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, `"iterm2_with_bell"`, `"kitty"`, `"ghostty"`, `"notifications_disabled"` |
| `prefersReducedMotion` | boolean | Reduce/disable UI animations |
| `prUrlTemplate` | string | URL template for PR badge links |
| `respectGitignore` | boolean | `@` file picker respects `.gitignore` (default: `true`) |
| `showClearContextOnPlanAccept` | boolean | Show "clear context" option on plan accept screen (default: `false`) |
| `showThinkingSummaries` | boolean | Show extended thinking summaries in interactive sessions |
| `showTurnDuration` | boolean | Show turn duration messages (default: `true`) |
| `skillListingBudgetFraction` | number | Fraction of context window for skill listing (default: `0.01`; v2.1.105+) |
| `skillOverrides` | object | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"` (v2.1.129+) |
| `skipWebFetchPreflight` | boolean | Skip WebFetch domain safety check (for Bedrock/Vertex/Foundry with restrictive egress) |
| `spinnerTipsEnabled` | boolean | Show tips in spinner (default: `true`) |
| `spinnerTipsOverride` | object | Override spinner tips: `{ tips: [...], excludeDefault: bool }` |
| `spinnerVerbs` | object | Customize spinner verbs: `{ mode: "replace"|"append", verbs: [...] }` |
| `sshConfigs` | array | SSH connections for Desktop environment dropdown (managed + user only) |
| `statusLine` | object | Custom status line command. See `code.claude.com/docs/en/statusline.md` |
| `strictKnownMarketplaces` | array | (Managed only) Marketplace allowlist/lockdown |
| `strictPluginOnlyCustomization` | boolean \| array | (Managed only) Block skills, agents, hooks, and/or MCP servers from user and project sources; only plugin-provided or managed sources load. `true` locks all four surfaces; an array names which to lock: `"skills"`, `"agents"`, `"hooks"`, `"mcp"`. Requires v2.1.82+. Combine with `strictKnownMarketplaces` to control the full customization supply chain. Source: `code.claude.com/docs/en/settings.md` |
| `syntaxHighlightingDisabled` | boolean | Disable syntax highlighting |
| `teammateMode` | string | Agent team display: `"auto"`, `"in-process"`, or `"tmux"` |
| `terminalProgressBarEnabled` | boolean | Show terminal progress bar in supported terminals (default: `true`) |
| `tui` | string | Renderer: `"fullscreen"` or `"default"` |
| `useAutoModeDuringPlan` | boolean | Use auto mode semantics in plan mode (default: `true`). Not read from shared project settings |
| `viewMode` | string | Default transcript view: `"default"`, `"verbose"`, `"focus"` |
| `voice` | object | Voice dictation: `{ enabled, mode: "hold"|"tap", autoSubmit }` |
| `voiceEnabled` | boolean | Legacy alias for `voice.enabled` |
| `wslInheritsWindowsSettings` | boolean | (Windows managed only) WSL reads Windows policy chain |

### Global config settings (stored in `~/.claude.json`, not `settings.json`)

| Key | Notes |
|---|---|
| `autoConnectIde` | Auto-connect to running IDE on startup (default: `false`) |
| `autoInstallIdeExtension` | Auto-install Claude Code IDE extension in VS Code terminal (default: `true`) |
| `externalEditorContext` | Prepend previous response to external editor context (default: `false`) |
| `teammateDefaultModel` | Default model for agent team teammates |

### Worktree settings

| Key | Notes |
|---|---|
| `worktree.baseRef` | `"fresh"` (default, branches from `origin/<default>`) or `"head"` (from local HEAD) |
| `worktree.symlinkDirectories` | Directories to symlink from main repo into each worktree |
| `worktree.sparsePaths` | Directories for git sparse-checkout in each worktree |
| `worktree.bgIsolation` | Background session isolation: `"worktree"` (default) or `"none"` (v2.1.143+) |

## `permissions` block

The `permissions` object in `settings.json` controls tool permission rules.

```json
{
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(npm run test *)", "Read(~/.zshrc)"],
    "deny": ["Bash(curl *)", "Read(./.env)", "Read(./secrets/**)"],
    "ask": ["Bash(git push *)"],
    "defaultMode": "acceptEdits",
    "additionalDirectories": ["../docs/"]
  }
}
```

| Key | Type | Notes |
|---|---|---|
| `allow` | array | Rules granting tool use without prompting |
| `deny` | array | Rules blocking tool use |
| `ask` | array | Rules forcing confirmation |
| `additionalDirectories` | array | Additional working directories for file access |
| `defaultMode` | string | Starting permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. As of v2.1.142 `auto` is ignored from project/local settings |
| `disableBypassPermissionsMode` | string | `"disable"` to prevent bypassPermissions mode |
| `skipDangerousModePermissionPrompt` | boolean | Skip confirmation before bypass permissions mode (ignored in project settings) |

**Rule evaluation order:** `deny` → `ask` → `allow`. The first matching rule wins.

**Permission rule syntax:** `Tool` or `Tool(specifier)`.

| Rule | Effect |
|---|---|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Read(./.env)` | Matches reading the `.env` file |
| `WebFetch(domain:example.com)` | Matches fetch requests to example.com |

For full rule syntax (wildcards, tool-specific patterns, MCP, Agent rules), see `code.claude.com/docs/en/permissions.md`.

## `sandbox` block

Configure OS-level bash sandboxing (macOS, Linux, WSL2). Sandbox settings nest inside a `"sandbox"` key in `settings.json`.

| Key | Notes |
|---|---|
| `sandbox.enabled` | Enable bash sandboxing (default: `false`) |
| `sandbox.failIfUnavailable` | Exit with error if sandbox can't start when enabled |
| `sandbox.autoAllowBashIfSandboxed` | Auto-approve bash commands when sandboxed (default: `true`) |
| `sandbox.excludedCommands` | Commands that run outside the sandbox (e.g. `["docker *"]`) |
| `sandbox.allowUnsandboxedCommands` | Allow `dangerouslyDisableSandbox` escape hatch (default: `true`) |
| `sandbox.filesystem.allowWrite` | Paths where sandboxed commands can write |
| `sandbox.filesystem.denyWrite` | Paths where sandboxed commands cannot write |
| `sandbox.filesystem.denyRead` | Paths where sandboxed commands cannot read |
| `sandbox.filesystem.allowRead` | Re-allow reading within `denyRead` regions |
| `sandbox.filesystem.allowManagedReadPathsOnly` | (Managed only) Only `filesystem.allowRead` paths from managed settings are respected |
| `sandbox.network.allowedDomains` | Domains to allow for outbound traffic |
| `sandbox.network.deniedDomains` | Domains to block (takes precedence over allowedDomains) |
| `sandbox.network.allowUnixSockets` | (macOS only) Unix socket paths accessible in sandbox |
| `sandbox.network.allowAllUnixSockets` | Allow all Unix socket connections. On Linux/WSL2 this is the only way to permit Unix sockets (default: `false`) |
| `sandbox.network.allowLocalBinding` | Allow binding to localhost ports (macOS only; default: `false`) |
| `sandbox.network.allowMachLookup` | Additional XPC/Mach service names allowed (macOS only). Supports single trailing `*` — e.g. `"com.apple.coresimulator.*"` |
| `sandbox.network.allowManagedDomainsOnly` | (Managed only) Only `allowedDomains` from managed settings are respected; user/project/local entries ignored |
| `sandbox.network.httpProxyPort` | HTTP proxy port for bring-your-own-proxy |
| `sandbox.network.socksProxyPort` | SOCKS5 proxy port for bring-your-own-proxy |
| `sandbox.enableWeakerNestedSandbox` | Enable weaker sandbox for unprivileged Docker (Linux/WSL2 only). **Reduces security.** Default: `false` |
| `sandbox.enableWeakerNetworkIsolation` | (macOS only) Allow TLS trust service access — needed by Go tools (e.g. `gh`, `gcloud`) with a MITM proxy + custom CA. **Reduces security.** Default: `false` |
| `sandbox.bwrapPath` | (Managed only, Linux/WSL2) Absolute path to `bwrap` binary, overriding `PATH` lookup |
| `sandbox.socatPath` | (Managed only, Linux/WSL2) Absolute path to `socat` binary for sandbox network proxy |

## `env` injection

Environment variables in the `env` object are applied to every session. Any env var can also be set this way:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

`env` values must be strings. For the full list of recognized env vars, see `code.claude.com/docs/en/env-vars.md`. Cross-reference: [`SKILL-cli.md`](SKILL-cli.md) § *Environment variables*.

## `hooks` block

Cross-reference: full hook event reference lives in [`SKILL-hooks.md`](SKILL-hooks.md).

Hook configuration schema: `hooks.<EventName>` is an array of matcher-group objects, each with a `matcher` field and a `hooks` array of handler objects.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "/path/to/lint.sh" }
        ]
      }
    ]
  }
}
```

## `model` selection

`model` accepts a full model name (e.g. `"claude-opus-4-7"`) or a short alias:

| Alias | Resolves to |
|---|---|
| `sonnet` | Latest Claude Sonnet |
| `opus` | Latest Claude Opus |
| `haiku` | Latest Claude Haiku |

Precedence (highest wins): `--model` flag > `ANTHROPIC_MODEL` env var > `model` in `settings.json`.

## `attribution` settings

```json
{
  "attribution": {
    "commit": "Generated with AI\n\nCo-Authored-By: AI <ai@example.com>",
    "pr": ""
  }
}
```

Empty string for `commit` or `pr` hides that attribution. Replaces the deprecated `includeCoAuthoredBy`.

## `extraKnownMarketplaces` and `enabledPlugins`

Cross-reference: full plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

```json
{
  "enabledPlugins": {
    "formatter@acme-tools": true,
    "deployer@acme-tools": false
  },
  "extraKnownMarketplaces": {
    "acme-tools": {
      "source": { "source": "github", "repo": "acme-corp/claude-plugins" }
    }
  }
}
```

Keys in `enabledPlugins` use `"<plugin>@<marketplace>"` format. Setting a plugin to `false` in user settings does NOT override a project `settings.json` that enables it — use `settings.local.json` instead.

## Common mistakes (auto-corrected by `rules/settings.md`)

See [`rules/settings.md`](rules/settings.md) for auto-correction patterns:
- `permissions.allow` / `deny` / `ask` must be **arrays of strings**, not plain strings
- Hook event names are **PascalCase** (`PreToolUse`, not `preToolUse`)
- `enabledPlugins` keys use `<plugin>@<marketplace>` format

---

*Source pages: `code.claude.com/docs/en/settings.md`, `permissions.md`, `permission-modes.md`.*
