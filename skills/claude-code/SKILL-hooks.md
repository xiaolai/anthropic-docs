---
name: claude-code-hooks
description: |
  Deep reference for Claude Code's hook system. Covers all 29 hook
  events (SessionStart, Setup, InstructionsLoaded, UserPromptSubmit,
  UserPromptExpansion, PreToolUse, PermissionRequest, PermissionDenied,
  PostToolUse, PostToolUseFailure, PostToolBatch, SubagentStart,
  SubagentStop, TaskCreated, TaskCompleted, Stop, StopFailure,
  TeammateIdle, ConfigChange, CwdChanged, FileChanged, WorktreeCreate,
  WorktreeRemove, PreCompact, PostCompact, Elicitation,
  ElicitationResult, Notification, SessionEnd), the input JSON shape
  each event delivers to your hook command, the output JSON shape the
  hook can return to influence Claude's behavior, matcher syntax,
  blocking vs non-blocking semantics, and the five handler types
  (command, http, mcp_tool, prompt, agent).
  Read this file when the user asks about hook events, hook scripts,
  hook matchers, blocking tool calls, or hook debugging.
source: https://code.claude.com/docs/en/hooks.md
---

# Claude Code — Hooks

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for hook questions.*

## Hook event catalog

Complete list of hook events, in lifecycle order. Source: `code.claude.com/docs/en/hooks.md`.

| Event | When it fires | Blocking? | Matcher targets |
|---|---|---|---|
| `SessionStart` | Session begins or resumes | no | `startup`, `resume`, `clear`, `compact` |
| `Setup` | `--init-only` or `--init`/`--maintenance` in `-p` mode | no | `init`, `maintenance` |
| `InstructionsLoaded` | CLAUDE.md or `.claude/rules/*.md` file loaded into context | no | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | yes | no matcher support |
| `UserPromptExpansion` | User-typed command expands into a prompt | yes | command names |
| `PreToolUse` | Before a tool call executes | yes | tool name |
| `PermissionRequest` | Permission dialog appears | yes | tool name |
| `PermissionDenied` | Tool call denied by auto mode classifier | no (can `retry`) | tool name |
| `PostToolUse` | After a tool call succeeds | no | tool name |
| `PostToolUseFailure` | After a tool call fails | no | tool name |
| `PostToolBatch` | After a full batch of parallel tool calls resolves | yes | no matcher support |
| `SubagentStart` | A subagent is spawned | no | agent type (`general-purpose`, `Explore`, `Plan`, custom) |
| `SubagentStop` | A subagent finishes | yes | agent type |
| `TaskCreated` | Task being created via `TaskCreate` | yes | no matcher support |
| `TaskCompleted` | Task being marked as completed | yes | no matcher support |
| `Stop` | Claude finishes responding | yes | no matcher support |
| `StopFailure` | Turn ends due to API error (output ignored) | no | `rate_limit`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `TeammateIdle` | Agent team teammate about to go idle | yes | no matcher support |
| `ConfigChange` | A configuration file changes during a session | yes | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | Working directory changes (e.g. `cd` command) | no | no matcher support |
| `FileChanged` | A watched file changes on disk | no | literal filenames (e.g. `.envrc\|.env`) |
| `WorktreeCreate` | Worktree being created via `--worktree` or `isolation: "worktree"` | yes (any non-zero exit) | no matcher support |
| `WorktreeRemove` | Worktree being removed at session exit or subagent finish | no | no matcher support |
| `PreCompact` | Before context compaction | yes | `manual`, `auto` |
| `PostCompact` | After context compaction completes | no | `manual`, `auto` |
| `Elicitation` | MCP server requests user input during a tool call | yes | MCP server name |
| `ElicitationResult` | User responds to MCP elicitation, before response sent back | yes | MCP server name |
| `Notification` | Claude Code sends a notification | no | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SessionEnd` | Session terminates | no | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

## Configuration: where hooks live

Hooks are declared in `settings.json` under the `hooks` key. Where the file lives determines scope:

| Location | Scope |
|---|---|
| `~/.claude/settings.json` | All projects |
| `.claude/settings.json` | Single project (shareable) |
| `.claude/settings.local.json` | Single project (private) |
| Managed policy settings | Organization-wide |
| Plugin `hooks/hooks.json` | When plugin is enabled |
| Skill/agent frontmatter | While component is active |

Three-level nesting: event → matcher group → handler(s).

## Matcher syntax

The `matcher` field on a matcher group filters when hooks fire:

| Matcher value | Evaluated as |
|---|---|
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list |
| Contains any other character | JavaScript regular expression |

For tool events, the matcher filters the `tool_name` field. MCP tools follow `mcp__<server>__<tool>` naming; use `mcp__memory__.*` (with `.*`) to match all tools from a server. A bare `mcp__memory` is an exact match and matches nothing.

The `if` field on individual handlers applies permission-rule syntax (e.g., `"Bash(git *)"`) as a secondary filter after the matcher group — only evaluated on tool events.

## Hook input shape

<!-- seed: replace on first real research pass -->

Claude Code writes a single JSON object to your hook's stdin. Common top-level fields:

| Field | Type | Always present? | Notes |
|---|---|---|---|
| `hook_event_name` | string | yes | One of the 29 events in the catalog above (e.g. `PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, `UserPromptSubmit`, `WorktreeCreate`, etc.) |
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

