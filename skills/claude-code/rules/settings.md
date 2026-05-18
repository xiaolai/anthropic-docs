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

### Global config keys belong in `~/.claude.json`, not `settings.json`

Keys like `autoConnectIde`, `autoInstallIdeExtension`, `externalEditorContext`, and `teammateDefaultModel` are stored in `~/.claude.json`. Adding them to `settings.json` triggers a schema validation error. Check the "Global config settings" table in [`SKILL-settings.md`](../SKILL-settings.md) before adding unfamiliar keys.

### Managed-only keys are silently ignored outside managed settings

Keys like `allowManagedHooksOnly`, `allowManagedMcpServersOnly`, `allowManagedPermissionRulesOnly`, `channelsEnabled`, `claudeMd`, `allowedMcpServers`, and `deniedMcpServers` are only honored when set in `managed-settings.json` or delivered via MDM/server-managed settings. Setting them in `settings.json` (user or project scope) has no effect.

### Hook event names in `settings.json` are now expanded — 29 total

The full set includes: `SessionStart`, `Setup`, `UserPromptSubmit`, `UserPromptExpansion`, `PreToolUse`, `PermissionRequest`, `PermissionDenied`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Notification`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `Stop`, `StopFailure`, `TeammateIdle`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`, `WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `Elicitation`, `ElicitationResult`, `SessionEnd`. Any typo or unknown key is silently ignored.
