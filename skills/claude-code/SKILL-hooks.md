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

Source: [`code.claude.com/docs/en/hooks.md`](https://code.claude.com/docs/en/hooks.md)

| Event | When it fires |
|---|---|
| `SessionStart` | When a session begins or resumes |
| `Setup` | When started with `--init-only`, `--init`, or `--maintenance` in `-p` mode |
| `UserPromptSubmit` | When you submit a prompt, before Claude processes it |
| `UserPromptExpansion` | When a typed command expands into a prompt (can block expansion) |
| `PreToolUse` | Before a tool call executes — **can block it** |
| `PermissionRequest` | When a permission dialog appears |
| `PermissionDenied` | When a tool call is denied by the auto mode classifier. Return `{retry: true}` to allow retry |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `PostToolBatch` | After a full batch of parallel tool calls resolves |
| `Notification` | When Claude Code sends a notification |
| `SubagentStart` | When a subagent is spawned |
| `SubagentStop` | When a subagent finishes |
| `TaskCreated` | When a task is being created via TaskCreate |
| `TaskCompleted` | When a task is being marked as completed |
| `Stop` | When Claude finishes responding |
| `StopFailure` | When the turn ends due to an API error (output/exit code ignored) |
| `TeammateIdle` | When an agent team teammate is about to go idle |
| `InstructionsLoaded` | When a CLAUDE.md or `.claude/rules/*.md` file is loaded into context |
| `ConfigChange` | When a configuration file changes during a session |
| `CwdChanged` | When the working directory changes (e.g. Claude runs `cd`) |
| `FileChanged` | When a watched file changes on disk (matcher = filenames to watch) |
| `WorktreeCreate` | When a worktree is being created — replaces default git behavior |
| `WorktreeRemove` | When a worktree is being removed |
| `PreCompact` | Before context compaction |
| `PostCompact` | After context compaction completes |
| `Elicitation` | When an MCP server requests user input during a tool call |
| `ElicitationResult` | After a user responds to an MCP elicitation |
| `SessionEnd` | When a session terminates |

## Configuration: where hooks live

Hooks are declared in `settings.json` under the `hooks` key:

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (commit to git) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (bundled with plugin) |
| Skill or agent frontmatter | While component is active | Yes |

Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) for the `hooks` key, `allowManagedHooksOnly`, `allowedHttpHookUrls`, `httpHookAllowedEnvVars`.

## Matcher syntax

How a `matcher` field is evaluated depends on its characters:

| Matcher value | Evaluated as |
|---|---|
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list: `Edit\|Write` matches either |
| Contains any other character | JavaScript regular expression: `^Notebook`, `mcp__memory__.*` |

**What each event type matches on:**

| Event(s) | Matcher filters |
|---|---|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | Tool name: `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | How session started: `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag triggered: `init`, `maintenance` |
| `SessionEnd` | Why session ended: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | Notification type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | Agent type: `general-purpose`, `Explore`, `Plan`, or custom names |
| `PreCompact`, `PostCompact` | Trigger: `manual`, `auto` |
| `ConfigChange` | Source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | Error type: `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | Load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion` | Command name |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `FileChanged` | Literal filenames to watch: `.envrc\|.env` |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | No matcher support — always fires |

**MCP tool naming in matchers:** MCP tools follow `mcp__<server>__<tool>` (double underscore). To match all tools from a server: `mcp__memory__.*` (the `.*` is required; `mcp__memory` would be exact-matched and match nothing). To match write tools from any server: `mcp__.*__write.*`.

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

## Hook handler fields

Each hook handler in the `hooks` array has a `type` and common + type-specific fields.

**Common fields (all types):**

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax to filter when this hook spawns: `"Bash(git *)"`, `"Edit(*.ts)"`. Only evaluated on tool events. |
| `timeout` | no | Seconds before canceling. Defaults: 600 for command/http/mcp_tool; 30 for prompt; 60 for agent. |
| `statusMessage` | no | Custom spinner message while hook runs |
| `once` | no | If `true`, runs once per session then removed (only in skill frontmatter) |

