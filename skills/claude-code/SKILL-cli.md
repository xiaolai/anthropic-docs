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

| Invocation | Description |
|---|---|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Non-interactive print mode (exits after response) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |

Source: `code.claude.com/docs/en/cli-reference.md`.

## CLI subcommands

| Subcommand | Description |
|---|---|
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall native binary (accepts `2.1.118`, `stable`, `latest`) |
| `claude auth login` | Sign in. Flags: `--email`, `--sso`, `--console` |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable). Exit 0 if logged in, 1 if not |
| `claude agents` | Open agent view to monitor/dispatch background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude daemon status` | Print supervisor state for diagnostics |
| `claude logs <id>` | Print recent output from a background session |
| `claude mcp` | Configure MCP servers (see [`SKILL-mcp.md`](SKILL-mcp.md)) |
| `claude plugin` | Manage plugins (alias: `claude plugins`). See [`SKILL-plugins.md`](SKILL-plugins.md) |
| `claude project purge [path]` | Delete all local Claude Code state for a project. Flags: `--dry-run`, `-y`, `--all` |
| `claude remote-control` | Start a Remote Control server |
| `claude respawn <id>` | Restart a background session (use `--all` for all running sessions) |
| `claude rm <id>` | Remove a background session from the list |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts |
| `claude stop <id>` | Stop a background session (also: `claude kill`) |
| `claude ultrareview [target]` | Run ultrareview non-interactively. Flags: `--json`, `--timeout <minutes>` |

## CLI flags

Selected key flags (source: `code.claude.com/docs/en/cli-reference.md`):

| Flag | Description |
|---|---|
| `--add-dir` | Add additional working directories |
| `--agent` | Specify an agent for the current session |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, auto memory, CLAUDE.md |
| `--bg` | Start session as background agent, return immediately |
| `--channels` | MCP servers whose channel notifications to listen for |
| `--chrome` | Enable Chrome browser integration |
| `--continue`, `-c` | Continue most recent conversation |
| `--dangerously-skip-permissions` | Bypass permission prompts (`--permission-mode bypassPermissions`) |
| `--debug` | Enable debug mode (optional category filter e.g. `"api,hooks"`) |
| `--debug-file <path>` | Write debug logs to a file |
| `--disable-slash-commands` | Disable all skills and commands for this session |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves cache reuse) |
| `--fallback-model` | Fallback model when default is overloaded (print mode / background only) |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr` | Resume sessions linked to a PR (number, GitHub URL, GitLab MR URL, Bitbucket URL) |
| `--init` | Run Setup hooks with `init` matcher before session (print mode only) |
| `--init-only` | Run Setup and SessionStart hooks then exit |
| `--maintenance` | Run Setup hooks with `maintenance` matcher (print mode only) |
| `--max-budget-usd` | Max API spend before stopping (print mode only) |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--mcp-config` | Load MCP servers from JSON files/strings |
| `--model` | Override model for this session |
| `--name`, `-n` | Set display name for the session |
| `--output-format` | Print mode output format: `text`, `json`, `stream-json` |
| `--permission-mode` | Begin in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--plugin-dir` | Load plugin from directory or `.zip` archive for this session |
| `--plugin-url` | Fetch plugin `.zip` archive from URL for this session |
| `--print`, `-p` | Non-interactive print mode |
| `--remote` | Create new web session on claude.ai |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--resume`, `-r` | Resume session by ID or name |
| `--settings` | Path to settings JSON file or inline JSON string |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Load system prompt from file |
| `--append-system-prompt` | Append to default system prompt |
| `--append-system-prompt-file` | Append file contents to default system prompt |
| `--teleport` | Resume a web session in local terminal |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` |
| `--tools` | Restrict built-in tools (e.g. `"Bash,Edit,Read"` or `""` for none) |
| `--verbose` | Enable verbose logging |
| `--version`, `-v` | Output version number |
| `--worktree`, `-w` | Start in isolated git worktree |

## Environment variables

