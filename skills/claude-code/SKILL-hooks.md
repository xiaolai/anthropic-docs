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

All hook events, in lifecycle order. Source: `code.claude.com/docs/en/hooks.md`, `code.claude.com/docs/en/hooks-guide.md`.

| Event | When it fires | Blocking? |
|---|---|---|
| `SessionStart` | Session begins or resumes | No (exit 2 shows stderr to user only) |
| `Setup` | `--init-only` or `--init`/`--maintenance` in `-p` mode | No |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | Yes — exit 2 blocks and erases the prompt |
| `UserPromptExpansion` | A slash command expands into a prompt | Yes — exit 2 blocks the expansion |
| `PreToolUse` | Before a tool call executes | Yes — exit 2 blocks the tool call |
| `PermissionRequest` | Permission dialog is about to appear | Yes — exit 2 denies the permission |
| `PermissionDenied` | Tool call denied by auto mode classifier | No (use JSON `retry: true` to allow retry) |
| `PostToolUse` | After a tool call succeeds | No (tool already ran; exit 2 shows stderr to Claude) |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After a full batch of parallel tool calls resolves | Yes — exit 2 stops the agentic loop |
| `Notification` | Claude Code sends a notification | No |
| `SubagentStart` | A subagent is spawned | No |
| `SubagentStop` | A subagent finishes | Yes — exit 2 prevents the subagent from stopping |
| `TaskCreated` | Task created via `TaskCreate` | Yes — exit 2 rolls back task creation |
| `TaskCompleted` | Task being marked completed | Yes — exit 2 prevents completion |
| `Stop` | Claude finishes responding | Yes — exit 2 prevents Claude from stopping |
| `StopFailure` | Turn ends due to API error | No (output and exit code are ignored) |
| `TeammateIdle` | An agent team teammate is about to go idle | Yes — exit 2 keeps the teammate working |
| `InstructionsLoaded` | A CLAUDE.md or `.claude/rules/*.md` file is loaded | No |
| `ConfigChange` | A configuration file changes during a session | Yes — exit 2 blocks the change (except `policy_settings`) |
| `CwdChanged` | Working directory changes (e.g. `cd` command) | No |
| `FileChanged` | A watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created via `--worktree` or `isolation: "worktree"` | Yes — any non-zero exit fails creation |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes — exit 2 blocks compaction |
| `PostCompact` | After context compaction completes | No |
| `Elicitation` | MCP server requests user input | Yes — exit 2 denies the elicitation |
| `ElicitationResult` | User responds to MCP elicitation | Yes — exit 2 blocks the response |
| `SessionEnd` | Session terminates | No |

## Configuration: where hooks live

Hooks are declared inside a `hooks` key in a settings file. Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) for the full `settings.json` schema.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude Code needs your attention\"'"
          }
        ]
      }
    ]
  }
}
```

The structure has three nesting levels: `hooks` object → event name → array of matcher groups → inner `hooks` array of handlers. Each event name is a sibling key inside the single top-level `hooks` object.

**Where to put hooks (scope):**

| Location | Scope | Shared? |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (bundled with plugin) |
| Skill/agent frontmatter | While component is active | Yes (in component file) |

Run `/hooks` in Claude Code to browse all configured hooks. Set `"disableAllHooks": true` in settings to disable all hooks. Source: `code.claude.com/docs/en/hooks.md#configuration`.

## Matcher syntax

The `matcher` field filters when hooks fire. Evaluation depends on the characters in the matcher value:

| Matcher value | Evaluated as | Example |
|---|---|---|
| `""`, `"*"`, or omitted | Match all (fires on every occurrence) | `""` fires on every `PostToolUse` |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list of exact strings | `Edit\|Write` matches either tool exactly |
| Contains any other character | JavaScript regular expression | `mcp__memory__.*` matches all memory server tools |

**What each event matches on:**