**Command hook additional fields (`type: "command"`):**

| Field | Required | Description |
|---|---|---|
| `command` | yes | Shell command (shell form) or executable path (exec form when `args` is set) |
| `args` | no | Argument vector — enables exec form (no shell). Each element passed verbatim. |
| `async` | no | If `true`, runs in background without blocking |
| `asyncRewake` | no | If `true`, runs in background and wakes Claude on exit code 2. Implies `async`. |
| `shell` | no | `"bash"` (default) or `"powershell"`. Ignored when `args` is set. |

**HTTP hook additional fields (`type: "http"`):**

| Field | Required | Description |
|---|---|---|
| `url` | yes | URL to POST to |
| `headers` | no | Key-value headers. Supports `$VAR_NAME` interpolation for vars in `allowedEnvVars`. |
| `allowedEnvVars` | no | Env var names that may be interpolated into header values. Required for any interpolation. |

**MCP tool hook additional fields (`type: "mcp_tool"`):**
`serverName` (required), `toolName` (required). Calls a tool on an already-connected MCP server.

## Hook output shape

Hooks write JSON to stdout. Claude Code reads it to decide what to do:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive command blocked"
  }
}
```

Or simply return nothing / `exit 0` to allow execution to proceed.

For non-blocking decisions (like PostToolUse), write `{"decision": "block"}` to block or just exit 0 to continue. HTTP hooks use the same JSON format in the response body.

## Blocking vs non-blocking

- **Blocking events**: `PreToolUse`, `UserPromptSubmit`, `UserPromptExpansion`, `PermissionRequest`, `WorktreeCreate`, `WorktreeRemove`, `Elicitation`, `ElicitationResult` — hook result can affect execution.
- **Non-blocking events**: `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `StopFailure`, `SessionStart`, `SessionEnd`, `Notification`, `SubagentStart`, `SubagentStop`, `ConfigChange`, `CwdChanged`, `FileChanged`, `InstructionsLoaded`, `PreCompact`, `PostCompact`, `TeammateIdle`, `TaskCreated`, `TaskCompleted` — output/exit code logged but doesn't block.
- **Async hooks**: Set `async: true` to run a command hook in the background without blocking any event.

## Worked examples

**Block rm -rf in Bash:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "if": "Bash(rm *)", "command": ".claude/hooks/block-rm.sh"}]
      }
    ]
  }
}
```

**Run linter after file edits:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{"type": "command", "command": "/path/to/lint-check.sh"}]
      }
    ]
  }
}
```

**HTTP hook with auth:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "http", "url": "http://localhost:8080/hooks/pre-tool-use", "timeout": 30, "headers": {"Authorization": "Bearer $MY_TOKEN"}, "allowedEnvVars": ["MY_TOKEN"]}]
      }
    ]
  }
}
```

## Path placeholders in hook commands

These are substituted in both `command` and `args`:
- `${CLAUDE_PROJECT_DIR}` — project root directory
- `${CLAUDE_PLUGIN_ROOT}` — plugin root (in plugin hooks)
- `${CLAUDE_PLUGIN_DATA}` — plugin data directory
- `${user_config.*}` — plugin user configuration values

These are also exported as environment variables to the spawned hook process.

## Common mistakes (auto-corrected by `rules/hooks.md`)

- Using `matcher: "mcp__memory"` (no regex chars) — matches nothing. Must use `mcp__memory__.*` to match all memory server tools.
- Setting `async: true` on a `PreToolUse` hook that's supposed to block — async hooks cannot block execution.
- Forgetting `allowedEnvVars` in HTTP hooks — env var interpolation silently produces empty strings.
- Adding a `matcher` to `UserPromptSubmit`, `PostToolBatch`, `Stop`, `CwdChanged`, etc. — matcher is silently ignored on these events.
- Using exec form (`args` present) with a `.cmd` or `.bat` shim on Windows — these aren't real executables; use shell form or invoke `node` directly.

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `hooks-guide.md`.*