Key env vars (full list: `code.claude.com/docs/en/env-vars`):

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Metered API authentication. Mutually exclusive with `CLAUDE_CODE_OAUTH_TOKEN`. |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max/Pro) OAuth authentication. Preferred over API key when both set. |
| `ANTHROPIC_MODEL` | Override default model (e.g. `claude-opus-4-7`). Overrides `model` in settings. |
| `ANTHROPIC_BASE_URL` | Custom API endpoint (LLM gateway, Bedrock proxy, etc.) |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location for sandboxed/multi-account setups. |
| `EDITOR` | External editor for Ctrl+G. Common: `code --wait`, `vim`, `nvim`. |
| `MCP_TIMEOUT` | MCP server startup timeout in ms (e.g. `MCP_TIMEOUT=10000`). |
| `MAX_MCP_OUTPUT_TOKENS` | Max MCP tool output tokens before warning (default: 10000). |
| `DISABLE_AUTOUPDATER` | Set to `1` to disable auto-updates entirely. |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Disable transcript writes when set. |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry. |
| `CLAUDE_CODE_DEBUG_LOGS_DIR` | Directory for debug logs. |
| `CLAUDE_CODE_EFFORT_LEVEL` | Session effort level (`low`, `medium`, `high`, `xhigh`). |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | Set to `1` for session recap on terminal return. |
| `CLAUDE_CODE_SIMPLE` | Set by `--bare` flag; disables auto-discovery. |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | Set to `1` to enable PowerShell tool on Windows. |
| `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` | Prefix for auto-generated Remote Control session names. |

Precedence (highest wins): CLI flags > shell env var > `settings.local.json` > `settings.json` (project) > `settings.json` (user) > built-in default.

## Permission modes

Source: `code.claude.com/docs/en/permission-modes.md`.

| Mode | `--permission-mode` value | Description |
|---|---|---|
| Default | `default` | Prompts before most tool use |
| Accept edits | `acceptEdits` | Auto-approves file edits; prompts for Bash and network |
| Plan | `plan` | Read-only; presents a plan for approval before acting |
| Auto | `auto` | AI classifier decides what to allow/deny without prompting |
| Don't ask | `dontAsk` | Approves all except explicitly denied; no prompts |
| Bypass permissions | `bypassPermissions` | Skips ALL permission checks (use in trusted CI only) |

Cycle modes with **Shift+Tab** in interactive CLI. `auto` mode can be disabled with `disableAutoMode: "disable"` in settings. `bypassPermissions` can be disabled with `permissions.disableBypassPermissionsMode: "disable"`.

## Authentication

Two authentication methods:
- **OAuth/subscription** (`CLAUDE_CODE_OAUTH_TOKEN`): For Max/Pro subscribers via `claude auth login`.
- **API key** (`ANTHROPIC_API_KEY`): For metered API usage via Anthropic Console.

`claude auth login --console` signs in with Anthropic Console for API billing.
`claude setup-token` generates a long-lived OAuth token for CI (requires Claude subscription).

## `~/.claude/` directory layout

| Path | Contents |
|---|---|
| `~/.claude/settings.json` | User-scope settings (all projects) |
| `~/.claude/agents/` | Personal subagent definitions |
| `~/.claude/skills/` | Personal skills |
| `~/.claude/commands/` | Personal commands (legacy, still supported) |
| `~/.claude/CLAUDE.md` | User-scope memory |
| `~/.claude/plans/` | Plan files (default location) |
| `~/.claude.json` | OAuth session, user-scoped MCP servers, per-project state, caches |

Project-level configuration lives in `<project>/.claude/`. MCP project servers live in `<project>/.mcp.json`.

Source: `code.claude.com/docs/en/claude-directory.md`.

## IDE integrations

- **VS Code**: Install the Claude Code extension from the VS Code marketplace. Source: `code.claude.com/docs/en/vs-code`.
- **JetBrains** (IntelliJ, PyCharm, WebStorm, etc.): Install the Claude Code plugin from JetBrains marketplace. Source: `code.claude.com/docs/en/jetbrains`.
- **Web**: `claude.ai/code` — cloud environment, no local install. Source: `code.claude.com/docs/en/claude-code-on-the-web`.

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `settings.md` (env section), `permissions.md`.*