| Event(s) | Matcher filters | Example values |
|---|---|---|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | how the session started | `startup`, `resume`, `clear`, `compact` |
| `Setup` | which CLI flag triggered setup | `init`, `maintenance` |
| `SessionEnd` | why the session ended | `clear`, `resume`, `logout`, `prompt_input_exit`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success` |
| `SubagentStart`, `SubagentStop` | agent type | `general-purpose`, `Explore`, `Plan`, or custom names |
| `PreCompact`, `PostCompact` | what triggered compaction | `manual`, `auto` |
| `ConfigChange` | configuration source | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | error type | `rate_limit`, `authentication_failed`, `server_error`, etc. |
| `InstructionsLoaded` | load reason | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name | your configured MCP server names |
| `FileChanged` | literal filenames to watch (pipe-separated) | `.envrc\|.env` |
| `UserPromptExpansion` | command name | your skill or command names |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | no matcher support | always fires |

**MCP tool name pattern:** `mcp__<server>__<tool>`. Use `mcp__memory__.*` to match all tools from the `memory` server.

**The `if` field** (requires v2.1.85+): Finer-grained filter using permission rule syntax on the inner hook handler. The hook process only spawns when the tool call matches. Example: `"if": "Bash(git *)"` runs only for git subcommands. Only works on tool events (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`).

Source: `code.claude.com/docs/en/hooks.md#matcher-patterns`.

## Hook input shape

All events receive these **common fields** as JSON on stdin (for command hooks) or as the POST body (for HTTP hooks):

| Field | Description |
|---|---|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory when the hook is invoked |
| `hook_event_name` | Name of the event that fired |
| `permission_mode` | Active permission mode: `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, or `"bypassPermissions"` |
| `effort` | Object with a `level` field: `"low"`, `"medium"`, `"high"`, `"xhigh"`, or `"max"` (present for tool-use context events) |

When running inside a subagent, `agent_id` and `agent_type` are also present.

**Example `PreToolUse` input for a Bash call:**

```json
{
  "session_id": "abc123",
  "transcript_path": "/home/user/.claude/projects/.../transcript.jsonl",
  "cwd": "/home/user/my-project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test"
  }
}
```

**Event-specific additional fields** (examples):
- `PreToolUse` / `PostToolUse`: `tool_name`, `tool_input`
- `PostToolUse`: also `tool_response`
- `UserPromptSubmit`: `prompt`
- `SessionStart`: `source` (`startup`/`resume`/`clear`/`compact`), `model`

Source: `code.claude.com/docs/en/hooks.md#common-input-fields`.

## Hook output shape

Hooks communicate results back via exit codes, stdout JSON, and stderr. Choose **one approach per hook**—do not mix exit codes and JSON.

**Exit codes:**
- `0`: success; Claude Code parses stdout for JSON. For `UserPromptSubmit`, `UserPromptExpansion`, and `SessionStart`, plain stdout is added to Claude's context.
- `2`: blocking error; stdout JSON is ignored. Stderr text is fed back to Claude (or user) as an error message.
- Any other non-zero: non-blocking error; execution continues. Transcript shows a hook error notice.

**JSON output fields (exit 0 with JSON on stdout):**

| Field | Default | Description |
|---|---|---|
| `continue` | `true` | If `false`, Claude stops entirely after the hook runs |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, omits stdout from the debug log |
| `systemMessage` | none | Warning message shown to the user |
| `terminalSequence` | none | Terminal escape sequence for Claude Code to emit (OSC 0/1/2/9/99/777 and BEL only; requires v2.1.141+) |

**Event-specific `decision` field** (used by `UserPromptSubmit`, `PostToolUse`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact`, etc.):
```json
{ "decision": "block", "reason": "Test suite must pass before proceeding" }
```

**`hookSpecificOutput` for `PreToolUse`:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Database writes are not allowed"
  }
}
```
`permissionDecision` values: `"allow"`, `"deny"`, `"ask"`, `"defer"` (non-interactive only).

**`hookSpecificOutput` for `PermissionRequest`:**
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": { "behavior": "allow" }
  }
}
```

**`additionalContext`** — injects text into Claude's context window (inside `hookSpecificOutput`):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "This file is generated. Edit src/schema.ts and run `bun generate` instead."
  }
}
```

Source: `code.claude.com/docs/en/hooks.md#json-output`, `code.claude.com/docs/en/hooks.md#decision-control`.

## Blocking vs non-blocking

