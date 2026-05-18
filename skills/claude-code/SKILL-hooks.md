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

Source: [`code.claude.com/docs/en/hooks.md`](https://code.claude.com/docs/en/hooks.md), [`code.claude.com/docs/en/hooks-guide.md`](https://code.claude.com/docs/en/hooks-guide.md)

## Hook event catalog

| Event | When it fires | Can block? |
|---|---|---|
| `SessionStart` | When a session begins or resumes | No (stderr shown to user) |
| `Setup` | When started with `--init-only`, or `--init`/`--maintenance` in `-p` mode | No |
| `UserPromptSubmit` | When you submit a prompt, before Claude processes it | Yes |
| `UserPromptExpansion` | When a user-typed command expands into a prompt, before Claude. Can block | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | When a permission dialog appears | Yes |
| `PermissionDenied` | When a tool call is denied by auto mode classifier | No (use `retry:true` to let model retry) |
| `PostToolUse` | After a tool call succeeds | No (stderr shown to Claude) |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After a full batch of parallel tool calls, before next model call | Yes (stops agentic loop) |
| `Notification` | When Claude Code sends a notification | No |
| `SubagentStart` | When a subagent is spawned | No |
| `SubagentStop` | When a subagent finishes | Yes |
| `TaskCreated` | When a task is being created via `TaskCreate` | Yes (rolls back creation) |
| `TaskCompleted` | When a task is being marked completed | Yes |
| `Stop` | When Claude finishes responding | Yes (continues conversation) |
| `StopFailure` | When turn ends due to API error | No (output/exit code ignored) |
| `TeammateIdle` | When an agent team teammate is about to go idle | Yes |
| `InstructionsLoaded` | When CLAUDE.md or `.claude/rules/*.md` loaded into context | No |
| `ConfigChange` | When a configuration file changes during a session | Yes (except `policy_settings`) |
| `CwdChanged` | When working directory changes (e.g. Claude runs `cd`) | No |
| `FileChanged` | When a watched file changes on disk. `matcher` specifies filenames to watch | No |
| `WorktreeCreate` | When a worktree is being created via `--worktree` or `isolation:"worktree"` | Yes (any non-zero exit fails) |
| `WorktreeRemove` | When a worktree is being removed | No (failures logged in debug) |
| `PreCompact` | Before context compaction | Yes (blocks compaction) |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | When an MCP server requests user input during a tool call | Yes (denies elicitation) |
| `ElicitationResult` | After a user responds to an MCP elicitation | Yes (blocks response, becomes decline) |
| `SessionEnd` | When a session terminates | No |

## Configuration: where hooks live

Hooks are declared in JSON settings files under the `hooks` key. Location determines scope:

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No (local to machine) |
| `.claude/settings.json` | Single project | Yes (committable to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (bundled with plugin) |
| Skill or agent frontmatter | While component is active | Yes (in component file) |

Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) `hooks` block.

## Configuration structure

Three levels of nesting:

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<matcher-pattern>",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/script.sh"
          }
        ]
      }
    ]
  }
}
```

1. **Hook event** — lifecycle point (e.g. `PreToolUse`)
2. **Matcher group** — filter when it fires (e.g. `"Bash"` for Bash-only)
3. **Hook handler** — shell command, HTTP endpoint, MCP tool, prompt, or agent

## Matcher syntax

| Matcher value | Evaluated as | Example |
|---|---|---|
| `"*"`, `""`, or omitted | Match all | fires on every occurrence |
| Only letters, digits, `_`, `\|` | Exact string or `\|`-separated list | `Bash` or `Edit\|Write` |
| Contains any other character | JavaScript regular expression | `^Notebook`, `mcp__memory__.*` |

**What each event matches on:**

| Event(s) | Matcher filters |
|---|---|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name |
| `SessionStart` | how session started: `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag: `init`, `maintenance` |
| `SessionEnd` | why session ended: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | notification type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | agent type: `general-purpose`, `Explore`, `Plan`, or custom agent names |
| `PreCompact`, `PostCompact` | what triggered: `manual`, `auto` |
| `ConfigChange` | source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error type: `rate_limit`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion` | command name |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `FileChanged` | literal filenames to watch (not regex) |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher (always fires) |

### Matching MCP tools

MCP tools follow `mcp__<server>__<tool>` pattern. `.*` is required for server-wide matching:
- `mcp__memory__.*` — all tools from the `memory` server
- `mcp__.*__write.*` — any tool starting with `write` from any server

A matcher like `mcp__memory` (no `.*`) is an exact string and matches no tool.

## Hook handler types and fields

### Common fields (all types)

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax to filter when this hook runs (e.g. `"Bash(git *)"`, `"Edit(*.ts)"`). Only evaluated on tool events |
| `timeout` | no | Seconds before cancel. Defaults: 600 for command/http/mcp_tool; 30 for prompt; 60 for agent. `UserPromptSubmit` lowers command/http/mcp_tool default to 30 |
| `statusMessage` | no | Custom spinner message while hook runs |
| `once` | no | If `true`, runs once per session then removed. Only honored in skill frontmatter |

### Command hook fields

| Field | Required | Description |
|---|---|---|
| `command` | yes | Shell command to execute. With `args`, the executable to spawn directly |
| `args` | no | Argument list. When present, runs as exec form (no shell) |
| `async` | no | If `true`, runs in background without blocking |
| `asyncRewake` | no | If `true`, runs in background and wakes Claude on exit code 2. Implies `async` |
| `shell` | no | `"bash"` (default) or `"powershell"`. Ignored when `args` is set |

**Exec form vs shell form:** When `args` is set, `command` is resolved as an executable (no shell). When `args` is absent, `command` is passed to shell (`sh -c` on macOS/Linux, Git Bash on Windows).

### HTTP hook fields

| Field | Required | Description |
|---|---|---|
| `url` | yes | URL to send POST request to |
| `headers` | no | HTTP headers. Values support `$VAR_NAME` interpolation (only vars in `allowedEnvVars`) |
| `allowedEnvVars` | no | Env var names that may be interpolated into header values |

Non-2xx responses, connection failures, and timeouts are all non-blocking. To block, return 2xx with JSON `decision:"block"` or `hookSpecificOutput.permissionDecision:"deny"`.

### MCP tool hook fields

| Field | Required | Description |
|---|---|---|
| `server` | yes | Name of a configured, already-connected MCP server |
| `tool` | yes | Name of the tool to call |
| `input` | no | Arguments. String values support `${path}` substitution from hook input (e.g. `"${tool_input.file_path}"`) |

### Prompt / agent hook fields

| Field | Required | Description |
|---|---|---|
| `prompt` | yes | Prompt text. Use `$ARGUMENTS` as placeholder for hook input JSON |
| `model` | no | Model for evaluation. Defaults to a fast model |

## Path placeholders in hook scripts

| Placeholder | Meaning |
|---|---|
| `${CLAUDE_PROJECT_DIR}` | The project root |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin's installation directory (for plugin-bundled scripts) |
| `${CLAUDE_PLUGIN_DATA}` | Plugin's persistent data directory (survives plugin updates) |

Prefer exec form (`args` set) for hooks referencing path placeholders — no quoting needed for paths with spaces.

## Hook input (stdin JSON)

### Common input fields

| Field | Description |
|---|---|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory when hook is invoked |
| `permission_mode` | Current mode: `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"` |
| `effort` | Object with `level` field: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"`. Present for tool-context events on models supporting effort parameter |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | (inside subagent) Unique identifier for the subagent |
| `agent_type` | (inside subagent) Agent name (e.g. `"Explore"`, `"security-reviewer"`) |

