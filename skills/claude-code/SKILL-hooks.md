---
name: claude-code-hooks
description: |
  Deep reference for Claude Code's hook system. Covers every hook
  event (PreToolUse, PostToolUse, Stop, SubagentStop, Notification,
  UserPromptSubmit, PreCompact, SessionStart, SessionEnd, and many more),
  the input JSON shape each event delivers to your hook command, the output
  JSON shape the hook can return to influence Claude's behavior, matcher
  syntax, handler types, blocking vs non-blocking semantics, and authoring
  patterns. Read this file when the user asks about hook events, hook scripts,
  hook matchers, blocking tool calls, or hook debugging.
source: https://code.claude.com/docs/en/hooks.md
---

# Claude Code — Hooks

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for hook questions.*

## Hook event catalog

All 27 hook events, grouped by cadence. Source: [code.claude.com/docs/en/hooks.md](https://code.claude.com/docs/en/hooks.md)

**Once per session:**

| Event | When it fires | Matcher field |
|---|---|---|
| `SessionStart` | Session begins or resumes | `startup`, `resume`, `clear`, `compact` |
| `Setup` | When `--init-only`, `--init`, or `--maintenance` CLI flag is used | `init`, `maintenance` |
| `SessionEnd` | Session terminates | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `InstructionsLoaded` | A `CLAUDE.md` or `.claude/rules/*.md` file is loaded into context | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `ConfigChange` | A configuration file changes during a session | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |

**Once per turn:**

| Event | When it fires | Matcher field |
|---|---|---|
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | no matcher support |
| `UserPromptExpansion` | A user-typed command expands into a prompt | command name |
| `Stop` | Claude finishes responding | no matcher support |
| `StopFailure` | Turn ends due to API error | `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, etc. |
| `TeammateIdle` | An agent team teammate is about to go idle | no matcher support |
| `PostToolBatch` | After a full batch of parallel tool calls resolves, before next model call | no matcher support |

**On every tool call (agentic loop):**

| Event | When it fires | Matcher field |
|---|---|---|
| `PreToolUse` | Before a tool call executes. **Can block it** | tool name |
| `PermissionRequest` | When a permission dialog appears | tool name |
| `PermissionDenied` | When a tool call is denied by the auto mode classifier | tool name |
| `PostToolUse` | After a tool call succeeds | tool name |
| `PostToolUseFailure` | After a tool call fails | tool name |
| `SubagentStart` | When a subagent is spawned | agent type (`general-purpose`, `Explore`, `Plan`, custom names) |
| `SubagentStop` | When a subagent finishes | agent type |
| `TaskCreated` | When a task is being created via `TaskCreate` | no matcher support |
| `TaskCompleted` | When a task is being marked as completed | no matcher support |
| `WorktreeCreate` | When a worktree is being created | no matcher support |
| `WorktreeRemove` | When a worktree is being removed | no matcher support |

**MCP-related:**

| Event | When it fires | Matcher field |
|---|---|---|
| `Elicitation` | When an MCP server requests user input during a tool call | MCP server name |
| `ElicitationResult` | After a user responds to an MCP elicitation | MCP server name |

**File/directory watching:**

| Event | When it fires | Matcher field |
|---|---|---|
| `CwdChanged` | Working directory changes (e.g., Claude runs `cd`) | no matcher support |
| `FileChanged` | A watched file changes on disk | literal filenames to watch (e.g., `.envrc\|.env`) |

**Notification:**

| Event | When it fires | Matcher field |
|---|---|---|
| `Notification` | Claude Code sends a notification | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, etc. |

**Compaction:**

| Event | When it fires | Matcher field |
|---|---|---|
| `PreCompact` | Before context compaction | `manual`, `auto` |
| `PostCompact` | After context compaction completes | `manual`, `auto` |

## Configuration: where hooks live

Hooks are declared in `settings.json` under the `hooks` key. The scope determines who they apply to:

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No (local to your machine) |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (bundled with plugin) |
| Skill or agent frontmatter | While component is active | Yes (defined in component file) |

Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) `hooks` block.

## Matcher syntax

The `matcher` field filters when hooks fire. Evaluation depends on its content:

| Matcher value | Evaluated as |
|---|---|
| `"*"`, `""`, or omitted | Match all occurrences |
| Only letters, digits, `_`, `\|` | Exact string or `\|`-separated list |
| Contains any other character | JavaScript regex |

Examples: `"Bash"` (exact), `"Edit\|Write"` (either), `"^Notebook"` (regex), `"mcp__memory__.*"` (regex for all memory server tools).

The `if` field on individual handlers uses [permission rule syntax](https://code.claude.com/docs/en/permissions.md) for fine-grained filtering, e.g. `"Bash(rm *)"` or `"Edit(*.ts)"`. Only evaluated on tool events.

## Hook handler types

There are five handler types (set via `type` field):

| Type | Description |
|---|---|
| `"command"` | Run a shell command. Input arrives on stdin; results via exit code and stdout |
| `"http"` | POST the event JSON to a URL. Response body uses same JSON output format |
| `"mcp_tool"` | Call a tool on an already-connected MCP server |
| `"prompt"` | Send a prompt to a Claude model for single-turn yes/no decision |
| `"agent"` | Spawn a subagent that can use Read/Grep/Glob to verify conditions |

**Common fields for all handler types:**

| Field | Required | Notes |
|---|---|---|
| `type` | yes | One of the five types above |
| `if` | no | Permission rule syntax filter (tool events only) |
| `timeout` | no | Seconds before canceling. Default: 600 for command/http/mcp_tool; 30 for prompt; 60 for agent |

## Hook input shape

Claude Code writes a JSON object to stdin (for `command` type) or POST body (for `http` type). Common fields:

| Field | Present for |
|---|---|
| `hook_event_name` | All events |
| `session_id` | All events |
| `transcript_path` | All events (may be absent in some SDK/headless contexts) |
| `cwd` | All events (may be absent if no working directory) |
| `tool_name` | `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` |
| `tool_input` | Same as above |
| `tool_response` | `PostToolUse` only |
| `prompt` | `UserPromptSubmit` only |
| `source` | `SessionStart` only (`startup`, `resume`, `compact`) |

Example `PreToolUse` payload for a Bash call:

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

## Hook output shape (blocking vs non-blocking)

Hooks control Claude's behavior via stdout JSON and exit codes:

**Exit codes (command hooks):**
- `0` — allow the action (or non-blocking notification)
- `2` — **block** the tool call (return `hookSpecificOutput` in stdout to show Claude why)
- Other non-zero — error (logged, action allowed anyway for non-blocking events)

**JSON output for `PreToolUse` (to block or allow):**

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive command blocked by hook"
  }
}
```

`permissionDecision` values: `"allow"`, `"deny"`.

**JSON output for `UserPromptSubmit` (to modify or block):**

Return `{"decision": "block", "reason": "..."}` to block the prompt, or `{"decision": "approve"}` to allow it.

**`PermissionDenied` output:** Return `{"retry": true}` to tell the model it may retry the denied tool call.

## Worked example: block `rm -rf` commands

```bash
#!/bin/bash
# .claude/hooks/block-rm.sh
COMMAND=$(jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Destructive rm -rf blocked"
    }
  }'
  exit 2
fi
exit 0
```

Settings configuration:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(rm *)",
            "command": "${CLAUDE_PROJECT_DIR}/.claude/hooks/block-rm.sh"
          }
        ]
      }
    ]
  }
}
```

## Common mistakes (auto-corrected by `rules/hooks.md`)

- Forgetting `exit 2` when trying to block — exit `0` always allows.
- Using `matcher` on events that don't support it (`UserPromptSubmit`, `Stop`, `PostToolBatch`, etc.) — silently ignored.
- Returning blocking output without `"hookSpecificOutput"` wrapper — must be wrapped.
- Using `if` on non-tool events — the `if` filter only applies to tool events; on other events a hook with `if` set never runs.

---

*Source pages: [code.claude.com/docs/en/hooks.md](https://code.claude.com/docs/en/hooks.md), [hooks-guide.md](https://code.claude.com/docs/en/hooks-guide.md).*
