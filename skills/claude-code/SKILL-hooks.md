---
name: claude-code-hooks
description: |
  Deep reference for Claude Code's hook system. Covers every hook
  event (PreToolUse, PostToolUse, Stop, SubagentStop, Notification,
  UserPromptSubmit, PreCompact, SessionStart, SessionEnd, and many
  more), the input JSON shape each event delivers, the output JSON
  shape the hook can return, matcher syntax, blocking vs non-blocking
  semantics, and handler types (command, http, mcp_tool, prompt, agent).
  Read this file when the user asks about hook events, hook scripts,
  hook matchers, blocking tool calls, or hook debugging.
source: https://code.claude.com/docs/en/hooks.md
---

# Claude Code — Hooks

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for hook questions.*

## Hook event catalog

All 30 hook events. Events fire at specific lifecycle points:

| Event | Fires when | Can block? | Matcher field |
|---|---|---|---|
| `SessionStart` | Session begins or resumes | No | session start reason: `startup`, `resume`, `clear`, `compact` |
| `Setup` | `--init-only` or `--init`/`--maintenance` in `-p` mode | No | which flag triggered: `init`, `maintenance` |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | Yes (exit 2 rejects) | no matcher support — always fires |
| `UserPromptExpansion` | User-typed command expands into a prompt | Yes | command name |
| `PreToolUse` | Before a tool call executes | Yes | tool name (e.g. `Bash`, `Edit`) |
| `PermissionRequest` | When a permission dialog appears | No | tool name |
| `PermissionDenied` | Tool call denied by auto mode classifier | No (return `{retry:true}` to let model retry) | tool name |
| `PostToolUse` | After a tool call succeeds | No | tool name |
| `PostToolUseFailure` | After a tool call fails | No | tool name |
| `PostToolBatch` | After a full batch of parallel tool calls, before next model call | No | no matcher — always fires |
| `Notification` | Claude Code sends a notification | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart` | Subagent is spawned | No | agent type: `general-purpose`, `Explore`, `Plan`, custom name |
| `SubagentStop` | Subagent finishes | No | agent type (same as SubagentStart) |
| `TaskCreated` | Task being created via TaskCreate | No | no matcher |
| `TaskCompleted` | Task being marked completed | No | no matcher |
| `Stop` | Claude finishes responding | No | no matcher |
| `StopFailure` | Turn ends due to API error | No | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `TeammateIdle` | Agent team teammate about to go idle | No | no matcher |
| `InstructionsLoaded` | CLAUDE.md or `.claude/rules/*.md` loaded | No | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `ConfigChange` | Configuration file changes during session | No | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | Working directory changes (e.g., after `cd`) | No | no matcher — always fires |
| `FileChanged` | Watched file changes on disk | No | literal filenames to watch (e.g., `.envrc\|.env`) |
| `WorktreeCreate` | Worktree created via `--worktree` or `isolation:"worktree"` | Yes (any non-zero exit aborts) | no matcher |
| `WorktreeRemove` | Worktree removed at session exit or subagent finish | No | no matcher |
| `PreCompact` | Before context compaction | No | compaction trigger: `manual`, `auto` |
| `PostCompact` | After context compaction | No | compaction trigger: `manual`, `auto` |
| `Elicitation` | MCP server requests user input during a tool call | No | MCP server name |
| `ElicitationResult` | User responds to MCP elicitation | No | MCP server name |
| `SessionEnd` | Session terminates | No | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

Source: `code.claude.com/docs/en/hooks.md`

## Configuration: where hooks live

Hooks are declared in `settings.json` (or `settings.local.json`) under the `hooks` key.
Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) `hooks` block.

**Hook locations and scope:**

| Location | Scope | Shareable? |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (committed to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (in plugin) |
| Skill/agent frontmatter | While component is active | Yes (in component file) |

**Configuration shape (3 levels):**
1. Hook event name (e.g., `PreToolUse`)
2. Matcher group — filters when this group fires
3. Hook handlers — the commands/endpoints to run

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
    ]
  }
}
```

## Matcher syntax

The `matcher` field filters when a hook group fires:

| Matcher value | Evaluated as | Example |
|---|---|---|
| `"*"`, `""`, or omitted | Match all | fires on every occurrence |
| Only letters, digits, `_`, `\|` | Exact string or `\|`-separated list | `Bash` or `Edit\|Write` |
| Contains any other character | JavaScript regex | `^Notebook`, `mcp__memory__.*` |

**Per-event matcher targets:**
- `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` → **tool name**
- `SessionStart` → session start reason (`startup`, `resume`, `clear`, `compact`)
- `SessionEnd` → end reason
- `Notification` → notification type
- `SubagentStart`, `SubagentStop` → agent type
- `FileChanged` → literal filenames to watch (`\|`-separated)
- Other events → no matcher (always fires)

**Matching MCP tools:** MCP tools use pattern `mcp__<server>__<tool>`. Use `.*` to match all tools from a server: `mcp__memory__.*` matches all memory server tools. A matcher like `mcp__memory` (no `.*`) is treated as exact-string and matches nothing.

**Narrow with `if`:** use the `if` field on individual handlers to apply permission-rule syntax for finer filtering: `"Bash(git *)"` only runs the handler when the Bash command starts with `git`. Works only on tool events.

## Hook handler fields

Five handler types:

| Type | Description |
|---|---|
| `command` | Shell command; input on stdin, output via exit code + stdout/stderr |
| `http` | HTTP POST to a URL; input as request body, output in response body |
| `mcp_tool` | Call a tool on a connected MCP server |
| `prompt` | Single-turn Claude prompt for yes/no decisions |
| `agent` | Spawns a subagent that can use Read/Grep/Glob before returning a decision |

### Common fields (all handler types)

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax to filter this handler (tool events only) |
| `timeout` | no | Seconds before cancel. Default: 600 for command/http/mcp_tool, 30 for prompt, 60 for agent. UserPromptSubmit lowers command/http/mcp_tool default to 30 |
| `statusMessage` | no | Custom spinner message while hook runs |
| `once` | no | If `true`, runs once per session then removed. Only for skill/agent frontmatter hooks |

### Command hook fields

| Field | Required | Description |
|---|---|---|
| `command` | yes | Shell command (shell form) or executable (exec form) |
| `args` | no | Argument vector. When present, uses exec form (no shell). When absent, uses shell form |
| `async` | no | If `true`, runs in background without blocking |
| `asyncRewake` | no | If `true`, runs async and wakes Claude on exit code 2 |
| `shell` | no | `"bash"` (default) or `"powershell"`. Ignored when `args` is set |

**Exec vs shell form:** With `args`, `command` is an executable spawned directly (no shell, no globbing). Without `args`, `command` is passed to the shell (`sh -c` or Git Bash on Windows).

### HTTP hook fields

| Field | Required | Description |
|---|---|---|
| `url` | yes | URL to POST to |
| `headers` | no | Key-value pairs. Supports `$VAR_NAME` interpolation for vars in `allowedEnvVars` |
| `allowedEnvVars` | no | List of env var names that may be interpolated into headers |

Non-2xx responses, connection failures, and timeouts are non-blocking errors.

### MCP tool hook fields

| Field | Required | Description |
|---|---|---|
| `server` | yes | MCP server name (as configured in `.mcp.json`) |
| `tool` | yes | Tool name to call |
| `input` | no | Static input to pass to the tool |

## Hook input shape

Claude Code writes a single JSON object to stdin (command hooks) or POST body (HTTP hooks).

**Common fields (all events):**

| Field | Notes |
|---|---|
| `hook_event_name` | Event name (e.g., `"PreToolUse"`) |
| `session_id` | Stable ID for the current session |
| `transcript_path` | Path to the rolling conversation transcript (may be absent in headless/SDK contexts) |
| `cwd` | Working directory the session was launched from |

**Additional fields by event:**
- `PreToolUse` / `PostToolUse`: `tool_name`, `tool_input` (object), `tool_response` (PostToolUse only)
- `UserPromptSubmit`: `prompt` (the submitted text)
- `SessionStart`: `source` (`startup`, `resume`, or `compact`)

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

## Hook output shape (exit codes + JSON)

### Exit codes (command hooks)

| Exit code | Meaning |
|---|---|
| **0** | Success. Claude Code parses stdout for JSON output. |
| **2** | Blocking error. Claude ignores stdout; stderr is fed back as an error message. For `PreToolUse` this blocks the tool call. For `UserPromptSubmit` this rejects the prompt. |
| **other** | Non-blocking error. Transcript shows `<hook name> hook error` + first line of stderr. Execution continues. Exception: `WorktreeCreate` — any non-zero aborts creation. |

> **Important:** Exit code 1 is NOT a block — it's a non-blocking error. Use exit code **2** to enforce policy.

### JSON output (stdout on exit 0, or HTTP response body)

Return a JSON object with any of these fields:

| Field | Type | Notes |
|---|---|---|
| `decision` | string | `"block"` to block the action (alternative to exit 2) |
| `reason` | string | Human-readable reason shown when blocking |
| `systemMessage` | string | Text shown in transcript as a system message |
| `terminalSequence` | string | Terminal escape sequence (for bell, title, notifications) |
| `hookSpecificOutput` | object | Event-specific decisions (see below) |

**For `PreToolUse` blocking via JSON output:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked by policy hook"
  }
}
```
Then exit 0.

**Dual mechanism:** You can block via either exit code 2 OR JSON `permissionDecision: "deny"` (exit 0 + JSON). Use exit code 2 when you detect a violation early (before stdout). Use JSON when you need to provide structured output.

## Worked examples

### Block destructive shell commands (PreToolUse)

```bash
#!/bin/bash
# .claude/hooks/block-destructive.sh
PAYLOAD=$(cat)
COMMAND=$(echo "$PAYLOAD" | jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q 'rm -rf'; then
  echo "Blocked: destructive rm command" >&2
  exit 2
fi
exit 0
```

Wire it up in settings.json:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": "/path/to/block-destructive.sh" }]
      }
    ]
  }
}
```

### Run linter after file edits (PostToolUse, async)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint -- $CLAUDE_EDITED_FILE",
            "async": true
          }
        ]
      }
    ]
  }
}
```

## Common mistakes (auto-corrected by `rules/hooks.md`)

See [`rules/hooks.md`](rules/hooks.md). Key pitfalls:
- Hook scripts must be executable (`chmod +x`) and have a shebang line
- Exit code 2 blocks; exit code 1 does NOT block (common mistake)
- Read stdin once with `PAYLOAD=$(cat)`, not multiple times
- `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` don't support matchers

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `hooks-guide.md`.*
