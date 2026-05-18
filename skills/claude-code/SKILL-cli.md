---
name: claude-code-cli
description: |
  Deep reference for Claude Code's CLI surface: command-line flags,
  subcommands, environment variables (ANTHROPIC_* / CLAUDE_*),
  permission modes (default / acceptEdits / plan / auto / dontAsk /
  bypassPermissions), the ~/.claude/ directory layout, IDE integration
  entry points, and authentication mechanisms. Read this file when the
  user asks about CLI invocation, env vars, permission modes,
  ~/.claude/ structure, or how Claude Code authenticates.
source: https://code.claude.com/docs/en/cli-reference.md
---

# Claude Code — CLI, environment, and layout

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for CLI / env / layout questions.*

## Top-level subcommands

| Command | Description |
|---|---|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode (query and exit, SDK-style) |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall native binary. Accepts version like `2.1.118`, `stable`, or `latest` |
| `claude auth login` | Sign in. Use `--email`, `--sso`, `--console` flags |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable). Exit 0 if logged in |
| `claude agents` | Open agent view to monitor/dispatch parallel background sessions. Use `--cwd <path>` to filter |
| `claude attach <id>` | Attach to a background session in this terminal |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude logs <id>` | Print recent output from a background session |
| `claude mcp` | Configure MCP servers (see [`SKILL-mcp.md`](SKILL-mcp.md)) |
| `claude plugin` | Manage plugins. Alias: `claude plugins`. See `plugins-reference.md#cli-commands-reference` |
| `claude project purge [path]` | Delete all local Claude Code state for a project. Flags: `--dry-run`, `-y`/`--yes`, `-i`/`--interactive`, `--all` |
| `claude remote-control` | Start Remote Control server (no local interactive session) |
| `claude respawn <id>` | Restart a stopped background session. `--all` for all stopped sessions |
| `claude rm <id>` | Remove a background session from the list |
| `claude setup-token` | Generate long-lived OAuth token for CI. Requires Claude subscription |
| `claude stop <id>` | Stop a background session. Alias: `claude kill` |
| `claude ultrareview [target]` | Run ultrareview non-interactively. `--json` for raw payload; `--timeout <minutes>` (default 30) |

Source: `code.claude.com/docs/en/cli-reference.md`.

## CLI flags

`claude --help` does not list every flag; a flag's absence from `--help` doesn't mean it's unavailable.

| Flag | Notes |
|---|---|
| `--add-dir` | Add additional working directories for file access. Validates path exists |
| `--agent` | Specify an agent for current session (overrides `agent` setting) |
| `--agents` | Define custom subagents dynamically via JSON |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to Shift+Tab cycle without starting in it |
| `--allowedTools` | Tools that execute without prompting. See permission rule syntax |
| `--append-system-prompt` | Append custom text to end of default system prompt |
| `--append-system-prompt-file` | Load additional system prompt text from file |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, auto memory, CLAUDE.md. Sets `CLAUDE_CODE_SIMPLE` |
| `--betas` | Beta headers for API requests (API key users only) |
| `--bg` | Start as background agent, return immediately. Prints session ID |
| `--channels` | MCP servers whose channel notifications to listen for |
| `--chrome` | Enable Chrome browser integration |
| `--continue`, `-c` | Load most recent conversation in current directory |
| `--dangerously-skip-permissions` | Skip permission prompts. Equivalent to `--permission-mode bypassPermissions` |
| `--debug` | Enable debug mode with optional category filtering (`"api,hooks"` or `"!statsig,!file"`) |
| `--debug-file <path>` | Write debug logs to specific file. Implicitly enables debug mode |
| `--disable-slash-commands` | Disable all skills and commands for this session |
| `--disallowedTools` | Tools removed from model's context and unusable |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max`. Overrides `effortLevel` setting for session |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves prompt-cache reuse). Only with `-p` |
| `--fallback-model` | Enable automatic fallback to specified model when default overloaded (print mode only) |
| `--fork-session` | When resuming, create new session ID instead of reusing original |
| `--from-pr` | Resume sessions linked to a PR (number, GitHub URL, GitLab MR URL, or Bitbucket PR URL) |
| `--ide` | Auto-connect to IDE if exactly one valid IDE is available |
| `--init` | Run Setup hooks with `init` matcher before session (print mode only) |
| `--init-only` | Run Setup and SessionStart hooks, then exit without starting conversation |
| `--include-hook-events` | Include hook lifecycle events in output stream (requires `--output-format stream-json`) |
| `--include-partial-messages` | Include partial streaming events (requires `--print --output-format stream-json`) |
| `--input-format` | Input format for print mode: `text` or `stream-json` |
| `--json-schema` | Get validated JSON output matching a JSON Schema after workflow (print mode only) |
| `--maintenance` | Run Setup hooks with `maintenance` matcher before session (print mode only) |
| `--max-budget-usd` | Maximum dollar amount before stopping (print mode only) |
| `--max-turns` | Limit agentic turns (print mode only). Exits with error when reached |
| `--mcp-config` | Load MCP servers from JSON files or strings |
| `--model` | Set model with alias (`sonnet`, `opus`) or full name |
| `--name`, `-n` | Set display name for session. Resume with `claude --resume <name>` |
| `--no-chrome` | Disable Chrome integration for this session |
| `--no-session-persistence` | Disable session saving to disk (print mode only). Same as `CLAUDE_CODE_SKIP_PROMPT_HISTORY` |
| `--output-format` | Output format for print mode: `text`, `json`, or `stream-json` |
| `--permission-mode` | Begin in specified permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--permission-prompt-tool` | MCP tool to handle permission prompts in non-interactive mode |
| `--plugin-dir` | Load plugin from directory or `.zip` archive for this session |
| `--plugin-url` | Fetch plugin `.zip` archive from URL for this session |
| `--print`, `-p` | Print mode: response without interactive mode |
| `--remote` | Create new web session on claude.ai with task description |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--remote-control-session-name-prefix <prefix>` | Prefix for auto-generated Remote Control session names |
| `--replay-user-messages` | Re-emit user messages from stdin on stdout |
| `--resume`, `-r` | Resume specific session by ID or name |
| `--session-id` | Use specific session ID (must be valid UUID) |
| `--setting-sources` | Comma-separated list of setting sources to load: `user`, `project`, `local` |
| `--settings` | Path to settings JSON file or inline JSON string |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config`, ignoring all others |
| `--system-prompt` | Replace entire system prompt with custom text |
| `--system-prompt-file` | Load system prompt from file, replacing default |
| `--teleport` | Resume a web session in local terminal |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, or `tmux` |
| `--tmux` | Create tmux session for worktree (requires `--worktree`) |
| `--tools` | Restrict built-in tools: `""` (none), `"default"` (all), or tool names like `"Bash,Edit,Read"` |
| `--verbose` | Enable verbose logging. Overrides `viewMode` setting |
| `--version`, `-v` | Output version number |
| `--worktree`, `-w` | Start in isolated git worktree at `<repo>/.claude/worktrees/<name>`. Pass `#<N>` or PR URL to fetch |

