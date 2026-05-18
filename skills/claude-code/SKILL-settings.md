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

Selected commonly-used keys. The JSON Schema at `https://json.schemastore.org/claude-code-settings.json` is the authoritative list. Source: [`code.claude.com/docs/en/settings.md`](https://code.claude.com/docs/en/settings.md).

| Key | Type | Notes |
|---|---|---|
| `model` | string | Override model. Examples: `claude-sonnet-4-6`, `claude-opus-4-7`. `--model` and `ANTHROPIC_MODEL` override for one session. |
| `permissions` | object | `allow`, `deny`, `ask`, `additionalDirectories`, `defaultMode`, `disableBypassPermissionsMode`, `skipDangerousModePermissionPrompt`. See § *`permissions` block* below. |
| `env` | object | Environment variables injected into every session. Also controls e.g. `CLAUDE_CODE_ENABLE_TELEMETRY`. |
| `hooks` | object | Hook event handlers. Full reference in [`SKILL-hooks.md`](SKILL-hooks.md). |
| `enabledPlugins` | object | Map of `"<plugin>@<marketplace>"` → boolean. See [`SKILL-plugins.md`](SKILL-plugins.md). |
| `extraKnownMarketplaces` | object | Named marketplace sources auto-prompted on folder trust. See [`SKILL-plugins.md`](SKILL-plugins.md). |
| `autoUpdatesChannel` | string | `"latest"` (default) or `"stable"` (≈1 week old). |
| `availableModels` | array | Restrict selectable models via `/model` or `--model`. Does not affect the default. |
| `alwaysThinkingEnabled` | bool | Enable extended thinking by default. |
| `effortLevel` | string | Persist effort across sessions: `"low"` / `"medium"` / `"high"` / `"xhigh"`. |
| `language` | string | Claude's response language, e.g. `"japanese"`. Also sets voice dictation language. |
| `outputStyle` | string | Output style preset, e.g. `"Explanatory"`. |
| `tui` | string | `"fullscreen"` for alt-screen renderer; `"default"` for classic. |
| `viewMode` | string | Default transcript view: `"default"`, `"verbose"`, or `"focus"`. |
| `editorMode` | string | Key binding mode: `"normal"` or `"vim"`. |
| `sandbox` | object | Bash sandboxing (macOS, Linux, WSL2). See § *Sandbox settings* below. |
| `statusLine` | object | Custom status line command. See [statusline docs](https://code.claude.com/docs/en/statusline.md). |
| `apiKeyHelper` | string | Shell script generating an API auth value (sent as `X-Api-Key` and `Authorization: Bearer`). |
| `attribution` | object | Git commit and PR attribution strings. `commit` and `pr` keys; empty string hides attribution. |
| `autoMemoryEnabled` | bool | Default `true`. Set `false` to disable auto memory read/write. |
| `worktree.baseRef` | string | `"fresh"` (default, branches from `origin/<default>`) or `"head"` (branches from local HEAD). |
| `cleanupPeriodDays` | number | Delete session files older than N days at startup (default: 30, minimum 1). |
| `minimumVersion` | string | Prevent downgrade below this version string. |
| `skillOverrides` | object | Per-skill visibility: `"on"` / `"name-only"` / `"user-invocable-only"` / `"off"`. (v2.1.129+) |
| `disableAllHooks` | bool | Disable all hooks and custom status line. |
| `disableAutoMode` | string | `"disable"` to remove auto mode from Shift+Tab cycle. |
| `spinnerTipsEnabled` | bool | Default `true`. Show tips while Claude works. |
| `includeCoAuthoredBy` | bool | **Deprecated** – use `attribution` instead. |

Minimal valid `settings.json`:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-6"
}
```

## `permissions` block

Source: [`settings.md#permission-settings`](https://code.claude.com/docs/en/settings.md) and [`permissions.md`](https://code.claude.com/docs/en/permissions.md).

```json
{
  "permissions": {
    "allow":  ["Bash(npm run lint)", "Bash(npm run test *)", "Read(~/.zshrc)"],
    "deny":   ["Bash(curl *)", "Read(./.env)", "Read(./secrets/**)"],
    "ask":    ["Bash(git push *)"],
    "additionalDirectories": ["../docs/"],
    "defaultMode": "acceptEdits"
  }
}
```

| Sub-key | Type | Notes |
|---|---|---|
| `allow` | string[] | Rules auto-approved. Deny evaluated first, then ask, then allow. First match wins. |
| `deny` | string[] | Rules always rejected. |
| `ask` | string[] | Rules that prompt for confirmation. |
| `additionalDirectories` | string[] | Extra working directories for file access (not `.claude/` config discovery). |
| `defaultMode` | string | Default permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. |
| `disableBypassPermissionsMode` | string | `"disable"` to block bypass-permissions mode. |
| `skipDangerousModePermissionPrompt` | bool | Skip the confirmation before entering bypass mode. Ignored in project settings. |

**Rule syntax:** `Tool` or `Tool(specifier)`. Examples: `Bash`, `Bash(npm run *)`, `Read(./.env)`, `WebFetch(domain:example.com)`, `Edit(*.ts)`. Arrays merge across scopes (they concatenate, not override). See full grammar at [`permissions.md`](https://code.claude.com/docs/en/permissions.md#permission-rule-syntax).

## `env` injection

The `env` key injects environment variables into every session. Useful for rolling out telemetry flags or auth helpers to a team:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp"
  }
}
```

Any env var accepted by Claude Code (see [`env-vars.md`](https://code.claude.com/docs/en/env-vars.md)) can go here. To disable auto-updates entirely use `"DISABLE_AUTOUPDATER": "1"`. Precedence: actual shell env > `settings.local.json` env > `settings.json` (project) env > `settings.json` (user) env.

## `hooks` block

> Cross-reference: full hook event reference lives in [`SKILL-hooks.md`](SKILL-hooks.md).

## `model` selection and overrides

Override precedence (highest wins): `--model` flag > `ANTHROPIC_MODEL` env var > `settings.json` `model` key.

```json
{ "model": "claude-opus-4-7" }
```

**Model aliases**: `sonnet`, `opus`, `haiku` resolve to the latest stable model in that family. Full model IDs like `claude-sonnet-4-6` pin an exact version. `effortLevel` controls extended thinking budget; accepted by Opus 4.7+ and Sonnet 4.6+. For Bedrock/Vertex ARN remapping use `modelOverrides`: `{"claude-opus-4-6": "arn:aws:bedrock:us-east-1::..."}`. To restrict which models users can pick via `/model`, set `availableModels: ["sonnet", "haiku"]`. Source: [`model-config.md`](https://code.claude.com/docs/en/model-config.md).

## `enabledPlugins`

Cross-reference: plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

```json
{
  "enabledPlugins": {
    "code-formatter@team-tools": true,
    "experimental@personal": false
  }
}
```

Format: `"<plugin-name>@<marketplace-name>"` → boolean. Project settings take precedence over user settings for a given key. To opt out of a project-enabled plugin, set it to `false` in `.claude/settings.local.json`.

## Sandbox settings

Configure bash sandboxing under the `sandbox` key. Supported on macOS, Linux, and WSL2.

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "excludedCommands": ["docker *"],
    "filesystem": {
      "allowWrite": ["/tmp/build", "~/.kube"],
      "denyRead": ["~/.aws/credentials"]
    },
    "network": {
      "allowedDomains": ["github.com", "*.npmjs.org"],
      "allowLocalBinding": true
    }
  }
}
```

