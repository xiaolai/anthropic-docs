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

Source: [`cli-reference.md`](https://code.claude.com/docs/en/cli-reference.md).

| Command | Description |
|---|---|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Print mode: query then exit (non-interactive / SDK mode) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall native binary. Accepts version like `2.1.118`, `stable`, or `latest` |
| `claude auth login` | Sign in. `--email`, `--sso`, `--console` flags available |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable) |
| `claude agents` | Open agent view. `--cwd <path>` filters to sessions under that dir |
| `claude attach <id>` | Attach a background session to this terminal |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude logs <id>` | Print recent output from a background session |
| `claude mcp` | Manage MCP servers. See [`SKILL-mcp.md`](SKILL-mcp.md) |
| `claude plugin` | Manage plugins. Alias: `claude plugins`. See [`SKILL-plugins.md`](SKILL-plugins.md) |
| `claude project purge [path]` | Delete local Claude Code state for a project. `--dry-run`, `-y`, `--all` |
| `claude remote-control` | Start Remote Control server (no local interactive session) |
| `claude respawn <id>` | Restart a stopped background session |
| `claude rm <id>` | Remove a background session from the list |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts |
| `claude stop <id>` | Stop a background session (alias: `claude kill`) |
| `claude ultrareview [target]` | Run ultrareview non-interactively. `--json`, `--timeout <minutes>` |

## CLI flags

Key flags (full list at [`cli-reference.md`](https://code.claude.com/docs/en/cli-reference.md)):

| Flag | Short | Description |
|---|---|---|
| `--print` | `-p` | Print/SDK mode: query and exit |
| `--continue` | `-c` | Load most recent conversation in current directory |
| `--resume <id>` | `-r` | Resume session by ID or name |
| `--name <name>` | `-n` | Set display name for the session |
| `--worktree [name]` | `-w` | Start in isolated git worktree |
| `--permission-mode <mode>` | | `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--dangerously-skip-permissions` | | Equivalent to `--permission-mode bypassPermissions` |
| `--allow-dangerously-skip-permissions` | | Add `bypassPermissions` to Shift+Tab cycle without activating it |
| `--model <name>` | | Model for this session. Overrides `ANTHROPIC_MODEL` and settings `model` |
| `--effort <level>` | | `low`, `medium`, `high`, `xhigh`, `max`. Overrides `effortLevel` setting for this session |
| `--bg` | | Start as background agent, return immediately |
| `--agent <name>` | | Specify subagent for the session |
| `--agents <json>` | | Define custom subagents dynamically via JSON |
| `--append-system-prompt <text>` | | Append custom text to default system prompt |
| `--system-prompt <text>` | | Replace entire system prompt |
| `--system-prompt-file <path>` | | Replace system prompt from file |
| `--append-system-prompt-file <path>` | | Append file contents to default system prompt |
| `--output-format <fmt>` | | `text`, `json`, `stream-json` (print mode) |
| `--input-format <fmt>` | | `text`, `stream-json` (print mode) |
| `--max-turns <n>` | | Max agentic turns (print mode). Exit with error when reached |
| `--max-budget-usd <n>` | | Max API spend before stopping (print mode) |
| `--allowedTools <rules>` | | Tools that execute without prompting |
| `--disallowedTools <rules>` | | Tools removed from context entirely |
| `--tools <list>` | | Restrict which built-in tools Claude can use |
| `--add-dir <path>` | | Add additional working directories |
| `--mcp-config <file>` | | Load MCP servers from JSON file or string |
| `--strict-mcp-config` | | Only use MCP servers from `--mcp-config` |
| `--plugin-dir <path>` | | Load plugin from directory or `.zip` for this session only |
| `--plugin-url <url>` | | Fetch plugin `.zip` from URL for this session only |
| `--bare` | | Skip auto-discovery of hooks/skills/plugins/MCP/CLAUDE.md. Faster startup for scripts |
| `--verbose` | | Enable verbose logging |
| `--debug [categories]` | | Debug mode with optional category filter |
| `--debug-file <path>` | | Write debug logs to file |
| `--version` | `-v` | Print version |
| `--from-pr <ref>` | | Resume sessions linked to a PR number or URL |
| `--fork-session` | | Create new session ID when resuming (use with `--resume`/`--continue`) |
| `--settings <path-or-json>` | | Load settings from file or inline JSON (overrides file-based settings for this session) |
| `--setting-sources <list>` | | Comma-separated sources to load: `user`, `project`, `local` |
| `--remote "task"` | | Create a new web session on claude.ai |
| `--teleport` | | Resume a web session in local terminal |
| `--remote-control` / `--rc` | | Start session with Remote Control enabled |
| `--chrome` | | Enable Chrome browser integration |
| `--tmux` | | Create tmux session for the worktree (requires `--worktree`) |
| `--ide` | | Auto-connect to IDE on startup |
| `--teammate-mode <mode>` | | `auto`, `in-process`, `tmux` |
| `--channels <list>` | | MCP servers whose channel notifications to listen for |
| `--init` | | Run Setup hooks with `init` matcher before session (print mode) |
| `--init-only` | | Run Setup and SessionStart hooks, then exit |
| `--maintenance` | | Run Setup hooks with `maintenance` matcher (print mode) |
| `--no-session-persistence` | | Disable saving session to disk (print mode) |
| `--fallback-model <model>` | | Fallback model when primary is overloaded (print mode) |
| `--json-schema <schema>` | | Get validated JSON output matching schema after workflow (print mode) |
| `--exclude-dynamic-system-prompt-sections` | | Move per-machine sections into first user message (improves cache reuse in `-p` mode) |
| `--include-hook-events` | | Include hook lifecycle events in stream-json output |
| `--include-partial-messages` | | Include partial streaming events in stream-json output |

## Subcommands

See the "Top-level invocation" table above for full subcommand list. Key subcommand families: `claude auth *` (login/logout/status), `claude mcp *` (add/list/get/remove/reset-project-choices), `claude plugin *` (install/list/uninstall/marketplace), `claude project purge`, `claude agents`, `claude attach/logs/stop/rm/respawn/attach`. Cross-reference: [`SKILL-mcp.md`](SKILL-mcp.md) for `mcp` subcommands; [`SKILL-plugins.md`](SKILL-plugins.md) for `plugin` subcommands.

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

Source: [`permission-modes.md`](https://code.claude.com/docs/en/permission-modes.md).

| Mode | What runs without asking | Best for |
|---|---|---|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `rm`, `rmdir`, `sed`) | Iterating on code you review after |
| `plan` | Reads only (no edits) | Exploring before changing |
| `auto` | Everything, with background classifier safety checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools (from `permissions.allow`). All other tool calls auto-denied | Locked-down CI |
| `bypassPermissions` | Everything (incl. protected paths as of v2.1.126) | Isolated containers/VMs only |

**Switch modes:**
- During CLI session: `Shift+Tab` cycles `default → acceptEdits → plan` (and optionally `auto`/`bypassPermissions`)
- At startup: `claude --permission-mode plan`
- As default: `permissions.defaultMode: "acceptEdits"` in `settings.json`

**Protected paths** (never auto-approved in modes other than `bypassPermissions`): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`); files: `.gitconfig`, `.gitmodules`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json`.

**auto mode requirements:** Claude Code v2.1.83+; Max/Team/Enterprise/API plan (not Pro); supported model (Sonnet 4.6, Opus 4.6, Opus 4.7 on most plans; Opus 4.7 only on Max); Anthropic API only (not Bedrock/Vertex/Foundry). Disable with `permissions.disableAutoMode: "disable"` in managed settings.

**bypassPermissions notes:** Cannot be entered from a session not started with an enabling flag. On Linux/macOS, refused when running as root. Admins block with `permissions.disableBypassPermissionsMode: "disable"` in managed settings.

## Authentication

| Method | Env var | Use case |
|---|---|---|
| Claude.ai subscription (OAuth) | `CLAUDE_CODE_OAUTH_TOKEN` | Max/Pro/Team/Enterprise subscription; preferred when both set |
| API key (metered) | `ANTHROPIC_API_KEY` | Anthropic Console API usage billing |

Login: `claude auth login` (browser OAuth). For CI: `claude setup-token` generates a long-lived OAuth token. `--console` flag forces Console (API billing) login. `--sso` forces SSO.

For Amazon Bedrock: set `ANTHROPIC_BEDROCK=true`, `AWS_REGION`, and standard AWS credentials. For Google Vertex AI: set `CLAUDE_CODE_USE_VERTEX=true`, `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID`. Source: [`authentication.md`](https://code.claude.com/docs/en/authentication.md).

## `~/.claude/` directory layout

Source: [`claude-directory.md`](https://code.claude.com/docs/en/claude-directory.md).

| Path | Contents |
|---|---|
| `~/.claude/settings.json` | User-scope settings (personal defaults) |
| `~/.claude/CLAUDE.md` | User-scope memory/instructions |
| `~/.claude/commands/` | User-scope custom slash commands (`.md` files) |
| `~/.claude/agents/` | User-scope custom subagent definitions |
| `~/.claude/skills/` | User-scope skills (`SKILL.md` files) |
| `~/.claude/plans/` | Default plan file storage (configurable via `plansDirectory`) |
| `~/.claude.json` | OAuth session, per-project state, user/local-scope MCP configs, caches |

**Project-level** (inside repo): `.claude/settings.json`, `.claude/settings.local.json` (gitignored), `.claude/CLAUDE.md`, `.claude/commands/`, `.claude/agents/`, `.claude/skills/`, `.claude/rules/`, `.claude/worktrees/`. **MCP config**: project-scope servers go in `.mcp.json` at the repo root.

On Windows: `~/.claude` → `%USERPROFILE%\.claude`.

## IDE integrations

| Integration | How it works |
|---|---|
| **VS Code** | Install the Claude Code extension from the VS Code Marketplace. Provides inline diffs, `@`-mentions, plan review. Set `claudeCode.initialPermissionMode` in VS Code settings for a default permission mode. Auto-connects when running Claude Code from the VS Code terminal. See [`vs-code.md`](https://code.claude.com/docs/en/vs-code.md). |
| **JetBrains** (IntelliJ, PyCharm, WebStorm, etc.) | Plugin runs Claude Code in the IDE terminal. Mode switching works same as CLI (`Shift+Tab`). See [`jetbrains.md`](https://code.claude.com/docs/en/jetbrains.md). |
| **Web** | [claude.ai/code](https://claude.ai/code) — browser-based Claude Code sessions with GitHub integration. See [`claude-code-on-the-web.md`](https://code.claude.com/docs/en/claude-code-on-the-web.md). |
| **Desktop app** | Parallel sessions, git isolation, drag-and-drop pane layout, integrated terminal and file editor. See [`desktop.md`](https://code.claude.com/docs/en/desktop.md). |

Auto-connect behavior: `autoConnectIde: true` in `~/.claude.json` (global config, not `settings.json`) makes Claude Code auto-connect to a running IDE on startup. `autoInstallIdeExtension: false` disables auto-install of the VS Code extension when running from the VS Code terminal.

## Cost and quota

**Subscription (OAuth):** Claude Max, Pro, Team, Enterprise — usage counts against subscription limits, not per-token billing. Team/Enterprise admins can view usage in the analytics dashboard.

**API key (metered):** Per-token billing via Anthropic Console. Set `--max-budget-usd <n>` (print mode) to cap spend per run. Track usage with `CLAUDE_CODE_ENABLE_TELEMETRY=1` + OpenTelemetry. See [`monitoring-usage.md`](https://code.claude.com/docs/en/monitoring-usage.md).

**Reduce costs:** Use `--model haiku` for lightweight tasks; `--bare` for fast scripted runs; context compaction (`/compact`) for long sessions. Source: [`costs.md`](https://code.claude.com/docs/en/costs.md).

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `settings.md` (env section), `permissions.md`.*
