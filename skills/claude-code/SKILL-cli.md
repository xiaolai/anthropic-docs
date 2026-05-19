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

Source: [`code.claude.com/docs/en/cli-reference.md`](https://code.claude.com/docs/en/cli-reference.md)

| Command | Description |
|---|---|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Non-interactive (print) mode — run then exit |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude --resume` | Interactive session picker |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall native binary (accepts `stable`, `latest`, or `2.1.X`) |
| `claude auth login` | Sign in (flags: `--email`, `--sso`, `--console`) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | Open agent view for parallel background sessions |
| `claude mcp` | Configure MCP servers (see [`SKILL-mcp.md`](SKILL-mcp.md)) |
| `claude plugin` | Manage plugins (alias: `claude plugins`) |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token for CI |
| `claude ultrareview [target]` | Run ultrareview non-interactively |

## CLI flags (key flags)

Source: [`code.claude.com/docs/en/cli-reference.md`](https://code.claude.com/docs/en/cli-reference.md)

| Flag | Notes |
|---|---|
| `--print`, `-p` | Non-interactive (print) mode |
| `--continue`, `-c` | Load most recent conversation in current directory |
| `--resume`, `-r` | Resume session by ID or name; or interactive picker |
| `--model` | Set model for session (alias or full name) |
| `--permission-mode` | Start in a specific mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--dangerously-skip-permissions` | Equivalent to `--permission-mode bypassPermissions` |
| `--allow-dangerously-skip-permissions` | Adds `bypassPermissions` to Shift+Tab cycle without activating it |
| `--worktree`, `-w` | Start in an isolated git worktree |
| `--bg` | Start as a background agent, return immediately |
| `--agent` | Specify a named subagent for the session |
| `--append-system-prompt` | Append text to the default system prompt |
| `--system-prompt` | Replace the entire system prompt |
| `--output-format` | `text` (default), `json`, `stream-json` (print mode only) |
| `--max-turns` | Limit agentic turns (print mode only) |
| `--max-budget-usd` | Spend cap in dollars (print mode only) |
| `--no-session-persistence` | Disable session saving (print mode only) |
| `--bare` | Skip hooks/skills/plugins/MCP/CLAUDE.md auto-discovery |
| `--mcp-config` | Load MCP servers from JSON file |
| `--plugin-dir` | Load plugin from directory or `.zip` archive |
| `--plugin-url` | Fetch plugin `.zip` from URL |
| `--tools` | Restrict which built-in tools Claude can use |
| `--add-dir` | Add additional working directories |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--debug` | Enable debug mode (optional category filter) |
| `--verbose` | Full turn-by-turn output |

`claude --help` does not list every flag; absence from `--help` does not mean a flag is unavailable.

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

Source: [`code.claude.com/docs/en/permission-modes.md`](https://code.claude.com/docs/en/permission-modes.md)

| Mode | What runs without asking | Best for |
|---|---|---|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (blocks edits, shows plan) | Exploring before changing |
| `auto` | Everything, with background safety checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI and scripts |
| `bypassPermissions` | Everything (skips permission layer entirely) | Isolated containers/VMs only |

Switch modes: `Shift+Tab` cycles `default` → `acceptEdits` → `plan` in CLI. Set at startup: `--permission-mode <mode>`. Persist: `permissions.defaultMode` in settings.

**Protected paths** are never auto-approved in any mode except `bypassPermissions`.

## Authentication

Source: [`code.claude.com/docs/en/authentication.md`](https://code.claude.com/docs/en/authentication.md)

| Method | Env var | Notes |
|---|---|---|
| Claude.ai subscription (OAuth) | `CLAUDE_CODE_OAUTH_TOKEN` | Max / Pro plan; run `claude auth login` |
| API key (metered) | `ANTHROPIC_API_KEY` | Anthropic Console billing |
| Long-lived token (CI) | `CLAUDE_CODE_OAUTH_TOKEN` | Generate with `claude setup-token`; requires subscription |

**`apiKeyHelper` setting**: Custom script executed in `/bin/sh` that generates an auth value sent as `X-Api-Key` and `Authorization: Bearer` headers for model requests.

`claude auth status` prints auth state as JSON; exits 0 if logged in, 1 if not. Pass `--text` for human-readable output.

## `~/.claude/` directory layout

Source: [`code.claude.com/docs/en/claude-directory.md`](https://code.claude.com/docs/en/claude-directory.md)

| Path | Contents |
|---|---|
| `~/.claude/settings.json` | User-scope settings |
| `~/.claude/CLAUDE.md` | User-scope memory (loaded into every session) |
| `~/.claude/agents/` | User-scope custom subagents |
| `~/.claude/commands/` | User-scope slash commands |
| `~/.claude/skills/` | User-scope skills |
| `~/.claude/hooks/` | User-scope hook scripts |
| `~/.claude/plans/` | Saved plan files (default; configurable with `plansDirectory`) |
| `~/.claude.json` | OAuth session, per-project state, user-scope MCP servers, caches |
| `~/.claude/statsig/` | Feature flag / experimentation cache |

Project-level equivalents live at `<project>/.claude/`. Project-scoped MCP servers are in `<project>/.mcp.json`.

On Windows, `~/.claude` resolves to `%USERPROFILE%\.claude`.

## IDE integrations

> *Populated by the research agent.* VS Code, JetBrains, web app.

## Cost and quota

> *Populated by the research agent.* Subscription limits, API
> billing.

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `settings.md` (env section), `permissions.md`.*