Hook stdout must be a single JSON object (only parsed on exit 0). Universal fields:

| Field | Default | Description |
|---|---|---|
| `continue` | `true` | If `false`, Claude stops processing entirely |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, omits stdout from debug log |
| `systemMessage` | none | Warning message shown to the user |
| `terminalSequence` | none | Terminal escape sequence (OSC 0/1/2/9/99/777 or BEL only) emitted on Claude Code's behalf |

Event-specific output uses one of three patterns:

| Events | Pattern | Key fields |
|---|---|---|
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | — |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (`allow`/`deny`/`ask`/`defer`), `permissionDecisionReason` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (`allow`/`deny`) |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` |
| `WorktreeCreate` | Path return | Print path on stdout; HTTP: `hookSpecificOutput.worktreePath` |
| `Elicitation` / `ElicitationResult` | `hookSpecificOutput` | `action` (`accept`/`decline`/`cancel`), `content` |

`additionalContext` (inside `hookSpecificOutput` alongside `hookEventName`) adds a string to Claude's context window at the point where the hook fired.

## Blocking vs non-blocking

**Exit 0**: success. Claude Code parses JSON from stdout.
**Exit 2**: blocking error. Stderr is fed to Claude. Effect varies by event (see catalog table "Blocking?" column).
**Any other exit code**: non-blocking error; execution continues; first stderr line shown as notice.

Exception: `WorktreeCreate` — any non-zero exit code aborts worktree creation.

HTTP hooks: non-2xx status is always non-blocking. To block, return a 2xx with `decision: "block"` JSON body.

## Hook handler types

Five handler types share common fields (`type`, `if`, `timeout`, `statusMessage`, `once`):

| Type | Required fields | Notes |
|---|---|---|
| `command` | `command` | Shell command; `args` enables exec form (no shell); `async`/`asyncRewake` for background |
| `http` | `url` | POST with JSON body; `headers`, `allowedEnvVars` for auth |
| `mcp_tool` | `server`, `tool` | Calls tool on already-connected MCP server; `input` for arguments |
| `prompt` | `prompt` | Single-turn LLM evaluation; returns yes/no decision as JSON |
| `agent` | `prompt` | Spawns subagent with tools (Read, Grep, Glob); experimental |

Path placeholders in `command`/`args`: `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`.

## Worked examples

See also: [`templates/hooks/`](templates/hooks/).

Minimal `PreToolUse` block hook (bash, shell form):
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-rm.sh" }]
      }
    ]
  }
}
```

Script returns `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}` to block, or exits 0 with no output to allow.

## Common mistakes (auto-corrected by `rules/hooks.md`)

- Using `exit 1` to block — only `exit 2` blocks; `exit 1` is non-blocking.
- Adding a `matcher` to `UserPromptSubmit`, `Stop`, `PostToolBatch`, etc. — those events ignore matchers.
- Writing escape sequences to `/dev/tty` — hooks run without a controlling terminal; use `terminalSequence` JSON field instead.
- Bare `mcp__servername` matcher — this matches nothing; use `mcp__servername__.*` instead.
- Printing non-JSON to stdout on exit 0 — JSON is only parsed if stdout is valid JSON; mix-in text breaks it.

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `hooks-guide.md`.*
