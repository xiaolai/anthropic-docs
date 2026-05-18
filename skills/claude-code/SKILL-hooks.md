---
name: claude-code-hooks
description: |
  Deep reference for Claude Code's hook system. Covers every hook
  event (PreToolUse, PostToolUse, Stop, SubagentStop, Notification,
  UserPromptSubmit, PreCompact, SessionStart, SessionEnd), the input
  JSON shape each event delivers to your hook command, the output JSON
  shape the hook can return to influence Claude's behavior, matcher
  syntax, blocking vs non-blocking semantics, and authoring patterns.
  Read this file when the user asks about hook events, hook scripts,
  hook matchers, blocking tool calls, or hook debugging.
source: https://code.claude.com/docs/en/hooks.md
---

# Claude Code — Hooks

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for hook questions.*

## Hook event catalog

Source: [`hooks.md`](https://code.claude.com/docs/en/hooks.md) and [`hooks-guide.md`](https://code.claude.com/docs/en/hooks-guide.md).

| Event | When it fires | Matcher filters | Can block? |
|---|---|---|---|
| `SessionStart` | Session begins or resumes | how session started: `startup`, `resume`, `clear`, `compact` | no |
| `Setup` | `--init-only` or `--init`/`--maintenance` in `-p` mode | which CLI flag: `init`, `maintenance` | no |
| `UserPromptSubmit` | After prompt submitted, before Claude processes it | none (always fires) | no |
| `UserPromptExpansion` | When a typed command expands, before reaching Claude | command name | yes (blocks expansion) |
| `PreToolUse` | Before a tool call executes | tool name | yes |
| `PermissionRequest` | When a permission dialog appears | tool name | yes |
| `PermissionDenied` | When auto mode classifier denies a tool call | tool name | no (return `{retry:true}` to let model retry) |
| `PostToolUse` | After a tool call succeeds | tool name | no |
| `PostToolUseFailure` | After a tool call fails | tool name | no |
| `PostToolBatch` | After a full batch of parallel tool calls, before next model call | none | no |
| `Notification` | When Claude Code sends a notification | notification type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, etc. | no |
| `SubagentStart` | When a subagent is spawned | agent type: `general-purpose`, `Explore`, `Plan`, or custom names | no |
| `SubagentStop` | When a subagent finishes | agent type | no |
| `TaskCreated` | When a task is being created via `TaskCreate` | none | no |
| `TaskCompleted` | When a task is being marked completed | none | no |
| `Stop` | When Claude finishes responding | none | no |
| `StopFailure` | When the turn ends due to an API error | error type: `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, etc. | no |
| `TeammateIdle` | When an agent team teammate is about to go idle | none | no |
| `InstructionsLoaded` | When a CLAUDE.md or `.claude/rules/*.md` file is loaded | load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` | no |
| `ConfigChange` | When a configuration file changes during a session | config source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` | no |
| `CwdChanged` | When working directory changes (e.g. Claude runs `cd`) | none | no |
| `FileChanged` | When a watched file changes on disk | literal filenames to watch (pipe-separated) | no |
| `WorktreeCreate` | When a worktree is being created | none | yes (replaces default git behavior) |
| `WorktreeRemove` | When a worktree is being removed | none | no |
| `PreCompact` | Before context compaction | what triggered: `manual`, `auto` | no |
| `PostCompact` | After context compaction completes | what triggered: `manual`, `auto` | no |
| `Elicitation` | When an MCP server requests user input during a tool call | MCP server name | no |
| `ElicitationResult` | After user responds to an MCP elicitation | MCP server name | no |
| `SessionEnd` | When a session terminates | why: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` | no |

## Configuration: where hooks live

Hooks are declared under the `hooks` key in any settings file. Scope determines who sees them:

| Location | Scope | Committed? |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | This project (all users) | Yes |
| `.claude/settings.local.json` | This project (you only) | No (gitignored) |
| Managed policy settings | Organization-wide | Admin-deployed |
| Plugin `hooks/hooks.json` | When plugin is enabled | Bundled with plugin |

Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) for the `hooks` key in `settings.json`.

Three-level nesting: **event** → **matcher group** → **handler(s)**:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "/path/to/check.sh" }
        ]
      }
    ]
  }
}
```

## Matcher syntax

The `matcher` field on a matcher group filters when the group fires:

| Matcher value | Evaluated as |
|---|---|
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, `\|` | Exact string or pipe-separated list (`Edit\|Write`) |
| Contains any other character | JavaScript regular expression |

Examples: `Bash`, `Edit|Write`, `mcp__memory__.*`, `^Notebook`.

**MCP tool matching:** MCP tools are named `mcp__<server>__<tool>`. To match all tools from a server: `mcp__memory__.*` (the `.*` is required — `mcp__memory` would be an exact-string match that never matches a tool). To match any write tool from any server: `mcp__.*__write.*`.

**`if` field (finer filter on individual handlers):** Use permission-rule syntax. Evaluated on tool events only. `"Bash(git push *)"` runs the handler only when a Bash subcommand matches `git push *`. No `&&`/`||`; use separate handlers for multiple conditions.

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

Hooks return JSON to stdout. The top-level structure:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive command blocked"
  }
}
```

Or the simpler `decision` form:

```json
{ "decision": "block", "reason": "Not allowed" }
```

Key output fields for `PreToolUse` / `PermissionRequest`:

| Field | Values | Effect |
|---|---|---|
| `permissionDecision` | `"allow"`, `"deny"`, `"ask"` | Override the permission decision |
| `permissionDecisionReason` | string | Reason shown to Claude |
| `decision` | `"block"` | Block the tool call (shown to user and Claude) |
| `reason` | string | Explanation accompanying a `block` decision |

Exit codes also control flow: exit `0` = allow/continue; exit non-zero = Claude sees stderr as a warning but execution continues (non-blocking). To hard-block, write the JSON decision above and exit `0`.

## Blocking vs non-blocking

**Blocking hooks** (default): The tool call or session action waits for the hook to finish. `PreToolUse` and `PermissionRequest` hooks are blocking and their output can allow or deny the action.

**Non-blocking / async hooks**: Set `"async": true` on a command handler. The hook runs in the background and execution continues immediately. The hook's output is ignored for permission decisions. Use for notifications, logging, or side effects.

**asyncRewake**: Set `"asyncRewake": true` (implies `async: true`). If the hook exits with code 2, Claude Code wakes Claude with the hook's stderr (or stdout if stderr empty) as a system reminder. Use for long-running background checks that need to surface failures back to Claude.

**HTTP hooks**: Non-2xx responses, connection failures, and timeouts produce non-blocking errors. To block, return a 2xx response with the `decision: "block"` or `permissionDecision: "deny"` JSON body.

**Handler types:**
- `command` — shell script (exec or shell form)
- `http` — HTTP POST endpoint
- `mcp_tool` — call a tool on a connected MCP server
- `prompt` — single-turn Claude model evaluation returning yes/no
- `agent` — subagent that can use Read/Grep/Glob to verify conditions

## Worked examples

> *Populated by the research agent.* Concrete hook scripts for common
> use cases. See also: [`templates/hooks/`](templates/hooks/).

## Common mistakes (auto-corrected by `rules/hooks.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `hooks-guide.md`.*
