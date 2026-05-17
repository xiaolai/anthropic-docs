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
