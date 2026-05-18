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

| Event | Cadence | Can block? | Notes |
|---|---|---|---|
| `SessionStart` | Once per session | no | Fires on start or resume. Matcher: `startup`, `resume`, `clear`, `compact` |
| `Setup` | Once per `--init-only`/`--init` | no | One-time CI/script preparation. Matcher: `init`, `maintenance` |
| `UserPromptSubmit` | Once per turn | no (output injected) | Before Claude processes your message. |
| `UserPromptExpansion` | When a slash command expands | yes | Can block command expansion. Matcher: command name |
| `PreToolUse` | Every tool call | yes | Before a tool executes. Can block or modify input. |
| `PermissionRequest` | When permission dialog appears | yes | Can auto-approve or deny. |
| `PermissionDenied` | When auto-mode denies | no | Return `{retry: true}` to let model retry the denied call. |
| `PostToolUse` | After tool succeeds | no | After a tool call completes. |
| `PostToolUseFailure` | After tool fails | no | After a tool call errors. |
| `PostToolBatch` | After a parallel tool batch | no | Before next model call. |
| `Notification` | Various | no | When Claude Code sends a notification. |
| `SubagentStart` | Subagent spawned | no | Matcher: agent type name |
| `SubagentStop` | Subagent finishes | no | Matcher: agent type name |
| `TaskCreated` | TaskCreate tool | no | When a task is being created |
| `TaskCompleted` | Task marked complete | no | When a task is marked completed |
| `Stop` | End of turn | no | When Claude finishes responding |
| `StopFailure` | Turn ends via API error | no | Output and exit code are ignored |
| `TeammateIdle` | Agent team teammate goes idle | no | No matcher support |
| `InstructionsLoaded` | CLAUDE.md/rules file loaded | no | Matcher: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `ConfigChange` | Config file changes mid-session | no | Matcher: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | Working directory changes | no | No matcher support |
| `FileChanged` | Watched file changes on disk | no | `matcher` specifies filenames to watch |
| `WorktreeCreate` | Worktree being created | no | Replaces default git behavior |
| `WorktreeRemove` | Worktree being removed | no | At session exit or subagent finish |
| `PreCompact` | Before context compaction | no | Matcher: `manual`, `auto` |
| `PostCompact` | After context compaction | no | Matcher: `manual`, `auto` |
| `Elicitation` | MCP server requests user input | no | Matcher: MCP server name |
| `ElicitationResult` | After user responds to MCP elicitation | no | Matcher: MCP server name |
| `SessionEnd` | Session terminates | no | Matcher: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

Source: `code.claude.com/docs/en/hooks.md`.

## Configuration: where hooks live

Hooks are declared in `settings.json` under the `hooks` key, using three levels of nesting:
1. **Event name** (e.g. `PreToolUse`)
2. **Matcher group** — array of objects with a `matcher` field and inner `hooks` array
3. **Hook handler** — object with `type`, `command`/`url`/etc., and optional fields

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/validate.sh"
          }
        ]
      }
    ]
  }
}
```

Hook scope is determined by which settings file you put them in:

| Location | Scope |
|---|---|
| `~/.claude/settings.json` | All your projects |
| `.claude/settings.json` | Single project (shareable via git) |
| `.claude/settings.local.json` | Single project, personal only |
| Managed policy settings | Organization-wide |
| Plugin `hooks/hooks.json` | When plugin is enabled |
| Skill/agent frontmatter | While that component is active |

Source: `code.claude.com/docs/en/hooks.md`.

## Matcher syntax

The `matcher` field controls when a hook group fires:

| Matcher value | Evaluated as |
|---|---|
| `"*"`, `""`, or omitted | Match all — fires on every occurrence |
| Only letters, digits, `_`, `\|` | Exact string or pipe-separated list (`"Edit\|Write"`) |
| Any other character | JavaScript regex (`"^Notebook"`, `"mcp__memory__.*"`) |

To match all MCP tools from a server, use `"mcp__memory__.*"` — a bare `"mcp__memory"` is an exact string and matches no tool.

The `if` field on individual handlers adds a second filter using permission-rule syntax (e.g. `"Bash(git push *)"`, `"Edit(*.ts)"`). The hook only spawns when both the matcher and the `if` condition match.

Source: `code.claude.com/docs/en/hooks.md`.

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

Hook commands write JSON to stdout to influence Claude Code:

**To block a tool call (PreToolUse, exit code 2 or JSON decision):**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked by policy"
  }
}
```

**To allow a tool call without prompting:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow"
  }
}
```

**To inject a message into the conversation (any event):**
```json
{
  "decision": "allow",
  "reason": "Message shown in transcript"
}
```

Exit codes:
- `0` — allow the action (no opinion)
- `1` — non-blocking error; Claude sees a warning but proceeds
- `2` — block the action; Claude receives the reason

For HTTP hooks: return the same JSON in the response body with a 2xx status. Non-2xx responses are treated as non-blocking errors.

Source: `code.claude.com/docs/en/hooks.md`.

## Blocking vs non-blocking

**Blocking hooks** (PreToolUse, UserPromptExpansion, PermissionRequest): Claude Code waits for the hook to complete before proceeding. Use exit code 2 or a JSON `permissionDecision: "deny"` to block.

**Non-blocking hooks** (PostToolUse, Stop, SessionStart, etc.): Claude Code does not wait. Use `"async": true` on any hook handler to make it explicitly non-blocking. Use `"asyncRewake": true` to run async but wake Claude on exit code 2 (for long-running background failures).

Default timeouts:
- `command`, `http`, `mcp_tool`: 600 seconds (UserPromptSubmit lowers this to 30)
- `prompt`: 30 seconds
- `agent`: 60 seconds

Source: `code.claude.com/docs/en/hooks.md`.

## Worked examples

> *Populated by the research agent.* Concrete hook scripts for common
> use cases. See also: [`templates/hooks/`](templates/hooks/).

## Common mistakes (auto-corrected by `rules/hooks.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `hooks-guide.md`.*
