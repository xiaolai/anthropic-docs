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

| Command | Description |
|---|---|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode: query via SDK then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall the native binary |
| `claude auth login` | Sign in. Use `--console` for API billing, `--sso` for SSO |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (exit 0=logged-in, 1=not) |
| `claude agents` | Open agent view for parallel background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins |
| `claude project purge [path]` | Delete all local state for a project |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

Typing a mistyped subcommand shows a "Did you mean X?" suggestion.

Source: `code.claude.com/docs/en/cli-reference.md`.

## CLI flags

`claude --help` does not list every flag. Key flags:

| Flag | Description |
|---|---|
| `-p`, `--print` | Print mode (non-interactive, SDK-style) |
| `-c`, `--continue` | Load most recent conversation in current directory |
| `-r`, `--resume <id>` | Resume a session by ID or name |
| `-n`, `--name <name>` | Set display name for the session |
| `-w`, `--worktree [name]` | Start in an isolated git worktree |
| `--bg` | Start as background agent, return immediately |
| `--permission-mode <mode>` | Start in specified permission mode |
| `--dangerously-skip-permissions` | Bypass all permission prompts |
| `--allow-dangerously-skip-permissions` | Add bypassPermissions to Shift+Tab cycle |
| `--model <model>` | Override model for this session |
| `--effort <level>` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--system-prompt <text>` | Replace entire system prompt |
| `--system-prompt-file <path>` | Replace with file contents |
| `--append-system-prompt <text>` | Append to default system prompt |
| `--append-system-prompt-file <path>` | Append file to default system prompt |
| `--output-format <fmt>` | Output format for print mode: `text`, `json`, `stream-json` |
| `--max-turns <N>` | Limit agentic turns (print mode) |
| `--max-budget-usd <N>` | Max dollar spend (print mode) |
| `--mcp-config <file>` | Load MCP servers from JSON file |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--agent <name>` | Specify an agent for this session |
| `--allowedTools "..."` | Tools that execute without prompting |
| `--disallowedTools "..."` | Tools that are removed from context |
| `--tools "..."` | Restrict which built-in tools are available |
| `--add-dir <path>` | Add additional working directories |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--debug [categories]` | Enable debug mode |
| `--verbose` | Verbose turn-by-turn output |
| `--version`, `-v` | Output version number |
| `--plugin-dir <path>` | Load a local plugin for this session only |
| `--plugin-url <url>` | Fetch plugin from URL for this session only |
| `--no-session-persistence` | Disable session persistence (print mode only) |
| `--fork-session` | Create new session ID when resuming |
| `--from-pr <pr>` | Resume sessions linked to a PR |
| `--chrome` | Enable Chrome browser integration |
| `--remote "task"` | Create a new web session on claude.ai |
| `--remote-control` | Enable Remote Control from claude.ai |
| `--teleport` | Resume a web session in local terminal |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--teammate-mode <mode>` | Agent team display: `auto`, `in-process`, `tmux` |
| `--setting-sources <list>` | Comma-separated settings sources to load |
| `--settings <path\|json>` | Override settings for this session |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves prompt caching) |

Source: `code.claude.com/docs/en/cli-reference.md`.

## Subcommands

| Subcommand | Description |
|---|---|
| `claude mcp add [--transport stdio\|http\|sse] [--scope local\|project\|user] <name> [-- <cmd>]` | Add an MCP server |
| `claude mcp add-json <name> <json>` | Add an MCP server from JSON |
| `claude mcp list` | List configured MCP servers |
| `claude mcp get <name>` | Get details for a specific server |
| `claude mcp remove <name>` | Remove an MCP server |
| `claude plugin install <name>@<marketplace>` | Install a plugin |
| `claude plugin list` | List installed plugins |
| `claude plugin update [name]` | Update plugins |
| `claude plugin marketplace add <url>` | Add a marketplace |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules |
| `claude auto-mode config` | Show effective auto mode config |
| `claude project purge [path]` | Delete local project state |
| `claude setup-token` | Generate long-lived OAuth token |
| `claude remote-control [--name <name>]` | Start Remote Control server |
| `claude attach <id>` | Attach to background session |
| `claude stop <id>` | Stop background session |
| `claude rm <id>` | Remove background session |
| `claude logs <id>` | Print recent output from background session |
| `claude respawn <id>` | Restart stopped background session |
| `claude ultrareview [target] [--json] [--timeout <min>]` | Non-interactive ultrareview |
| `claude install [version\|stable\|latest]` | Install or reinstall native binary |

Source: `code.claude.com/docs/en/cli-reference.md`.

## Environment variables

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | API key authentication. Mutually exclusive with OAuth token. |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max/Pro) authentication via OAuth. |
| `ANTHROPIC_MODEL` | Override default model for the session. |
| `ANTHROPIC_BASE_URL` | Override the API base URL. |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location. |
| `EDITOR` | Editor invoked for external editing (`code --wait`, `vim`, etc.). |
| `CLAUDE_CODE_USE_BEDROCK` | Set to `1` to use Amazon Bedrock. |
| `CLAUDE_CODE_USE_VERTEX` | Set to `1` to use Google Vertex AI. |
| `MCP_TIMEOUT` | MCP server startup timeout in milliseconds (e.g. `MCP_TIMEOUT=10000`). |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens per MCP tool output. Default: 10,000. |
| `DISABLE_AUTOUPDATER` | Set to `1` to disable auto-updates. |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry. |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Set to `1` to disable auto memory. |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Set to `1` to disable session persistence. |
| `CLAUDE_CODE_SIMPLE` | Set by `--bare` flag; disables auto-discovery. |
| `CLAUDE_CODE_NO_FLICKER` | Set to `1` for fullscreen (alt-screen) rendering. |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level for the session (overrides settings). |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | Set to `1` to show session recap after being away. |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | Set to `1` to enable PowerShell tool on Windows. |
| `CLAUDE_CODE_FORK_SUBAGENT` | When set, `/fork` spawns a forked subagent instead of branching. |

