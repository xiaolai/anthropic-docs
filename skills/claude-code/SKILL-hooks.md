---
name: claude-code-hooks
description: |
  Deep reference for Claude Code's hook system. Covers every hook
  event (PreToolUse, PostToolUse, Stop, SubagentStop, Notification,
  UserPromptSubmit, PreCompact, SessionStart, SessionEnd, and more),
  the input JSON shape each event delivers to your hook command, the
  output JSON shape the hook can return to influence Claude's behavior,
  matcher syntax, blocking vs non-blocking semantics, and hook types
  (command/http/mcp_tool/prompt/agent). Read this file when the user
  asks about hook events, hook scripts, hook matchers, blocking tool
  calls, or hook debugging.
source: https://code.claude.com/docs/en/hooks.md
---

# Claude Code — Hooks

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for hook questions.*

## Hook event catalog

All hook event names (exact spelling required):

| Event | Fires when | Blocking? |
|---|---|---|
| `SessionStart` | Session begins (startup, resume, compact) | No |
| `Setup` | `--init` / `--init-only` / `--maintenance` run | No |
| `UserPromptSubmit` | User submits a prompt | Can block expansion |
| `UserPromptExpansion` | Prompt is expanded (mentions, skills injected) | Can block |
| `PreToolUse` | Before any tool call | **Yes** — can deny/allow/ask |
| `PermissionRequest` | Permission prompt shown | Can allow/deny |
| `PermissionDenied` | Permission was denied | No |
| `PostToolUse` | After tool call succeeds | Can block subsequent step |
| `PostToolUseFailure` | After tool call fails | No |
| `PostToolBatch` | After a batch of tool calls | Most-restrictive decision wins |
| `Notification` | Permission prompt / idle / auth / elicitation events | No |
| `SubagentStart` | Subagent session begins | No |
| `SubagentStop` | Subagent session ends | Can block |
| `TaskCreated` | New task created | No |
| `TaskCompleted` | Task completed | No |
| `Stop` | Claude finishes responding | Can block (shows to user; execution continues) |
| `StopFailure` | Claude fails to finish | No |
| `TeammateIdle` | Agent team teammate becomes idle | No |
| `InstructionsLoaded` | Skills/CLAUDE.md loaded | No |
| `ConfigChange` | Settings changed | No |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes | No |
| `WorktreeCreate` | Git worktree created | No |
| `WorktreeRemove` | Git worktree removed | No |
| `PreCompact` | Before context compaction | No |
| `PostCompact` | After context compaction | No |
| `Elicitation` | MCP server requests structured input | Can respond |
| `ElicitationResult` | MCP server receives elicitation response | No |
| `SessionEnd` | Session ends | No |

## Configuration: where hooks live

Hooks are declared in the `hooks` key of any `settings.json` (user, project, local) or managed settings. They can also be defined in plugin `hooks/hooks.json` files, or inline in skill/agent frontmatter.

Full settings integration: [`SKILL-settings.md`](SKILL-settings.md) `hooks` block.

