---
name: claude-code-hooks
description: |
  Deep reference for Claude Code's hook system. Covers every hook
  event (PreToolUse, PostToolUse, Stop, SubagentStop, Notification,
  UserPromptSubmit, PreCompact, PostCompact, SessionStart, SessionEnd,
  and more), the input JSON shape each event delivers to your hook
  command, the output JSON shape the hook can return to influence
  Claude's behavior, matcher syntax, blocking vs non-blocking
  semantics, and authoring patterns.
  Read this file when the user asks about hook events, hook scripts,
  hook matchers, blocking tool calls, or hook debugging.
source: https://code.claude.com/docs/en/hooks.md
---

# Claude Code — Hooks

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for hook questions.*

Source: [code.claude.com/docs/en/hooks.md](https://code.claude.com/docs/en/hooks.md), [hooks-guide.md](https://code.claude.com/docs/en/hooks-guide.md)

## Hook event catalog

All hook events:

| Event | When it fires | Blocking? |
|---|---|---|
| `SessionStart` | When a session begins or resumes | no |
| `Setup` | With `--init-only`, or `--init`/`--maintenance` in `-p` mode | yes |
| `UserPromptSubmit` | When you submit a prompt, before Claude processes it | yes |
| `UserPromptExpansion` | When a user-typed command expands into a prompt | yes (can block) |
| `PreToolUse` | Before a tool call executes | yes (can block) |
| `PermissionRequest` | When a permission dialog appears | yes |
| `PermissionDenied` | When auto mode classifier denies a tool call | no (can return `{retry: true}`) |
| `PostToolUse` | After a tool call succeeds | no |
| `PostToolUseFailure` | After a tool call fails | no |
| `PostToolBatch` | After a full batch of parallel tool calls resolves | no |
| `Notification` | When Claude Code sends a notification | no |
| `SubagentStart` | When a subagent is spawned | no |
| `SubagentStop` | When a subagent finishes | no |
| `TaskCreated` | When a task is being created via `TaskCreate` | yes |
| `TaskCompleted` | When a task is being marked completed | no |
| `Stop` | When Claude finishes responding | no |
| `StopFailure` | When turn ends due to API error (output/exit code ignored) | no |
| `TeammateIdle` | When an agent team teammate is about to go idle | no |
| `InstructionsLoaded` | When a CLAUDE.md or `.claude/rules/*.md` is loaded | no |
| `ConfigChange` | When a configuration file changes during a session | no |
| `CwdChanged` | When working directory changes (e.g., `cd` command) | no |
| `FileChanged` | When a watched file changes on disk | no |
| `WorktreeCreate` | When a worktree is created; replaces default git behavior | yes |
| `WorktreeRemove` | When a worktree is removed | no |
| `PreCompact` | Before context compaction | no |
| `PostCompact` | After context compaction completes | no |
| `Elicitation` | When an MCP server requests user input during a tool call | yes |
| `ElicitationResult` | After user responds to MCP elicitation | yes |
| `SessionEnd` | When a session terminates | no |

## Configuration: where hooks live

Hooks are declared in `settings.json` under the `hooks` key. The scope (user/project/local/managed) is determined by which file the hook is in. Cross-reference: [`SKILL-settings.md`](SKILL-settings.md).

| Location | Scope |
|---|---|
| `~/.claude/settings.json` | All your projects, not shared |
| `.claude/settings.json` | Single project, committable |
| `.claude/settings.local.json` | Single project, gitignored |
| Managed policy settings | Organization-wide, admin-controlled |
| Plugin `hooks/hooks.json` | When plugin is enabled |
| Skill or agent frontmatter | While that component is active |

Enterprise admins can set `allowManagedHooksOnly: true` to block user/project/plugin hooks (except plugins force-enabled via `enabledPlugins`).

## Matcher syntax

The `matcher` field filters when hooks fire:

| Matcher value | Evaluated as |
|---|---|
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, `\|` | Exact string or `\|`-separated list of exact strings |
| Any other character | JavaScript regular expression |

**What the matcher filters per event type:**

| Event | What matcher filters | Example values |
|---|---|---|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name | `Bash`, `Edit\|Write`, `mcp__memory__.*` |
| `SessionStart` | how session started | `startup`, `resume`, `clear`, `compact` |
| `Setup` | which CLI flag triggered | `init`, `maintenance` |
| `SessionEnd` | why session ended | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete` |
| `SubagentStart`, `SubagentStop` | agent type | `general-purpose`, `Explore`, `Plan`, custom agent names |
| `PreCompact`, `PostCompact` | what triggered | `manual`, `auto` |
| `ConfigChange` | config source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `FileChanged` | literal filenames to watch | `.envrc\|.env` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion` | command name | skill or command names |
| `Elicitation`, `ElicitationResult` | MCP server name | configured MCP server names |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher support | always fires |

**MCP tool matching:** MCP tools follow `mcp__<server>__<tool>` naming. Use `mcp__memory__.*` (regex, requires `.*`) to match all tools from a server.

## Hook handler types

| Type | Description |
|---|---|
| `"command"` | Run a shell command. Input on stdin, output on stdout/exit code |
| `"http"` | POST event JSON to a URL. Response body is the output |
| `"mcp_tool"` | Call a tool on an already-connected MCP server |
| `"prompt"` | Send a prompt to Claude for single-turn yes/no evaluation |
| `"agent"` | Spawn a subagent that can use tools (experimental) |

## Hook handler fields (common to all types)

| Field | Required | Description |
|---|---|---|
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax to filter when this hook runs (`"Bash(git *)"`, `"Edit(*.ts)"`). Only evaluated on tool events |
| `timeout` | no | Seconds before canceling. Defaults: 600 for command/http/mcp_tool; 30 for prompt; 60 for agent. `UserPromptSubmit` lowers command/http/mcp_tool default to 30 |

### Command hook fields

| Field | Required | Description |
|---|---|---|
| `command` | yes | Shell command string |
| `args` | no | Additional arguments |
| `env` | no | Extra environment variables for this hook |
| `async` | no | If `true`, hook runs asynchronously (does not block Claude). Output goes to stderr |
| `background` | no | Like `async` but always non-blocking |

### HTTP hook fields

| Field | Required | Description |
|---|---|---|
| `url` | yes | HTTP endpoint URL |
| `method` | no | HTTP method. Default: `"POST"` |
| `headers` | no | Object of HTTP headers. Supports `${VAR}` env var interpolation |
| `allowedEnvVars` | no | Env vars this hook can reference in headers |
| `timeout` | no | Seconds before cancel |

### MCP tool hook fields

| Field | Required | Description |
|---|---|---|
| `serverName` | yes | Name of the connected MCP server |
| `toolName` | yes | Tool to call on that server |
| `arguments` | no | Arguments to pass to the tool |

## Hook input shape

Claude Code writes a single JSON object to your hook's stdin (or HTTP POST body). Common fields:

| Field | Type | Present in |
|---|---|---|
| `hook_event_name` | string | All events |
| `session_id` | string | All events |
| `transcript_path` | string | Most events |
| `cwd` | string | Most events |
| `tool_name` | string | PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, PermissionDenied |
| `tool_input` | object | PreToolUse only (arguments to be passed) |
| `tool_response` | any | PostToolUse only (what the tool returned) |
| `tool_error` | string | PostToolUseFailure only |
| `prompt` | string | UserPromptSubmit only |
| `source` | string | SessionStart only: `"startup"`, `"resume"`, or `"compact"` |
| `notification` | object | Notification event |

Example `PreToolUse` payload:

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

## Hook output shape

Your hook writes JSON to stdout to influence Claude's behavior:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Destructive command blocked"
  }
}
```

### `PreToolUse` output options

| Field | Value | Effect |
|---|---|---|
| `permissionDecision` | `"allow"` | Allow the tool call |
| `permissionDecision` | `"deny"` | Block the tool call (shows reason to Claude) |
| `permissionDecision` | `"ask"` | Show permission prompt to user |
| `permissionDecisionReason` | string | Reason shown to Claude (or user) |
| `updatedInput` | object | Replace the tool's input with this modified version |

### `UserPromptSubmit` output options

| Field | Value | Effect |
|---|---|---|
| `decision` | `"block"` | Block the prompt from reaching Claude |
| `reason` | string | Reason shown to user when blocked |
| `additionalContext` | string | Extra context prepended to Claude's prompt |

### `Stop` output options

Returning non-zero exit code prompts Claude to continue working. The stdout content is provided as feedback.

### Other events

For non-blocking events (PostToolUse, SessionStart, etc.), exit 0 to succeed. Non-zero exit shows an error in the UI. Write user-facing messages to stdout, debug to stderr.

## Blocking vs non-blocking

- **Blocking hooks**: `PreToolUse`, `UserPromptSubmit`, `UserPromptExpansion`, `PermissionRequest`, `Setup`, `WorktreeCreate`, `Elicitation`, `ElicitationResult`, `TaskCreated` — Claude waits for them to complete.
- **Non-blocking hooks**: `PostToolUse`, `PostToolBatch`, `Stop`, `SessionEnd`, `Notification`, etc. — Claude does not wait. Mark `async: true` to also make blocking hooks non-blocking.

## Worked examples

### Block a dangerous command (PreToolUse)

```bash
#!/bin/bash
# .claude/hooks/block-rm-rf.sh
COMMAND=$(cat | jq -r '.tool_input.command')
if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: "rm -rf blocked by hook"}}'
else
  exit 0
fi
```

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
            "command": ".claude/hooks/block-rm-rf.sh"
          }
        ]
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
            "command": "/path/to/lint-check.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

### Send desktop notification on Stop

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude finished\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

## Environment variables available in hooks

| Variable | Value |
|---|---|
| `CLAUDE_PROJECT_DIR` | The project root directory |
| `CLAUDE_SESSION_ID` | Current session ID |
| `HOME`, `PATH`, etc. | Standard environment |

## Common mistakes (auto-corrected by `rules/hooks.md`)

- Putting hook commands outside the `hooks` array nested under the event/matcher. The correct nesting is: `hooks[event][{matcher, hooks: [{type, command}]}]`.
- Using `"matcher": "*"` when you want to match all tools — omitting matcher entirely or `""` also works.
- Forgetting `#!/bin/bash` shebang in shell scripts and making them non-executable.
- Using regex in `if` field — `if` uses permission rule syntax (e.g. `Bash(git *)`), not regex.

---

*Source: [code.claude.com/docs/en/hooks.md](https://code.claude.com/docs/en/hooks.md), [hooks-guide.md](https://code.claude.com/docs/en/hooks-guide.md)*