### PreToolUse / PostToolUse / PostToolUseFailure additional fields

| Field | Description |
|---|---|
| `tool_name` | Tool name (e.g. `Bash`, `Read`, `Edit`, `mcp__server__tool`) |
| `tool_input` | Arguments passed to the tool |
| `tool_response` | (PostToolUse only) What the tool returned |

Example `PreToolUse` payload:
```json
{
  "session_id": "abc123",
  "transcript_path": "/home/user/.claude/projects/.../transcript.jsonl",
  "cwd": "/home/user/my-project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": { "command": "npm test" }
}
```

## Hook output (stdout JSON)

Your hook can exit with a code, or exit 0 and print JSON to stdout (choose one approach per hook — JSON is only processed on exit 0).

### Exit codes

| Exit code | Meaning |
|---|---|
| 0 | Success. Stdout parsed for JSON output. For `UserPromptSubmit`, `UserPromptExpansion`, and `SessionStart`, stdout is added as context Claude can see |
| 2 | Blocking error. Stderr fed back to Claude as error message. Ignores stdout |
| Any other | Non-blocking error. First line of stderr shown as `<hook name> hook error`. Execution continues |

> **Critical:** Only exit 2 blocks. Exit 1 is non-blocking and execution continues. If you intend to enforce policy, use `exit 2`.
> Exception: `WorktreeCreate` — any non-zero exit code fails worktree creation.

### Universal JSON output fields