Precedence (highest wins): env var > `settings.local.json` > `settings.json` (project) > `settings.json` (user) > built-in default.

For the complete env var reference, see [env-vars.md](https://code.claude.com/docs/en/env-vars.md).

Source: `code.claude.com/docs/en/env-vars.md`, `code.claude.com/docs/en/cli-reference.md`.

## Permission modes

| Mode | What runs without asking | Best for |
|---|---|---|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `rm`, `rmdir`, `sed`) | Iterating on code you're reviewing |
| `plan` | Reads only (no edits) | Exploring a codebase before changing it |
| `auto` | Everything, with background classifier safety checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools (`permissions.allow` rules) | Locked-down CI and scripts |
| `bypassPermissions` | Everything (including protected paths since v2.1.126) | Isolated containers and VMs **only** |

Switch modes: `Shift+Tab` cycles `default → acceptEdits → plan`. `--permission-mode <mode>` sets at startup. `defaultMode` in settings persists across sessions.

**Auto mode** requires Claude Code v2.1.83+, Max/Team/Enterprise/API plan (not Pro), Claude Sonnet 4.6 or Opus 4.6/4.7, Anthropic API only (not Bedrock/Vertex/Foundry).

**bypassPermissions**: cannot be used as root/sudo. Removals targeting `/` or `~` still prompt. Admins can block it with `permissions.disableBypassPermissionsMode: "disable"`.

**Protected paths** (never auto-approved except in bypassPermissions): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except commands/agents/skills/worktrees subdirs), `.gitconfig`, `.gitmodules`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json`.

Source: `code.claude.com/docs/en/permission-modes.md`, `code.claude.com/docs/en/permissions.md`.

## Authentication

Two auth methods:

**Subscription auth (Claude.ai)**: `CLAUDE_CODE_OAUTH_TOKEN` or `claude auth login`. For Max, Pro, Team, Enterprise plans. Authenticate via browser OAuth flow. Generate a long-lived CI token with `claude setup-token`.

**API key auth (Anthropic Console)**: `ANTHROPIC_API_KEY` or `claude auth login --console`. For API usage billing. Supports `--sso` for SSO authentication.

Settings:
- `forceLoginMethod`: `"claudeai"` or `"console"` to restrict login to one method
- `forceLoginOrgUUID`: require a specific organization UUID

Source: `code.claude.com/docs/en/authentication.md`, `code.claude.com/docs/en/cli-reference.md`.

## `~/.claude/` directory layout

| Path | Purpose |
|---|---|
| `~/.claude/settings.json` | User-scope settings (applies to all projects) |
| `~/.claude/CLAUDE.md` | User-scope memory (loaded in every session) |
| `~/.claude/commands/` | User-scope slash commands |
| `~/.claude/skills/` | User-scope skills |
| `~/.claude/agents/` | User-scope subagent definitions |
| `~/.claude/themes/` | Custom color themes |
| `~/.claude/plans/` | Plan files (default location) |
| `~/.claude/keybindings.json` | Custom keyboard shortcuts |
| `~/.claude/loop.md` | Default prompt for `/loop` with no arguments |
| `~/.claude.json` | OAuth session, user-scope MCP configs, per-project state, caches |

Project-level config lives in `.claude/` at the project root:
- `.claude/settings.json` — project settings (git-committed)
- `.claude/settings.local.json` — personal project overrides (gitignored)
- `.mcp.json` — project MCP servers (git-committed)
- `.claude/CLAUDE.md` — project memory
- `.claude/commands/` — project commands
- `.claude/skills/` — project skills
- `.claude/agents/` — project subagents
- `CLAUDE.md` — memory file at project root (also loaded)
- `CLAUDE.local.md` — personal project memory (gitignored)

`CLAUDE_CONFIG_DIR` overrides `~/.claude/`. On Windows, `~/.claude` resolves to `%USERPROFILE%\.claude`.

Source: `code.claude.com/docs/en/claude-directory.md`, `code.claude.com/docs/en/settings.md`.

## IDE integrations

- **VS Code**: Install the Claude Code extension. Provides inline diffs, @-mentions, plan review, and keyboard shortcuts. Configure `claudeCode.initialPermissionMode` in VS Code settings.
- **JetBrains** (IntelliJ, PyCharm, WebStorm, etc.): Claude Code runs in the IDE terminal. Modes work the same as CLI (`Shift+Tab` to cycle).
- **Web** (`claude.ai/code`): Cloud sessions with plan/acceptEdits modes. Remote Control links local sessions to the web UI.
- **Desktop app**: Parallel sessions with git isolation, drag-and-drop pane layout, computer use, PR monitoring.

`claude --ide` auto-connects to a running IDE at startup.

Source: `code.claude.com/docs/en/vs-code.md`, `code.claude.com/docs/en/jetbrains.md`.

## Cost and quota

View session cost and limits with `/usage` (aliases: `/cost`, `/stats`).

- **Subscription plans**: Max, Team, Enterprise have per-period usage limits. `/usage` shows your current limits and activity.
- **API billing**: usage is metered per token. Set `--max-budget-usd <N>` for per-run spend caps.
- **Context management**: `/compact` summarizes the conversation to free up context. Auto-compaction fires when the context window gets full.
- **Effort level**: higher effort uses more tokens. Set with `--effort` or `/effort`. `xhigh` and `max` are for models that support extended thinking.

Source: `code.claude.com/docs/en/costs.md`, `code.claude.com/docs/en/cli-reference.md`.

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `settings.md` (env section), `permissions.md`.*