### System prompt flags

| Flag | Behavior |
|---|---|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt (preserves tool guidance and safety instructions) |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

## Permission modes

Modes set the baseline for what Claude can do without a prompt. Modes are layered: permission rules from [`SKILL-settings.md`](SKILL-settings.md) §`permissions` block apply on top (except `bypassPermissions` which skips the permission layer entirely).

| Mode | What runs without asking | Best for |
|---|---|---|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands (`mkdir`, `touch`, `rm`, `rmdir`, `mv`, `cp`, `sed`) | Iterating on code you're reviewing |
| `plan` | Reads only (Claude writes plan but doesn't edit source) | Exploring before changing |
| `auto` | Everything, with background safety checks (research preview) | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI and scripts |
| `bypassPermissions` | Everything (circuit breaker: root/home-dir `rm -rf` still prompts) | **Isolated containers/VMs only** |

In every mode except `bypassPermissions`, protected paths (`~/.git`, `.claude`, `.vscode`, `.idea`, `.husky`) are never auto-approved.

### Switch modes

- **During session**: `Shift+Tab` cycles `default → acceptEdits → plan`. `auto` appears if account qualifies; `bypassPermissions` appears after launch flags enable it.
- **At startup**: `claude --permission-mode plan`
- **As default**: set `permissions.defaultMode` in `settings.json`:
  ```json
  { "permissions": { "defaultMode": "acceptEdits" } }
  ```

### `acceptEdits` mode details

Auto-approves: file edits and create/delete/move/copy commands (`mkdir`, `touch`, `rm`, `rmdir`, `mv`, `cp`, `sed`). Also auto-approves these with safe env prefix (`LANG=C`) or process wrappers (`timeout`, `nice`, `nohup`). Only for paths inside working directory or `additionalDirectories`.

When PowerShell tool enabled: also approves `Set-Content`, `Add-Content`, `Clear-Content`, `Remove-Item` (and aliases) on in-scope paths.

### `auto` mode

Uses a background classifier to verify actions align with your request. Configure with `autoMode` in settings or `claude auto-mode defaults`. To prevent auto mode: set `permissions.disableAutoMode: "disable"` in settings.

### `bypassPermissions` mode

⚠️ **Only use in isolated containers/VMs.** Skips all permission prompts including writes to `.git`, `.claude`, `.vscode`, `.idea`, `.husky`. Prevent it: set `permissions.disableBypassPermissionsMode: "disable"` in managed settings.

Source: `code.claude.com/docs/en/permission-modes.md`.

## Environment variables

Key environment variables (full list at `code.claude.com/docs/en/env-vars.md`):

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | API key authentication |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth token for subscription (Max/Pro) auth |
| `ANTHROPIC_MODEL` | Override default model for session |
| `ANTHROPIC_BASE_URL` | Custom API base URL (for proxies/gateways) |
| `CLAUDE_CODE_USE_BEDROCK` | `1` to use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | `1` to use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | `1` to use Microsoft Foundry |
| `ANTHROPIC_SMALL_FAST_MODEL` | Model for background/lightweight tasks |
| `EDITOR` | Editor for external edit (`code --wait`, `vim`, etc.) |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `1` to enable OpenTelemetry |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OpenTelemetry endpoint |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Override default max output tokens |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Refresh interval for `apiKeyHelper` |
| `DISABLE_AUTOUPDATER` | `1` to disable auto-updates entirely |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Skip writing prompt history |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | `1` to disable auto memory |
| `CLAUDE_CODE_DISABLE_THINKING` | `1` to force off extended thinking |
| `CLAUDE_CODE_EFFORT_LEVEL` | Override effort level for session |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | Control away summary (same as `awaySummaryEnabled`) |
| `CLAUDE_CODE_DISABLE_AGENT_VIEW` | `1` to disable background agents |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | `1` to enable PowerShell tool on Windows |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | `1` to suppress quality survey |
| `CLAUDE_CODE_SIMPLE` | Set by `--bare` flag; skips auto-discovery |
| `CLAUDE_CODE_NO_FLICKER` | Use fullscreen TUI renderer |
| `MCP_TIMEOUT` | MCP server startup timeout in ms |
| `MAX_MCP_OUTPUT_TOKENS` | Override 10k-token MCP output warning threshold |
| `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` | Prefix for Remote Control session names |
| `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` | Skip auto-installing IDE extension |
| `CLAUDE_CODE_AUTO_CONNECT_IDE` | Auto-connect to IDE from external terminal |
| `CLAUDE_CODE_DEBUG_LOGS_DIR` | Directory for debug logs |
| `CLAUDE_CODE_FORK_SUBAGENT` | When set, `/fork` spawns a forked subagent |

Precedence (highest wins): shell env var > `settings.local.json` > `settings.json` (project) > `settings.json` (user) > built-in default.

## `~/.claude/` directory layout

```
~/.claude/
  settings.json          # User settings
  CLAUDE.md              # Global memory instructions
  agents/                # User-level subagent definitions
  commands/              # User-level slash commands (~/.claude/commands/<name>.md)
  hooks/                 # User-level hook scripts
  skills/                # User-level skills
  themes/                # Custom color themes
  plans/                 # Plan files (configurable via plansDirectory)
  transcripts/           # Session transcripts (cleaned up per cleanupPeriodDays)
  worktrees/             # Git worktrees for isolated parallel sessions
~/.claude.json           # OAuth session, user MCP configs, per-project state, caches
```

Project-level layout:
```
<project>/
  .claude/
    settings.json        # Project settings (committed)
    settings.local.json  # Local settings (gitignored)
    CLAUDE.md            # Project memory instructions
    agents/              # Project subagent definitions
    commands/            # Project slash commands
    hooks/               # Project hook scripts
    skills/              # Project skills
    rules/               # Auto-correction rules
  .mcp.json              # Project MCP servers (committed)
  CLAUDE.md              # Alternative location for project memory
  CLAUDE.local.md        # Local memory (gitignored)
```

## Authentication

Two authentication methods (mutually exclusive):

| Method | Env var | Use case |
|---|---|---|
| OAuth (subscription) | `CLAUDE_CODE_OAUTH_TOKEN` | Claude.ai Max/Pro/Team/Enterprise |
| API key | `ANTHROPIC_API_KEY` | Anthropic Console / API billing |

- **Login**: `claude auth login` (interactive browser flow) or `claude auth login --console` (API key)
- **Long-lived token for CI**: `claude setup-token` (prints OAuth token; requires subscription)
- **Check status**: `claude auth status` (exit 0 if logged in, 1 if not)

## IDE integrations

| IDE | Notes |
|---|---|
| VS Code | Extension auto-installs when Claude Code runs in VS Code terminal (controlled by `autoInstallIdeExtension`). Provides inline diffs, @-mentions, plan review, keyboard shortcuts |
| JetBrains | Run Claude Code in IDE terminal; same CLI behavior. `/ide` to manage integrations |
| Web (claude.ai) | Cloud sessions via `--remote`; teleport back with `--teleport` or `/teleport` |

To auto-connect to an IDE from an external terminal: `claude --ide` or set `autoConnectIde: true` in `~/.claude.json`.

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `code.claude.com/docs/en/permission-modes.md`, `code.claude.com/docs/en/permissions.md`.*
