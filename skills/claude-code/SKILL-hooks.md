---
name: claude-code-hooks
description: |
  Deep reference for Claude Code's hook system. Covers every hook
  event (PreToolUse, PostToolUse, Stop, SubagentStop, Notification,
  UserPromptSubmit, PreCompact, SessionStart, SessionEnd, and many
  more), the input JSON shape each event delivers to your hook command,
  the output JSON shape the hook can return to influence Claude's
  behavior, matcher syntax, blocking vs non-blocking semantics, and
  authoring patterns.
  Read this file when the user asks about hook events, hook scripts,
  hook matchers, blocking tool calls, or hook debugging.
source: https://code.claude.com/docs/en/hooks.md
---

# Claude Code — Hooks

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for hook questions.*

## Hook event catalog

Source: [`hooks.md`](https://code.claude.com/docs/en/hooks.md), [`hooks-guide.md`](https://code.claude.com/docs/en/hooks-guide.md) — audited 2026-05-18.

| Event | When it fires | Can block? |
|---|---|---|
| `SessionStart` | Session begins or resumes | No (stderr shown to user) |
| `Setup` | With `--init-only`, or `--init`/`--maintenance` in `-p` mode | No |
| `UserPromptSubmit` | User submits prompt, before Claude processes it | Yes (exit 2 blocks + erases prompt) |
| `UserPromptExpansion` | Slash command expands into prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes (exit 2 or `permissionDecision: "deny"`) |
| `PermissionRequest` | Permission dialog appears | Yes (can deny) |
| `PermissionDenied` | Auto-mode classifier denies a tool call | No (but `retry: true` available) |
| `PostToolUse` | After a tool call succeeds | No (tool already ran; can add context) |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After full batch of parallel tool calls, before next model call | Yes |
| `Notification` | Claude Code sends a notification | No (stderr shown to user) |
| `SubagentStart` | Subagent is spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task being created via `TaskCreate` | Yes (exit 2 rolls back) |
| `TaskCompleted` | Task being marked completed | Yes |
| `Stop` | Claude finishes responding | Yes (exit 2 prevents stopping) |
| `StopFailure` | Turn ends due to API error | No (output and exit code ignored) |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `InstructionsLoaded` | CLAUDE.md or `.claude/rules/*.md` file loaded | No |
| `ConfigChange` | Config file changes during session | Yes (except `policy_settings`) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes (any non-zero exit fails creation) |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation, before response sent | Yes |
| `SessionEnd` | Session terminates | No |

## Configuration: where hooks live

Hooks are declared in the `hooks` key of `settings.json`. The hook config can live in:

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (committed) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes (bundled) |
| Skill/agent frontmatter | While component active | Yes |

Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) `hooks` block.

## Hook handler types

| `type` | Description |
|---|---|
| `"command"` | Shell command (default); receives event JSON on stdin |
| `"http"` | POST event data to a URL |
| `"mcp_tool"` | Call a tool on a connected MCP server |
| `"prompt"` | Single-turn LLM evaluation |
| `"agent"` | Multi-turn verification with tool access (experimental) |

## Common handler fields (all types)

| Field | Required | Description |
|---|---|---|
| `type` | yes | Handler type (see above) |
| `if` | no | Permission rule syntax to filter when hook runs (tool events only; v2.1.85+) |
| `timeout` | no | Seconds. Defaults: 600 for command/http/mcp_tool (30 for `UserPromptSubmit`), 30 for prompt, 60 for agent |
| `statusMessage` | no | Custom spinner message |
| `once` | no | If `true`, runs once per session (only honored in skill frontmatter) |

### `command` handler fields

| Field | Required | Description |
|---|---|---|
| `command` | yes | Shell command (shell form) or executable (exec form when `args` present) |
| `args` | no | Argument list; enables exec form (no shell tokenization) |
| `async` | no | Run in background without blocking |
| `asyncRewake` | no | Run in background and wake Claude on exit code 2; implies `async` |
| `shell` | no | `"bash"` (default) or `"powershell"`; ignored when `args` set |