| Field | Default | Description |
|---|---|---|
| `continue` | `true` | If `false`, Claude stops processing entirely. Takes precedence over event-specific decisions |
| `stopReason` | none | Message shown to user when `continue` is `false`. Not shown to Claude |
| `suppressOutput` | `false` | If `true`, omits stdout from debug log |
| `systemMessage` | none | Warning message shown to the user |
| `terminalSequence` | none | Terminal escape sequence for Claude Code to emit (OSC 0/1/2/9/99/777, BEL). Requires v2.1.141+. Use instead of writing to `/dev/tty` |
| `additionalContext` | none | String passed into Claude's context window as a system reminder |

### Decision control (PreToolUse, PermissionRequest)

Use `hookSpecificOutput` with `hookEventName` matching the event:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive command blocked by hook"
  }
}
```

`permissionDecision` values: `"allow"`, `"deny"`, `"ask_once"`, `"always_allow"`.

### Stopping Claude entirely

```json
{ "continue": false, "stopReason": "Build failed, fix errors before continuing" }
```

### Adding context for Claude

```json
{ "additionalContext": "Security scan found 2 issues in the edited file" }
```

## Exit code 2 behavior per event

| Hook event | What happens on exit 2 |
|---|---|
| `PreToolUse` | Blocks the tool call |
| `PermissionRequest` | Denies the permission |
| `UserPromptSubmit` | Blocks prompt processing and erases prompt |
| `UserPromptExpansion` | Blocks the expansion |
| `Stop` | Prevents Claude from stopping, continues conversation |
| `SubagentStop` | Prevents subagent from stopping |
| `TeammateIdle` | Prevents teammate from going idle |
| `TaskCreated` | Rolls back task creation |
| `TaskCompleted` | Prevents task being marked completed |
| `ConfigChange` | Blocks config change (except `policy_settings`) |
| `PostToolBatch` | Stops agentic loop before next model call |
| `PreCompact` | Blocks compaction |
| `Elicitation` | Denies the elicitation |
| `ElicitationResult` | Blocks response (action becomes decline) |
| `WorktreeCreate` | Any non-zero exit fails worktree creation |
| `PostToolUse`, `PostToolUseFailure` | Shows stderr to Claude (tool already ran) |
| `StopFailure`, `Notification`, `SubagentStart`, `SessionStart`, `Setup`, `SessionEnd`, `CwdChanged`, `FileChanged`, `PostCompact`, `PermissionDenied`, `WorktreeRemove`, `InstructionsLoaded` | Non-blocking: shows stderr to user only |

## Blocking vs non-blocking summary

**Blocking** (hook controls whether action proceeds): `PreToolUse`, `PermissionRequest`, `UserPromptSubmit`, `UserPromptExpansion`, `Stop`, `SubagentStop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `ConfigChange`, `PostToolBatch`, `PreCompact`, `Elicitation`, `ElicitationResult`, `WorktreeCreate`

**Non-blocking** (action already happened or can't be prevented): `PostToolUse`, `PostToolUseFailure`, `PermissionDenied`, `StopFailure`, `Notification`, `SubagentStart`, `SessionStart`, `Setup`, `SessionEnd`, `CwdChanged`, `FileChanged`, `PostCompact`, `WorktreeRemove`, `InstructionsLoaded`

## Hooks in skills and agents

Hooks can be defined in skill and subagent YAML frontmatter. They are scoped to the component's lifecycle and cleaned up when it finishes. `Stop` hooks in subagents are automatically converted to `SubagentStop`.

```yaml
---
name: secure-operations
description: Perform operations with security checks
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "./scripts/security-check.sh"
---
```

## The `/hooks` menu

Type `/hooks` in Claude Code to open a read-only browser of configured hooks. Shows every event with hook count, matchers, and full handler details. Displays source (`User`, `Project`, `Local`, `Plugin`, `Session`, `Built-in`).

## Disabling hooks

- **Disable all hooks**: Set `"disableAllHooks": true` in settings. Managed hooks can only be disabled by managed settings.
- **Disable individual hook**: Delete its entry from settings JSON.
- **`allowManagedHooksOnly`** (managed setting): Blocks all user, project, and non-approved-plugin hooks.

## HTTP hooks (macOS/Linux behavior change)

As of v2.1.139, command hooks run in their own session without a controlling terminal. Hooks cannot write directly to `/dev/tty`. Use `terminalSequence` in JSON output instead.

---

*Source pages: [`code.claude.com/docs/en/hooks.md`](https://code.claude.com/docs/en/hooks.md), [`code.claude.com/docs/en/hooks-guide.md`](https://code.claude.com/docs/en/hooks-guide.md)*
