---
name: claude-code-settings-edits
description: Auto-correction rules that fire when Claude edits Claude Code settings files. Catches schema typos, deprecated keys, scope confusion, and common mistakes that have appeared in the upstream issue tracker.
appliesTo:
  - "**/.claude/settings.json"
  - "**/.claude/settings.local.json"
---

# Rules: editing `settings.json` / `settings.local.json`

> *This file is auto-updated. The research agent adds rules as it
> finds common mistakes in `anthropics/claude-code` issues.*

## Cross-reference

For the full settings schema, see [`SKILL-settings.md`](../SKILL-settings.md).
For the hook config sub-schema, see [`SKILL-hooks.md`](../SKILL-hooks.md).

## Rules

<!-- seed: replace on first real research pass -->

### `permissions.allow` / `deny` / `ask` must be arrays of strings

These three fields are arrays — not objects, not single strings. Common typo: writing `"allow": "Bash(git:*)"` instead of `"allow": ["Bash(git:*)"]`. Wrap every rule in `[ ... ]` even if there's only one.

### `hooks` keys are event names with PascalCase

Hook event names use PascalCase: `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `Notification`, `UserPromptSubmit`, `PreCompact`, `SessionStart`, `SessionEnd`. Lowercase or snake_case keys silently fail to bind.

### `enabledPlugins` keys use `<plugin>@<marketplace>` format

The key is the qualified plugin id, not the bare plugin name. Example: `"my-plugin@my-marketplace": true`. The bare-name form `"my-plugin": true` may silently fail to enable.

### `sandbox` is a top-level key, not nested under `permissions`

Sandbox config lives at the top level: `{ "sandbox": { "enabled": true, ... } }`. Nesting it under `permissions` silently fails.

### `worktree` settings use dot notation

Worktree settings are at the top level with dot notation: `"worktree.baseRef": "head"`. They are NOT nested under a `worktree` object in the JSON.

### Managed-only settings are ignored outside managed delivery

Settings like `allowedMcpServers`, `channelsEnabled`, `claudeMd`, `allowManagedHooksOnly`, and `strictKnownMarketplaces` are silently ignored when set in user, project, or local settings files. They only take effect in `managed-settings.json`, MDM profiles, or registry keys.

### Windows managed settings legacy path is no longer supported

As of v2.1.75, `C:\ProgramData\ClaudeCode\managed-settings.json` is no longer supported. Use `C:\Program Files\ClaudeCode\managed-settings.json` instead.
