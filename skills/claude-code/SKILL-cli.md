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

## CLI commands

Source: [`code.claude.com/docs/en/cli-reference.md`](https://code.claude.com/docs/en/cli-reference.md)

| Command | Description | Example |
|---|---|---|
| `claude` | Start interactive session | `claude` |
| `claude "query"` | Start interactive session with initial prompt | `claude "explain this project"` |
| `claude -p "query"` | Non-interactive (print) mode — query then exit | `claude -p "explain this function"` |
| `cat file \| claude -p "query"` | Process piped content | `cat logs.txt \| claude -p "explain"` |
| `claude -c` | Continue most recent conversation in current dir | `claude -c` |
| `claude -r "<session>" "query"` | Resume session by ID or name | `claude -r "auth-refactor" "Finish this PR"` |
| `claude update` | Update to latest version | `claude update` |
| `claude install [version]` | Install/reinstall native binary. Accepts `2.1.118`, `stable`, or `latest` | `claude install stable` |
| `claude auth login` | Sign in. Flags: `--email`, `--sso`, `--console` (API billing) | `claude auth login --console` |
| `claude auth logout` | Log out | `claude auth logout` |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable). Exit 0=logged-in, 1=not | `claude auth status` |
| `claude agents` | Open agent view to monitor parallel sessions. `--cwd <path>` to filter | `claude agents` |
| `claude attach <id>` | Attach to a background session in this terminal | `claude attach 7c5dcf5d` |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON | `claude auto-mode defaults > rules.json` |
| `claude logs <id>` | Print recent output from a background session | `claude logs 7c5dcf5d` |
| `claude mcp` | Configure MCP servers. See [`SKILL-mcp.md`](SKILL-mcp.md) | — |
| `claude plugin` | Manage plugins (alias: `claude plugins`) | `claude plugin install code-review@claude-plugins-official` |
| `claude project purge [path]` | Delete all local Claude Code state for a project. Flags: `--dry-run`, `-y`, `--all` | `claude project purge ~/work/repo --dry-run` |
| `claude remote-control` | Start Remote Control server (server mode, no local session) | `claude remote-control --name "My Project"` |
| `claude respawn <id>` | Restart a stopped background session. `--all` for every stopped session | `claude respawn 7c5dcf5d` |
| `claude rm <id>` | Remove a background session from the list | `claude rm 7c5dcf5d` |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts (requires Claude subscription) | `claude setup-token` |
| `claude stop <id>` | Stop a background session (alias: `claude kill`) | `claude stop 7c5dcf5d` |
| `claude ultrareview [target]` | Run ultrareview non-interactively. `--json` for raw payload, `--timeout <min>` | `claude ultrareview 1234 --json` |

If you mistype a subcommand, Claude suggests the closest match: `claude udpate` → "Did you mean claude update?".

## CLI flags

`claude --help` does not list every flag — a flag's absence from `--help` does not mean it's unavailable.