**Blocking events** (exit 2 prevents the action):
`PreToolUse`, `PermissionRequest`, `UserPromptSubmit`, `UserPromptExpansion`, `Stop`, `SubagentStop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `ConfigChange`, `PostToolBatch`, `PreCompact`, `Elicitation`, `ElicitationResult`, `WorktreeCreate`

**Non-blocking events** (exit 2 shows stderr to user/Claude but execution continues):
`PostToolUse`, `PostToolUseFailure`, `Notification`, `SubagentStart`, `SessionStart`, `Setup`, `SessionEnd`, `CwdChanged`, `FileChanged`, `PostCompact`, `InstructionsLoaded`, `WorktreeRemove`

**Always ignored** (no output or exit code processing):
`StopFailure` (output and exit code are ignored)

Key rules:
- `PreToolUse` hooks fire **before** any permission-mode check. A `deny` decision blocks even in `bypassPermissions` mode.
- A hook returning `"allow"` does not bypass deny rules from settings. Hooks tighten restrictions but cannot loosen them past what permission rules allow.
- `PermissionRequest` hooks do not fire in non-interactive mode (`-p`). Use `PreToolUse` for automated permission decisions in headless mode.
- `Stop` hooks: if blocked more than 8 consecutive times without progress, Claude Code overrides the block. Check `stop_hook_active` in input to avoid this.

Source: `code.claude.com/docs/en/hooks.md#exit-code-2-behavior-per-event`.

## Worked examples

### Auto-format code after edits (PostToolUse)

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

Add to `.claude/settings.json`. The `Edit|Write` matcher fires only after file-editing tools. `jq` extracts the edited file path from stdin JSON. Source: `code.claude.com/docs/en/hooks-guide.md#auto-format-code-after-edits`.

### Block edits to protected files (PreToolUse, exit 2)

```bash
#!/bin/bash
# .claude/hooks/protect-files.sh
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
PROTECTED_PATTERNS=(".env" "package-lock.json" ".git/")
for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: $FILE_PATH matches protected pattern '$pattern'" >&2
    exit 2
  fi
done
exit 0
```

Register in settings:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh" }
        ]
      }
    ]
  }
}
```

Source: `code.claude.com/docs/en/hooks-guide.md#block-edits-to-protected-files`.

### Auto-approve specific permission prompts (PermissionRequest, JSON output)

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "ExitPlanMode",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"hookSpecificOutput\": {\"hookEventName\": \"PermissionRequest\", \"decision\": {\"behavior\": \"allow\"}}}'"
          }
        ]
      }
    ]
  }
}
```

The matcher scopes the hook to `ExitPlanMode` only so no other prompts are affected. The transcript shows "Allowed by PermissionRequest hook" where the dialog would have appeared. Source: `code.claude.com/docs/en/hooks-guide.md#auto-approve-specific-permission-prompts`.

### Re-inject context after compaction (SessionStart with matcher)

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: use Bun, not npm. Run bun test before committing.'"
          }
        ]
      }
    ]
  }
}
```

Stdout from `SessionStart` hooks is added to Claude's context. The `compact` matcher fires only after compaction, not on fresh session starts. Source: `code.claude.com/docs/en/hooks-guide.md#re-inject-context-after-compaction`.

## Common mistakes (auto-corrected by `rules/hooks.md`)

- **Mixing exit codes and JSON**: If you exit 2, JSON output is ignored. Exit 0 and write JSON for structured control, OR use exit 2 with stderr for a simple block.
- **Using exit 1 to block**: Only exit code 2 blocks for most events. Exit 1 is treated as a non-blocking error and execution continues.
- **Using `PermissionRequest` in headless mode**: `PermissionRequest` hooks do not fire with `-p`. Use `PreToolUse` for automated decisions.
- **Adding `if` to non-tool events**: The `if` field only works on `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, and `PermissionDenied`. On any other event, a hook with `if` set never runs.
- **Shell profile pollution**: If `~/.bashrc` or `~/.zshrc` prints text unconditionally, it prepends to your hook's JSON output and causes a JSON validation error. Wrap echo statements in an interactive-shell check (`[[ $- == *i* ]]`).
- **Missing `args: []` for exec form**: When referencing path placeholders like `${CLAUDE_PROJECT_DIR}`, prefer exec form (`"args": []`) so paths with spaces need no quoting.

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `hooks-guide.md`.*
