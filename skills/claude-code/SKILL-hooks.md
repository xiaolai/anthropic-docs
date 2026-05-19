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

Full list of hook events. Source: [hooks.md](https://code.claude.com/docs/en/hooks.md).

| Event | When it fires | Can block? |
|---|---|---|
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only`, `--init`, or `--maintenance` mode before session | No |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | Yes |
| `UserPromptExpansion` | A user-typed command expands into a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes — exit 2 |
| `PermissionRequest` | Permission dialog appears | No |
| `PermissionDenied` | Auto mode classifier denies a tool call. Return `{retry:true}` to allow retry | No |
| `PostToolUse` | After a tool call succeeds | No |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After a full batch of parallel tool calls resolves | No |
| `Notification` | Claude Code sends a notification | No |
| `SubagentStart` | A subagent is spawned | No |
| `SubagentStop` | A subagent finishes | No |
| `TaskCreated` | A task is being created via `TaskCreate` | No |
| `TaskCompleted` | A task is marked completed | No |
| `Stop` | Claude finishes responding | No |
| `StopFailure` | Turn ends due to API error (output/exit ignored) | No |
| `TeammateIdle` | An agent team teammate is about to go idle | No |
| `InstructionsLoaded` | A CLAUDE.md or `.claude/rules/*.md` is loaded | No |
| `ConfigChange` | A configuration file changes during a session | No |
| `CwdChanged` | Working directory changes (e.g. Claude runs `cd`) | No |
| `FileChanged` | A watched file changes on disk (matcher = filename pattern) | No |
| `WorktreeCreate` | Worktree being created; replaces default git behavior | Yes |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | No |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | An MCP server requests user input during a tool call | No |
| `ElicitationResult` | User responds to MCP elicitation, before response sent to server | No |
| `SessionEnd` | Session terminates | No |

**Blocking:** Only `PreToolUse` supports blocking via exit code 2. Other events that say "Yes" (UserPromptSubmit, WorktreeCreate) support blocking via the JSON output `permissionDecision: "deny"`.

## Configuration: where hooks live

Hooks are declared in `settings.json` under the `hooks` key (cross-reference: [`SKILL-settings.md`](SKILL-settings.md)):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/hook.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude finished'"
          }
        ]
      }
    ]
  }
}
```

Hook types: `"command"` (shell command), `"http"` (HTTP POST), `"prompt"` (LLM as hook). Hook commands receive JSON on stdin and can write JSON to stdout.

## Matcher syntax

Matchers narrow which invocations a hook fires for:

| Matcher field | Form | Effect |
|---|---|---|
| `matcher` | `"Bash"` | Fires on any Bash tool call |
| `matcher` | `"Bash(git *)"` | Fires only on git Bash calls |
| `matcher` | `"Read"` | Fires on any file read |
| `if` | `"Bash(rm *)"` | Secondary filter inside a hook entry |
| (none) | — | Fires on all events of that type |

Matchers use the same permission rule syntax as `permissions.allow/deny` (see [`SKILL-settings.md`](SKILL-settings.md#permission-rule-syntax)).

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

Hooks write a JSON object to stdout. The top-level key is `hookSpecificOutput`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive rm -rf blocked by policy"
  }
}
```

Key `permissionDecision` values for `PreToolUse`:
- `"allow"` — proceed without prompting the user
- `"deny"` — block the tool call and surface `permissionDecisionReason` to Claude
- `"ask"` — show the normal permission prompt

For `UserPromptSubmit`, you can rewrite the prompt:
```json
{ "hookSpecificOutput": { "hookEventName": "UserPromptSubmit", "userPrompt": "Rewritten prompt text" } }
```

## Blocking vs non-blocking

**Blocking a tool call** requires TWO things in `PreToolUse`:
1. Write JSON with `permissionDecision: "deny"` **or** exit with code **2** (not any other non-zero code).
2. Write the reason to stderr — Claude surfaces it to the user.

Exit code semantics:
- `0` — hook ran successfully; Claude reads stdout for output
- `2` — block the tool call (PreToolUse only)
- Any other non-zero — hook error; logged but does not block

**Non-blocking hooks** (`PostToolUse`, `Stop`, etc.) can still write stdout that Claude reads as additional context, but they cannot prevent the action.

## Worked examples

> *Populated by the research agent.* Concrete hook scripts for common
> use cases. See also: [`templates/hooks/`](templates/hooks/).

## Common mistakes (auto-corrected by `rules/hooks.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `hooks-guide.md`.*
