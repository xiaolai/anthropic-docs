---
name: claude-code-cli
description: |
  Deep reference for Claude Code's CLI surface: command-line commands,
  flags, environment variables (ANTHROPIC_* / CLAUDE_*), permission
  modes (default / acceptEdits / plan / auto / dontAsk / bypassPermissions),
  the ~/.claude/ directory layout, IDE integration entry points, and
  authentication mechanisms. Read this file when the user asks about
  CLI invocation, env vars, permission modes, ~/.claude/ structure,
  or how Claude Code authenticates.
source: https://code.claude.com/docs/en/cli-reference.md
---

# Claude Code — CLI, environment, and layout

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for CLI / env / layout questions.*

## Top-level commands

| Command | Description | Example |
|---|---|---|
| `claude` | Start interactive session | `claude` |
| `claude "query"` | Start with initial prompt | `claude "explain this project"` |
| `claude -p "query"` | Query via SDK, then exit (print mode) | `claude -p "explain this function"` |
| `cat file \| claude -p "query"` | Process piped content | `cat logs.txt \| claude -p "explain"` |
| `claude -c` | Continue most recent conversation | `claude -c` |
| `claude -r "<session>" "query"` | Resume session by ID or name | `claude -r "auth-refactor" "Finish this PR"` |
| `claude update` | Update to latest version | `claude update` |
| `claude install [version]` | Install/reinstall native binary. Accepts version like `2.1.118`, `stable`, or `latest` | `claude install stable` |
| `claude auth login` | Sign in. Flags: `--email`, `--sso`, `--console` | `claude auth login --console` |
| `claude auth logout` | Log out | `claude auth logout` |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable). Exit 0 if logged in, 1 if not | `claude auth status` |
| `claude agents` | Open agent view. `--cwd <path>` to filter by directory | `claude agents` |
| `claude attach <id>` | Attach to a background session | `claude attach 7c5dcf5d` |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON | `claude auto-mode defaults` |
| `claude logs <id>` | Print output from a background session | `claude logs 7c5dcf5d` |
| `claude mcp` | Configure MCP servers | See [`SKILL-mcp.md`](SKILL-mcp.md) |
| `claude plugin` | Manage plugins. Alias: `claude plugins` | `claude plugin install code-review@claude-plugins-official` |
| `claude project purge [path]` | Delete local state for a project. Flags: `--dry-run`, `-y`, `-i`, `--all` | `claude project purge ~/work/repo --dry-run` |
| `claude remote-control` | Start Remote Control server (no local session). Flags: `--name` | `claude remote-control --name "My Project"` |
| `claude respawn <id>` | Restart a stopped background session. `--all` for all | `claude respawn 7c5dcf5d` |
| `claude rm <id>` | Remove a background session from list | `claude rm 7c5dcf5d` |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts | `claude setup-token` |
| `claude stop <id>` | Stop a background session. Alias: `claude kill` | `claude stop 7c5dcf5d` |
| `claude ultrareview [target]` | Run ultrareview non-interactively. Flags: `--json`, `--timeout <minutes>` | `claude ultrareview 1234 --json` |

Source: `code.claude.com/docs/en/cli-reference.md`

## CLI flags

Selected most-used flags. `claude --help` does not list all flags; a flag's absence from `--help` doesn't mean it's unavailable.

