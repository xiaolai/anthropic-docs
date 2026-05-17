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

Source: `code.claude.com/docs/en/settings.md`. The research agent expands this table on each docs change.

## `permissions` block

> *Populated by the research agent.*
> Source: `code.claude.com/docs/en/permission-modes.md` and `permissions.md`,
> `code.claude.com/docs/en/settings.md#permissions`.

## `env` injection

> *Populated by the research agent.*

## `hooks` block

> Cross-reference: full hook event reference lives in [`SKILL-hooks.md`](SKILL-hooks.md).

## `model` selection and overrides

> *Populated by the research agent.*

## `enabledPlugins`

> Cross-reference: plugin lifecycle in [`SKILL-plugins.md`](SKILL-plugins.md).

## Common mistakes (auto-corrected by `rules/settings.md`)

> *Populated by the research agent from `anthropics/claude-code` issues.*

---

*Source pages: `code.claude.com/docs/en/settings.md`. Last reviewed: <pipeline-stamp>.*
