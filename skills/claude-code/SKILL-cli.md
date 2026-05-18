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
| `claude -p "query"` | Print mode (SDK): query and exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install specific version (e.g. `stable`, `latest`, `2.1.118`) |

## CLI flags

Selected important flags (full list: `code.claude.com/docs/en/cli-reference.md`):

| Flag | Description |
|---|---|
| `--print`, `-p` | Non-interactive (print) mode |
| `--continue`, `-c` | Load most recent conversation |
| `--resume`, `-r` | Resume session by ID or name |
| `--model` | Set model for this session |
| `--permission-mode` | Starting permission mode (see § *Permission modes*) |
| `--dangerously-skip-permissions` | Equivalent to `--permission-mode bypassPermissions` |
| `--output-format` | `text`, `json`, or `stream-json` (print mode only) |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spending cap (print mode only) |
| `--append-system-prompt` | Append text to default system prompt |
| `--system-prompt` | Replace entire system prompt |
| `--system-prompt-file` | Replace system prompt from file |
| `--append-system-prompt-file` | Append file to system prompt |
| `--add-dir` | Add additional working directories |
| `--tools` | Restrict which built-in tools are available |
| `--allowedTools` | Tools that execute without permission prompts |
| `--disallowedTools` | Tools removed from model's context |
| `--mcp-config` | Load MCP servers from JSON file |
| `--plugin-dir` | Load plugin from directory for this session |
| `--plugin-url` | Fetch plugin from URL for this session |
| `--agent` | Run session as named subagent |
| `--worktree`, `-w` | Start in isolated git worktree |
| `--bg` | Start as background agent |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md |
| `--verbose` | Show full turn-by-turn output |
| `--debug` | Enable debug mode |
| `--name`, `-n` | Set session display name |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--no-session-persistence` | Disable session persistence (print mode only) |
| `--settings` | Path to settings JSON or inline JSON string |
| `--version`, `-v` | Output version number |

## Subcommands

| Subcommand | Description |
|---|---|
| `claude auth login` | Sign in (`--email`, `--sso`, `--console`) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON |
| `claude agents` | Open agent view for background sessions |
| `claude attach <id>` | Attach to a background session |
| `claude stop <id>` | Stop a background session |
| `claude logs <id>` | Print output from background session |
| `claude respawn <id>` | Restart a stopped session |
| `claude rm <id>` | Remove a background session |
| `claude mcp` | Configure MCP servers |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules |

## Environment variables

<!-- seed: replace on first real research pass -->

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Metered API authentication. Mutually exclusive with `CLAUDE_CODE_OAUTH_TOKEN`. |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max / Pro) authentication via OAuth. Preferred over API key when both are set. |
| `ANTHROPIC_MODEL` | Override the default model for the session (e.g. `claude-opus-4-7`). Equivalent to `model` in `settings.json` but takes precedence. |
| `EDITOR` | Editor invoked by `claude` when an edit needs an external editor. Common values: `code --wait`, `vim`, `nvim`. |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location. Useful for sandboxed / multi-account setups. |

Precedence (highest wins): env var > `settings.local.json` > `settings.json` (project) > `settings.json` (user) > built-in default.

Source: `code.claude.com/docs/en/settings.md` (environment section). The research agent expands this table as new env vars are documented.

## Permission modes

| Mode | What runs without asking | Best for |
|---|---|---|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, and common filesystem commands | Iterating on code |
| `plan` | Reads only (Claude proposes changes without making them) | Exploring before changing |
| `auto` | Everything, with background safety checks | Long tasks, reducing prompts |
| `dontAsk` | Only pre-approved tools | Locked-down CI and scripts |
| `bypassPermissions` | Everything — skips permission layer entirely | Isolated containers/VMs only |

Set at startup: `claude --permission-mode plan`  
Set as default: `"defaultMode": "acceptEdits"` in `permissions` settings block  
Cycle modes: `Shift+Tab` in interactive session  

Protected paths are never auto-approved in any mode except `bypassPermissions`.

## Authentication

> *Populated by the research agent.* OAuth (`CLAUDE_CODE_OAUTH_TOKEN`)
> vs API key (`ANTHROPIC_API_KEY`), subscription vs metered.

## `~/.claude/` directory layout

> *Populated by the research agent.* Every directory and file Claude
> Code creates or reads under `~/.claude/`.

## IDE integrations

> *Populated by the research agent.* VS Code, JetBrains, web app.

## Cost and quota

> *Populated by the research agent.* Subscription limits, API
> billing.

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `settings.md` (env section), `permissions.md`.*
