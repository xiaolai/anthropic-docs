---
name: claude-code-cli
description: |
  Deep reference for Claude Code's CLI surface: command-line flags,
  subcommands, environment variables (ANTHROPIC_* / CLAUDE_*),
  permission modes (default / acceptEdits / plan / auto / dontAsk /
  bypassPermissions), the ~/.claude/ directory layout, IDE integration
  entry points, and authentication mechanisms. Read this file when
  the user asks about CLI invocation, env vars, permission modes,
  ~/.claude/ structure, or how Claude Code authenticates.
source: https://code.claude.com/docs/en/cli-reference.md
---

# Claude Code — CLI, environment, and layout

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for CLI / env / layout questions.*

## Top-level invocation

```bash
claude                          # Start interactive REPL
claude "write me a function"    # Start with initial prompt
claude -p "query"               # Non-interactive: print and exit
cat file.txt | claude -p "q"   # Pipe content as input
claude -c                       # Continue most recent conversation
claude -r "<id|name>" "query"  # Resume session by ID or name
claude update                   # Update to latest version
```

## CLI flags

| Flag | Short | Type | Notes |
|---|---|---|---|
| `--print` | `-p` | bool | Non-interactive mode: print output and exit |
| `--continue` | `-c` | bool | Continue the most recent conversation |
| `--resume` | `-r` | string | Resume session by ID or display name |
| `--name` | `-n` | string | Set session display name |
| `--worktree` | `-w` | bool | Start in a new git worktree |
| `--model` | | string | Set model (alias: `sonnet`, `opus`, or full model name) |
| `--permission-mode` | | string | Set permission mode (see § *Permission modes*) |
| `--dangerously-skip-permissions` | | bool | Alias for `--permission-mode bypassPermissions` |
| `--bare` | | bool | Minimal mode, skip discovery and prompts |
| `--add-dir` | | string | Add additional working directory (repeatable) |
| `--agent` | | string | Specify subagent to use |
| `--agents` | | string | Define custom subagents via JSON |
| `--allowedTools` | | string | Pre-approved tools (permission rule syntax, comma-separated) |
| `--disallowedTools` | | string | Blocked tools (permission rule syntax) |
| `--tools` | | string | Restrict available tools |
| `--system-prompt` | | string | Fully replace system prompt |
| `--system-prompt-file` | | string | Load system prompt from file |
| `--append-system-prompt` | | string | Append to system prompt |
| `--append-system-prompt-file` | | string | Append system prompt from file |
| `--effort` | | string | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--max-turns` | | number | Limit agentic turns (print mode) |
| `--max-budget-usd` | | number | Spending limit in USD (print mode) |
| `--output-format` | | string | Output format: `text`, `json`, `stream-json` |
| `--input-format` | | string | Input format: `text`, `stream-json` |
| `--json-schema` | | string | Structured output schema (print mode) |
| `--include-hook-events` | | bool | Include hook lifecycle events (requires `stream-json`) |
| `--include-partial-messages` | | bool | Include streaming partial events (print mode) |
| `--init` | | bool | Run Setup hooks (init type) |
| `--init-only` | | bool | Run Setup hooks and exit |
| `--maintenance` | | bool | Run Setup hooks (maintenance type) |
| `--mcp-config` | | string | Load MCP servers from JSON files/strings |
| `--plugin-dir` | | string | Load plugin from directory or .zip |
| `--plugin-url` | | string | Fetch and load plugin from URL |
| `--chrome` / `--no-chrome` | | bool | Enable/disable browser integration |
| `--bg` | | bool | Start as background agent |
| `--channels` | | string | MCP server channels (research preview) |
| `--debug` | | bool | Enable debug logging |
| `--debug-file` | | string | Write debug output to file |
| `--exclude-dynamic-system-prompt-sections` | | string | Improve prompt cache reuse |
| `--fallback-model` | | string | Fallback model on overload (print mode) |
| `--fork-session` | | bool | Create new session ID on resume |
| `--ide` | | string | Auto-connect to IDE |
| `--no-session-persistence` | | bool | Skip session transcript writing (print mode) |
| `--session-id` | | string | Use specific UUID for session |
| `--settings` | | string | Override settings path for session |
| `--setting-sources` | | string | Which settings to load: `user`, `project`, `local` |
| `--teammate-mode` | | string | Agent team display: `auto`, `in-process`, `tmux` |
| `--verbose` | | bool | Enable verbose logging |
| `--version` | `-v` | bool | Show version |

## Subcommands

| Subcommand | Description |
|---|---|
| `claude auth login\|logout\|status` | Authentication management |
| `claude update` | Update to latest version |
| `claude install [version]` | Install specific version (`stable`, `latest`, or semver) |
| `claude agents` | Open agent view |
| `claude attach <id>` | Attach to background session |
| `claude logs <id>` | View background session logs |
| `claude stop <id>` | Stop background session |
| `claude respawn <id>` | Restart background session |
| `claude rm <id>` | Remove background session |
| `claude mcp ...` | MCP server management (see [`SKILL-mcp.md`](SKILL-mcp.md)) |
| `claude plugin ...` | Plugin management (see [`SKILL-plugins.md`](SKILL-plugins.md)) |
| `claude project purge [path]` | Delete local project state |
| `claude remote-control` | Start Remote Control server |
| `claude setup-token` | Generate long-lived OAuth token |
| `claude ultrareview [target]` | Run non-interactive code review |
| `claude auto-mode defaults` | View built-in auto mode rules |
| `claude auto-mode config` | View effective auto mode config |

## Environment variables

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Metered API authentication. Mutually exclusive with `CLAUDE_CODE_OAUTH_TOKEN` |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max/Pro) OAuth authentication. Preferred over API key when both set |
| `ANTHROPIC_MODEL` | Override default model for session (e.g., `claude-opus-4-7`). Overrides `model` in `settings.json` |
| `ANTHROPIC_BASE_URL` | Override Anthropic API base URL (e.g., for proxies) |
| `EDITOR` | External editor invoked by Ctrl+G. Common values: `code --wait`, `vim`, `nvim` |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location. Useful for sandboxed/multi-account setups |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set `"1"` to enable OpenTelemetry telemetry |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Set `"1"` to disable auto memory |
| `CLAUDE_CODE_DISABLE_THINKING` | Set `"1"` to force thinking off |
| `CLAUDE_CODE_DISABLE_AGENT_VIEW` | Set `"1"` to disable background agents/agent view |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Set `"1"` to suppress session quality survey |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | Set `"1"` to enable away session recap |
| `CLAUDE_CODE_EFFORT_LEVEL` | Override effort level: `low`, `medium`, `high`, `xhigh` |
| `CLAUDE_CODE_NO_FLICKER` | Set `"1"` for fullscreen TUI renderer |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | Set `"1"` to enable PowerShell tool |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Set `"1"` to disable transcript writes |
| `CLAUDE_CODE_AUTO_CONNECT_IDE` | Set `"1"` to auto-connect to IDE |
| `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` | Set `"1"` to skip auto-installing IDE extension |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Refresh interval (ms) for `apiKeyHelper` script |
| `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS` | Refresh interval (ms) for OTel headers helper |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Disable built-in git workflow instructions in system prompt |
| `DISABLE_AUTOUPDATER` | Set `"1"` to disable auto-updates |
| `OTEL_METRICS_EXPORTER` | OpenTelemetry metrics exporter (e.g., `otlp`) |
| `CLAUDE_ENV_FILE` | Environment variables file run as preamble before Bash tool calls |
| `CLAUDE_PROJECT_DIR` | Set by Claude Code; available to all hook types and MCP stdio servers |

**Precedence (highest wins):** env var → `settings.local.json` → `settings.json` (project) → `settings.json` (user) → built-in default.

## Permission modes

| Mode | What auto-runs without prompting | Best for |
|---|---|---|
| `default` | Read-only operations | Getting started, sensitive codebases |
| `acceptEdits` | Reads + file edits + common filesystem commands | Iterative development |
| `plan` | Read-only exploration, then asks before editing | Analyze before changing |
| `auto` | Everything with background safety classifier | Long tasks, reducing interruptions |
| `dontAsk` | Only pre-approved tools | Locked-down CI/scripts |
| `bypassPermissions` | Everything (circuit breakers on root/home deletes) | Isolated containers only |

Set mode: `--permission-mode <mode>` or `defaultMode` in `settings.json` `permissions` block.

### `acceptEdits` auto-approves

- File edits: Edit, Write
- Filesystem commands: mkdir, touch, rm, rmdir, mv, cp, sed
- PowerShell equivalents: Set-Content, Add-Content, Clear-Content, Remove-Item
- With safe env vars: `LANG=C`, `NO_COLOR=1`
- With process wrappers: timeout, nice, nohup
- **Scope:** working directory + `additionalDirectories` only

### `auto` mode requirements

- **Plan required:** Max, Team, Enterprise, or API (not Pro)
- **Admin required:** on Team/Enterprise, must enable in admin settings
- **Model:** Sonnet 4.6, Opus 4.6/4.7 (Team/Enterprise/API); Opus 4.7 only (Max)
- **Provider:** Anthropic API only (not Bedrock/Vertex)

Auto mode classifier blocks by default: curl-piped code execution, sensitive data exfiltration, production deploys/migrations, mass deletions, IAM grants, shared infrastructure changes, force pushes to main.

Classifier fallback: blocks 3× in a row OR 20× total → shows notification → press `r` to retry with manual approval.

### Protected paths (not auto-approved in any mode except `bypassPermissions`)

Directories: `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`)

Files: `.gitconfig`, `.gitmodules`, `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`, `.ripgreprc`, `.mcp.json`, `.claude.json`

## Authentication

| Method | Env var / credential | Use case |
|---|---|---|
| Claude.ai OAuth | `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Pro/Max); `claude auth login` |
| Anthropic API key | `ANTHROPIC_API_KEY` | API usage billing; Console account |
| `apiKeyHelper` script | setting in `settings.json` | Custom auth (dynamic keys, SSO tokens) |
| Amazon Bedrock | AWS credentials + `awsCredentialExport` / `awsAuthRefresh` | Enterprise Bedrock |
| Google Vertex AI | GCP ADC + `gcpAuthRefresh` | Enterprise Vertex |
| Azure/Foundry | via `ANTHROPIC_BASE_URL` | Microsoft Foundry |

