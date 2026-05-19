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
| managed | Server-managed settings, plist/registry, or system-level `managed-settings.json` | n/a (admin-set) | enterprise policy, enforced org-wide |
| user | `~/.claude/settings.json` | n/a | personal defaults across all projects |
| project | `<project>/.claude/settings.json` | yes | team-shared settings committed to git |
| local | `<project>/.claude/settings.local.json` | gitignored | personal overrides for this project |

Precedence (highest wins): `managed` → `local` → `project` → `user` → built-in default.

Source: [code.claude.com/docs/en/settings.md](https://code.claude.com/docs/en/settings.md)

## All settings keys (alphabetical)

These are all keys documented in `settings.json`. Array-type keys merge across scopes unless noted.

| Key | Notes |
|---|---|
| `agent` | Run main thread as a named subagent. |
| `allowedChannelPlugins` | (Managed only) Allowlist of channel plugins. |
| `allowedHttpHookUrls` | Allowlist of URL patterns HTTP hooks may target (`*` wildcard). Merges across scopes. |
| `allowedMcpServers` | (Managed only) Allowlist of MCP server names users can configure. |
| `allowManagedHooksOnly` | (Managed only) Block user/project/plugin hooks; only managed hooks run. |
| `allowManagedMcpServersOnly` | (Managed only) Only `allowedMcpServers` from managed settings are respected. |
| `allowManagedPermissionRulesOnly` | (Managed only) Prevent user/project from defining allow/ask/deny rules. |
| `alwaysThinkingEnabled` | Enable extended thinking by default. |
| `apiKeyHelper` | Custom `/bin/sh` script to generate an auth value sent as `X-Api-Key`. |
| `attribution` | Customize git commit/PR attribution. |
| `autoMemoryDirectory` | Custom directory for auto memory storage (absolute path or `~`-relative). |
| `autoMemoryEnabled` | Enable/disable auto memory. When `false`, Claude does not read from or write to memory. |
| `autoMode` | Customize what the auto mode classifier blocks/allows. |
| `autoScrollEnabled` | In fullscreen rendering, follow new output. Default: `true`. |
| `autoUpdatesChannel` | Release channel: `"stable"` (default, ~1 week behind) or `"latest"`. |
| `availableModels` | Restrict which models users can select via `/model`, `--model`, or `ANTHROPIC_MODEL`. |
| `awaySummaryEnabled` | Show a one-line session recap when returning to terminal. Default: `true`. |
| `awsAuthRefresh` | Custom script that modifies `.aws` directory for refreshing credentials. |
| `awsCredentialExport` | Custom script that outputs JSON with AWS credentials. |
| `blockedMarketplaces` | (Managed only) Blocklist of marketplace sources. |
| `channelsEnabled` | (Managed only) Allow channels for the organization. |
| `claudeMd` | (Managed only) CLAUDE.md-style instructions injected as org-managed memory. |
| `claudeMdExcludes` | Glob patterns or absolute paths of `CLAUDE.md` files to skip when loading memory. |
| `cleanupPeriodDays` | Session files older than this are deleted at startup. Default: 30, minimum 1. |
| `companyAnnouncements` | Announcement shown to users at startup. Multiple entries cycle across sessions. |
| `defaultShell` | Default shell for input-box `!` commands: `"bash"` (default) or `"powershell"`. |
| `deniedMcpServers` | (Managed only) Denylist of MCP servers explicitly blocked. Takes precedence over allowlist. |
| `disableAgentView` | Set `true` to turn off background agents and agent view. |
| `disableAllHooks` | Disable all hooks and any custom status line. |
| `disableAutoMode` | Set `"disable"` to prevent auto mode. |
| `disableDeepLinkRegistration` | Set `"disable"` to prevent registering `claude-cli://` protocol handler. |
| `disabledMcpjsonServers` | List of specific MCP servers from `.mcp.json` files to reject. |
| `disableRemoteControl` | Disable Remote Control (blocks `claude remote-control`). |
| `disableSkillShellExecution` | Disable inline shell execution in skills and custom commands. |
| `editorMode` | Key binding mode for input prompt: `"normal"` (default) or `"vim"`. |
| `effortLevel` | Persist effort level across sessions: `"low"`, `"medium"`, `"high"`, or `"xhigh"`. |
| `enableAllProjectMcpServers` | Auto-approve all MCP servers defined in project `.mcp.json` files. |
| `enabledMcpjsonServers` | List of specific MCP servers from `.mcp.json` files to approve. |
| `enabledPlugins` | Map of `"<plugin>@<marketplace>"` → boolean. See [`SKILL-plugins.md`](SKILL-plugins.md). |
| `env` | Environment variables injected into every session. See § *`env` injection* below. |
| `extraKnownMarketplaces` | Additional plugin marketplaces beyond the default set. |
| `fastModePerSessionOptIn` | When `true`, fast mode does not persist across sessions. |
| `feedbackSurveyRate` | Probability (0–1) that session quality survey appears at end. |
| `fileSuggestion` | Configure a custom script for `@` file autocomplete. |
| `forceLoginMethod` | `"claudeai"` restricts to Claude.ai accounts; `"console"` restricts to Console accounts. |
| `forceLoginOrgUUID` | Require login to a specific organization UUID. |
| `forceRemoteSettingsRefresh` | (Managed only) Block startup until remote managed settings are freshly fetched. |
| `gcpAuthRefresh` | Custom script that refreshes GCP Application Default Credentials. |
| `hooks` | Configure custom commands at lifecycle events. Full reference in [`SKILL-hooks.md`](SKILL-hooks.md). |
| `httpHookAllowedEnvVars` | Allowlist of env var names HTTP hooks may interpolate into headers. |
| `includeCoAuthoredBy` | **Deprecated**: use `attribution` instead. |
| `includeGitInstructions` | Include built-in commit/PR workflow instructions in system prompt. Default: `true`. |
| `language` | Configure Claude's preferred response language (e.g., `"japanese"`, `"spanish"`). |
| `maxSkillDescriptionChars` | Per-skill character cap on combined `description`+`when_to_use` fields. |
| `minimumVersion` | Floor version; prevents auto-updates and `claude update` below this version. |
| `model` | Override default model (e.g., `"claude-opus-4-7"`, `"claude-sonnet-4-6"`). |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs (e.g., Bedrock ARNs). |
| `otelHeadersHelper` | Script to generate dynamic OpenTelemetry headers. |
| `outputStyle` | Configure an output style to adjust the system prompt. |
| `parentSettingsBehavior` | (Managed only) Controls whether managed settings supplied programmatically take effect. |
| `permissions` | Permission allow/ask/deny rules. See § *`permissions` block* below. |
| `plansDirectory` | Customize where plan files are stored. Default: `~/.claude/plans`. |
| `pluginTrustMessage` | (Managed only) Custom message appended to plugin trust warning. |
| `policyHelper` | Admin-deployed executable that computes managed settings dynamically. |
| `preferredNotifChannel` | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, `"system"`, etc. |
| `prefersReducedMotion` | Reduce/disable UI animations for accessibility. |
| `prUrlTemplate` | URL template for PR badge shown in footer. Substitutes `{host}`, `{owner}`, `{repo}`, `{pr}`. |
| `respectGitignore` | Control whether `@` file picker respects `.gitignore`. Default: `true`. |
| `showClearContextOnPlanAccept` | Show "clear context" option on plan accept screen. Default: `false`. |
| `showThinkingSummaries` | Show extended thinking summaries in interactive sessions. |
| `showTurnDuration` | Show turn duration messages after responses. Default: `true`. |
| `skillListingBudgetFraction` | Fraction of context window reserved for skill listing. |
| `skillOverrides` | Per-skill visibility overrides keyed by skill name: `"on"`, `"never"`, or `"always"`. |
| `skipWebFetchPreflight` | Skip the WebFetch domain safety check. |
| `spinnerTipsEnabled` | Show tips in spinner while Claude works. Default: `true`. |
| `spinnerTipsOverride` | Override spinner tips with custom strings. |
| `spinnerVerbs` | Customize action verbs shown in spinner and turn duration messages. |
| `sshConfigs` | SSH connections shown in Desktop environment. |
| `statusLine` | Configure a custom status line. See [statusline docs](https://code.claude.com/docs/en/statusline.md). |
| `strictKnownMarketplaces` | (Managed only) Allowlist of plugin marketplace sources. |
| `syntaxHighlightingDisabled` | Disable syntax highlighting in diffs/code blocks. |
| `teammateMode` | How agent team teammates display: `"auto"` (default), `"in-process"`, `"split-panes"`. |
| `terminalProgressBarEnabled` | Show terminal progress bar in supported terminals. Default: `true`. |
| `tui` | Terminal UI renderer: `"fullscreen"` for alt-screen or `"default"`. |
| `useAutoModeDuringPlan` | Whether plan mode uses auto mode semantics when auto mode is available. Default: `true`. |
| `viewMode` | Default transcript view on startup: `"default"`, `"verbose"`, or `"focus"`. |
| `voice` | Voice dictation settings: `enabled`, `mode` (`"hold"` or `"tap"`). |
| `voiceEnabled` | Legacy alias for `voice.enabled`. Prefer `voice` object. |
| `wslInheritsWindowsSettings` | (Windows managed only) Read managed settings from Windows host when running in WSL. |

## `permissions` block

```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Read"],
    "ask": ["Edit(*.md)"],
    "deny": ["Bash(git push *)"],
    "defaultMode": "acceptEdits",
    "additionalDirectories": ["../shared-lib"]
  }
}
```

### Permission rule syntax

Rules follow `Tool` or `Tool(specifier)` format. Evaluation order: **deny → ask → allow** (first match wins).

| Rule form | Effect |
|---|---|
| `Bash` | Match all Bash commands |
| `Bash(*)` | Equivalent to `Bash` (match all) |
| `Bash(npm run build)` | Match exact command |
| `Bash(npm run *)` | Match any npm run subcommand |
| `Bash(git * main)` | Wildcard in middle position |
| `Read(./.env)` | Match reading specific file |
| `WebFetch(domain:example.com)` | Match fetch requests to a domain |
| `Edit(*.ts)` | Match edits to TypeScript files |
| `mcp__memory__.*` | Match all tools from memory MCP server |

**Space before `*` matters**: `Bash(ls *)` matches `ls -la` but not `lsof`. The `:*` suffix is an equivalent trailing wildcard.

### `permissions.defaultMode`

Persists the session's starting permission mode. Accepted values: `"default"`, `"acceptEdits"`, `"plan"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"`. Note: `"auto"` is ignored in project/local settings (only honored in user settings).

Full permission mode reference: [`SKILL-cli.md`](SKILL-cli.md#permission-modes).

### Managed-only permission settings

| Key | Effect |
|---|---|
| `allowManagedPermissionRulesOnly` | Block user/project from defining allow/ask/deny rules |
| `disableAutoMode` | `"disable"` prevents auto mode for all users |
| `disableBypassPermissionsMode` | `"disable"` prevents bypassPermissions for all users |

Source: [code.claude.com/docs/en/permissions.md](https://code.claude.com/docs/en/permissions.md)

## `env` injection

The `env` key injects environment variables into every tool call session-wide:

```json
{
  "env": {
    "NODE_ENV": "development",
    "MY_API_KEY": "sk-..."
  }
}
```

Variables defined in `env` are available to Bash tool calls, hook commands, and MCP server processes. Scopes merge (project `env` + user `env` both apply).

## `hooks` block

Cross-reference: full hook event reference lives in [`SKILL-hooks.md`](SKILL-hooks.md).

The `hooks` key maps event names to arrays of matcher groups:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "npm run lint" }]
      }
    ]
  }
}
```

## `model` selection and overrides

The `model` key accepts any Anthropic model alias. Precedence (highest first): `ANTHROPIC_MODEL` env var → CLI `--model` flag → `settings.json` `model` key → account default.

Common values: `"claude-opus-4-7"`, `"claude-sonnet-4-6"`, `"claude-haiku-4-5"`. Use `/model` in the REPL to see all available models.

For effort level (extended thinking), see `effortLevel` key or `--effort` CLI flag.

## `enabledPlugins`

Cross-reference: plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

```json
{
  "enabledPlugins": {
    "my-plugin@my-marketplace": true
  }
}
```

## Common mistakes (auto-corrected by `rules/settings.md`)

- Putting `defaultMode: "auto"` in project/local settings — it is **ignored** there; must be in `~/.claude/settings.json`.
- Using the wrong scope file path: `settings.local.json` (gitignored) vs `settings.json` (committed).
- Forgetting that `deny` rules take precedence over `allow` rules — ordering in the array does not matter.

---

*Source pages: [code.claude.com/docs/en/settings.md](https://code.claude.com/docs/en/settings.md), [permissions.md](https://code.claude.com/docs/en/permissions.md), [permission-modes.md](https://code.claude.com/docs/en/permission-modes.md).*
