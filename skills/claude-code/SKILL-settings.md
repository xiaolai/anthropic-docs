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

Selected important keys (full list at `code.claude.com/docs/en/settings.md#available-settings`):

| Key | Type | Default | Notes |
|---|---|---|---|
| `model` | string | account default | Override default model. E.g. `claude-sonnet-4-6`. |
| `permissions` | object | `{}` | Tool-permission rules. See § *`permissions` block* below. |
| `env` | object | `{}` | Environment variables injected into every session. See § *`env` injection*. |
| `hooks` | object | `{}` | Hook event handlers. Full reference in [`SKILL-hooks.md`](SKILL-hooks.md). |
| `enabledPlugins` | object | `{}` | Map of `"<plugin>@<marketplace>"` → boolean. See [`SKILL-plugins.md`](SKILL-plugins.md). |
| `extraKnownMarketplaces` | object | `{}` | Named marketplaces to auto-register for team members. |
| `autoUpdatesChannel` | string | `"latest"` | `"stable"` or `"latest"`. |
| `cleanupPeriodDays` | number | 30 | Session files older than N days deleted at startup. |
| `disableAllHooks` | boolean | `false` | Disable all hooks and custom status line. |
| `editorMode` | string | `"normal"` | `"normal"` or `"vim"`. |
| `effortLevel` | string | — | Persist effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"`. |
| `language` | string | — | Claude's preferred response language, e.g. `"japanese"`. |
| `skillOverrides` | object | `{}` | Per-skill visibility: `"on"`, `"name-only"`, `"user-invocable-only"`, `"off"`. |
| `sandbox` | object | — | Sandboxing config (see settings docs for sub-keys). |
| `attribution` | object | — | Git commit and PR attribution strings. |
| `worktree.*` | — | — | Worktree behavior: `baseRef`, `symlinkDirectories`, `sparsePaths`. |
| `statusLine` | object | — | Custom status line: `{"type":"command","command":"..."}`. |
| `tui` | string | — | Terminal renderer: `"fullscreen"` or `"default"`. |
| `viewMode` | string | — | Default transcript view: `"default"`, `"verbose"`, or `"focus"`. |

Managed-only keys (set in `managed-settings.json` only): `allowManagedHooksOnly`, `allowManagedPermissionRulesOnly`, `allowManagedMcpServersOnly`, `strictKnownMarketplaces`, `claudeMd`, `companyAnnouncements`, `disableAutoMode`, `channelsEnabled`.

Minimal valid `settings.json`:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "model": "claude-sonnet-4-6"
}
```

Source: `code.claude.com/docs/en/settings.md`.

## `permissions` block

The `permissions` key is an object with these sub-keys:

| Key | Type | Description |
|---|---|---|
| `allow` | string[] | Tool rules to auto-allow. Format: `Tool` or `Tool(specifier)`. |
| `ask` | string[] | Tool rules to confirm before allowing. |
| `deny` | string[] | Tool rules to block. Evaluated first. |
| `additionalDirectories` | string[] | Extra working directories for file access. |
| `defaultMode` | string | Starting permission mode. Values: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. |
| `disableBypassPermissionsMode` | `"disable"` | Prevent `bypassPermissions` mode from being activated. |
| `skipDangerousModePermissionPrompt` | boolean | Skip confirmation before entering bypass mode. Ignored in project settings. |

**Permission rule syntax** — format is `Tool` or `Tool(specifier)`:

| Rule | Effect |
|---|---|
| `Bash` | Matches all Bash commands |
| `Bash(npm run *)` | Matches commands starting with `npm run` |
| `Read(./.env)` | Matches reading the `.env` file |
| `WebFetch(domain:example.com)` | Matches fetch requests to example.com |
| `Skill(deploy)` | Matches the `deploy` skill |

Deny rules are evaluated first, then `ask`, then `allow`. First match wins. Arrays from different scopes are **concatenated** (not replaced).

## `env` injection

The `env` key is a `Record<string, string>` object. Variables are injected into every tool call and session. Example:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "DISABLE_AUTOUPDATER": "1"
  }
}
```

Any environment variable accepted by the CLI can be set here. Values in `env` take effect for every session that loads the settings file. The `env` key can be set at user, project, or local scope. Arrays (not applicable here) merge; scalars in `env` follow normal scope precedence (higher scope wins).

## `hooks` block

> Cross-reference: full hook event reference lives in [`SKILL-hooks.md`](SKILL-hooks.md).

## `model` selection and overrides

> *Populated by the research agent.*

## `enabledPlugins`

> Cross-reference: plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

## Common mistakes (auto-corrected by `rules/settings.md`)

> *Populated by the research agent from `anthropics/claude-code` issues.*

---

*Source pages: `code.claude.com/docs/en/settings.md`.*
