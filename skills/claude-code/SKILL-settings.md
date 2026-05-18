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

Evaluation order (highest → lowest priority):
1. **Managed** — `/Library/Application Support/ClaudeCode/managed-settings.json` (macOS), `/etc/claude-code/managed-settings.json` (Linux/WSL), `C:\Program Files\ClaudeCode\managed-settings.json` (Windows). Drop-in: `managed-settings.d/*.json` in the same directory (sorted alphabetically, merged on top). Cannot be overridden by anything including CLI args.
2. **Command line** — `--settings <file-or-json>` (temporary session override)
3. **Local** — `.claude/settings.local.json` (gitignored; personal overrides for this repo)
4. **Project** — `.claude/settings.json` (committed; team-shared)
5. **User** — `~/.claude/settings.json` (personal defaults, all projects)

**Array fields concatenate** across scopes instead of overriding — e.g., `permissions.allow`, `sandbox.filesystem.allowWrite`.

| Scope | Path | Tracked in git? |
|---|---|---|
| User | `~/.claude/settings.json` | n/a |
| Project | `.claude/settings.json` | yes |
| Local | `.claude/settings.local.json` | gitignored |
| Managed (macOS) | `/Library/Application Support/ClaudeCode/managed-settings.json` | n/a (admin-set) |
| Managed (Linux/WSL) | `/etc/claude-code/managed-settings.json` | n/a (admin-set) |
| Managed (Windows) | `C:\Program Files\ClaudeCode\managed-settings.json` | n/a (admin-set) |

> `~/.claude.json` stores global state (user-level MCP config, IDE preferences). It is **not** `settings.json` — do not put settings keys there.

## Top-level keys

