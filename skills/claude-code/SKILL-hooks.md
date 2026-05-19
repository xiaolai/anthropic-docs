---
name: claude-code-hooks
description: |
  Deep reference for Claude Code's hook system. Covers every hook
  event (SessionStart, Setup, UserPromptSubmit, UserPromptExpansion,
  PreToolUse, PermissionRequest, PermissionDenied, PostToolUse,
  PostToolUseFailure, PostToolBatch, Notification, SubagentStart,
  SubagentStop, TaskCreated, TaskCompleted, Stop, StopFailure,
  TeammateIdle, InstructionsLoaded, ConfigChange, CwdChanged,
  FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact,
  Elicitation, ElicitationResult, SessionEnd), the input JSON shape each
  event delivers to your hook command, the output JSON shape the hook can
  return to influence Claude's behavior, matcher syntax, blocking vs
  non-blocking semantics, and authoring patterns. Read this file when the
  user asks about hook events, hook scripts, hook matchers, blocking tool
  calls, or hook debugging.
source: https://code.claude.com/docs/en/hooks.md
---

# Claude Code — Hooks

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for hook questions.*

## Hook event catalog

Source: [`code.claude.com/docs/en/hooks.md`](https://code.claude.com/docs/en/hooks.md)

| Event | When it fires | Blocking? |
|---|---|---|
| `SessionStart` | Session begins or resumes. Matcher: `startup`, `resume`, `clear`, `compact` | no |
| `Setup` | Start with `--init-only` or `--init`/`--maintenance` in `-p` mode. Matcher: `init`, `maintenance` | no |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | no |
| `UserPromptExpansion` | A user-typed command expands into a prompt. Can block the expansion | **yes** |
| `PreToolUse` | Before a tool call executes. Matcher: tool name. Can block | **yes** |
| `PermissionRequest` | A permission dialog appears | no |
| `PermissionDenied` | Tool denied by auto-mode classifier. Return `{retry: true}` to allow model retry | no |
| `PostToolUse` | After a tool call succeeds | no |
| `PostToolUseFailure` | After a tool call fails | no |
| `PostToolBatch` | After a full batch of parallel tool calls resolves | no |
| `Notification` | Claude Code sends a notification. Matcher: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_*` | no |
| `SubagentStart` | A subagent is spawned. Matcher: agent type or name | no |
| `SubagentStop` | A subagent finishes | no |
| `TaskCreated` | Task created via `TaskCreate` tool | no |
| `TaskCompleted` | Task marked as completed | no |
| `Stop` | Claude finishes responding | no |
| `StopFailure` | Turn ends due to API error (output + exit code ignored) | — |
| `TeammateIdle` | An agent team teammate is about to go idle | no |
| `InstructionsLoaded` | A `CLAUDE.md` or `.claude/rules/*.md` file is loaded into context | no |
| `ConfigChange` | A configuration file changes during a session | no |
| `CwdChanged` | Working directory changes (e.g., `cd` command) | no |
| `FileChanged` | A watched file changes on disk. Matcher field specifies filenames to watch | no |
| `WorktreeCreate` | Worktree being created via `--worktree` or `isolation: "worktree"`. Replaces default git behavior | **yes** |
| `WorktreeRemove` | Worktree being removed | no |
| `PreCompact` | Before context compaction. Matcher: `manual`, `auto` | no |
| `PostCompact` | After context compaction completes | no |
| `Elicitation` | MCP server requests user input during a tool call | no |
| `ElicitationResult` | User responds to MCP elicitation, before response sent to server | no |
| `SessionEnd` | Session terminates. Matcher: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` | no |

## Configuration: where hooks live

Hooks are declared in `settings.json` under the `hooks` key. Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) `hooks` block.

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No (local) |
| `.claude/settings.json` | Single project | Yes (committed) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (bundled) |
| Skill/agent frontmatter | While component is active | Yes (in component file) |

Three-level nesting: **hook event** → **matcher group** (filter) → **hook handler** (command/HTTP/MCP/prompt/agent).

## Matcher syntax

| Matcher value | Evaluated as | Example |
|---|---|---|
| `"*"`, `""`, or omitted | Match all | fires on every event occurrence |
| Letters, digits, `_`, `\|` only | Exact string or `\|`-separated list | `Bash` or `Edit\|Write` |
| Any other character | JavaScript regex | `^Notebook`, `mcp__memory__.*` |

`FileChanged` uses the matcher as a filename glob, not a regex. Each event matches on a different field: tool events match the tool name; `SessionStart`/`SessionEnd` match start/end reason; `Notification` matches notification type.

## Hook input shape

<!-- seed: replace on first real research pass -->

Claude Code writes a single JSON object to your hook's stdin. Common top-level fields:

| Field | Type | Always present? | Notes |
|---|---|---|---|
| `hook_event_name` | string | yes | One of: `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop`, `Notification`, `UserPromptSubmit`, `PreCompact`, `SessionStart`, `SessionEnd` |
| `session_id` | string | yes | Stable id for the current Claude Code session |
| `transcript_path` | string | yes (absent only when the session runs without persistent transcript, e.g. headless and SDK contexts that run without a persistent transcript file) | Path to the rolling conversation transcript |
| `cwd` | string | yes (absent only when the session is launched without a working directory, e.g. SDK contexts where the caller passes no cwd) | Working directory the session was launched from |
| `tool_name` | string | PreToolUse / PostToolUse only | e.g. `Bash`, `Read`, `Edit` |
| `tool_input` | object | PreToolUse / PostToolUse only | The arguments the tool is about to receive (or was just called with) |
| `tool_response` | any | PostToolUse only | What the tool returned |
| `prompt` | string | UserPromptSubmit only | The user's just-submitted prompt text |
| `source` | string | SessionStart only | `startup`, `resume`, or `compact` |

Example payload for a `PreToolUse` event on a Bash call:

```json
{
  "hook_event_name": "PreToolUse",
  "session_id": "01J9...XYZ",
  "transcript_path": "/tmp/claude/transcripts/01J9.jsonl",
  "cwd": "/Users/me/projects/demo",
  "tool_name": "Bash",
  "tool_input": {
    "command": "git status",
    "description": "Show working tree status"
  }
}
```

Source: `code.claude.com/docs/en/hooks-guide.md`. The research agent fills in per-event variations on each daily run.

## Hook output shape

For **blocking events** (`PreToolUse`, `UserPromptExpansion`), return JSON on stdout with a `hookSpecificOutput` wrapper:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Reason shown to Claude and the user"
  }
}
```

`permissionDecision` values: `"deny"` (block) | `"allow"` (approve without prompting) | `"ask"` (prompt user).

For **non-blocking events** (`Stop`, etc.), you can return JSON to inject context back into Claude's next turn:

```json
{ "continue": true, "stopReason": "..." }
```

For `PermissionDenied`, return `{ "retry": true }` to tell the model it may retry the denied tool call.

Exit code semantics: `0` = success/allow, non-zero = hook error (logged, does not block). Use stderr for human-readable messages.

## Blocking vs non-blocking

**Blocking events**: `PreToolUse`, `UserPromptExpansion`, `WorktreeCreate`. Claude Code waits for these hooks to complete before continuing. A `permissionDecision: "deny"` in the output prevents the action.

**Non-blocking events**: All others. Claude Code fires these asynchronously (or synchronously but ignores the return value for permission purposes). Use them for side effects (logging, notifications, post-processing).

**Async hooks**: Add `"async": true` to the handler to fire-and-forget (hook runs in background, Claude does not wait). Useful for long-running side effects.

## Worked examples

> *Populated by the research agent.* Concrete hook scripts for common
> use cases. See also: [`templates/hooks/`](templates/hooks/).

## Common mistakes (auto-corrected by `rules/hooks.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `hooks-guide.md`.*
