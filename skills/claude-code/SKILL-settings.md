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

## `permissions` block

Source: [`code.claude.com/docs/en/settings.md#permission-settings`](https://code.claude.com/docs/en/settings.md)

| Key | Type | Notes |
|---|---|---|
| `allow` | string[] | Tool rules that auto-approve without prompting. Arrays **merge** across scopes. |
| `ask` | string[] | Tool rules that trigger a confirmation prompt. |
| `deny` | string[] | Tool rules that always block. Deny wins over allow. |
| `additionalDirectories` | string[] | Extra working directories for file access (does not grant config discovery). |
| `defaultMode` | string | Starting permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. `auto` is ignored in project/local settings. |
| `disableBypassPermissionsMode` | `"disable"` | Prevents `bypassPermissions` mode from being activated. |
| `skipDangerousModePermissionPrompt` | boolean | Skip confirmation before `bypassPermissions`; ignored in project settings. |

**Permission rule syntax**: `Tool` or `Tool(specifier)`. Examples:
- `"Bash"` — all Bash commands
- `"Bash(npm run *)"` — commands matching `npm run *`
- `"Read(./.env)"` — reading `.env`
- `"WebFetch(domain:example.com)"` — fetches to example.com

Rules are evaluated: **deny first**, then ask, then allow. First matching rule wins.

```json
{
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(npm run test *)"],
    "deny": ["Bash(curl *)", "Read(./.env)"],
    "defaultMode": "acceptEdits"
  }
}
```

## `env` injection

The `env` key in `settings.json` injects environment variables into every tool call and session for the applicable scope. Values must be strings (numbers/booleans must be quoted).

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "NODE_ENV": "development"
  }
}
```

Precedence: env vars set on the CLI shell override those in `env`; `env` in higher-priority scopes (local > project > user) override lower ones. The full env-var reference is at [`code.claude.com/docs/en/env-vars.md`](https://code.claude.com/docs/en/env-vars.md).

## `hooks` block

> Cross-reference: full hook event reference lives in [`SKILL-hooks.md`](SKILL-hooks.md).

## `model` selection and overrides

Source: [`code.claude.com/docs/en/model-config.md`](https://code.claude.com/docs/en/model-config.md)

Set the default model for a scope with the `model` key:

```json
{ "model": "claude-sonnet-4-6" }
```

Override precedence (highest wins): `--model` CLI flag → `ANTHROPIC_MODEL` env var → `settings.json` `model` key.

Key model-related settings:

| Key | Notes |
|---|---|
| `model` | Model name or alias (`sonnet`, `opus`). Per-scope. |
| `effortLevel` | Persist effort level: `low`, `medium`, `high`, `xhigh`. `/effort` command writes this. |
| `availableModels` | (Managed) Restrict which models users can select. |
| `modelOverrides` | Map Anthropic model IDs to provider-specific IDs (e.g., Bedrock ARNs). |
| `alwaysThinkingEnabled` | Enable extended thinking by default. |

## `enabledPlugins`

> Cross-reference: plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

## Common mistakes (auto-corrected by `rules/settings.md`)

> *Populated by the research agent from `anthropics/claude-code` issues.*

---

*Source pages: `code.claude.com/docs/en/settings.md`.*