### `http` handler fields

| Field | Required | Description |
|---|---|---|
| `url` | yes | URL to POST to (must be in `allowedHttpHookUrls`) |
| `headers` | no | Key-value HTTP headers; values support `$VAR_NAME` interpolation |
| `allowedEnvVars` | no | Env var names allowed to be interpolated into header values |

### `mcp_tool` handler fields

| Field | Required | Description |
|---|---|---|
| `server` | yes | Name of configured MCP server |
| `tool` | yes | Name of tool on that server |
| `input` | no | Arguments; strings support `${path}` substitution from JSON input |

### `prompt` / `agent` handler fields

| Field | Required | Description |
|---|---|---|
| `prompt` | yes | Prompt text; `$ARGUMENTS` is placeholder for hook input JSON |
| `model` | no | Model for evaluation; defaults to fast model |

## Matcher syntax

Matcher patterns filter which hook instances fire. Placed in the `"matcher"` key of a hook group.

| Matcher value | Evaluated as |
|---|---|
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, `\|` | Exact string or pipe-separated list |
| Contains any other character | JavaScript regular expression |

### Matcher filters by event

| Event | What the matcher matches |
|---|---|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | Tool name (e.g., `"Bash"`, `"Edit\|Write"`, `"mcp__memory__.*"`) |
| `SessionStart` | `startup`, `resume`, `clear`, `compact` |
| `Setup` | `init`, `maintenance` |
| `SessionEnd` | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | `general-purpose`, `Explore`, `Plan`, or custom agent names |
| `PreCompact`, `PostCompact` | `manual`, `auto` |
| `ConfigChange` | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | `rate_limit`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `FileChanged` | Literal filenames (pipe-separated) |
| `UserPromptExpansion` | Command name |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | No matcher support (always fires) |

### MCP tool matchers

`mcp__<server>__<tool>` format. Examples:
- `mcp__memory__create_entities` — specific tool
- `mcp__memory__.*` — all tools from a server
- `mcp__.*__write.*` — write-prefixed tools across all servers

## Hook input shape

Claude Code writes a JSON object to your hook's stdin. All events include:

| Field | Always present | Description |
|---|---|---|
| `hook_event_name` | yes | Event name (e.g., `"PreToolUse"`) |
| `session_id` | yes | Stable id for the current session |
| `transcript_path` | yes* | Path to rolling conversation transcript |
| `cwd` | yes* | Working directory the session was launched from |
| `permission_mode` | yes | Current mode: `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"` |
| `effort` | yes | Object with `level` field: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `agent_id` | subagent only | Unique identifier for subagent |
| `agent_type` | subagent only | Agent name |

*Absent only in headless/SDK contexts without persistent files.

### Additional fields by event

