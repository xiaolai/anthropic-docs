---
name: claude-code-cli
description: |
  Deep reference for Claude Code's CLI surface: command-line flags,
  subcommands, environment variables (ANTHROPIC_* / CLAUDE_*),
  permission modes (default / acceptEdits / plan / bypassPermissions),
  the ~/.claude/ directory layout, IDE integration entry points, and
  authentication mechanisms. Read this file when the user asks about
  CLI invocation, env vars, permission modes, ~/.claude/ structure,
  or how Claude Code authenticates.
source: https://code.claude.com/docs/en/cli-reference.md
---

# Claude Code — CLI, environment, and layout

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for CLI / env / layout questions.*

## Top-level invocation

| Invocation | Purpose |
|---|---|
| `claude` | Start interactive session |
| `claude "query"` | Interactive session with initial prompt |
| `claude -p "query"` | Non-interactive (print mode); exit after one response |
| `cat file \| claude -p "query"` | Process piped content in print mode |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall the native binary (`stable`, `latest`, or `2.1.x`) |

Source: [cli-reference.md](https://code.claude.com/docs/en/cli-reference.md).

## CLI flags

Selected important flags. Full list: `claude --help` (note: not all flags appear in `--help`).

| Flag | Notes |
|---|---|
| `--print`, `-p` | Non-interactive print mode |
| `--continue`, `-c` | Load most recent conversation |
| `--resume`, `-r` | Resume by session ID or name |
| `--model` | Model for this session (overrides settings, `ANTHROPIC_MODEL`) |
| `--permission-mode` | Start in a specific mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Equivalent to `--permission-mode bypassPermissions` |
| `--output-format` | Print mode output: `text`, `json`, `stream-json` |
| `--allowedTools` | Tools that execute without prompting (permission rule syntax) |
| `--disallowedTools` | Tools removed from model context entirely |
| `--tools` | Restrict available built-in tools (e.g. `"Bash,Edit,Read"`) |
| `--system-prompt` | Replace entire system prompt |
| `--append-system-prompt` | Append to default system prompt |
| `--system-prompt-file` | Load replacement system prompt from file |
| `--append-system-prompt-file` | Append file contents to default prompt |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Dollar spending cap (print mode only) |
| `--worktree`, `-w` | Start in isolated git worktree at `<repo>/.claude/worktrees/<name>` |
| `--bg` | Start as background agent; return immediately with session ID |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, auto memory, CLAUDE.md |
| `--mcp-config` | Load MCP servers from JSON file or inline string |
| `--plugin-dir` | Load plugin from directory or `.zip` for this session |
| `--plugin-url` | Fetch plugin `.zip` from URL for this session |
| `--settings` | Settings JSON file or inline JSON (overrides file-based settings) |
| `--add-dir` | Add additional working directories (persists with `permissions.additionalDirectories`) |
| `--effort` | Effort level: `low`, `medium`, `high`, `xhigh`, `max` (session only) |
| `--name`, `-n` | Set display name for session (resumable by name with `claude -r <name>`) |
| `--debug` | Enable debug logging, optional category filter (`"api,hooks"`) |
| `--debug-file <path>` | Write debug logs to file |
| `--verbose` | Show full turn-by-turn output |
| `--no-session-persistence` | Don't save session to disk (print mode only) |
| `--version`, `-v` | Output version number |
| `--init` | Run Setup hooks with `init` matcher before session (print mode) |
| `--init-only` | Run Setup + SessionStart hooks, then exit |
| `--fork-session` | Create new session ID when resuming (use with `--resume`/`--continue`) |
| `--from-pr` | Resume sessions linked to a specific PR (number, GitHub URL, GitLab MR URL, etc.) |
| `--remote` | Create new web session on claude.ai with provided task |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--teleport` | Resume a web session in local terminal |
| `--fallback-model` | Auto-fallback model when default is overloaded (print mode + background) |
| `--json-schema` | Get JSON output matching schema after agent completes (print mode) |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves cache reuse) |

## Subcommands

| Subcommand | Purpose |
|---|---|
| `claude agents` | Open agent view to monitor/dispatch parallel background sessions |
| `claude attach <id>` | Attach to background session in this terminal |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` flags available) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (exit 0 = logged in, 1 = not) |
| `claude daemon status` | Print background supervisor state and worker count |
| `claude install [version]` | Install/reinstall native binary |
| `claude logs <id>` | Print recent output from a background session |
| `claude mcp` | Configure MCP servers (see [SKILL-mcp.md](SKILL-mcp.md)) |
| `claude plugin` | Manage plugins. Alias: `claude plugins` |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start Remote Control server (no local interactive session) |
| `claude respawn <id>` | Restart a background session with conversation intact |
| `claude rm <id>` | Remove a background session from list |
| `claude setup-token` | Generate long-lived OAuth token for CI/scripts |
| `claude stop <id>` | Stop a background session. Alias: `claude kill` |
| `claude ultrareview [target]` | Run ultrareview non-interactively (`--json`, `--timeout <minutes>`) |
| `claude update` | Update to latest version |

