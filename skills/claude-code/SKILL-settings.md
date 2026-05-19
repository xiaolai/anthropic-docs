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

## Top-level keys

Source: `code.claude.com/docs/en/settings.md`. JSON schema: `https://json.schemastore.org/claude-code-settings.json`.

Selected commonly used keys (full list at source URL):

| Key | Type | Notes |
|---|---|---|
| `model` | string | Override default model (e.g. `claude-sonnet-4-6`, `claude-opus-4-7`). `--model` and `ANTHROPIC_MODEL` override per session. |
| `permissions` | object | Tool-permission rules (`allow`, `deny`, `ask`, `defaultMode`, etc.). See § *`permissions` block*. |
| `env` | object | Env vars injected into every session. See § *`env` injection*. |
| `hooks` | object | Hook event handlers. Full reference in [`SKILL-hooks.md`](SKILL-hooks.md). |
| `enabledPlugins` | object | `"<plugin>@<marketplace>": true/false`. See [`SKILL-plugins.md`](SKILL-plugins.md). |
| `extraKnownMarketplaces` | object | Named marketplace sources to pre-register for the project. |
| `agent` | string | Run main thread as a named subagent. |
| `alwaysThinkingEnabled` | boolean | Enable extended thinking by default. |
| `apiKeyHelper` | string | Shell script to generate API auth value (sent as `X-Api-Key`/`Authorization: Bearer`). |
| `attribution` | object | Git commit and PR attribution strings. Keys: `commit`, `pr`. Empty string hides attribution. |
| `autoMemoryEnabled` | boolean | Enable auto memory (default: `true`). |
| `autoMemoryDirectory` | string | Custom directory for auto memory (absolute or `~/`-prefixed). User/policy settings only. |
| `autoMode` | object | Auto-mode classifier config (`environment`, `allow`, `soft_deny`, `hard_deny` arrays). Not read from shared project settings. |
| `autoUpdatesChannel` | string | Update channel: `"latest"` (default) or `"stable"`. |
| `availableModels` | array | Restrict models selectable via `/model`, `--model`, `ANTHROPIC_MODEL`. |
| `awaySummaryEnabled` | boolean | Show session recap on return to terminal (same as `CLAUDE_CODE_ENABLE_AWAY_SUMMARY`). |
| `channelsEnabled` | boolean | (Managed only) Allow channels for the org. Required for Team/Enterprise plans. |
| `claudeMd` | string | (Managed only) CLAUDE.md-style instructions injected org-wide. |
| `claudeMdExcludes` | array | Glob patterns of CLAUDE.md files to skip. |
| `cleanupPeriodDays` | number | Days before session files are deleted at startup (default: 30, min: 1). |
| `companyAnnouncements` | array | Startup announcements cycled randomly. |
| `defaultShell` | string | `"bash"` (default) or `"powershell"` for `!` commands. |
| `disableAllHooks` | boolean | Disable all hooks and custom status line. |
| `disableAutoMode` | string | Set `"disable"` to remove auto mode from Shift+Tab cycle. |
| `disabledMcpjsonServers` | array | MCP server names from `.mcp.json` to reject. |
| `editorMode` | string | Key binding mode: `"normal"` (default) or `"vim"`. |
| `effortLevel` | string | Persist effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"`. |
| `enableAllProjectMcpServers` | boolean | Auto-approve all MCP servers in `.mcp.json` files. |
| `enabledMcpjsonServers` | array | Specific MCP server names from `.mcp.json` to approve. |
| `forceLoginMethod` | string | `"claudeai"` or `"console"` to restrict auth method. |
| `forceLoginOrgUUID` | string\|array | Require login to belong to specific org UUID(s). |
| `hooks` | object | See [`SKILL-hooks.md`](SKILL-hooks.md). |
| `includeGitInstructions` | boolean | Include git workflow instructions in system prompt (default: `true`). |
| `language` | string | Claude's preferred response language (e.g. `"japanese"`, `"spanish"`). |
| `maxSkillDescriptionChars` | number | Per-skill character cap on description text Claude sees (default: 1536). Requires v2.1.105+. |
| `minimumVersion` | string | Minimum version floor for auto-updates (e.g. `"2.1.100"`). |
| `modelOverrides` | object | Map Anthropic model IDs to provider-specific IDs (e.g. Bedrock ARNs). |
| `outputStyle` | string | Output style to adjust system prompt (see `/en/output-styles`). |
| `parentSettingsBehavior` | string | (Managed only) `"first-wins"` (default) or `"merge"` for SDK-supplied managed settings. Requires v2.1.133+. |
| `policyHelper` | object | (MDM/system managed only) Executable that computes managed settings at startup. Keys: `path`, `timeoutMs`, `refreshIntervalMs`. Requires v2.1.136+. |
| `preferredNotifChannel` | string | Notification method: `"auto"`, `"terminal_bell"`, `"iterm2"`, `"iterm2_with_bell"`, `"kitty"`, `"ghostty"`, `"notifications_disabled"`. |
| `sandbox` | object | Sandboxing config (filesystem/network isolation). See § *Sandbox settings*. |
| `skillListingBudgetFraction` | number | Fraction of context window for skill listing (default: `0.01`). Requires v2.1.105+. |
| `skillOverrides` | object | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"`. Requires v2.1.129+. |
| `spinnerTipsEnabled` | boolean | Show tips in spinner (default: `true`). |
| `statusLine` | object | Custom status line config. See `/en/statusline`. |
| `tui` | string | TUI renderer: `"fullscreen"` (alt-screen, flicker-free) or `"default"` (classic). |
| `viewMode` | string | Default transcript view: `"default"`, `"verbose"`, or `"focus"`. |
| `voice` | object | Voice dictation settings: `enabled`, `mode` (`"hold"` or `"tap"`), `autoSubmit`. |
| `worktree.baseRef` | string | Worktree branch base: `"fresh"` (default, from `origin/<default-branch>`) or `"head"` (local HEAD). |
| `worktree.symlinkDirectories` | array | Dirs to symlink from main repo into each worktree (e.g. `["node_modules"]`). |
| `worktree.bgIsolation` | string | Background session isolation: `"worktree"` (default) or `"none"`. Requires v2.1.143+. |

