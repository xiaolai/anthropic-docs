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

Curated reference for the most commonly used `settings.json` keys. For the complete list see [settings docs](https://code.claude.com/docs/en/settings.md).

| Key | Type | Notes |
|---|---|---|
| `model` | string | Override the default model. Examples: `"claude-sonnet-4-6"`, `"claude-opus-4-7"`. `--model` and `ANTHROPIC_MODEL` override this per session. |
| `permissions` | object | Tool-permission rules (`allow`, `deny`, `ask`, `defaultMode`, `additionalDirectories`). See § *`permissions` block* below. |
| `env` | object | Environment variables injected into every session. See § *`env` injection*. |
| `hooks` | object | Hook event handlers keyed by event name. Full reference in [`SKILL-hooks.md`](SKILL-hooks.md). |
| `enabledPlugins` | object | Map of `"<plugin>@<marketplace>"` → boolean. See [`SKILL-plugins.md`](SKILL-plugins.md). |
| `extraKnownMarketplaces` | object | Additional plugin marketplaces to make available. Key is marketplace name, value has `source` and optional `autoUpdate`. |
| `alwaysThinkingEnabled` | boolean | Enable extended thinking by default for all sessions. |
| `autoMemoryEnabled` | boolean | Default `true`. Set `false` to stop Claude reading/writing auto memory. |
| `autoUpdatesChannel` | string | `"stable"` for ~1-week-old releases; `"latest"` (default) for newest. |
| `awaySummaryEnabled` | boolean | Show a one-line recap when returning to terminal after a few minutes away. |
| `cleanupPeriodDays` | number | Transcript retention in days (default: 30, min: 1). |
| `companyAnnouncements` | string[] | Messages shown at startup, cycled randomly. |
| `defaultShell` | string | `"bash"` (default) or `"powershell"`. |
| `disableAllHooks` | boolean | Disable all hooks and custom status line. |
| `effortLevel` | string | Persisted effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"`. |
| `language` | string | Claude's preferred response language (e.g. `"japanese"`, `"french"`). Also sets voice dictation language. |
| `maxSkillDescriptionChars` | number | Per-skill char cap on description in skill listing (default: 1536). Requires v2.1.105+. |
| `minimumVersion` | string | Prevents auto-updates from installing below this version. |
| `modelOverrides` | object | Map Anthropic model IDs to provider-specific IDs (e.g. Bedrock ARNs). |
| `outputStyle` | string | Configure output style to adjust system prompt. See [output styles](https://code.claude.com/docs/en/output-styles.md). |
| `skillListingBudgetFraction` | number | Fraction of context window for skill listing (default: 0.01). Requires v2.1.105+. |
| `skillOverrides` | object | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, or `"off"`. Requires v2.1.129+. |
| `spinnerTipsEnabled` | boolean | Show tips while Claude is working (default: true). |
| `statusLine` | object | Custom status line config. `{"type": "command", "command": "~/.claude/statusline.sh"}`. |
| `syntaxHighlightingDisabled` | boolean | Disable syntax highlighting in diffs and code blocks. |
| `tui` | string | Terminal UI renderer: `"default"` or `"fullscreen"` (flicker-free alt-screen). |
| `viewMode` | string | Default transcript view: `"default"`, `"verbose"`, or `"focus"`. |
| `voice` | object | Voice dictation: `{enabled, mode: "hold"/"tap", autoSubmit}`. |
| `worktree.baseRef` | string | `"fresh"` (default, branches from `origin/<default>`) or `"head"` (from local HEAD). |
| `worktree.symlinkDirectories` | string[] | Dirs to symlink from main repo into each worktree (e.g. `["node_modules"]`). |

Managed-only keys (set in `managed-settings.json` or MDM policies only):

| Key | Notes |
|---|---|
| `allowManagedHooksOnly` | Only managed/SDK hooks load; user and project hooks are blocked. |
| `allowManagedMcpServersOnly` | Only admin-defined MCP servers are allowed. |
| `allowManagedPermissionRulesOnly` | Only managed `allow`/`deny`/`ask` rules apply. |
| `allowedMcpServers` | Allowlist of allowed MCP servers (by `serverName`). |
| `deniedMcpServers` | Denylist of blocked MCP servers. Takes precedence over allowlist. |
| `disableAutoMode` | Set `"disable"` to remove auto mode from Shift+Tab cycle. |
| `disableBypassPermissionsMode` | Not here — see `permissions.disableBypassPermissionsMode`. |
| `forceLoginMethod` | `"claudeai"` or `"console"` to restrict login method. |
| `forceLoginOrgUUID` | UUID(s) that authenticated accounts must belong to. |
| `policyHelper` | `{path, timeoutMs?, refreshIntervalMs?}` — dynamic managed settings via executable. Requires v2.1.136+. |
| `strictKnownMarketplaces` | Allowlist of plugin marketplace sources. |

Minimal valid `settings.json`:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-6"
}
```

Source: [settings.md](https://code.claude.com/docs/en/settings.md).

## `permissions` block

The `permissions` object in `settings.json` controls tool access. Keys:

| Key | Type | Notes |
|---|---|---|
| `allow` | string[] | Rules that permit a tool without prompting. |
| `ask` | string[] | Rules that always prompt before allowing. |
| `deny` | string[] | Rules that permanently block a tool. Evaluated first — deny wins. |
| `additionalDirectories` | string[] | Extra project-root paths Claude can read/edit files in. |
| `defaultMode` | string | Starting permission mode: `"default"`, `"acceptEdits"`, `"plan"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"`. As of v2.1.142, `"auto"` is ignored in project/local settings. |
| `disableBypassPermissionsMode` | string | Set `"disable"` to prevent `bypassPermissions` mode. |
| `skipDangerousModePermissionPrompt` | boolean | Skip confirmation before `bypassPermissions`. Ignored in project settings. |

Rule evaluation order: **deny → ask → allow**. First matching rule wins. Rules are arrays of strings—never a single string.

### Permission rule syntax

`Tool` or `Tool(specifier)`. Wildcards (`*`) supported in Bash rules.

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git commit *)",
      "Read(~/.zshrc)"
    ],
    "deny": [
      "Bash(git push *)",
      "Read(./.env)",
      "Read(./secrets/**)",
      "WebFetch"
    ]
  }
}
```

| Rule form | Effect |
|---|---|
| `Bash` | All Bash commands |
| `Bash(npm run *)` | Commands starting with `npm run` |
| `Bash(git * main)` | git commands whose last arg is `main` |
| `Read(./.env)` | Reading `.env` in project root |
| `Read(//Users/alice/secrets/**)` | Absolute path (`//` = filesystem root) |
| `Read(~/Documents/*.pdf)` | Home-relative path |
| `WebFetch(domain:example.com)` | Fetches to `example.com` |
| `mcp__<server>__<tool>` | Specific MCP tool |

Compound Bash commands are parsed — each sub-command must match independently. Claude Code recognizes built-in read-only commands (`ls`, `cat`, `echo`, `grep`, `git status`, etc.) and runs them without prompting.

Source: [permissions.md](https://code.claude.com/docs/en/permissions.md), [settings.md](https://code.claude.com/docs/en/settings.md#permission-settings).

### Sandbox settings

`settings.json` → `sandbox` key controls OS-level sandboxing (macOS, Linux, WSL2):

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

Source: [settings.md](https://code.claude.com/docs/en/settings.md#sandbox-settings).

## `env` injection

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "MY_TOOL_TOKEN": "..."
  }
}
```

All values must be **strings**. The `env` object is set per-scope; higher scopes override lower for scalar values. Use `env` to inject secrets without exposing them in hook commands or command lines.

Common env vars set this way: `ANTHROPIC_API_KEY`, `DISABLE_AUTOUPDATER`, `CLAUDE_CODE_ENABLE_TELEMETRY`.

## `hooks` block

> Cross-reference: full hook event reference lives in [`SKILL-hooks.md`](SKILL-hooks.md).

## `model` selection and overrides

```json
{ "model": "claude-opus-4-7" }
```

Aliases: `"sonnet"` (latest Sonnet), `"opus"` (latest Opus), `"haiku"` (latest Haiku). Full model IDs also accepted.

Override order (highest wins): `--model` CLI flag > `ANTHROPIC_MODEL` env var > `model` in `settings.json`.

Use `modelOverrides` to map Anthropic model IDs to provider-specific IDs (e.g. Bedrock inference profile ARNs):
```json
{ "modelOverrides": { "claude-opus-4-6": "arn:aws:bedrock:us-east-1::..." } }
```

Use `availableModels` (managed-only) to restrict which models users can select.

## `enabledPlugins`

```json
{
  "enabledPlugins": {
    "formatter@acme-tools": true,
    "experimental-features@personal": false
  }
}
```

Key format: `"<plugin-name>@<marketplace-name>"`. Setting `true` enables, `false` disables. Project settings override user settings for the same key; use `settings.local.json` to opt out of a project-enabled plugin on your machine.

Cross-reference: full plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

## Common mistakes (auto-corrected by `rules/settings.md`)

> *Populated by the research agent from `anthropics/claude-code` issues.*

---

*Source pages: `code.claude.com/docs/en/settings.md`.*