| Event | Extra fields |
|---|---|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | `tool_name`, `tool_input` |
| `PostToolUse` | `tool_response` (what the tool returned) |
| `PostToolUseFailure` | `tool_error` |
| `UserPromptSubmit` | `prompt` (the user's text) |
| `UserPromptExpansion` | `prompt`, `command_name` |
| `SessionStart` | `source` (`"startup"`, `"resume"`, `"clear"`, `"compact"`) |
| `Stop`, `SubagentStop` | `stop_hook_active` (boolean; `true` if already inside a Stop hook — use to prevent infinite loops) |

### `PreToolUse` tool_input schemas

| Tool | Input fields |
|---|---|
| `Bash` | `command` (string), `description` (string, optional), `timeout` (number ms, optional), `run_in_background` (boolean) |
| `Write` | `file_path` (string), `content` (string) |
| `Edit` | `file_path` (string), `old_string` (string), `new_string` (string), `replace_all` (boolean) |
| `Read` | `file_path` (string), `offset` (number, optional), `limit` (number, optional) |
| `Glob` | `pattern` (string), `path` (string, optional) |
| `Grep` | `pattern` (string), `path` (string, optional), `glob` (string, optional), `output_mode`, `-i` (boolean), `multiline` (boolean) |
| `WebFetch` | `url` (string), `prompt` (string) |
| `WebSearch` | `query` (string), `allowed_domains` (array, optional), `blocked_domains` (array, optional) |
| `Agent` | `prompt` (string), `description` (string), `subagent_type` (string), `model` (string, optional) |

### `CLAUDE_ENV_FILE` availability

`CLAUDE_ENV_FILE` env var is only available for: `SessionStart`, `Setup`, `CwdChanged`, `FileChanged` hooks. Use it to inject env vars into the session (write `KEY=value` lines to the file).

## Hook output shape (stdout JSON)

Your hook writes JSON to stdout. Universal fields:

| Field | Default | Description |
|---|---|---|
| `continue` | `true` | If `false`, Claude stops processing entirely |
| `stopReason` | — | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Omit stdout from debug log |
| `systemMessage` | — | Warning message shown to user |
| `terminalSequence` | — | Terminal escape sequence (OSC 0/1/2/9/99/777 and BEL only); v2.1.141+ |

### Event-specific output fields

| Event(s) | Pattern | Key output fields |
|---|---|---|
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | `decision` at top-level | `{"decision": "block", "reason": "..."}` |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` |
| `PostToolUse` | `hookSpecificOutput` | `additionalContext`, `updatedToolOutput` |
| `WorktreeCreate` | path return | Command hook prints path on stdout; HTTP returns `hookSpecificOutput.worktreePath` |
| `Elicitation` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `ElicitationResult` | `hookSpecificOutput` | `action`, `content` |

### `PreToolUse` `permissionDecision` values

| Value | Effect |
|---|---|
| `"allow"` | Skip permission prompt (deny/ask rules still apply) |
| `"deny"` | Cancel tool call; `permissionDecisionReason` shown to Claude |
| `"ask"` | Show permission prompt to user; `permissionDecisionReason` shown to user |
| `"defer"` | Exit process with `stop_reason: "tool_deferred"`; non-interactive mode only |

When multiple PreToolUse hooks return decisions: precedence `deny > defer > ask > allow`.

### `PermissionRequest` `updatedPermissions` entry types

| `type` | Fields | Effect |
|---|---|---|
| `addRules` | `rules`, `behavior`, `destination` | Add permission rules |
| `replaceRules` | `rules`, `behavior`, `destination` | Replace all rules of given behavior at destination |
| `removeRules` | `rules`, `behavior`, `destination` | Remove matching rules |
| `setMode` | `mode`, `destination` | Change permission mode |
| `addDirectories` | `directories`, `destination` | Add working directories |
| `removeDirectories` | `directories`, `destination` | Remove working directories |

`destination` values: `session`, `localSettings`, `projectSettings`, `userSettings`.

## Exit codes

| Exit code | Effect |
|---|---|
| `0` | Action proceeds; stdout JSON is processed; for `UserPromptSubmit`/`SessionStart`/`Setup` stdout added to Claude's context |
| `2` | **Blocking error** (for blockable events): prevents the action; stderr fed back to Claude |
| Any other non-zero | Non-blocking error; action proceeds; error shown in transcript |

**Exception:** `WorktreeCreate` — any non-zero exit aborts worktree creation.

### What exit code 2 does per event

| Event | Effect of exit 2 |
|---|---|
| `PreToolUse` | Blocks tool call |
| `PermissionRequest` | Denies permission |
| `UserPromptSubmit` | Blocks prompt and erases it |
| `UserPromptExpansion` | Blocks the expansion |
| `Stop` | Prevents Claude from stopping |
| `SubagentStop` | Prevents subagent from stopping |
| `TeammateIdle` | Prevents teammate going idle |
| `TaskCreated` | Rolls back task creation |
| `TaskCompleted` | Prevents task marked completed |
| `ConfigChange` | Blocks config change (except `policy_settings`) |
| `PostToolBatch` | Stops agentic loop before next model call |
| `PreCompact` | Blocks compaction |
| `Elicitation` | Denies elicitation |
| `ElicitationResult` | Blocks response (action becomes decline) |
| `WorktreeCreate` | Fails creation |
| `PostToolUse`, `PostToolUseFailure`, `StopFailure` | Non-blocking; stderr shown to Claude |
| `Notification`, `SubagentStart`, `SessionStart`, `Setup`, `SessionEnd`, `CwdChanged`, `FileChanged`, `PostCompact`, `WorktreeRemove`, `InstructionsLoaded`, `PermissionDenied` | Non-blocking; stderr shown to user |

## Blocking vs non-blocking

- **Blocking** (exit 2 or `decision: "block"`): the action is prevented; Claude receives feedback via stderr.
- **Non-blocking** (all events where exit 2 is non-blocking): stderr shown to user only; execution continues.
- `PostToolUse` is always non-blocking (tool already ran); add context via `additionalContext` or replace Claude's view via `updatedToolOutput`.
- A `PreToolUse` hook returning `"allow"` skips the interactive prompt but does **NOT** override deny rules.
- PreToolUse hooks fire **before** any permission-mode check — a hook returning `"deny"` blocks even in `bypassPermissions` mode.

## Prompt-based hooks

`type: "prompt"` hooks evaluate via a single-turn LLM call. The model returns `{"ok": true}` or `{"ok": false, "reason": "..."}`.

When `"ok": false`:
- `Stop` / `SubagentStop`: reason fed back to Claude as next instruction.
- `PreToolUse`: tool call denied; reason returned as tool error.
- `PostToolUse`, `PostToolBatch`, `UserPromptSubmit`, `UserPromptExpansion`: turn ends; reason shown as warning.

## Agent-based hooks (experimental)

`type: "agent"` hooks run multi-turn verification with tool access. Same `"ok"` / `"reason"` response. Default timeout 60s. Up to 50 tool-use turns.

## Stop hook infinite loop prevention

Parse `stop_hook_active` from input JSON; if `true`, exit 0 immediately:

```bash
#!/usr/bin/env bash
PAYLOAD=$(cat)
if echo "$PAYLOAD" | jq -e '.stop_hook_active' > /dev/null 2>&1; then
  exit 0
fi
# … your actual hook logic
```

## Path placeholders in hook scripts

| Placeholder | Value |
|---|---|
| `${CLAUDE_PROJECT_DIR}` | Project root |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |

## Worked examples

### Desktop notification when Claude goes idle

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "idle_prompt",
        "hooks": [{ "type": "command", "command": "osascript -e 'display notification \"Claude is waiting\" with title \"Claude Code\"'" }]
      }
    ]
  }
}
```

### Auto-format after edits

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write" }]
      }
    ]
  }
}
```

### Reload direnv on directory change

```json
{
  "hooks": {
    "CwdChanged": [
      {
        "hooks": [{ "type": "command", "command": "direnv export bash > \"$CLAUDE_ENV_FILE\"" }]
      }
    ]
  }
}
```

## Common mistakes (auto-corrected by `rules/hooks.md`)

- Hook scripts must be **executable** (`chmod +x`) with a shebang line. Non-executable hooks silently fail.
- Use **exit code 2** to block; any other non-zero exit is a non-blocking error.
- **Read stdin once**: `PAYLOAD=$(cat)` — piping stdin multiple times drops bytes.
- Hook event names in `settings.json` are **PascalCase** (`PreToolUse`, not `pre_tool_use`).

---

*Source pages: [`hooks.md`](https://code.claude.com/docs/en/hooks.md), [`hooks-guide.md`](https://code.claude.com/docs/en/hooks-guide.md) — audited 2026-05-18.*
