---
name: claude-code-hooks
description: |
  Deep reference for Claude Code's hook system. Covers every hook
  event (PreToolUse, PostToolUse, Stop, SubagentStop, Notification,
  UserPromptSubmit, PreCompact, SessionStart, SessionEnd, and more),
  the input JSON shape each event delivers to your hook command, the
  output JSON shape the hook can return to influence Claude's behavior,
  matcher syntax, blocking vs non-blocking semantics, and all hook
  handler types (command, http, mcp_tool, prompt, agent).
  Read this file when the user asks about hook events, hook scripts,
  hook matchers, blocking tool calls, or hook debugging.
source: https://code.claude.com/docs/en/hooks.md
---

# Claude Code — Hooks

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for hook questions.*

## Hook event catalog

Hooks fire at specific lifecycle points. Events fall into three cadences: once per session (`SessionStart`, `SessionEnd`), once per turn (`UserPromptSubmit`, `Stop`, `StopFailure`), and on every tool call (`PreToolUse`, `PostToolUse`).

| Event | When it fires | Blocking? |
|---|---|---|
| `SessionStart` | Session begins or resumes | No |
| `Setup` | Started with `--init-only`, `--init`, or `--maintenance` (CI preparation) | No |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | No |
| `UserPromptExpansion` | User-typed command expands into a prompt (before Claude). Can block expansion | Yes (can block) |
| `PreToolUse` | Before a tool call executes | Yes (can block) |
| `PermissionRequest` | When a permission dialog appears | No |
| `PermissionDenied` | Tool call denied by auto mode classifier. Return `{retry: true}` to let model retry | No |
| `PostToolUse` | After a tool call succeeds | No |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After a full batch of parallel tool calls resolves, before next model call | No |
| `Notification` | Claude Code sends a notification | No |
| `SubagentStart` | Subagent is spawned | No |
| `SubagentStop` | Subagent finishes | No |
| `TaskCreated` | Task being created via TaskCreate | No |
| `TaskCompleted` | Task being marked as completed | No |
| `Stop` | Claude finishes responding | No |
| `StopFailure` | Turn ends due to API error. Output and exit code are ignored | No |
| `TeammateIdle` | Agent team teammate about to go idle | No |
| `InstructionsLoaded` | CLAUDE.md or `.claude/rules/*.md` file loaded into context | No |
| `ConfigChange` | Configuration file changes during a session | No |
| `CwdChanged` | Working directory changes (e.g. Claude runs `cd`) | No |
| `FileChanged` | Watched file changes on disk (`matcher` specifies filenames) | No |
| `WorktreeCreate` | Worktree being created via `--worktree` or `isolation: "worktree"`. Replaces default git behavior | Yes (replaces) |
| `WorktreeRemove` | Worktree being removed (session exit or subagent finish) | No |
| `PreCompact` | Before context compaction | No |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | MCP server requests user input during a tool call | No |
| `ElicitationResult` | User responds to MCP elicitation, before response sent back | No |
| `SessionEnd` | Session terminates | No |

Source: `code.claude.com/docs/en/hooks.md`.

## Configuration: where hooks live

Hooks are declared under the `hooks` key in `settings.json`. Hook location determines scope:

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No (local machine) |
| `.claude/settings.json` | Single project | Yes (committable) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (bundled with plugin) |
| Skill or agent frontmatter | While component is active | Yes (defined in file) |

Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) `hooks` block.

Enterprise: use `allowManagedHooksOnly` in managed settings to block user/project/plugin hooks. Hooks from plugins force-enabled in managed `enabledPlugins` are exempt.

## Matcher syntax

The `matcher` field filters when a hook group fires:

| Matcher value | Evaluated as | Example |
|---|---|---|
| `"*"`, `""`, or omitted | Match all occurrences | Always fires |
| Only letters, digits, `_`, `\|` | Exact string or `\|`-separated list | `Bash`, `Edit\|Write` |
| Contains any other character | JavaScript regular expression | `^Notebook`, `mcp__memory__.*` |

What the matcher filters, by event type:

| Event | Matcher filters |
|---|---|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name |
| `SessionStart` | how session started: `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag: `init`, `maintenance` |
| `SessionEnd` | why ended: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | agent type: `general-purpose`, `Explore`, `Plan`, or custom names |
| `PreCompact`, `PostCompact` | trigger: `manual`, `auto` |
| `ConfigChange` | source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `FileChanged` | literal filenames to watch (`\|`-separated) |
| `StopFailure` | error type: `rate_limit`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptExpansion` | command name |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher support — always fires |

**MCP tool matching**: MCP tools follow `mcp__<server>__<tool>` naming. Use regex to match a server: `mcp__memory__.*` (matches all tools from `memory` server). A bare `mcp__memory` is compared as exact string and matches nothing — the `.*` suffix is required.

## Hook handler types

Five handler types in the inner `hooks` array:

| Type | `type` value | Description |
|---|---|---|
| Command | `"command"` | Run a shell command. Receives JSON on stdin; communicates via exit codes and stdout |
| HTTP | `"http"` | POST event JSON to a URL. Response body uses same JSON output format |
| MCP tool | `"mcp_tool"` | Call a tool on a connected MCP server. Text output treated like command stdout |
| Prompt | `"prompt"` | Send a prompt to Claude for single-turn yes/no evaluation |
| Agent | `"agent"` | Spawn a subagent (experimental) that can use tools to verify conditions |

