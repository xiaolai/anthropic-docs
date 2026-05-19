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
| `claude -p "query"` | Print mode (non-interactive, then exit) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |

## CLI subcommands

| Command | Description |
|---|---|
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall native binary. Accepts version like `2.1.118`, `stable`, or `latest`. |
| `claude auth login` | Sign in. Flags: `--email`, `--sso`, `--console`. |
| `claude auth logout` | Sign out. |
| `claude auth status` | Auth status as JSON (`--text` for human-readable). Exits 0 if logged in, 1 if not. |
| `claude agents` | Open agent view to monitor background sessions. |
| `claude attach <id>` | Attach to a background session. |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON. |
| `claude daemon status` | Print background-session supervisor state. |
| `claude logs <id>` | Print recent output from a background session. |
| `claude mcp` | Configure MCP servers. See [`SKILL-mcp.md`](SKILL-mcp.md). |
| `claude plugin` | Manage plugins. Alias: `claude plugins`. |
| `claude project purge [path]` | Delete all local state for a project. Flags: `--dry-run`, `-y`, `--all`. |
| `claude remote-control` | Start Remote Control server (no local session). |
| `claude respawn <id>` | Restart a background session with conversation intact. |
| `claude rm <id>` | Remove a background session. |
| `claude setup-token` | Generate long-lived OAuth token for CI/scripts. |
| `claude stop <id>` | Stop a background session. Also `claude kill`. |
| `claude ultrareview [target]` | Run ultrareview non-interactively. `--json` for raw payload. |

## CLI flags (key selection)

| Flag | Description |
|---|---|
| `--add-dir` | Add working directories. Persist with `permissions.additionalDirectories` in settings. |
| `--agent` | Specify a subagent for the current session. |
| `--allowedTools` | Tools that execute without a permission prompt. |
| `--append-system-prompt` | Append custom text to the default system prompt. |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, memory, CLAUDE.md. Faster for scripts. |
| `--bg` | Start session as background agent, return immediately with session ID. |
| `--continue` / `-c` | Load most recent conversation in current directory. |
| `--dangerously-skip-permissions` | Skip all permission prompts (bypassPermissions mode). |
| `--debug [categories]` | Enable debug mode with optional category filtering. |
| `--debug-file <path>` | Write debug logs to a file. |
| `--disable-slash-commands` | Disable all skills and commands for this session. |
| `--disallowedTools` | Tools removed from model's context entirely. |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max`. |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections into first user message for better prompt-cache reuse. |
| `--fallback-model` | Auto-fallback model when default is overloaded (print mode and background sessions). |
| `--fork-session` | Create new session ID when resuming. |
| `--from-pr` | Resume sessions linked to a PR (number, URL, or GitLab/Bitbucket URL). |
| `--init` | Run Setup hooks with `init` matcher before session (print mode only). |
| `--init-only` | Run Setup + SessionStart hooks, then exit. |
| `--json-schema` | Get validated JSON output matching a JSON Schema (print mode only). |
| `--max-budget-usd` | Max dollar amount on API calls before stopping (print mode only). |
| `--max-turns` | Limit agentic turns (print mode only). |
| `--mcp-config` | Load MCP servers from JSON files or strings. |
| `--model` | Override model for session. Accepts alias (`sonnet`, `opus`) or full name. |
| `--name` / `-n` | Set display name for session. Resume with `claude --resume <name>`. |
| `--no-session-persistence` | Disable session saves (print mode only). |
| `--output-format` | Output format: `text`, `json`, `stream-json`. |
| `--permission-mode` | Start in specified mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. |
| `--plugin-dir` | Load plugin from directory or `.zip` archive for this session. |
| `--plugin-url` | Fetch plugin `.zip` archive from URL for this session. |
| `--print` / `-p` | Print mode (non-interactive). |
| `--remote` | Create new web session on claude.ai. |
| `--remote-control` / `--rc` | Start interactive session with Remote Control enabled. |
| `--resume` / `-r` | Resume session by ID or name, or show interactive picker. |
| `--settings` | Settings JSON file or inline JSON string (overrides same keys in settings files). |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config`. |
| `--system-prompt` | Replace entire system prompt with custom text. |
| `--teleport` | Resume a web session in your local terminal. |
| `--tools` | Restrict which built-in tools Claude can use. `""` = none, `"default"` = all. |
| `--verbose` | Enable verbose logging (overrides `viewMode` setting). |
| `--worktree` / `-w` | Start in isolated git worktree. Pass `#<number>` or PR URL to fetch a PR. |

Source: `code.claude.com/docs/en/cli-reference.md`.

## Subcommands

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

Modes set the baseline for what Claude can do without prompting. See also [`SKILL-settings.md`](SKILL-settings.md) `permissions.defaultMode`.

| Mode | What runs without asking | Best for |
|---|---|---|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem cmds (`mkdir`, `touch`, `mv`, `cp`, `sed`) | Iterating on code |
| `plan` | Reads only — Claude proposes a plan but does not edit | Exploring before changing |
| `auto` | Everything, with background classifier checks | Long tasks, low prompt fatigue (requires Max/Team/Enterprise, v2.1.83+) |
| `dontAsk` | Only pre-approved tools (from `allow` rules) | Locked-down CI and scripts |
| `bypassPermissions` | Everything including protected paths | Isolated containers/VMs only |

**Protected paths** (never auto-approved except in `bypassPermissions`):
- Directories: `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except commands/agents/skills/worktrees)
- Files: `.gitconfig`, `.gitmodules`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json`

**Switching modes:**
- During session: `Shift+Tab` cycles `default` → `acceptEdits` → `plan` (→ `bypassPermissions` → `auto` if enabled)
- At startup: `claude --permission-mode plan`
- As default: `permissions.defaultMode` in `settings.json` (user scope for `auto`)

**Auto mode requirements** (v2.1.83+): Plan Max/Team/Enterprise/API; admin must enable for Team/Enterprise; supported models only; Anthropic API only (not Bedrock/Vertex/Foundry).

Source: `code.claude.com/docs/en/permission-modes.md`.

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