| Flag | Description |
|---|---|
| `--add-dir` | Add additional working directories for file access |
| `--agent` | Specify an agent for the current session |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to the Shift+Tab cycle without starting in it |
| `--allowedTools` | Tools that execute without prompting |
| `--append-system-prompt` | Append custom text to the end of the default system prompt |
| `--append-system-prompt-file` | Load additional system prompt text from a file and append |
| `--bare` | Minimal mode: skip auto-discovery of hooks, skills, plugins, MCP, auto memory, and CLAUDE.md. Faster for scripts. Sets `CLAUDE_CODE_SIMPLE` |
| `--bg` | Start as a background agent and return immediately. Prints session ID |
| `--continue`, `-c` | Load most recent conversation in current directory |
| `--dangerously-skip-permissions` | Skip all permission prompts. Equivalent to `--permission-mode bypassPermissions` |
| `--debug ["cat,list"]` | Enable debug mode with optional category filtering (e.g., `"api,hooks"`) |
| `--debug-file <path>` | Write debug logs to a specific file |
| `--disable-slash-commands` | Disable all skills and commands for this session |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves prompt-cache reuse). Use with `-p` |
| `--fallback-model` | Fallback model when default is overloaded (print mode only) |
| `--fork-session` | When resuming, create a new session ID instead of reusing original |
| `--from-pr` | Resume sessions linked to a specific PR (number, GitHub URL, GitLab MR URL, Bitbucket PR URL) |
| `--ide` | Auto-connect to IDE on startup if exactly one valid IDE is available |
| `--include-hook-events` | Include hook lifecycle events in output stream. Requires `--output-format stream-json` |
| `--input-format` | Input format for print mode: `text` or `stream-json` |
| `--json-schema` | Get validated JSON output matching a JSON Schema (print mode only) |
| `--max-budget-usd` | Maximum dollar amount to spend before stopping (print mode only) |
| `--max-turns` | Limit number of agentic turns (print mode only). No limit by default |
| `--mcp-config` | Load MCP servers from JSON files or strings |
| `--model` | Sets model for session. Accepts alias (`sonnet`, `opus`) or full model name |
| `--name`, `-n` | Set a display name for the session |
| `--no-session-persistence` | Disable session persistence (print mode only) |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--permission-mode` | Begin in specified mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--permission-prompt-tool` | MCP tool to handle permission prompts in non-interactive mode |
| `--plugin-dir` | Load a plugin from a directory or `.zip` archive for this session only |
| `--plugin-url` | Fetch a plugin `.zip` from a URL for this session only |
| `--print`, `-p` | Print response without interactive mode |
| `--remote` | Create a new web session on claude.ai with the provided task |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--resume`, `-r` | Resume a session by ID or name, or show interactive picker |
| `--session-id` | Use a specific session ID (must be valid UUID) |
| `--setting-sources` | Comma-separated: `user`, `project`, `local` |
| `--settings` | Path to settings JSON file or inline JSON string (overrides settings files for this session) |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config`, ignoring all others |
| `--system-prompt` | Replace entire system prompt with custom text |
| `--system-prompt-file` | Load system prompt from file (replaces default) |
| `--teleport` | Resume a web session in your local terminal |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, or `tmux` |
| `--tools` | Restrict built-in tools. `""` = disable all, `"default"` = all, or names like `"Bash,Edit,Read"` |
| `--verbose` | Enable verbose logging (shows full turn-by-turn output) |
| `--version`, `-v` | Output version number |
| `--worktree`, `-w` | Start in isolated git worktree. `#<number>` or GitHub PR URL to fetch that PR |

### System prompt flags

All four work in both interactive and non-interactive modes:

| Flag | Behavior |
|---|---|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

## Environment variables

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Metered API authentication |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max/Pro) OAuth authentication |
| `ANTHROPIC_MODEL` | Override default model for the session |
| `EDITOR` | External editor invoked by `claude` for edits |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location |
| `CLAUDE_CODE_SIMPLE` | Set by `--bare`; disables auto-discovery |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry metrics/traces |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto-memory when set to `1` |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | Enable/disable session recap on return |
| `CLAUDE_CODE_EFFORT_LEVEL` | Session effort level override |
| `CLAUDE_CODE_FORK_SUBAGENT` | When set, `/fork` spawns forked subagent |
| `CLAUDE_CODE_NO_FLICKER` | Use fullscreen alt-screen renderer |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Disable session persistence in any mode |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | Enable PowerShell tool on Windows |
| `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` | Prefix for auto-generated Remote Control session names |
| `DISABLE_AUTOUPDATER` | Set to `1` to disable auto-updates |
| `HTTP_PROXY` / `HTTPS_PROXY` | Proxy server for API requests |

