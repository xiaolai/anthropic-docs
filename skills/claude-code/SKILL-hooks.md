---
name: claude-code-hooks
description: |
  Deep reference for Claude Code's hook system. Covers every hook
  event (SessionStart, Setup, InstructionsLoaded, UserPromptSubmit,
  UserPromptExpansion, PreToolUse, PermissionRequest, PostToolUse,
  PostToolUseFailure, PostToolBatch, PermissionDenied, Notification,
  SubagentStart, SubagentStop, TaskCreated, TaskCompleted, Stop,
  StopFailure, TeammateIdle, ConfigChange, CwdChanged, FileChanged,
  WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, SessionEnd,
  Elicitation, ElicitationResult), the input JSON shape each event
  delivers, the output JSON shape hooks can return, matcher syntax,
  blocking vs non-blocking semantics, and the five handler types
  (command, http, mcp_tool, prompt, agent).
source: https://code.claude.com/docs/en/hooks.md
---

# Claude Code — Hooks

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for hook questions.*

## Configuration: where hooks live

Hooks are declared in `settings.json` under the `hooks` key (or the `hooks` front-matter field of a skill/agent). Scope determines which sessions run them.

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (committed) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill / agent frontmatter | While component is active | Yes |

### Structure

Three levels of nesting:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "validate-command.sh" }
        ]
      }
    ]
  }
}
```

1. **Hook event name** (e.g., `"PreToolUse"`)
2. **Matcher group** — `{ "matcher": "...", "hooks": [...] }`
3. **Hook handler** — the command/HTTP endpoint/MCP tool/prompt/agent to invoke

## Matcher syntax

The `matcher` field filters when a hook fires. Evaluation depends on characters:

| Matcher | Evaluated as |
|---|---|
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, `\|` | Exact string or `\|`-separated list |
| Any other characters | JavaScript regular expression |

Examples:
- `"Bash"` — only Bash tool
- `"Edit\|Write"` — Edit or Write tools
- `"^Notebook"` — any tool starting with Notebook
- `"mcp__memory__.*"` — every tool from the `memory` MCP server

## Hook handler types (5 types)

| Type | `type` value | How it runs |
|---|---|---|
| Command | `"command"` | Shell command; JSON input on stdin; communicates via exit code + stdout |
| HTTP | `"http"` | HTTP POST to `url`; JSON input as request body; response body = JSON output |
| MCP tool | `"mcp_tool"` | Calls a tool on a connected MCP server; text output treated as command stdout |
| Prompt | `"prompt"` | Sends a prompt to Claude for yes/no evaluation |
| Agent | `"agent"` | Spawns a subagent with tools like Read, Grep, Glob |

### Common handler fields

| Field | Required | Notes |
|---|---|---|
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission-rule filter (e.g. `"Bash(git *)"`) — only for tool events |
| `timeout` | no | Seconds before cancellation. Default: 600 for command/http/mcp_tool, 30 for prompt, 60 for agent |
| `statusMessage` | no | Custom spinner message while hook runs |
| `async` | no | `true` = run hook in background, don't wait for result |

### Command hook fields

| Field | Required | Notes |
|---|---|---|
| `command` | yes | Shell command string or exec-form array |
| `env` | no | Extra env vars for this hook |
| `workingDir` | no | Working directory (default: session's `cwd`) |

### HTTP hook fields

| Field | Required | Notes |
|---|---|---|
| `url` | yes | POST endpoint (must match `allowedHttpHookUrls` if set) |
| `headers` | no | Object of HTTP headers |
| `method` | no | HTTP method (default: `POST`) |

## Common input fields

All hook events receive these fields as JSON (stdin for command hooks, request body for HTTP hooks):

| Field | Notes |
|---|---|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook invoked |
| `permission_mode` | Active mode: `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"` |
| `effort` | Object with `level` field: `"low"`, `"medium"`, `"high"`, `"xhigh"`, or `"max"`. Present on tool-context events (PreToolUse, PostToolUse, Stop, SubagentStop, etc.). Also exposed as `$CLAUDE_EFFORT` env var in hook commands and Bash tool (v2.1.128+). |
| `hook_event_name` | Name of the firing event |
| `agent_id` | (subagent only) Unique identifier for the subagent |
| `agent_type` | (subagent only) Agent name from frontmatter or `--agent` |

Example `PreToolUse` input:

```json
{
  "session_id": "abc123",
  "transcript_path": "/home/user/.claude/projects/.../transcript.jsonl",
  "cwd": "/home/user/my-project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "effort": { "level": "high" },
  "tool_name": "Bash",
  "tool_input": { "command": "npm test" }
}
```

## Exit code output

