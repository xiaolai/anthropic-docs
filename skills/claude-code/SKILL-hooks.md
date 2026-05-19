---
name: claude-code-hooks
description: |
  Deep reference for Claude Code's hook system. Covers all hook
  events (SessionStart, Setup, UserPromptSubmit, UserPromptExpansion,
  PreToolUse, PermissionRequest, PermissionDenied, PostToolUse,
  PostToolUseFailure, PostToolBatch, Notification, SubagentStart,
  SubagentStop, TaskCreated, TaskCompleted, Stop, StopFailure,
  TeammateIdle, InstructionsLoaded, ConfigChange, CwdChanged,
  FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact,
  Elicitation, ElicitationResult, SessionEnd), the input JSON shape
  each event delivers to your hook command, the output JSON shape the
  hook can return to influence Claude's behavior, matcher syntax,
  blocking vs non-blocking semantics, five hook handler types
  (command/http/mcp_tool/prompt/agent), and authoring patterns.
  Read this file when the user asks about hook events, hook scripts,
  hook matchers, blocking tool calls, or hook debugging.
source: https://code.claude.com/docs/en/hooks.md
---

# Claude Code — Hooks

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for hook questions.*

## Hook event catalog

Source: `code.claude.com/docs/en/hooks.md`.

| Event | When it fires | Matcher field | Blocking? |
|---|---|---|---|
| `SessionStart` | Session begins or resumes | how session started: `startup`, `resume`, `clear`, `compact` | no |
| `Setup` | `--init-only` or `--init`/`--maintenance` in `-p` mode | CLI flag: `init`, `maintenance` | no |
| `UserPromptSubmit` | User submits a prompt, before Claude processes it | no matcher | no |
| `UserPromptExpansion` | A user-typed command expands into a prompt | command name | yes (can block expansion) |
| `PreToolUse` | Before a tool call executes | tool name | yes (can block) |
| `PermissionRequest` | Permission dialog appears | tool name | yes |
| `PermissionDenied` | Tool call denied by auto-mode classifier; return `{retry: true}` to allow retry | tool name | yes |
| `PostToolUse` | After a tool call succeeds | tool name | no |
| `PostToolUseFailure` | After a tool call fails | tool name | no |
| `PostToolBatch` | After a full batch of parallel tool calls resolves, before next model call | no matcher | no |
| `Notification` | Claude Code sends a notification | notification type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` | no |
| `SubagentStart` | A subagent is spawned | agent type (e.g. `general-purpose`, `Explore`, `Plan`, custom names) | no |
| `SubagentStop` | A subagent finishes | agent type (same values as `SubagentStart`) | no |
| `TaskCreated` | Task is being created via `TaskCreate` | no matcher | no |
| `TaskCompleted` | Task is being marked completed | no matcher | no |
| `Stop` | Claude finishes responding | no matcher | no |
| `StopFailure` | Turn ends due to API error (output/exit code ignored) | error type: `rate_limit`, `authentication_failed`, `oauth_org_not_allowed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` | no |
| `TeammateIdle` | Agent team teammate is about to go idle | no matcher | no |
| `InstructionsLoaded` | A CLAUDE.md or `.claude/rules/*.md` file is loaded | load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` | no |
| `ConfigChange` | A config file changes during the session | source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` | no |
| `CwdChanged` | Working directory changes (e.g. via `cd`) | no matcher | no |
| `FileChanged` | A watched file changes on disk | **literal** filenames to watch (not regex): e.g. `.envrc\|.env` | no |
| `WorktreeCreate` | A worktree is being created (replaces default git behavior) | no matcher | yes (can replace) |
| `WorktreeRemove` | A worktree is being removed | no matcher | no |
| `PreCompact` | Before context compaction | trigger: `manual`, `auto` | no |
| `PostCompact` | After context compaction completes | trigger: `manual`, `auto` | no |
| `Elicitation` | MCP server requests user input | MCP server name | no |
| `ElicitationResult` | User responds to an MCP elicitation, before response sent back | MCP server name | no |
| `SessionEnd` | Session terminates | reason: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` | no |

## Configuration: where hooks live

Hooks are declared in `settings.json` under the `hooks` key (cross-reference: [`SKILL-settings.md`](SKILL-settings.md)). Scope is determined by which settings file you use:

| File | Scope | Shareable? |
|---|---|---|
| `~/.claude/settings.json` | All your projects | No (local only) |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes (bundled with plugin) |
| Skill / agent frontmatter | While component is active | Yes (in component file) |

Enterprise admins can set `allowManagedHooksOnly: true` to block user, project, and non-force-enabled plugin hooks. Hooks from plugins force-enabled via managed `enabledPlugins` are exempt.

## Matcher syntax

The `matcher` field is evaluated by these rules (source: `code.claude.com/docs/en/hooks.md`):

| Matcher value | Evaluated as |
|---|---|
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list of exact strings (e.g. `Edit\|Write`) |
| Contains any other character | JavaScript regular expression (e.g. `^Notebook`, `mcp__memory__.*`) |

**MCP tool matching:** MCP tools follow `mcp__<server>__<tool>` naming. A matcher like `mcp__memory` won't match (it's treated as exact string). Use `mcp__memory__.*` to match all tools from the `memory` server. Use `mcp__.*__write.*` to match `write`-prefixed tools from any server.

**`if` field:** Individual handlers can add a second filter with the `if` field (permission rule syntax, e.g. `"Bash(git *)"` or `"Edit(*.ts)"`). Only evaluated on tool events (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`). On other events, a handler with `if` set never runs.

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

Five types are supported (source: `code.claude.com/docs/en/hooks.md`):

| `type` | Description | Key fields |
|---|---|---|
| `command` | Run a shell command (stdin = event JSON, stdout = decision JSON) | `command`, `args` (optional, forces exec form), `async`, `asyncRewake`, `shell` |
| `http` | POST the event JSON to a URL; response body = decision JSON | `url`, `headers`, `allowedEnvVars` |
| `mcp_tool` | Call a tool on an already-connected MCP server | `server`, `tool`, `input` |
| `prompt` | Send a prompt to a Claude model for single-turn yes/no evaluation | `prompt`, `model` |
| `agent` | Spawn a subagent that can use Read/Grep/Glob before returning a decision (experimental) | `prompt`, `model` |

**Common fields** (all types): `type`, `if`, `timeout` (default: 600s for command/http/mcp_tool, 30s for prompt, 60s for agent; `UserPromptSubmit` lowers command/http/mcp_tool to 30s), `statusMessage`, `once` (skill frontmatter only).

**Exec form vs shell form** for `command` type: When `args` is set, `command` is spawned directly (no shell). When `args` is absent, `command` runs in `sh -c` (macOS/Linux), Git Bash (Windows), or PowerShell. Use `shell: "powershell"` to force PowerShell. Use exec form with `args` for scripts containing path placeholders like `${CLAUDE_PROJECT_DIR}`.

**Path placeholders:** `${CLAUDE_PROJECT_DIR}` (project root), `${CLAUDE_PLUGIN_ROOT}` (plugin install dir), `${CLAUDE_PLUGIN_DATA}` (plugin persistent data dir).

## Hook output shape

The JSON your hook writes to stdout to influence Claude. Blocking fields require synchronous execution (non-`async`).

For **`PreToolUse`** (block or allow):
```text
{ "hookSpecificOutput": { "hookEventName": "PreToolUse", "permissionDecision": "deny" | "allow" | "ask", "permissionDecisionReason": "<string>" } }
```

For **`PermissionDenied`** (allow retry):
```text
{ "retry": true }
```

For **any event** (show feedback to model without blocking):
```text
{ "decision": "block", "reason": "<string>" }
```
Exit code 2 from a `command` hook blocks the tool call and shows stderr to Claude. Exit 0 allows. Other non-zero exits produce a non-blocking warning.

## Blocking vs non-blocking

**Blocking** hooks run synchronously before the action they guard. `PreToolUse`, `UserPromptExpansion`, `PermissionRequest`, and `WorktreeCreate` hooks can block their respective actions by returning a deny decision or non-zero exit. `command`, `http`, and `mcp_tool` handlers must complete within `timeout` seconds.

**Non-blocking** hooks run fire-and-forget. Set `async: true` on a `command` handler for background execution. Set `asyncRewake: true` to also wake Claude on exit code 2 (shows stderr as a system reminder).

**HTTP hook errors** are always non-blocking: non-2xx responses, connection failures, and timeouts allow execution to continue.

## Worked examples

> *Populated by the research agent.* Concrete hook scripts for common
> use cases. See also: [`templates/hooks/`](templates/hooks/).

## Common mistakes (auto-corrected by `rules/hooks.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/hooks.md`, `hooks-guide.md`.*