Precedence (highest wins): **env var > command-line flag > local > project > user > built-in default**.

Source: `code.claude.com/docs/en/env-vars.md`, `code.claude.com/docs/en/settings.md`

## Permission modes

| Mode | What runs without asking | Best for |
|---|---|---|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands (`mkdir`, `touch`, `mv`, `cp`) | Iterating on code you're reviewing |
| `plan` | Reads only (Claude can explore but not edit) | Exploring a codebase before changing it |
| `auto` | Everything, with background safety checks (research preview) | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI and scripts |
| `bypassPermissions` | Everything (circuit breaker: root/home dir `rm -rf` still prompts) | Isolated containers/VMs **only** |

**Switch modes:**
- During session: `Shift+Tab` cycles `default → acceptEdits → plan`
- At startup: `--permission-mode <mode>`
- Persistent: set `permissions.defaultMode` in settings.json

**Protected paths** (never auto-approved in any mode except bypassPermissions): `.git`, `.claude`, `.vscode`, `.idea`, `.husky` — guard against accidental corruption.

Source: `code.claude.com/docs/en/permission-modes.md`, `permissions.md`

## Authentication

**Two authentication methods:**
- `ANTHROPIC_API_KEY` / `claude auth login --console`: API key, metered billing via Anthropic Console
- `CLAUDE_CODE_OAUTH_TOKEN` / `claude auth login`: OAuth token, uses Claude subscription (Pro/Max)

**Generate a long-lived token for CI:**
```bash
claude setup-token
```
Requires a Claude subscription. Token is printed (not saved) — store it securely.

**SSO:** `claude auth login --sso` forces SSO authentication.

## `~/.claude/` directory layout

| Path | Contents |
|---|---|
| `~/.claude/settings.json` | User-scope settings |
| `~/.claude/agents/` | User-scope subagent definitions |
| `~/.claude/commands/` | User-scope custom commands (legacy; now use `skills/`) |
| `~/.claude/skills/` | User-scope skill directories |
| `~/.claude/CLAUDE.md` | User-scope memory file |
| `~/.claude/hooks/` | User-scope hook scripts |
| `~/.claude/plans/` | Plan files (default location; configurable via `plansDirectory`) |
| `~/.claude/worktrees/` | Isolated git worktrees created with `--worktree` |
| `~/.claude.json` | OAuth session, user/local MCP configs, per-project state, caches |

**Project-scope** (inside `<project>/`):
| Path | Contents |
|---|---|
| `.claude/settings.json` | Project-scope shared settings |
| `.claude/settings.local.json` | Project-scope local (gitignored) settings |
| `.claude/agents/` | Project-scope subagents |
| `.claude/skills/` | Project-scope skills |
| `.claude/commands/` | Project-scope custom commands (legacy) |
| `.claude/hooks/` | Project-scope hook scripts |
| `.claude/rules/` | Project-scope rules files |
| `.mcp.json` | Project-scope MCP server config |
| `CLAUDE.md` | Project memory file |

Source: `code.claude.com/docs/en/claude-directory.md`

## IDE integrations

- **VS Code**: Install the Claude Code extension. Mode selector at bottom of prompt box. `--ide` flag auto-connects.
- **JetBrains**: Plugin runs Claude Code in IDE terminal; same modes as CLI.
- **Web**: [claude.ai/code](https://claude.ai/code) — cloud sessions with subset of modes (acceptEdits, plan).
- **Remote Control**: `claude remote-control` or `--remote-control` flag to allow control from claude.ai.

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `env-vars.md`, `permissions.md`, `permission-modes.md`, `claude-directory.md`.*