## Environment variables

Selected important env vars. Full list: [env-vars.md](https://code.claude.com/docs/en/env-vars.md).

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Metered API authentication |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Pro/Max) OAuth token |
| `ANTHROPIC_MODEL` | Override default model (e.g. `claude-opus-4-7`); overrides `model` in settings |
| `ANTHROPIC_BASE_URL` | Custom API base URL (for proxies/gateways) |
| `EDITOR` | External editor for `Ctrl+G` (e.g. `code --wait`, `vim`) |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set `"1"` to enable OpenTelemetry tracing |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP endpoint for traces/metrics |
| `DISABLE_AUTOUPDATER` | Set `"1"` to disable auto-updates |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip saving prompts to history |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Set `"1"` to disable auto memory |
| `CLAUDE_CODE_DISABLE_THINKING` | Set `"1"` to force thinking off |
| `CLAUDE_CODE_EFFORT_LEVEL` | Session effort level (`low`, `medium`, `high`, `xhigh`) |
| `CLAUDE_CODE_USE_BEDROCK` | Set `"1"` to use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Set `"1"` to use Google Vertex AI |
| `CLAUDE_CODE_SIMPLE` | Set by `--bare` flag to indicate minimal mode |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Refresh interval for `apiKeyHelper` script |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | Same as `awaySummaryEnabled` setting |
| `ENABLE_TOOL_SEARCH` | Set `"false"` to disable MCP tool search (falls back to WaitForMcpServers) |

Precedence (highest wins): env var > `settings.local.json` > `settings.json` (project) > `settings.json` (user) > built-in defaults. Env vars set in the `env` settings key are injected into every session but don't override shell-level vars of the same name.

## Permission modes

Set with `--permission-mode <mode>` or `permissions.defaultMode` in settings. Cycled with Shift+Tab in the CLI.

| Mode | Description |
|---|---|
| `default` | Prompts for permission on first use of each tool |
| `acceptEdits` | Auto-accepts file edits and common filesystem commands for working-dir paths |
| `plan` | Read-only: Claude explores but does not edit files |
| `auto` | Auto-approves tool calls with background safety checks (research preview) |
| `dontAsk` | Auto-denies tools unless pre-approved via `/permissions` or `permissions.allow` |
| `bypassPermissions` | Skips all permission prompts. Root/home directory removals still prompt. Use only in isolated containers. |

**Note:** `auto` mode is ignored when set in project settings (`.claude/settings.json`) as of v2.1.142 — prevents repos from granting themselves auto mode. Set in `~/.claude/settings.json` instead.

To disable `bypassPermissions`: set `permissions.disableBypassPermissionsMode: "disable"` in managed settings.
To disable `auto` mode: set `disableAutoMode: "disable"` in managed settings.

Source: [permission-modes.md](https://code.claude.com/docs/en/permission-modes.md), [permissions.md](https://code.claude.com/docs/en/permissions.md).

## Authentication

Two authentication methods (mutually exclusive):

| Method | Env var | For whom |
|---|---|---|
| OAuth (subscription) | `CLAUDE_CODE_OAUTH_TOKEN` | Pro / Max / Team / Enterprise accounts |
| API key (metered) | `ANTHROPIC_API_KEY` | Anthropic Console accounts |

Login: `claude auth login`. Add `--console` for API key (metered) login, `--sso` to force SSO, `--email` to pre-fill email. Token generation for CI: `claude setup-token`.

Source: [authentication.md](https://code.claude.com/docs/en/authentication.md).

## `~/.claude/` directory layout

| Path | Contents |
|---|---|
| `~/.claude/settings.json` | User-scope settings |
| `~/.claude/CLAUDE.md` | User-scope memory |
| `~/.claude/commands/` | User-scope slash commands |
| `~/.claude/agents/` | User-scope subagent definitions |
| `~/.claude/skills/` | User-scope skills |
| `~/.claude/hooks/` | User-scope hook scripts |
| `~/.claude/themes/` | Custom color themes |
| `~/.claude/plans/` | Default plan storage (overridable) |
| `~/.claude.json` | OAuth session, user-scope MCP servers, per-project state and caches |

Project-scope paths live under `<project>/.claude/` (same structure minus `~/.claude.json`). See [claude-directory.md](https://code.claude.com/docs/en/claude-directory.md).

## IDE integrations

| IDE | Extension | Notes |
|---|---|---|
| VS Code / Cursor / Windsurf | Claude Code extension | Inline diffs, @-mentions, plan review, keyboard shortcuts |
| JetBrains IDEs | Claude Code plugin | IntelliJ, PyCharm, WebStorm, etc. |
| Web / Browser | claude.ai/code | Cloud sessions, no local setup |

Connect: `claude --ide` (auto-connect if exactly one IDE is running). `claude agents` supports `--cwd` to filter sessions by directory.

Source: [vs-code.md](https://code.claude.com/docs/en/vs-code.md), [jetbrains.md](https://code.claude.com/docs/en/jetbrains.md).

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `settings.md` (env section), `permissions.md`.*