| Flag | Description | Example |
|---|---|---|
| `--add-dir` | Add additional working directories for file access | `claude --add-dir ../apps ../lib` |
| `--agent` | Specify an agent for the session | `claude --agent my-custom-agent` |
| `--agents` | Define custom subagents dynamically via JSON | `claude --agents '{"reviewer":{"prompt":"..."}}'` |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to Shift+Tab cycle without activating it | `claude --permission-mode plan --allow-dangerously-skip-permissions` |
| `--allowedTools` | Tools that execute without prompting | `"Bash(git log *)" "Read"` |
| `--append-system-prompt` | Append custom text to default system prompt | `claude --append-system-prompt "Always use TypeScript"` |
| `--append-system-prompt-file` | Load additional system prompt from a file | `claude --append-system-prompt-file ./extra-rules.txt` |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, CLAUDE.md. Sets `CLAUDE_CODE_SIMPLE` | `claude --bare -p "query"` |
| `--bg` | Start as background agent, return immediately. Prints session ID | `claude --bg "investigate the flaky test"` |
| `--channels` | MCP servers to listen for channel notifications (research preview) | `claude --channels plugin:notifier@marketplace` |
| `--chrome` | Enable Chrome browser integration | `claude --chrome` |
| `--continue`, `-c` | Load most recent conversation in current directory | `claude --continue` |
| `--dangerously-skip-permissions` | Skip permission prompts (equivalent to `--permission-mode bypassPermissions`) | `claude --dangerously-skip-permissions` |
| `--debug` | Debug mode with optional category filtering: `"api,hooks"` or `"!statsig"` | `claude --debug "api,mcp"` |
| `--debug-file <path>` | Write debug logs to a specific file | `claude --debug-file /tmp/claude-debug.log` |
| `--disable-slash-commands` | Disable all skills and commands for this session | `claude --disable-slash-commands` |
| `--disallowedTools` | Tools removed from model context | `"Bash(git log *)" "Edit"` |
| `--effort` | Effort level for session: `low`, `medium`, `high`, `xhigh`, `max` | `claude --effort high` |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves prompt-cache reuse) | `claude -p --exclude-dynamic-system-prompt-sections "query"` |
| `--fallback-model` | Auto-fallback model when default is overloaded (print mode only) | `claude -p --fallback-model sonnet "query"` |
| `--fork-session` | Create new session ID instead of reusing original when resuming | `claude --resume abc123 --fork-session` |
| `--from-pr` | Resume sessions linked to a PR (accepts PR number, GitHub/GitLab/Bitbucket URL) | `claude --from-pr 123` |
| `--ide` | Auto-connect to IDE if exactly one valid IDE is available | `claude --ide` |
| `--init` | Run Setup hooks with `init` matcher before session (print mode only) | `claude -p --init "query"` |
| `--init-only` | Run Setup and SessionStart hooks, then exit | `claude --init-only` |
| `--include-hook-events` | Include hook lifecycle events in output. Requires `--output-format stream-json` | `claude -p --output-format stream-json --include-hook-events "query"` |
| `--input-format` | Input format for print mode: `text`, `stream-json` | `claude -p --input-format stream-json` |
| `--json-schema` | Get validated JSON output matching a JSON Schema (print mode only) | `claude -p --json-schema '{"type":"object",...}' "query"` |
| `--maintenance` | Run Setup hooks with `maintenance` matcher before session (print mode only) | `claude -p --maintenance "query"` |
| `--max-budget-usd` | Max dollar amount before stopping (print mode only) | `claude -p --max-budget-usd 5.00 "query"` |
| `--max-turns` | Limit agentic turns (print mode only). No limit by default | `claude -p --max-turns 3 "query"` |
| `--mcp-config` | Load MCP servers from JSON files or strings (space-separated) | `claude --mcp-config ./mcp.json` |
| `--model` | Set model with alias (`sonnet`/`opus`) or full name | `claude --model claude-sonnet-4-6` |
| `--name`, `-n` | Set session display name | `claude -n "my-feature-work"` |
| `--no-session-persistence` | Don't save session to disk (print mode only) | `claude -p --no-session-persistence "query"` |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` | `claude -p "query" --output-format json` |
| `--permission-mode` | Begin in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` | `claude --permission-mode plan` |
| `--plugin-dir` | Load a plugin from a dir or `.zip` archive for this session | `claude --plugin-dir ./my-plugin` |
| `--plugin-url` | Fetch a plugin `.zip` from a URL for this session | `claude --plugin-url https://example.com/plugin.zip` |
| `--print`, `-p` | Non-interactive print mode | `claude -p "query"` |
| `--remote` | Create a new web session on claude.ai | `claude --remote "Fix the login bug"` |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled | `claude --remote-control "My Project"` |
| `--resume`, `-r` | Resume session by ID or name | `claude --resume auth-refactor` |
| `--session-id` | Use specific session ID (valid UUID) | `claude --session-id "550e8400-..."` |
| `--setting-sources` | Comma-separated list of sources to load: `user`, `project`, `local` | `claude --setting-sources user,project` |
| `--settings` | Path to settings JSON or inline JSON string | `claude --settings ./settings.json` |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` | `claude --strict-mcp-config --mcp-config ./mcp.json` |
| `--system-prompt` | Replace entire system prompt with custom text | `claude --system-prompt "You are a Python expert"` |
| `--system-prompt-file` | Load system prompt from a file | `claude --system-prompt-file ./custom-prompt.txt` |
| `--teleport` | Resume a web session in your local terminal | `claude --teleport` |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, `tmux` | `claude --teammate-mode in-process` |
| `--tmux` | Create a tmux session for the worktree. Requires `--worktree` | `claude -w feature-auth --tmux` |
| `--tools` | Restrict built-in tools: `""` disables all, `"default"` allows all, `"Bash,Edit,Read"` selects | `claude --tools "Bash,Edit,Read"` |
| `--verbose` | Enable verbose logging | `claude --verbose` |
| `--version`, `-v` | Output version number | `claude -v` |
| `--worktree`, `-w` | Start in isolated git worktree at `<repo>/.claude/worktrees/<name>` | `claude -w feature-auth` |

### System prompt flags

`--system-prompt` and `--system-prompt-file` are mutually exclusive (both replace the full prompt). The append flags (`--append-system-prompt`, `--append-system-prompt-file`) can be combined with either. Use append when you want Claude to remain a coding assistant plus extra rules; use replace when the identity/permission model fundamentally changes.

## Subcommands

Key subcommand namespaces:
- `claude auth` — login, logout, status, token generation
- `claude mcp` — add, list, get, remove MCP servers; see [`SKILL-mcp.md`](SKILL-mcp.md)
- `claude plugin` / `claude plugins` — install, list, enable, disable; see [`SKILL-plugins.md`](SKILL-plugins.md)
- `claude project` — purge local project state
- `claude agents` — manage background sessions
- `claude auto-mode` — inspect/configure auto mode classifier rules

## Environment variables

Source: [`code.claude.com/docs/en/env-vars.md`](https://code.claude.com/docs/en/env-vars.md)

Key environment variables (set directly or via the `env` key in `settings.json`):

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Metered API authentication. |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max/Pro) OAuth auth. Preferred over API key. |
| `ANTHROPIC_MODEL` | Override default model (e.g. `claude-opus-4-7`). Overrides `model` in settings. |
| `EDITOR` | External editor invoked by `claude`. E.g. `code --wait`, `vim`. |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location. |
| `DISABLE_AUTOUPDATER` | Set to `1` to disable auto-updates entirely. |
| `CLAUDE_CODE_SIMPLE` | Set by `--bare`; disables auto-discovery of hooks/skills/plugins/MCP/memory. |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `1` to enable OpenTelemetry; `0` to disable. |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen/alt-screen renderer. |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Don't write sessions to disk (any mode). |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory. |
| `CLAUDE_CODE_EFFORT_LEVEL` | Override effort level for session (overrides `effortLevel` setting). |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | `1` to show recap when returning to terminal. |
| `CLAUDE_CODE_DISABLE_AGENT_VIEW` | `1` to disable background agents and agent view. |
| `CLAUDE_CODE_AUTO_CONNECT_IDE` | Override `autoConnectIde` global setting. |
| `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` | Skip auto-install of VS Code extension. |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Refresh interval for `apiKeyHelper` script (ms). |
| `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS` | Refresh interval for `otelHeadersHelper` script. |
| `CLAUDE_CODE_DISABLE_THINKING` | Force extended thinking off regardless of settings. |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Set in `env` to suppress session quality surveys. |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Takes precedence over `includeGitInstructions` setting. |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | `1` to enable PowerShell tool on Windows. |
| `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` | Prefix for auto-generated Remote Control session names. |
| `MCP_TIMEOUT` | Startup timeout for MCP servers (ms). E.g. `MCP_TIMEOUT=10000`. |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens from MCP tool output before a warning (default 10000). |

Precedence (highest wins): CLI flag > `settings.local.json` > `settings.json` (project) > `settings.json` (user) > built-in default.

## Permission modes

Source: [`code.claude.com/docs/en/permission-modes.md`](https://code.claude.com/docs/en/permission-modes.md)

| Mode | What runs without asking | Best for |
|---|---|---|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `rm`, `sed`) | Iterating on code you're reviewing |
| `plan` | Reads only (Claude proposes before editing) | Exploring a codebase before changing |
| `auto` | Everything, with background classifier safety checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools (deny any that would prompt) | Locked-down CI and scripts |
| `bypassPermissions` | Everything — no checks | Isolated containers/VMs ONLY |

**Switch modes:** Press `Shift+Tab` to cycle `default` → `acceptEdits` → `plan` → (optional) `auto`/`bypassPermissions`. Or:
```bash
claude --permission-mode plan       # at startup
claude --permission-mode auto       # start in auto mode
```

Set a persistent default in `.claude/settings.json`:
```json
{ "permissions": { "defaultMode": "acceptEdits" } }
```

**Auto mode requirements:** Max/Team/Enterprise/API plan (not Pro), Claude Sonnet 4.6, Opus 4.6, or Opus 4.7 (not Haiku), Anthropic API only (not Bedrock/Vertex/Foundry). Admin must enable it on Team/Enterprise.

**Protected paths (never auto-approved except in bypassPermissions):**
`.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `commands/`, `agents/`, `skills/`, `worktrees/`), `.gitconfig`, `.gitmodules`, `.bashrc`, `.zshrc`, `.mcp.json`, `.claude.json`.