Disable all hooks globally: `"disableAllHooks": true` in settings.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {"type": "command", "command": "/path/to/my-hook.sh"}
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {"type": "command", "command": "/path/to/notify.sh"}
        ]
      }
    ]
  }
}
```

### Hook configuration structure

Each event key maps to an **array of hook groups**. Each group:

| Field | Required | Notes |
|---|---|---|
| `matcher` | no | Tool-name or regex filter (for tool events). If absent, hook always fires for this event |
| `if` | no | Permission-rule–style filter, e.g., `Bash(git *)`. Only for: PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, PermissionDenied |
| `hooks` | yes | Array of hook objects |

Each hook object:

| Field | Required | Notes |
|---|---|---|
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, `"agent"` |
| `command` | for type=command | Shell command string |
| `url` | for type=http | HTTP endpoint URL |
| `prompt` | for type=prompt | LLM prompt string |
| `args` | no | Array → exec mode (no shell quoting). Used for MCP tool args |
| `headers` | no | Static headers for HTTP hooks |
| `env` | no | Extra env vars for the hook process |
| `timeout` | no | Override default timeout (seconds) |

## Hook types

| Type | Description | Default timeout |
|---|---|---|
| `command` | Spawns shell command; stdin = JSON payload | 10 min (30s for UserPromptSubmit) |
| `http` | POST JSON payload to URL; receives structured response | 10 min |
| `mcp_tool` | Calls an MCP tool with the event payload | 10 min |
| `prompt` | Single-turn LLM evaluation of the payload | 30 s |
| `agent` | Multi-turn LLM with tools (experimental) | 60 s |

Shell form vs exec form: when `args: []` is set, the command is exec'd without a shell (no quoting issues).

## Matcher syntax

For tool events (`PreToolUse`, `PostToolUse`, `PermissionRequest`, etc.):
- Plain string: matches tool name exactly (e.g., `"Bash"`, `"Edit"`)
- Regex: e.g., `"Edit|Write"`, `"mcp__.*"`, `"mcp__github__.*"`

For other events, per-event matcher values:

| Event | Matcher values |
|---|---|
| `SessionStart` | `startup\|resume\|clear\|compact` |
| `Setup` | `init\|maintenance` |
| `SessionEnd` | `clear\|resume\|logout\|prompt_input_exit\|bypass_permissions_disabled\|other` |
| `Notification` | `permission_prompt\|idle_prompt\|auth_success\|elicitation_dialog\|elicitation_complete\|elicitation_response` |
| `ConfigChange` | `user_settings\|project_settings\|local_settings\|policy_settings\|skills` |
| `FileChanged` | Literal filenames (split by `\|`) |
| `Elicitation` / `ElicitationResult` | MCP server names |

The `if` field uses permission rule syntax (e.g., `Bash(git *)`, `Edit(*.ts)`).

## Hook input shape

Claude Code writes a JSON object to stdin. Common top-level fields:

| Field | Type | Present when |
|---|---|---|
| `hook_event_name` | string | Always |
| `session_id` | string | Always |
| `cwd` | string | Always (absent if no cwd, e.g., some SDK contexts) |
| `transcript_path` | string | Always (absent in headless/SDK without persistent transcript) |
| `tool_name` | string | PreToolUse, PostToolUse, PermissionRequest, PermissionDenied |
| `tool_input` | object | PreToolUse, PostToolUse (the args passed to the tool) |
| `tool_response` | any | PostToolUse (what the tool returned) |
| `prompt` | string | UserPromptSubmit (the user's prompt text) |
| `source` | string | SessionStart (`startup`, `resume`, `clear`, `compact`) |
| `stop_hook_active` | bool | Stop event (use to avoid infinite loops) |

Example `PreToolUse` payload for a Bash call:

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

Environment variable available to all hook types: `CLAUDE_PROJECT_DIR`

## Hook output shape

### Exit codes (command hooks)

| Exit code | Meaning |
|---|---|
| `0` | Proceed normally. Stdout added to context (for UserPromptSubmit, UserPromptExpansion, SessionStart) |
| `2` | Block / provide feedback. Stderr sent to Claude as feedback. For Stop: shown to user, execution continues |
| Other | Proceed normally. Stderr shown in transcript |

### JSON output (structured control)

Hooks can write a JSON object to stdout for structured behavior:

**PreToolUse** — `hookSpecificOutput`:
```json
{
  "hookSpecificOutput": {
    "permissionDecision": "allow",
    "permissionDecisionReason": "Git status is read-only",
    "updatedInput": { "command": "sanitized-command" }
  }
}
```

`permissionDecision` values:
- `allow` — skip interactive prompt (deny/ask rules still apply)
- `deny` — cancel tool call; reason sent to Claude
- `ask` — show permission prompt
- `defer` — exit process in non-interactive mode (SDK wrapper collects input)

**PostToolUse / Stop** — block subsequent step:
```json
{"decision": "block", "reason": "Output contained sensitive data"}
```

**PermissionRequest** — `hookSpecificOutput`:
```json
{
  "hookSpecificOutput": {
    "decision": {"behavior": "allow"},
    "updatedPermissions": [{"type": "setMode", "mode": "acceptEdits"}]
  }
}
```

**UserPromptSubmit** — inject context:
```json
{"additionalContext": "Current git branch: feature/foo"}
```

**PostToolBatch** — results merged; most restrictive decision wins.

## Blocking vs non-blocking semantics

| Event | Can block? | How to block |
|---|---|---|
| PreToolUse | Yes | Exit 2 or `permissionDecision: "deny"` |
| PermissionRequest | Yes (allow/deny/ask) | `hookSpecificOutput.decision.behavior` |
| UserPromptExpansion | Yes | Exit 2 |
| PostToolUse | Partially | `{"decision": "block", "reason": "..."}` blocks subsequent step |
| Stop | Partial | Exit 2 shows stderr to user; execution still continues |
| PostToolBatch | Yes | Most restrictive decision across all hooks |
| All others | No | — |

**Multiple hooks on same event:** run in parallel; most restrictive decision wins for permission events. Identical commands deduplicated.

## Special behaviors

**`stop_hook_active` field:** set in the Stop event payload to prevent infinite hook loops. Check this before emitting output.

**Async hooks:** command hooks can exit 0 immediately and do work in background.

**Managed hook restrictions:**
- `allowManagedHooksOnly: true` in managed settings blocks all non-managed hooks
- `allowedHttpHookUrls` restricts HTTP hook target URLs
- `httpHookAllowedEnvVars` restricts env vars HTTP hooks can interpolate

**Plugin hooks:** loaded from `<plugin>/hooks/hooks.json`. Reload with `/reload-plugins`.

## Worked examples

**Log all Bash commands:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{"type": "command", "command": "jq '.tool_input.command' >> ~/.claude/bash-log.txt"}]
      }
    ]
  }
}
```

**Desktop notification on Stop:**
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [{"type": "command", "command": "osascript -e 'display notification \"Claude finished\" with title \"Claude Code\"'"}]
      }
    ]
  }
}
```

**Block dangerous Bash commands (exit 2):**
```bash
#!/bin/bash
# ~/.claude/hooks/check-bash.sh
INPUT=$(cat)
CMD=$(echo "$INPUT" | jq -r '.tool_input.command')
if echo "$CMD" | grep -qE 'rm -rf /|DROP TABLE'; then
  echo "Dangerous command blocked" >&2
  exit 2
fi
```

---

*Source pages: [`code.claude.com/docs/en/hooks.md`](https://code.claude.com/docs/en/hooks.md), [`hooks-guide.md`](https://code.claude.com/docs/en/hooks-guide.md)*