Minimal valid `settings.json`:

```json
{
  "model": "claude-sonnet-4-6"
}
```

**Note:** Global config settings (`autoConnectIde`, `autoInstallIdeExtension`, `externalEditorContext`, `teammateDefaultModel`) are stored in `~/.claude.json`, not `settings.json`.

## `permissions` block

Source: `code.claude.com/docs/en/settings.md#permission-settings`, `code.claude.com/docs/en/permissions.md`.

The `permissions` object inside `settings.json` contains:

| Key | Type | Notes |
|---|---|---|
| `allow` | array | Permission rules to allow tool use (e.g. `"Bash(npm run *)"`, `"Read(~/.zshrc)"`). |
| `deny` | array | Permission rules to deny tool use (e.g. `"Bash(curl *)"`, `"Read(./.env)"`). |
| `ask` | array | Permission rules to ask for confirmation. |
| `additionalDirectories` | array | Additional working directories for file access (e.g. `["../docs/"]`). |
| `defaultMode` | string | Default permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. As of v2.1.142, `auto` is ignored in project/local settings. |
| `disableBypassPermissionsMode` | string | Set `"disable"` to prevent bypassPermissions mode. |
| `skipDangerousModePermissionPrompt` | boolean | Skip confirmation before entering bypass mode (ignored in project settings). |

**Rule format:** `Tool` or `Tool(specifier)`. Rules are evaluated deny-first, then ask, then allow. First match wins.

| Example rule | Effect |
|---|---|
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Read(./.env)` | Reading the `.env` file |
| `WebFetch(domain:example.com)` | Fetches to `example.com` |

**Array settings merge across scopes** (concatenated and deduplicated, not replaced).

## `env` injection

The `env` object under `settings.json` injects environment variables into every session:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

Any `CLAUDE_*` or `ANTHROPIC_*` env var can be set here to apply team-wide. Precedence: actual shell env vars > `env` block in `settings.local.json` > `settings.json` (project) > `settings.json` (user).

See `code.claude.com/docs/en/env-vars` for the full list of recognized env vars.

## `hooks` block

> Cross-reference: full hook event reference lives in [`SKILL-hooks.md`](SKILL-hooks.md).

## `model` selection and overrides

The `model` key in `settings.json` sets the default model for that scope. Use model aliases (`sonnet`, `opus`, `haiku`) or full model IDs (e.g. `claude-sonnet-4-6`, `claude-opus-4-7`).

Override order (highest priority first):
1. `--model` CLI flag (session only)
2. `ANTHROPIC_MODEL` env var (session only)
3. `model` in `settings.local.json`
4. `model` in `settings.json` (project)
5. `model` in `settings.json` (user)

**Restrict available models**: Use `availableModels` to limit which models users can select via `/model`, `--model`, or `ANTHROPIC_MODEL`. Does not affect the "Default" option.

**Model ID overrides for providers**: Use `modelOverrides` to map Anthropic model IDs to Bedrock ARNs or other provider-specific IDs. Example: `{"claude-opus-4-6": "arn:aws:bedrock:us-east-1::foundation-model/..."}`.

Source: `code.claude.com/docs/en/model-config`.

## `enabledPlugins`

> Cross-reference: plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

## Common mistakes (auto-corrected by `rules/settings.md`)

> *Populated by the research agent from `anthropics/claude-code` issues.*

---

*Source pages: `code.claude.com/docs/en/settings.md`.*