## Authentication

- **Claude.ai subscription (Max/Pro):** `claude auth login` → browser OAuth flow. Token stored as `CLAUDE_CODE_OAUTH_TOKEN`.
- **Anthropic Console / API key:** `claude auth login --console` → use `ANTHROPIC_API_KEY`.
- **Long-lived token for CI:** `claude setup-token` → prints OAuth token without saving. Requires Claude subscription.
- **SSO:** `claude auth login --sso`.

## `~/.claude/` directory layout

Source: [`code.claude.com/docs/en/claude-directory.md`](https://code.claude.com/docs/en/claude-directory.md)

| Path | Contents |
|---|---|
| `~/.claude/settings.json` | User-scope settings |
| `~/.claude/CLAUDE.md` | User-scope memory instructions |
| `~/.claude/agents/` | User-scope custom subagents |
| `~/.claude/skills/` | User-scope skills |
| `~/.claude/commands/` | User-scope slash commands |
| `~/.claude/hooks/` | User-scope hook scripts |
| `~/.claude/plans/` | Plan files (default location) |
| `~/.claude.json` | OAuth session, user/local MCP configs, per-project state, caches |
| `.claude/settings.json` | Project-scope settings (commit to git) |
| `.claude/settings.local.json` | Local-scope settings (gitignored) |
| `.mcp.json` | Project-scope MCP server config |
| `.claude/agents/` | Project-scope subagents |
| `.claude/commands/` | Project-scope slash commands |
| `.claude/skills/` | Project-scope skills |
| `.claude/hooks/` | Project-scope hook scripts |
| `.claude/rules/` | Rules files loaded as CLAUDE.md fragments |

On Windows, `~/.claude` resolves to `%USERPROFILE%\.claude`.

## IDE integrations

- **VS Code:** Install "Claude Code" extension from marketplace. Extension terminal auto-detects and connects. Set `claudeCode.initialPermissionMode` for default mode.
- **JetBrains (IntelliJ, PyCharm, WebStorm, etc.):** Plugin runs Claude Code in the IDE terminal — same as CLI behavior.
- **claude.ai web:** Run cloud sessions at `claude.ai/code` — no local install needed.
- **Auto-connect:** Set `autoConnectIde: true` in `~/.claude.json` to auto-connect when launching from an external terminal.

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `settings.md` (env section), `permissions.md`.*