Source: [`code.claude.com/docs/en/settings.md`](https://code.claude.com/docs/en/settings.md) (2026-05-18).

| Key | Type / Values | Default | Notes |
|---|---|---|---|
| `agent` | string | — | Run main thread as named subagent |
| `allowedChannelPlugins` | array of `{marketplace, plugin}` | — | **Managed only.** Allowlist of channel plugins |
| `allowedHttpHookUrls` | array of URL patterns | — | Allowlist for HTTP hook targets; supports `*` wildcard |
| `allowedMcpServers` | array of `{serverName}` | — | **Managed only.** Allowlist of MCP servers |
| `allowManagedHooksOnly` | boolean | — | **Managed only.** Block all user/project/plugin hooks |
| `allowManagedMcpServersOnly` | boolean | — | **Managed only.** |
| `allowManagedPermissionRulesOnly` | boolean | — | **Managed only.** Block user/project allow/ask/deny rules |
| `alwaysThinkingEnabled` | boolean | — | Enable extended thinking by default |
| `apiKeyHelper` | string (script path) | — | Script that outputs an auth value; sent as `X-Api-Key` and `Authorization: Bearer` |
| `attribution` | object `{commit, pr}` | — | Customize git commit / PR attribution text. Empty string hides it |
| `autoMemoryDirectory` | string (path) | `~/.claude/memory` | Custom auto-memory dir; accepts `~/`-prefixed paths |
| `autoMemoryEnabled` | boolean | `true` | |
| `autoMode` | object `{environment, allow, soft_deny, hard_deny}` | — | Configure auto-mode classifier; use `"$defaults"` to inherit built-ins |
| `autoScrollEnabled` | boolean | `true` | In fullscreen rendering, follow new output |
| `autoUpdatesChannel` | `"stable"` \| `"latest"` | `"latest"` | |
| `availableModels` | array of strings | — | Restrict which models users can select |
| `awaySummaryEnabled` | boolean | `true` | Show one-line session recap on return |
| `awsAuthRefresh` | string (script) | — | Custom script that modifies the `.aws` directory |
| `awsCredentialExport` | string (script) | — | Custom script that outputs AWS credentials JSON |
| `blockedMarketplaces` | array of marketplace source objects | — | **Managed only.** Blocklist of marketplace sources |
| `channelsEnabled` | boolean | — | **Managed only.** Allow channels for the org |
| `claudeMd` | string | — | **Managed only.** Org-managed CLAUDE.md injected as instructions |
| `claudeMdExcludes` | array of glob patterns | — | CLAUDE.md files to skip when loading memory |
| `cleanupPeriodDays` | number | `30` | Min 1; 0 is rejected |
| `companyAnnouncements` | array of strings | — | Shown at startup; cycled randomly |
| `defaultShell` | `"bash"` \| `"powershell"` | `"bash"` | |
| `deniedMcpServers` | array of `{serverName}` | — | **Managed only.** Denylist of MCP servers |
| `disableAgentView` | boolean | — | Disable background agents and agent view |
| `disableAllHooks` | boolean | — | Disable all hooks and custom status line |
| `disableAutoMode` | `"disable"` | — | Prevent auto mode |
| `disableDeepLinkRegistration` | `"disable"` | — | Prevent `claude-cli://` protocol registration |
| `disabledMcpjsonServers` | array of strings | — | MCP servers from `.mcp.json` to reject |
| `disableRemoteControl` | boolean | — | Min-version 2.1.128; disable Remote Control |
| `disableSkillShellExecution` | boolean | — | Disable inline shell execution in skills |
| `editorMode` | `"normal"` \| `"vim"` | `"normal"` | |
| `effortLevel` | `"low"` \| `"medium"` \| `"high"` \| `"xhigh"` | — | Persists across sessions |
| `enableAllProjectMcpServers` | boolean | — | Auto-approve all `.mcp.json` MCP servers |
| `enabledMcpjsonServers` | array of strings | — | MCP servers from `.mcp.json` to approve |
| `enabledPlugins` | object `{"<plugin>@<marketplace>": boolean}` | — | Enable/disable plugins. See [`SKILL-plugins.md`](SKILL-plugins.md) |
| `env` | object (string→string) | — | Env vars injected every session. See § *`env` injection* |
| `extraKnownMarketplaces` | object keyed by name | — | Define additional marketplaces. See § *Plugin settings* |
| `fastModePerSessionOptIn` | boolean | — | Fast mode does not persist; requires `/fast` each session |
| `feedbackSurveyRate` | number (0–1) | — | Session quality survey probability |
| `fileSuggestion` | object `{type, command}` | — | Custom `@` file autocomplete command |
| `forceLoginMethod` | `"claudeai"` \| `"console"` | — | |
| `forceLoginOrgUUID` | string or array of strings | — | Require login to specific org UUID(s) |
| `forceRemoteSettingsRefresh` | boolean | — | **Managed only.** Block startup until remote settings fetched |
| `gcpAuthRefresh` | string (script) | — | Script to refresh GCP Application Default Credentials |
| `hooks` | object | — | Lifecycle hooks. Full reference in [`SKILL-hooks.md`](SKILL-hooks.md) |
| `httpHookAllowedEnvVars` | array of strings | — | Env var names HTTP hooks may interpolate |
| `includeCoAuthoredBy` | boolean | `true` | **Deprecated** — use `attribution` |
| `includeGitInstructions` | boolean | `true` | Include built-in git instructions and git status snapshot |
| `language` | string | — | Claude's preferred response language; also sets voice dictation language |
| `maxSkillDescriptionChars` | number | `1536` | Min-version 2.1.105 |
| `minimumVersion` | string | — | Floor for auto-updates |
| `model` | string | — | Override default model (e.g. `"claude-sonnet-4-6"`, `"claude-opus-4-7"`) |
| `modelOverrides` | object (Anthropic model ID → provider ID) | — | Map model IDs to provider-specific IDs |
| `otelHeadersHelper` | string (script path) | — | Script to generate dynamic OpenTelemetry headers |
| `outputStyle` | string | — | Configure output style to adjust system prompt |
| `parentSettingsBehavior` | `"first-wins"` \| `"merge"` | `"first-wins"` | **Managed only.** Min-version 2.1.133 |
| `permissions` | object | — | Permission rules. See § *`permissions` block* |
| `plansDirectory` | string (path) | `~/.claude/plans` | Relative to project root |
| `pluginTrustMessage` | string | — | **Managed only.** Appended to plugin trust warning |
| `policyHelper` | object `{path, timeoutMs?, refreshIntervalMs?}` | — | Min-version 2.1.136. **Managed only.** |
| `preferredNotifChannel` | `"auto"` \| `"terminal_bell"` \| `"iterm2"` \| `"iterm2_with_bell"` \| `"kitty"` \| `"ghostty"` \| `"notifications_disabled"` | `"auto"` | |
| `prefersReducedMotion` | boolean | — | Reduce UI animations |
| `prUrlTemplate` | string | — | URL template with `{host}`, `{owner}`, `{repo}`, `{number}`, `{url}` |
| `respectGitignore` | boolean | `true` | `@` file picker respects `.gitignore` |
| `showClearContextOnPlanAccept` | boolean | `false` | Show "clear context" option on plan accept |
| `showThinkingSummaries` | boolean | `false` | Show extended thinking summaries |
| `showTurnDuration` | boolean | `true` | Show turn duration messages |
| `skillListingBudgetFraction` | number | `0.01` | Min-version 2.1.105; fraction of context window for skill listing |
| `skillOverrides` | object (skill name → `"on"` \| `"name-only"` \| `"user-invocable-only"` \| `"off"`) | — | Min-version 2.1.129 |
| `skipWebFetchPreflight` | boolean | — | Skip WebFetch domain safety check |
| `spinnerTipsEnabled` | boolean | `true` | |
| `spinnerTipsOverride` | object `{tips: string[], excludeDefault?: boolean}` | — | |
| `spinnerVerbs` | object `{mode: "replace"\|"append", verbs: string[]}` | — | |
| `sshConfigs` | array of `{id, name, sshHost, sshPort?, sshIdentityFile?, startDirectory?}` | — | Desktop SSH connections |
| `statusLine` | object `{type, command}` | — | Custom status line |
| `strictKnownMarketplaces` | array of source objects | — | **Managed only.** Allowlist of marketplace sources |
| `syntaxHighlightingDisabled` | boolean | — | |
| `teammateMode` | `"auto"` \| `"in-process"` \| `"tmux"` | `"auto"` | |
| `terminalProgressBarEnabled` | boolean | `true` | |
| `tui` | `"fullscreen"` \| `"default"` | — | |
| `useAutoModeDuringPlan` | boolean | `true` | Not read from shared project settings |
| `viewMode` | `"default"` \| `"verbose"` \| `"focus"` | — | |
| `voice` | object `{enabled, mode: "hold"\|"tap", autoSubmit?}` | — | |
| `voiceEnabled` | boolean | — | Legacy alias for `voice.enabled` |
| `wslInheritsWindowsSettings` | boolean | — | **Managed only** (Windows) |

## `permissions` block

Source: [`permissions.md`](https://code.claude.com/docs/en/permissions.md), [`permission-modes.md`](https://code.claude.com/docs/en/permission-modes.md).

```json
{
  "permissions": {
    "allow": ["Bash(git *)", "Read(**/.env)"],
    "ask": ["Bash(curl *)"],
    "deny": ["Bash(rm -rf *)"],
    "additionalDirectories": ["/mnt/data"],
    "defaultMode": "acceptEdits",
    "disableBypassPermissionsMode": "disable",
    "skipDangerousModePermissionPrompt": false
  }
}
```

| Sub-key | Type | Description |
|---|---|---|
| `allow` | array of rule strings | Auto-approve matching tool calls |
| `ask` | array of rule strings | Always prompt for matching tool calls |
| `deny` | array of rule strings | Always deny matching tool calls |
| `additionalDirectories` | array of paths | Additional working directories |
| `defaultMode` | `"default"` \| `"acceptEdits"` \| `"plan"` \| `"auto"` \| `"dontAsk"` \| `"bypassPermissions"` | Starting permission mode |
| `disableBypassPermissionsMode` | `"disable"` | Prevent entering bypassPermissions mode |
| `skipDangerousModePermissionPrompt` | boolean | Skip bypass-permissions confirmation prompt |

**Rule syntax:** `Tool` or `Tool(specifier)`. Evaluation order: `deny → ask → allow` (first match wins).

| Example | Matches |
|---|---|
| `Bash` | All Bash calls |
| `Bash(npm run build)` | Exact command |
| `Bash(npm run *)` | Commands starting with `npm run ` |
| `Bash(git * main)` | Multi-position wildcard |
| `Read(./.env)` | Specific file |
| `Read(**/.env)` | Recursive glob |
| `Read(//Users/alice/file)` | Absolute path (double slash prefix) |
| `WebFetch(domain:example.com)` | All fetches to domain |
| `mcp__puppeteer__puppeteer_navigate` | Specific MCP tool |
| `mcp__puppeteer` | All tools from `puppeteer` MCP server |
| `Agent(Explore)` | The Explore subagent |

**Protected paths** (never auto-approved except in `bypassPermissions`): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`), `.gitconfig`, `.gitmodules`, `.bashrc`, `.bash_profile`, `.zshrc`, `.mcp.json`, `.claude.json`.

## `env` injection

Values in `env` are set as environment variables for every tool call (Bash, etc.) during the session. Values must be strings.

```json
{
  "env": {
    "NODE_ENV": "development",
    "MY_API_ENDPOINT": "https://api.example.com"
  }
}
```

`env` values in `settings.json` are **not** the same as environment variables that control Claude Code startup behavior (like `ANTHROPIC_API_KEY`). For startup env vars, see [`SKILL-cli.md`](SKILL-cli.md) § *Environment variables*.

## `hooks` block

Hook config is declared under the `hooks` key in `settings.json`. Each key is a hook event name.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "echo 'About to run bash'" }]
      }
    ]
  }
}
```

Full hook event reference → [`SKILL-hooks.md`](SKILL-hooks.md).

## `sandbox` block

Controls the sandboxed bash tool for filesystem and network isolation.

| Sub-key | Type | Default | Description |
|---|---|---|---|
| `sandbox.enabled` | boolean | `false` | Enable bash sandboxing |
| `sandbox.failIfUnavailable` | boolean | `false` | Exit with error if sandbox can't start |
| `sandbox.autoAllowBashIfSandboxed` | boolean | `true` | Auto-approve bash when sandboxed |
| `sandbox.excludedCommands` | array of strings | — | Commands that run outside sandbox |
| `sandbox.allowUnsandboxedCommands` | boolean | `true` | Allow `dangerouslyDisableSandbox` escape hatch |
| `sandbox.filesystem.allowWrite` | array of paths | — | Paths sandbox can write |
| `sandbox.filesystem.denyWrite` | array of paths | — | Paths sandbox cannot write |
| `sandbox.filesystem.denyRead` | array of paths | — | Paths sandbox cannot read |
| `sandbox.filesystem.allowRead` | array of paths | — | Re-allow reading within denyRead |
| `sandbox.filesystem.allowManagedReadPathsOnly` | boolean | `false` | **Managed only** |
| `sandbox.network.allowedDomains` | array of strings | — | Supports `*.` wildcards |
| `sandbox.network.deniedDomains` | array of strings | — | Takes precedence over `allowedDomains` |
| `sandbox.network.allowManagedDomainsOnly` | boolean | `false` | **Managed only** |
| `sandbox.network.httpProxyPort` | number | — | HTTP proxy port |
| `sandbox.network.socksProxyPort` | number | — | SOCKS5 proxy port |
| `sandbox.network.allowUnixSockets` | array of paths | — | macOS only |
| `sandbox.network.allowAllUnixSockets` | boolean | `false` | Allow all Unix sockets |
| `sandbox.network.allowLocalBinding` | boolean | `false` | macOS only; allow binding to localhost ports |
| `sandbox.enableWeakerNestedSandbox` | boolean | `false` | Linux/WSL2 only; unprivileged Docker |
| `sandbox.enableWeakerNetworkIsolation` | boolean | `false` | macOS only; allow system TLS trust service |

**Sandbox path prefix semantics:**

| Prefix | Meaning |
|---|---|
| `/` | Absolute path from filesystem root |
| `~/` | Relative to home directory |
| `./` or no prefix | Relative to project root (project scope) or `~/.claude` (user scope) |

## `worktree` block

| Sub-key | Type | Default | Description |
|---|---|---|---|
| `worktree.baseRef` | `"fresh"` \| `"head"` | `"fresh"` | Which ref new worktrees branch from |
| `worktree.symlinkDirectories` | array of strings | — | Directories to symlink into each worktree |
| `worktree.sparsePaths` | array of strings | — | Directories for sparse-checkout |

## Plugin settings

```json
{
  "enabledPlugins": {
    "my-plugin@my-marketplace": true
  },
  "extraKnownMarketplaces": {
    "my-org": {
      "source": { "type": "github", "repo": "my-org/claude-plugins" },
      "autoUpdate": true
    }
  }
}
```

`extraKnownMarketplaces` source types: `github` (needs `repo`), `git` (needs `url`), `directory` (needs `path`), `hostPattern` (needs `hostPattern`), `settings` (needs `name`, `plugins`), `url` (needs `url`, optional `headers`), `npm` (needs `package`), `file` (needs `path`).

See also: [`SKILL-plugins.md`](SKILL-plugins.md).

## `~/.claude.json` (global config — not `settings.json`)

These keys live in `~/.claude.json`, NOT in `settings.json`:

| Key | Default | Description |
|---|---|---|
| `autoConnectIde` | `false` | Auto-connect to running IDE |
| `autoInstallIdeExtension` | `true` | Auto-install IDE extension in VS Code |
| `externalEditorContext` | `false` | Prepend Claude's previous response in external editor |
| `teammateDefaultModel` | — | Default model for agent team teammates |

## Common mistakes (auto-corrected by `rules/settings.md`)

- `permissions.allow` / `deny` / `ask` must be **arrays** of strings, not a single string.
- Hook event names are **PascalCase**: `PreToolUse`, `PostToolUse`, etc. — lowercase silently fails.
- `enabledPlugins` keys must be `"<plugin>@<marketplace>"` format — bare plugin names are silently ignored.
- `env` values must be **strings** — numbers/booleans should be quoted.
- `sandbox` settings are nested under `"sandbox": { ... }`, not flat at the top level.

---

*Source pages: [`settings.md`](https://code.claude.com/docs/en/settings.md), [`permissions.md`](https://code.claude.com/docs/en/permissions.md), [`permission-modes.md`](https://code.claude.com/docs/en/permission-modes.md) — audited 2026-05-18.*