Login: `claude auth login` — follow prompts for OAuth or paste API key.

Long-lived OAuth token for CI: `claude setup-token`

## `~/.claude/` directory layout

| Path | Purpose |
|---|---|
| `~/.claude/settings.json` | User-scope settings |
| `~/.claude/skills/` | User-scope skills (one dir per skill) |
| `~/.claude/agents/` | User-scope subagent definitions |
| `~/.claude/commands/` | Legacy user-scope commands |
| `~/.claude/CLAUDE.md` | User-scope memory/instructions |
| `~/.claude/plans/` | Default plan files location |
| `~/.claude.json` | Auth session, user/local MCP configs, per-project state, caches |

Project layout (in repo):
| Path | Purpose |
|---|---|
| `.claude/settings.json` | Project-scope settings (commit to git) |
| `.claude/settings.local.json` | Local-scope settings (gitignored) |
| `.claude/skills/` | Project-scope skills |
| `.claude/agents/` | Project-scope subagents |
| `.claude/commands/` | Legacy project commands |
| `.claude/CLAUDE.md` | Project memory/instructions (or `CLAUDE.md` at root) |
| `.claude/worktrees/` | Subagent worktree state |
| `.mcp.json` | Project-scope MCP server config |
| `CLAUDE.local.md` | Local memory/instructions (gitignored) |

## IDE integrations

| IDE | Entry point |
|---|---|
| VS Code | Install Claude Code extension; `claude` in VS Code terminal auto-connects |
| JetBrains | Install Claude Code plugin; `claude` in built-in terminal auto-connects |
| Web app | `claude-code-on-the-web.md` integration |

Auto-connect behavior: controlled by `autoConnectIde` in `~/.claude.json` and `autoInstallIdeExtension`. Force: `--ide` flag or `CLAUDE_CODE_AUTO_CONNECT_IDE=1`.

---

*Source pages: [`code.claude.com/docs/en/cli-reference.md`](https://code.claude.com/docs/en/cli-reference.md), [`permissions.md`](https://code.claude.com/docs/en/permissions.md), [`permission-modes.md`](https://code.claude.com/docs/en/permission-modes.md)*