### Common fields (all handler types)

| Field | Required | Default | Notes |
|---|---|---|---|
| `type` | yes | — | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | — | Permission rule syntax to sub-filter (`"Bash(git *)"`, `"Edit(*.ts)"`). Only evaluated on tool events |
| `timeout` | no | 600 (command/http/mcp_tool), 30 (prompt), 60 (agent) | Seconds before canceling |
| `statusMessage` | no | — | Custom spinner message while hook runs |
| `once` | no | `false` | Run once per session then remove (skill frontmatter only, ignored elsewhere) |

The `if` field holds exactly one permission rule — no `&&`/`||`. For multiple conditions, use separate handler objects. For Bash, matched against each subcommand (after stripping leading `VAR=value` assignments).

### Command hook fields

| Field | Required | Notes |
|---|---|---|
| `command` | yes | Shell command (shell form) or executable path (exec form when `args` is set) |
| `args` | no | Argument list. When present, spawns executable directly (no shell). Path placeholders like `${CLAUDE_PLUGIN_ROOT}` expanded |
| `async` | no | Run in background without blocking |
| `asyncRewake` | no | Run in background, wake Claude on exit code 2. Implies `async` |
| `shell` | no | `"bash"` (default) or `"powershell"`. Only for shell form. Ignored when `args` is set |

**Exec form vs shell form**: exec form when `args` is set (no shell; each arg passed verbatim); shell form when `args` is omitted (passed to `sh -c` on macOS/Linux, Git Bash on Windows).

### HTTP hook fields

| Field | Required | Notes |
|---|---|---|
| `url` | yes | URL for the HTTP POST request |
| `headers` | no | Additional HTTP headers (key-value). Values support `$VAR`/`${VAR}` interpolation for vars in `allowedEnvVars` |
| `allowedEnvVars` | no | Env var names that may be interpolated into header values |

Non-2xx responses, connection failures, and timeouts produce non-blocking errors.

### MCP tool hook fields

Specify `server` (MCP server name) and `tool` (tool name on that server). The tool's text output is treated like command stdout.

## Hook input shape

Claude Code writes a single JSON object to your hook's stdin. Common top-level fields:

| Field | Type | Present when |
|---|---|---|
| `hook_event_name` | string | Always. One of the event names from the catalog above |
| `session_id` | string | Always |
| `transcript_path` | string | Most contexts (absent in some headless/SDK contexts) |
| `cwd` | string | Most contexts (absent in SDK contexts with no cwd) |
| `tool_name` | string | `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` |
| `tool_input` | object | `PreToolUse`, `PermissionRequest`, `PermissionDenied` |
| `tool_response` | any | `PostToolUse` |
| `tool_error` | string | `PostToolUseFailure` |
| `prompt` | string | `UserPromptSubmit` |
| `source` | string | `SessionStart` — `startup`, `resume`, or `compact` |

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

Source: `code.claude.com/docs/en/hooks-guide.md`.

## Hook output shape (JSON stdout)

Your hook writes JSON to stdout to influence Claude Code. The top-level wrapper:

```json
{
  "hookSpecificOutput": { ... },
  "decision": "block" | "allow",
  "reason": "Human-readable message shown to user"
}
```

For `PreToolUse` (permission decision):

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow" | "deny" | "ask",
    "permissionDecisionReason": "Reason shown to Claude"
  }
}
```

For `PermissionDenied` (retry):

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionDenied",
    "retry": true
  }
}
```

## Blocking vs non-blocking

- **Blocking** (affects Claude's behavior): use `PreToolUse` with `permissionDecision: "deny"` to block a tool call, or `decision: "block"` for HTTP hooks. `WorktreeCreate` hooks that return non-zero replace the default git behavior.
- **Non-blocking**: all other events. Hook exit code and stdout are logged but don't stop Claude.
- **Exit codes**: for command hooks, exit 0 = allow/continue; exit 2 = block (PreToolUse); other non-zero = hook error (logged, non-blocking).
- **Async hooks** (`async: true`): run in the background without blocking Claude. `asyncRewake: true` additionally wakes Claude if the hook exits with code 2.

## Worked example: blocking destructive commands

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

```bash
#!/bin/bash
# block-rm.sh
PAYLOAD=$(cat)
COMMAND=$(echo "$PAYLOAD" | jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: "Destructive command blocked"}}'
else
  exit 0  # allow
fi
```

Key: read stdin **once** with `PAYLOAD=$(cat)` then use `"$PAYLOAD"` — do not pipe stdin twice.

## Reference scripts by path

Use path placeholders in `command` or `args`:

| Placeholder | Expands to |
|---|---|
| `${CLAUDE_PROJECT_DIR}` | Project root |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin directory (plugin hooks only) |
| `${CLAUDE_PLUGIN_DATA}` | Plugin data directory (plugin hooks only) |

These are also exported as environment variables in the spawned process.

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `code.claude.com/docs/en/hooks-guide.md`.*