Key `sandbox` fields: `enabled` (bool), `failIfUnavailable` (bool), `autoAllowBashIfSandboxed` (bool, default true), `excludedCommands` (string[]), `allowUnsandboxedCommands` (bool), `filesystem.allowWrite` / `denyWrite` / `denyRead` / `allowRead` (all string[], merge across scopes), `network.allowedDomains`, `network.deniedDomains`, `network.allowAllUnixSockets` (bool). Path prefix convention: `/` = absolute, `~/` = home-relative, `./` or no prefix = project-root-relative. Source: [`settings.md#sandbox-settings`](https://code.claude.com/docs/en/settings.md) and [`sandboxing.md`](https://code.claude.com/docs/en/sandboxing.md).

## Managed-only settings

These keys are only honored from `managed-settings.json` (or MDM/registry policy) and ignored in user/project/local settings:

| Key | Purpose |
|---|---|
| `allowedMcpServers` | Allowlist of MCP servers users can configure. |
| `allowManagedMcpServersOnly` | Only managed allowlist applies. |
| `allowManagedPermissionRulesOnly` | Block user/project allow/ask/deny rules. |
| `allowManagedHooksOnly` | Block user/project/plugin hooks (except force-enabled plugin hooks). |
| `strictKnownMarketplaces` | Allowlist/blocklist of plugin marketplace sources. |
| `blockedMarketplaces` | Explicit denylist of marketplace sources. |
| `forceLoginMethod` | `"claudeai"` or `"console"`. |
| `forceLoginOrgUUID` | Require login to a specific org UUID. |
| `claudeMd` | Organization-wide CLAUDE.md instructions injected for all users. |
| `channelsEnabled` | Allow channels (Team/Enterprise plans). |
| `disableRemoteControl` | Block Remote Control feature. (v2.1.128+) |
| `policyHelper` | Executable that computes managed settings at startup. (v2.1.136+) |
| `parentSettingsBehavior` | `"first-wins"` (default) or `"merge"` for embedder-supplied managed settings. (v2.1.133+) |

Managed settings files: macOS `/Library/Application Support/ClaudeCode/managed-settings.json`, Linux/WSL `/etc/claude-code/managed-settings.json`, Windows `C:\Program Files\ClaudeCode\managed-settings.json`. Drop-in directory `managed-settings.d/` in the same location is merged alphabetically on top of the base file. Source: [`settings.md`](https://code.claude.com/docs/en/settings.md).

## Common mistakes (auto-corrected by `rules/settings.md`)

> *Populated by the research agent from `anthropics/claude-code` issues.*

---

*Source pages: `code.claude.com/docs/en/settings.md`.*
