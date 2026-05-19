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

All hook events with when they fire:

| Event | When it fires | Matcher field |
|---|---|---|
| `SessionStart` | Session begins or resumes | `startup`, `resume`, `clear`, `compact` |
| `Setup` | `--init-only`, `--init`, or `--maintenance` mode | `init`, `maintenance` |
| `UserPromptSubmit` | You submit a prompt, before Claude processes it | (no matcher) |
| `UserPromptExpansion` | A slash command expands into a prompt | command name |
| `PreToolUse` | Before a tool call executes — can block it | tool name |
| `PermissionRequest` | When a permission dialog appears | tool name |
| `PermissionDenied` | When auto mode classifier denies a tool | tool name |
| `PostToolUse` | After a tool call succeeds | tool name |
| `PostToolUseFailure` | After a tool call fails | tool name |
| `PostToolBatch` | After a full batch of parallel tool calls, before next model call | (no matcher) |
| `Notification` | When Claude Code sends a notification | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, etc. |
| `SubagentStart` | When a subagent is spawned | agent type (e.g. `general-purpose`, `Explore`, `Plan`) |
| `SubagentStop` | When a subagent finishes | agent type |
| `TaskCreated` | When a task is created via TaskCreate | (no matcher) |
| `TaskCompleted` | When a task is marked completed | (no matcher) |
| `Stop` | When Claude finishes responding | (no matcher) |
| `StopFailure` | When turn ends due to API error | `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, etc. |
| `TeammateIdle` | When an agent team teammate is about to go idle | (no matcher) |
| `InstructionsLoaded` | When a CLAUDE.md or `.claude/rules/*.md` file is loaded | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `ConfigChange` | When a configuration file changes during session | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | When working directory changes (e.g. `cd` command) | (no matcher support) |
| `FileChanged` | When a watched file changes on disk | literal filenames to watch |
| `WorktreeCreate` | When a worktree is being created | (no matcher) |
| `WorktreeRemove` | When a worktree is being removed | (no matcher) |
| `PreCompact` | Before context compaction | `manual`, `auto` |
| `PostCompact` | After context compaction completes | `manual`, `auto` |
| `Elicitation` | When MCP server requests user input | MCP server name |
| `ElicitationResult` | After user responds to MCP elicitation | MCP server name |
| `SessionEnd` | When session terminates | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

Source: `code.claude.com/docs/en/hooks.md`.

## Configuration: where hooks live

Hooks are declared in `settings.json` under the `hooks` key:

| Location | Scope | Shareable |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No (local to your machine) |
| `.claude/settings.json` | Single project | Yes (committed to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (bundled with plugin) |
| Skill or agent frontmatter | While component is active | Yes (in component file) |

Cross-reference: [`SKILL-settings.md`](SKILL-settings.md) `hooks` block.

## Matcher syntax

Three matching modes based on the `matcher` field value:

| Matcher value | Evaluated as |
|---|---|
| `"*"`, `""`, or omitted | Match all — fires on every occurrence |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list |
| Contains any other character | JavaScript regular expression |

Examples:
- `"Bash"` — only the Bash tool
- `"Edit|Write"` — either tool exactly
- `"^Notebook"` — any tool starting with Notebook
- `"mcp__memory__.*"` — every tool from the `memory` MCP server

**`if` field**: Additional filter on individual handlers using permission rule syntax (e.g. `"Bash(git *)"`, `"Edit(*.ts)"`). Only evaluated on tool events. Avoids process spawn when condition doesn't match.

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

## Hook handler types

| Type | Description |
|---|---|
| `"command"` | Run a shell command. Receives JSON on stdin, communicates via exit codes + stdout. |
| `"http"` | POST JSON to a URL. Response body uses same JSON output format as command hooks. |
| `"mcp_tool"` | Call a tool on an already-connected MCP server. Tool text output treated like command stdout. |
| `"prompt"` | Send prompt to a Claude model for single-turn yes/no decision. |
| `"agent"` | Spawn a subagent with tool access (Read, Grep, Glob) to verify conditions. Experimental. |

Common fields on every handler:
- `type` (required): one of the types above
- `if` (optional): permission-rule filter (tool events only)
- `timeout` (optional): milliseconds before hook is killed
- `background` (optional, async events only): `true` to run without blocking

## Hook output shape

Hook commands write JSON to stdout. Key `hookSpecificOutput` contains:

**For `PreToolUse`** (to block/allow):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Blocked by policy"
  }
}
```
`permissionDecision`: `"allow"`, `"deny"`, `"ask"`.

**To add context Claude sees**:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "additionalContext": "This file is read-only"
  }
}
```

**Exit codes**:
- `0` — allow (unless JSON decision says otherwise)
- `1` — block tool call with hook stderr as reason (non-async hooks)
- `2` — block and show hook output directly to Claude

## Blocking vs non-blocking

- **Blocking events** (`PreToolUse`, `UserPromptSubmit`, etc.): Claude waits for hook to finish. Exit code and stdout affect behavior.
- **Async/background events** (`Stop`, `Notification`, `SessionEnd`, `FileChanged`, `CwdChanged`, etc.): set `"background": true` on the handler to run without blocking. Output and exit codes are ignored for background hooks.
- **`background` default**: Most events block by default. Events labeled async in the event catalog default to non-blocking.

## Worked examples

**Format code after every file edit** (`.claude/settings.json`):
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [{ "type": "command", "command": "~/.claude/hooks/format.sh" }]
      }
    ]
  }
}
```

**Block rm -rf via PreToolUse**:
```bash
#!/bin/bash
# format.sh reads stdin for tool_input
COMMAND=$(cat | jq -r '.tool_input.command')
if echo "$COMMAND" | grep -q 'rm -rf'; then
  jq -n '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"rm -rf blocked"}}'
fi
```

Source: `code.claude.com/docs/en/hooks.md`, `code.claude.com/docs/en/hooks-guide.md`.

## Common mistakes (auto-corrected by `rules/hooks.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `hooks-guide.md`.*