| Exit code | Meaning |
|---|---|
| `0` | Success, proceed normally |
| `1` | Error (logged but execution continues for most events) |
| `2` | **Block** (PreToolUse / PermissionRequest): deny the tool call. (Stop): request Claude to continue. Other events: treated like exit 1. |

## JSON output

A hook can print a JSON object to stdout to influence behavior:

```json
{
  "decision": "block",           // "allow", "block", or "ask"
  "reason": "Command not allowed",
  "additionalContext": "...",     // extra context for Claude
  "stopReason": "..."            // reason to show user on Stop block
}
```

## Hook event catalog

### Session lifecycle

| Event | When it fires | Matchers on |
|---|---|---|
| `SessionStart` | Session starts or resumes | `startup` / `resume` / `clear` / `compact` |
| `Setup` | After SessionStart, before instructions load | — |
| `InstructionsLoaded` | After all CLAUDE.md files and skills are loaded | — |
| `SessionEnd` | Session ends (interactive) | — |
| `PreCompact` | Just before context compaction | — |
| `PostCompact` | Just after compaction | — |

**SessionStart** additionally receives `source` (how session started) and `model` fields.
**SessionEnd** has a generous timeout for cleanup tasks.

### User input events

| Event | When it fires | Matchers on |
|---|---|---|
| `UserPromptSubmit` | User submits a message | prompt text |
| `UserPromptExpansion` | After `@`-file and `!`-shell expansions | expanded prompt text |

Both support blocking (exit 2) to prevent the message from reaching Claude.

### Tool events

| Event | When it fires | Matchers on | Blocking? |
|---|---|---|---|
| `PreToolUse` | Before a tool call executes | tool name | Yes (exit 2 or `"decision":"block"`) |
| `PermissionRequest` | When Claude requests permission for a tool | tool name | Yes |
| `PostToolUse` | After a tool call succeeds | tool name | No (result is returned to Claude) |
| `PostToolUseFailure` | After a tool call fails | tool name | No |
| `PostToolBatch` | After a batch of parallel tool calls completes | — | No |
| `PermissionDenied` | After a tool is denied | tool name | No |

**PreToolUse additional fields:** `tool_name`, `tool_input` (arguments), `tool_use_id`

**PostToolUse additional fields:** `tool_name`, `tool_input`, `tool_response` (result), `tool_use_id`

### Subagent events

| Event | When it fires |
|---|---|
| `SubagentStart` | Subagent starts |
| `SubagentStop` | Subagent completes |
| `TaskCreated` | A task is added to the task list |
| `TaskCompleted` | A task is marked complete |

### Stop events

| Event | When it fires | Blocking? |
|---|---|---|
| `Stop` | Claude finishes a turn in interactive mode | Yes: exit 2 requests Claude to continue |
| `StopFailure` | Turn ends with an error | No |

**Stop additional fields:** `stop_hook_active` (bool, whether a stop hook is already running)

### Other events

| Event | When it fires | Notes |
|---|---|---|
| `Notification` | Claude wants your attention (e.g., needs permission, long task done) | Not blocking |
| `TeammateIdle` | Agent team: a teammate has no more tasks | Blocking: exit 2 to assign more work |
| `ConfigChange` | Settings file changed during session | — |
| `CwdChanged` | Working directory changed | Returns `newCwd` in output |
| `FileChanged` | Watched file modified | Matcher is a glob pattern, not tool name |
| `WorktreeCreate` | A worktree is created | — |
| `WorktreeRemove` | A worktree is removed | — |
| `Elicitation` | SDK elicitation request | — |
| `ElicitationResult` | Response to an SDK elicitation | — |

## Advanced: background (async) hooks

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Edit",
      "hooks": [{ "type": "command", "command": "run-tests.sh", "async": true }]
    }]
  }
}
```

Async hooks run in the background and don't block Claude's response. They can write to a file and the next synchronous hook for that event reads it via `additionalContext`.

## Advanced: defer a tool call (PreToolUse)

A `PreToolUse` hook can return `"decision": "defer"` in its JSON output to reschedule the tool call for after the next user message. The deferred call is re-evaluated by hooks when it actually runs.

## Security

- Hooks run with the same permissions as Claude Code itself.
- Validate all input — hook commands receive unsanitized tool arguments.
- `allowManagedHooksOnly: true` (managed settings) blocks user/project/plugin hooks except those in force-enabled plugins.
- HTTP hooks must match `allowedHttpHookUrls` if that setting is configured.

Source: `code.claude.com/docs/en/hooks.md`, `code.claude.com/docs/en/hooks-guide.md`

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `code.claude.com/docs/en/hooks-guide.md`.*
