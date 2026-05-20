---
name: claude-code-hooks
description: |
  Deep reference for Claude Code's hook system. Covers every hook
  event (PreToolUse, PostToolUse, Stop, SubagentStop, Notification,
  UserPromptSubmit, PreCompact, SessionStart, SessionEnd, and many
  more), the input JSON shape each event delivers to your hook command,
  the output JSON shape the hook can return to influence Claude's
  behavior, matcher syntax, blocking vs non-blocking semantics, and
  authoring patterns. Read this file when the user asks about hook
  events, hook scripts, hook matchers, blocking tool calls, or hook
  debugging.
source: https://code.claude.com/docs/en/hooks.md
---

# Claude Code — Hooks

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for hook questions.*

## Hook event catalog

Hooks fire at specific points in the Claude Code lifecycle. There are three cadence groups:

- **Per-session:** `SessionStart`, `SessionEnd`, `Setup`
- **Per-turn:** `UserPromptSubmit`, `UserPromptExpansion`, `Stop`, `StopFailure`, `TeammateIdle`
- **Per-tool-call:** `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `PermissionRequest`, `PermissionDenied`
- **Subagent/Task:** `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`
- **Context/State:** `PreCompact`, `PostCompact`, `InstructionsLoaded`, `ConfigChange`, `CwdChanged`, `FileChanged`
- **Worktree:** `WorktreeCreate`, `WorktreeRemove`
- **MCP Elicitation:** `Elicitation`, `ElicitationResult`
- **Permission async:** `Notification`

| Event | When it fires |
|---|---|
| `SessionStart` | When a session begins or resumes |
| `Setup` | With `--init-only`, or `--init`/`--maintenance` in `-p` mode. For CI/script preparation |
| `UserPromptSubmit` | When you submit a prompt, before Claude processes it |
| `UserPromptExpansion` | When a user-typed command expands into a prompt. Can block the expansion |
| `PreToolUse` | Before a tool call executes. Can block it |
| `PermissionRequest` | When a permission dialog appears |
| `PermissionDenied` | When auto mode denies a tool call. Return `{retry: true}` to let model retry |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `PostToolBatch` | After a full batch of parallel tool calls resolves, before the next model call |
| `Notification` | When Claude Code sends a notification |
| `SubagentStart` | When a subagent is spawned |
| `SubagentStop` | When a subagent finishes |
| `TaskCreated` | When a task is being created via `TaskCreate` |
| `TaskCompleted` | When a task is being marked as completed |
| `Stop` | When Claude finishes responding |
| `StopFailure` | When the turn ends due to an API error. Output and exit code ignored |
| `TeammateIdle` | When an agent team teammate is about to go idle |
| `InstructionsLoaded` | When a CLAUDE.md or `.claude/rules/*.md` file is loaded |
| `ConfigChange` | When a configuration file changes during a session |
| `CwdChanged` | When the working directory changes (e.g. Claude runs `cd`) |
| `FileChanged` | When a watched file changes on disk |
| `WorktreeCreate` | When a worktree is created. Replaces default git behavior |
| `WorktreeRemove` | When a worktree is removed (session exit or subagent finish) |
| `PreCompact` | Before context compaction |
| `PostCompact` | After context compaction completes |
| `Elicitation` | When an MCP server requests user input during a tool call |
| `ElicitationResult` | After user responds to an MCP elicitation |
| `SessionEnd` | When a session terminates |

Source: `code.claude.com/docs/en/hooks.md`.

## Configuration: where hooks live

Hooks are declared in `settings.json` under the `hooks` key. Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) `hooks` block.

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (committed) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes (bundled with plugin) |
| Skill/agent frontmatter | While component is active | Yes (in component file) |

Three levels of nesting:
1. Hook event name (e.g. `PreToolUse`)
2. Matcher group (`matcher` + inner `hooks` array)
3. Hook handlers (objects with `type`, `command`, etc.)

## Matcher syntax

The `matcher` field on a matcher-group object filters when hooks fire.

| Matcher value | Evaluated as |
|---|---|
| `"*"`, `""`, or omitted | Match all |
| Only letters/digits/`_`/`\|` | Exact string or `\|`-separated list (`Edit\|Write`) |
| Contains any other character | JavaScript regular expression (`^Notebook`, `mcp__memory__.*`) |

Per-event: what the matcher filters:

| Event(s) | Matcher filters |
|---|---|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | Tool name |
| `SessionStart` | How session started: `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag that triggered setup: `init`, `maintenance` |
| `SessionEnd` | Why session ended: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | Notification type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | Agent type: `general-purpose`, `Explore`, `Plan`, or custom names |
| `PreCompact`, `PostCompact` | What triggered compaction: `manual`, `auto` |
| `ConfigChange` | Configuration source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | Error type: `rate_limit`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `model_not_found`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | Load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion` | Command name |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `FileChanged` | Literal filenames to watch (e.g. `.envrc\|.env`) |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | No matcher support — always fires |

**MCP tool matching:** MCP tools follow the pattern `mcp__<server>__<tool>`. To match all tools from a server: `mcp__memory__.*` (the `.*` is required — bare `mcp__memory` is treated as an exact string).

## Hook handler types

Five handler types:

| Type | `type` value | How it runs |
|---|---|---|
| Command | `"command"` | Shell command; JSON input on stdin; output via exit code + stdout |
| HTTP | `"http"` | POST request to a URL; same JSON input as request body |
| MCP tool | `"mcp_tool"` | Calls a tool on an already-connected MCP server |
| Prompt | `"prompt"` | Sends a prompt to Claude for single-turn yes/no decision |
| Agent | `"agent"` | Spawns a subagent with tools (Read, Grep, Glob) for verification |

### Common fields (all handler types)

| Field | Required | Notes |
|---|---|---|
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax filter (`"Bash(git *)"`, `"Edit(*.ts)"`). Only evaluated on tool events |
| `timeout` | no | Seconds before canceling. Defaults: 600 for command/http/mcp_tool; 30 for prompt; 60 for agent |
| `statusMessage` | no | Custom spinner message while hook runs |
| `once` | no | If `true`, runs once per session then removed (skill frontmatter only) |
| `continueOnBlock` | no | `PostToolUse` only. If `true`, when the hook returns `decision: "block"`, feeds the rejection reason back to Claude and continues the turn instead of ending it |

### Command hook fields

| Field | Required | Notes |
|---|---|---|
| `command` | yes | Shell command (shell form) or executable path (exec form when `args` present) |
| `args` | no | Argument list; when present, spawns `command` directly without a shell |
| `async` | no | Run in background without blocking |
| `asyncRewake` | no | Background; wakes Claude on exit code 2 |
| `shell` | no | `"bash"` (default) or `"powershell"` |

**Shell form vs exec form:** When `args` is omitted, `command` is passed to `sh -c` (bash on macOS/Linux, Git Bash on Windows). When `args` is set, `command` is resolved as an executable and spawned directly (no shell, path placeholders substituted as plain strings).

### HTTP hook fields

| Field | Required | Notes |
|---|---|---|
| `url` | yes | URL for the POST request |
| `headers` | no | Key-value pairs; values support `$VAR_NAME`/`${VAR_NAME}` interpolation |
| `allowedEnvVars` | no | List of env var names that may be interpolated into headers |

Non-2xx responses, connection failures, and timeouts produce non-blocking errors.

### MCP tool hook fields

Calls a tool on an already-connected MCP server. The tool's text output is treated like command-hook stdout.

| Field | Required | Notes |
|---|---|---|
| `server` | yes | Name of a configured MCP server (must already be connected) |
| `tool` | yes | Name of the tool to call on that server |
| `input` | no | Arguments passed to the tool. String values support `${path}` substitution from the hook's JSON input (e.g. `"${tool_input.file_path}"`) |

If the named server is not connected, or the tool returns `isError: true`, the hook produces a non-blocking error and execution continues. `SessionStart` and `Setup` hooks typically fire before servers finish connecting.

## Hook input shape

Claude Code writes a JSON object to stdin (or POST body for HTTP hooks). Common top-level fields:

| Field | Present when | Notes |
|---|---|---|
| `hook_event_name` | always | Event name (e.g. `"PreToolUse"`) |
| `session_id` | always | Stable ID for the current session |
| `transcript_path` | most events | Path to the rolling conversation transcript |
| `cwd` | most events | Working directory the session was launched from |
| `permission_mode` | most events | Current permission mode: `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, or `"bypassPermissions"`. Not present for all events; check the event's example JSON |
| `tool_name` | PreToolUse / PostToolUse / PostToolUseFailure / PermissionRequest / PermissionDenied | Tool name (e.g. `"Bash"`, `"Edit"`, `"mcp__github__search"`) |
| `tool_input` | PreToolUse / PostToolUse tool events | Arguments passed to the tool |
| `tool_response` | PostToolUse | What the tool returned |
| `tool_error` | PostToolUseFailure | Error message from the failed tool call |
| `prompt` | UserPromptSubmit | The user's just-submitted prompt text |
| `source` | SessionStart | `"startup"`, `"resume"`, `"clear"` (after `/clear`), or `"compact"` (after compaction) |
| `model` | SessionStart only | Active model identifier (e.g. `"claude-sonnet-4-6"`). Only present in `SessionStart` — there is no `$CLAUDE_MODEL` env var. Does not update when `/model` changes mid-session |
| `effort` | `PreToolUse`, `PostToolUse`, `Stop`, `SubagentStop` (when model supports it) | Object `{"level": "low"\|"medium"\|"high"\|"xhigh"\|"max"}` — the active effort level. Also available as `$CLAUDE_EFFORT` env var in command hooks |
| `agent_id` | When hook fires inside a subagent | Unique identifier for the subagent. Use to distinguish subagent hook calls from main-thread calls |
| `agent_type` | When session uses `--agent` or fires inside a subagent | Agent name (e.g. `"Explore"`, `"security-reviewer"`). For custom subagents, this is the `name` from frontmatter, not the filename |
| `stop_hook_active` | `Stop`, `SubagentStop` | `true` when Claude Code is already continuing as a result of a stop hook. After 8 consecutive blocks Claude overrides and ends the turn |
| `last_assistant_message` | `Stop`, `SubagentStop`, `StopFailure` | Text content of Claude's final response (Stop/SubagentStop) or the API error string (StopFailure), so hooks can access it without parsing the transcript |
| `background_tasks` | `Stop`, `SubagentStop` | Array of background task objects still running when the turn ended. Each object has `id`, `status`, and `command` fields |
| `session_crons` | `Stop`, `SubagentStop` | Array of active session-scoped cron entries. Each object has `id`, `schedule`, and `command` fields |

**SubagentStop** additionally receives `agent_transcript_path` — the path to the subagent's own transcript stored in a nested `subagents/` folder (distinct from `transcript_path`, which is the main session's transcript).

**UserPromptExpansion** additionally receives `expansion_type`, `command_name`, `command_args`, and `command_source`:

| Field | Notes |
|---|---|
| `expansion_type` | `"slash_command"` for skill / custom commands; `"mcp_prompt"` for MCP server prompts |
| `command_name` | Name of the command being expanded (e.g. `"example-skill"`) |
| `command_args` | Arguments the user passed after the command name (e.g. `"arg1 arg2"`) |
| `command_source` | Where the command was defined: `"plugin"`, `"user"`, `"project"`, or `"mcp"` |
| `prompt` | The original slash command string typed by the user (e.g. `"/example-skill arg1 arg2"`) |

Example payload for `PreToolUse` on a Bash call:

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

Source: `code.claude.com/docs/en/hooks.md`.

## Hook output shape

Your hook can write a JSON object to stdout to influence Claude's behavior.

### PreToolUse output

<!-- skip-validate -->
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive command blocked"
  }
}
```

`permissionDecision` values: `"allow"`, `"deny"`, `"ask"`, `"defer"`.

| Field | Notes |
|---|---|
| `permissionDecision` | `"allow"` skips the prompt; `"deny"` blocks; `"ask"` prompts user; `"defer"` pauses and exits (`-p` mode only, v2.1.89+). Precedence when multiple hooks return: `deny` > `defer` > `ask` > `allow` |
| `permissionDecisionReason` | For `"allow"`/`"ask"`: shown to user. For `"deny"`: shown to Claude. |
| `updatedInput` | Replaces entire tool input before execution. Combine with `"allow"` or `"ask"`. |
| `additionalContext` | String added to Claude's context alongside the tool result. Ignored for `"defer"`. |

**Deprecated:** top-level `decision`/`reason` fields for PreToolUse. Use `hookSpecificOutput.permissionDecision` instead.

### PermissionRequest output

Fires when the permission dialog is about to appear. Uses `decision.behavior`, **not** `permissionDecision`.

<!-- skip-validate -->
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedInput": { "command": "npm run lint" }
    }
  }
}
```

| Field | Notes |
|---|---|
| `decision.behavior` | `"allow"` grants permission; `"deny"` denies it |
| `decision.updatedInput` | (`"allow"` only) Modifies tool input before execution |
| `decision.updatedPermissions` | (`"allow"` only) Permission update entries (addRules, setMode, etc.) to persist |
| `decision.message` | (`"deny"` only) Tells Claude why permission was denied |
| `decision.interrupt` | (`"deny"` only) If `true`, stops Claude entirely |

Input also includes `permission_suggestions` array with the "always allow" options the user would normally see.

### PermissionDenied output

For `PermissionDenied`, return `{ "retry": true }` to tell the model it may retry the denied tool call.

### TeammateIdle / TaskCreated / TaskCompleted output

Exit code 2 blocks these events (prevents teammate from going idle / rolls back task creation / prevents task completion). Or return JSON:

<!-- skip-validate -->
```json
{ "continue": false, "stopReason": "Not ready to complete" }
```

### Stop / PostToolUse / other events: inject messages

<!-- skip-validate -->
```json
{
  "decision": "block",
  "reason": "Validation failed"
}
```

Or to inject a message into the conversation:

<!-- skip-validate -->
```json
{
  "decision": "approve",
  "additionalContext": "Tests passed: 42/42"
}
```

### Terminal sequences (`terminalSequence`)

Any hook can include a `terminalSequence` string in its JSON output. Claude Code emits the sequence to the terminal, enabling desktop notifications, window title changes, and bell characters — even when no controlling terminal is attached:

<!-- skip-validate -->
```json
{
  "terminalSequence": ""
}
```

Combine with `additionalContext` or other fields as needed.

### WorktreeCreate output

Return shell commands to execute instead of the default `git worktree add`:

<!-- skip-validate -->
```json
{
  "hookSpecificOutput": {
    "hookEventName": "WorktreeCreate",
    "shellCommands": "git worktree add \"$WORKTREE_PATH\" \"$BASE_REF\" && cp .env \"$WORKTREE_PATH/.env\""
  }
}
```

## Blocking vs non-blocking

Events where exit code 2 (or JSON block decision) prevents the action from proceeding:

**Blocking events:** `PreToolUse`, `PermissionRequest`, `UserPromptSubmit`, `UserPromptExpansion`, `Stop`, `SubagentStop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `ConfigChange` (except `policy_settings`), `PostToolBatch`, `PreCompact`, `Elicitation`, `ElicitationResult`, `WorktreeCreate`.

**Non-blocking events:** `PostToolUse`, `PostToolUseFailure`, `PermissionDenied`, `Notification`, `SubagentStart`, `SessionStart`, `Setup`, `SessionEnd`, `CwdChanged`, `FileChanged`, `PostCompact`, `WorktreeRemove`, `InstructionsLoaded`. For non-blocking events, non-zero exit code shows stderr to user/Claude but does not block.

**`StopFailure`:** output and exit code are always ignored.

Events with `async: true` on the handler always run non-blocking.

## Exit codes for command hooks

| Exit code | Meaning |
|---|---|
| `0` | Success/allow |
| Non-zero | Error/block (for blocking events) |
| `2` with `asyncRewake: true` | Wake Claude with stderr/stdout as a system reminder |

## Path placeholders in `command` / `args`

Placeholders are substituted before the command runs:

| Placeholder | Value |
|---|---|
| `${CLAUDE_PROJECT_DIR}` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory (plugin hooks only) |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory (plugin hooks only) |

## Hooks in skills and agents

Hooks can be declared in SKILL.md or agent frontmatter:

```yaml
---
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "${CLAUDE_PROJECT_DIR}/.claude/hooks/validate.sh"
          once: true
---
```

When `once: true`, the hook runs once per session and is removed. Only honored in skill/agent frontmatter.

## Common mistakes (auto-corrected by `rules/hooks.md`)

See [`rules/hooks.md`](rules/hooks.md). Key pitfalls:
- Hook event names must be **PascalCase**: `PreToolUse`, not `pre_tool_use`
- `matcher` for MCP tools needs `.*` suffix: `mcp__memory__.*`, not `mcp__memory`
- Events that don't support matchers (`Stop`, `UserPromptSubmit`, etc.) silently ignore a `matcher` field
- `"allow"` rules in `permissions` and hook `permissionDecision` are different concerns — don't confuse them
- `args` enables exec form (no shell); without `args`, `command` runs in a shell

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `hooks-guide.md`.*
