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

<!-- seed: replace on first real research pass -->

| Key | Type | Default | Notes |
|---|---|---|---|
| `model` | string | (account default) | Override the default model for this scope. Examples: `claude-sonnet-4-6`, `claude-opus-4-7`, `claude-haiku-4-5`. |
| `permissions` | object | `{}` | Tool-permission rules. See § *`permissions` block* below. |
| `env` | object | `{}` | Environment variables injected into every tool call. See § *`env` injection*. |
| `hooks` | object | `{}` | Hook event handlers. Full reference in [`SKILL-hooks.md`](SKILL-hooks.md). |
| `enabledPlugins` | object | `{}` | Map of `"<plugin>@<marketplace>"` → boolean. See [`SKILL-plugins.md`](SKILL-plugins.md). |

Minimal valid `settings.json`:

```json
{
  "model": "claude-sonnet-4-6"
}
```

Source: `code.claude.com/docs/en/settings.md`. The research agent expands this table on each daily run when upstream documents a new key.

### Selected additional top-level settings keys

| Key | Type | Default | Notes |
|---|---|---|---|
| `autoUpdatesChannel` | string | `"latest"` | `"stable"` for one-week-old vetted releases; `"latest"` for newest. |
| `cleanupPeriodDays` | number | 30 | Session files older than this are deleted at startup. Min 1. |
| `companyAnnouncements` | array of strings | `[]` | Shown at startup, cycled randomly. Managed settings only in practice. |
| `disableAllHooks` | boolean | `false` | Disables all hooks including custom status line. |
| `editorMode` | string | `"normal"` | Key binding mode: `"normal"` or `"vim"`. |
| `effortLevel` | string | (model default) | Persisted effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"`. |
| `includeGitInstructions` | boolean | `true` | Include built-in git workflow instructions in the system prompt. |
| `language` | string | (system) | Claude's preferred response language, e.g. `"japanese"`. |
| `minimumVersion` | string | (none) | Prevent auto-update/install below this version. |
| `outputStyle` | string | (none) | Output style name, e.g. `"Explanatory"`. See output-styles docs. |
| `spinnerTipsEnabled` | boolean | `true` | Show tips while Claude is working. |
| `statusLine` | object/string | (none) | Custom status line. `{"type": "command", "command": "~/.claude/statusline.sh"}` |
| `tui` | string | `"default"` | TUI renderer: `"default"` or `"fullscreen"` (flicker-free alt-screen). |
| `viewMode` | string | `"default"` | Default transcript view: `"default"`, `"verbose"`, or `"focus"`. |

For the complete list of ~50+ settings keys, see [settings.md](https://code.claude.com/docs/en/settings.md#available-settings).

## `permissions` block

The `permissions` key in `settings.json` contains these sub-keys:

| Sub-key | Type | Description |
|---|---|---|
| `allow` | array of strings | Permission rules to allow tool use without prompting. See rule syntax below. |
| `ask` | array of strings | Permission rules to prompt for confirmation on tool use. |
| `deny` | array of strings | Permission rules to block tool use. Deny is evaluated first. |
| `additionalDirectories` | array of strings | Additional working directories for file access. |
| `defaultMode` | string | Default permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, or `bypassPermissions`. |
| `disableBypassPermissionsMode` | string | Set to `"disable"` to prevent `bypassPermissions` mode. Most useful in managed settings. |
| `skipDangerousModePermissionPrompt` | boolean | Skip confirmation before entering bypass permissions mode. |

Permission rule syntax: `Tool` or `Tool(specifier)`. Rules evaluate in order: deny → ask → allow. First matching rule wins.

Examples:
```json
{
  "permissions": {
    "allow": ["Bash(npm run *)", "Bash(git commit *)", "Read(~/.zshrc)"],
    "deny": ["Bash(curl *)", "Read(./.env)", "Read(./secrets/**)"],
    "defaultMode": "acceptEdits"
  }
}
```

Source: `code.claude.com/docs/en/permissions.md`, `code.claude.com/docs/en/settings.md`.

## `env` injection

The `env` key in `settings.json` injects environment variables into every tool call and subprocess:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "MY_CUSTOM_VAR": "value"
  }
}
```

These variables are set on every Bash, MCP, and other tool invocation for the session. Use this for API keys, telemetry config, or other per-project environment needs.

Source: `code.claude.com/docs/en/settings.md`.

## `hooks` block

> Cross-reference: full hook event reference lives in [`SKILL-hooks.md`](SKILL-hooks.md).

## `model` selection and overrides

Set the default model via the `model` key. The `--model` CLI flag and `ANTHROPIC_MODEL` env var override it for one session.

Model aliases: `sonnet` (latest Sonnet), `opus` (latest Opus), `haiku` (latest Haiku). Also accepts full model IDs like `claude-sonnet-4-6`, `claude-opus-4-7`.

`modelOverrides` maps Anthropic model IDs to provider-specific IDs (e.g., Bedrock ARNs):
```json
{
  "model": "claude-sonnet-4-6",
  "modelOverrides": {
    "claude-opus-4-6": "arn:aws:bedrock:us-east-1::foundation-model/..."
  }
}
```

`effortLevel` persists the effort level across sessions: `"low"`, `"medium"`, `"high"`, `"xhigh"`. Overridable with `--effort` or `/effort`.

Source: `code.claude.com/docs/en/settings.md`, `code.claude.com/docs/en/model-config.md`.

## `enabledPlugins`

> Cross-reference: plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

## Sandbox settings (`sandbox` key)

Configure OS-level bash isolation under the `sandbox` key:

| Key | Type | Default | Notes |
|---|---|---|---|
| `enabled` | boolean | `false` | Enable bash sandboxing (macOS, Linux, WSL2). |
| `autoAllowBashIfSandboxed` | boolean | `true` | Auto-approve bash when sandboxed. |
| `excludedCommands` | array | `[]` | Commands that bypass the sandbox (e.g. `["docker *"]`). |
| `filesystem.allowWrite` | array | `[]` | Additional paths sandboxed commands can write. |
| `filesystem.denyRead` | array | `[]` | Paths sandboxed commands cannot read. |
| `network.allowedDomains` | array | `[]` | Domains allowed for outbound traffic. Wildcards supported. |
| `network.deniedDomains` | array | `[]` | Domains blocked for outbound traffic. Takes precedence over allowedDomains. |

Source: `code.claude.com/docs/en/sandboxing.md`, `code.claude.com/docs/en/settings.md`.

## Common mistakes (auto-corrected by `rules/settings.md`)

> *Populated by the research agent from `anthropics/claude-code` issues.*

---

*Source pages: `code.claude.com/docs/en/settings.md`.*
