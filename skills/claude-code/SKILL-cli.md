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

Source: [code.claude.com/docs/en/cli-reference.md](https://code.claude.com/docs/en/cli-reference.md), [permissions.md](https://code.claude.com/docs/en/permissions.md), [permission-modes.md](https://code.claude.com/docs/en/permission-modes.md)

## Top-level invocation

```bash
claude                                 # Start interactive session
claude "query"                         # Interactive session with initial prompt
claude -p "query"                      # Print mode (non-interactive), then exit
cat file.txt | claude -p "explain"     # Process piped content
claude -c                              # Continue most recent conversation
claude -c -p "query"                   # Continue via print mode
claude -r "session-name" "query"       # Resume session by ID or name
```

## CLI subcommands

| Subcommand | Description |
|---|---|
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall native binary. Accepts `2.1.118`, `stable`, or `latest` |
| `claude auth login` | Sign in. Flags: `--email`, `--sso`, `--console` |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable). Exits 0=logged in, 1=not |
| `claude agents` | Open agent view for background sessions. `--cwd <path>` to filter |
| `claude attach <id>` | Attach to a background session in this terminal |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude logs <id>` | Print recent output from a background session |
| `claude mcp` | Configure MCP servers (see [`SKILL-mcp.md`](SKILL-mcp.md)) |
| `claude plugin` | Manage plugins. Alias: `claude plugins` |
| `claude project purge [path]` | Delete all local Claude Code state for a project. Flags: `--dry-run`, `-y`/`--yes`, `-i`/`--interactive`, `--all` |
| `claude remote-control` | Start a Remote Control server. See [remote-control docs](https://code.claude.com/docs/en/remote-control.md) |
| `claude respawn <id>` | Restart a stopped background session. `--all` for all stopped sessions |
| `claude rm <id>` | Remove a background session from the list |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts (subscription required) |
| `claude stop <id>` | Stop a background session. Alias: `claude kill` |
| `claude ultrareview [target]` | Run ultrareview non-interactively. `--json` for raw payload, `--timeout <min>` (default 30) |

Mistyped subcommands show the nearest match (e.g. `claude udpate` → `Did you mean claude update?`).

## CLI flags

`claude --help` does not list every flag — a flag's absence from `--help` does not mean it's unavailable.

| Flag | Description |
|---|---|
| `--add-dir` | Add additional working directories. Validates each path exists |
| `--agent` | Specify an agent for the current session (overrides `agent` setting) |
| `--agents` | Define custom subagents dynamically via JSON |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to Shift+Tab cycle without starting in it |
| `--allowedTools` | Tools that execute without prompting. See permission rule syntax |
| `--append-system-prompt` | Append custom text to end of default system prompt |
| `--append-system-prompt-file` | Load additional system prompt from file, appended to default |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, auto memory, CLAUDE.md. Sets `CLAUDE_CODE_SIMPLE` |
| `--betas` | Beta headers for API requests (API key users only) |
| `--bg` | Start session as background agent and return immediately |
| `--channels` | MCP servers whose channel notifications Claude should listen to |
| `--chrome` | Enable Chrome browser integration |
| `--continue`, `-c` | Load most recent conversation in current directory |
| `--dangerously-load-development-channels` | Enable channels not on the approved allowlist (dev only) |
| `--dangerously-skip-permissions` | Skip permission prompts. Equivalent to `--permission-mode bypassPermissions` |
| `--debug` | Enable debug mode with optional category filtering (`"api,hooks"` or `"!statsig,!file"`) |
| `--debug-file <path>` | Write debug logs to a file. Implicitly enables debug mode |
| `--disable-slash-commands` | Disable all skills and commands for this session |
| `--disallowedTools` | Tools removed from model's context (cannot be used) |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` (model-dependent). Does not persist |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves prompt-cache reuse in multi-user scripted workloads) |
| `--fallback-model` | Enable auto-fallback to specified model when default is overloaded (print mode only) |
| `--fork-session` | When resuming, create new session ID instead of reusing original |
| `--from-pr` | Resume sessions linked to a PR. Accepts PR number, GitHub/GitLab/Bitbucket PR URL |
| `--ide` | Auto-connect to IDE at startup if exactly one valid IDE is available |
| `--init` | Run Setup hooks with `init` matcher before session (print mode only) |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--include-hook-events` | Include all hook lifecycle events in output (requires `--output-format stream-json`) |
| `--include-partial-messages` | Include partial streaming events (requires `--print` and `--output-format stream-json`) |
| `--input-format` | Specify input format for print mode: `text`, `stream-json` |
| `--json-schema` | Get validated JSON output matching a JSON Schema (print mode only) |
| `--maintenance` | Run Setup hooks with `maintenance` matcher (print mode only) |
| `--max-budget-usd` | Max dollar amount for API calls before stopping (print mode only) |
| `--max-turns` | Limit agentic turns (print mode only). Exits with error when limit reached |
| `--mcp-config` | Load MCP servers from JSON files or strings (space-separated) |
| `--model` | Set model for current session. Alias `sonnet`, `opus`, or full name |
| `--name`, `-n` | Set display name for session (shown in `/resume` and terminal title) |
| `--no-chrome` | Disable Chrome browser integration |
| `--no-session-persistence` | Disable session persistence (print mode only) |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` |
| `--permission-mode` | Begin in specified permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` |
| `--permission-prompt-tool` | Specify MCP tool to handle permission prompts in non-interactive mode |
| `--plugin-dir` | Load plugin from directory or `.zip` archive for this session only |
| `--plugin-url` | Fetch plugin `.zip` from URL for this session only |
| `--print`, `-p` | Print response without interactive mode |
| `--remote` | Create a new web session on claude.ai with the task description |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--remote-control-session-name-prefix <prefix>` | Prefix for auto-generated Remote Control session names |
| `--replay-user-messages` | Re-emit user messages from stdin back on stdout |
| `--resume`, `-r` | Resume a specific session by ID or name, or show interactive picker |
| `--session-id` | Use a specific session ID (must be valid UUID) |
| `--setting-sources` | Comma-separated list of setting sources to load: `user`, `project`, `local` |
| `--settings` | Path to settings JSON file or inline JSON string. Overrides file-based settings for this session |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config`, ignoring all other configs |
| `--system-prompt` | Replace entire system prompt with custom text |
| `--system-prompt-file` | Load system prompt from file, replacing default |
| `--teleport` | Resume a web session in your local terminal |
| `--teammate-mode` | Set agent team display: `auto`, `in-process`, or `tmux` |
| `--tmux` | Create tmux session for worktree (requires `--worktree`) |
| `--tools` | Restrict which built-in tools Claude can use. `""` = none, `"default"` = all |
| `--verbose` | Enable verbose logging |
| `--version`, `-v` | Output version number |
| `--worktree`, `-w` | Start in isolated git worktree. Pass `#<number>` or PR URL to branch from a PR |

### System prompt flags summary

| Flag | Behavior |
|---|---|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can be combined with either replacement flag.

## Environment variables

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | API authentication. Mutually exclusive with `CLAUDE_CODE_OAUTH_TOKEN` |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max/Pro) OAuth auth. Preferred over API key when both set |
| `ANTHROPIC_MODEL` | Override default model for the session. Example: `claude-opus-4-7` |
| `ANTHROPIC_BASE_URL` | Custom API base URL (for LLM gateways / proxies) |
| `EDITOR` | Editor invoked for external editing. Common: `code --wait`, `vim`, `nvim` |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location. Useful for sandboxed/multi-account setups |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable OpenTelemetry export |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Set to `1` to disable auto memory |
| `CLAUDE_CODE_DISABLE_THINKING` | Set to `1` to force thinking off |
| `CLAUDE_CODE_EFFORT_LEVEL` | Override effort level: `low`, `medium`, `high`, `xhigh` |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | Set to `1` to show session recap on return |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Disable transcript writes in any mode |
| `CLAUDE_CODE_DEBUG_LOGS_DIR` | Directory for debug logs |
| `CLAUDE_CODE_SIMPLE` | Set by `--bare` mode; disables most auto-discovery |
| `CLAUDE_CODE_NO_FLICKER` | Use fullscreen renderer (same as `tui: "fullscreen"` in settings) |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | Set to `1` to enable PowerShell tool on Windows |
| `CLAUDE_CODE_AUTO_CONNECT_IDE` | Override `autoConnectIde` setting |
| `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` | Override `autoInstallIdeExtension` setting |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Set to `1` to suppress session quality surveys |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Refresh interval for `apiKeyHelper` script |
| `CLAUDE_CODE_DISABLE_GIT_INSTRUCTIONS` | Takes precedence over `includeGitInstructions` setting |
| `CLAUDE_CODE_DISABLE_AGENT_VIEW` | Equivalent to `disableAgentView: true` in settings |
| `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` | Prefix for Remote Control session names |
| `DISABLE_AUTOUPDATER` | Disable auto-updates when set in `env` setting |
| `MCP_TIMEOUT` | MCP server startup timeout in ms (e.g. `MCP_TIMEOUT=10000 claude`) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens for MCP tool output (default 10,000) |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OpenTelemetry endpoint for traces/metrics |
| `OTEL_METRICS_EXPORTER` | OTEL metrics exporter (e.g. `otlp`) |

**Precedence (highest wins):** env var > `settings.local.json` > `settings.json` (project) > `settings.json` (user) > built-in default.

## Permission modes

Modes control how often Claude asks for approval. Cycle modes with `Shift+Tab` in the CLI.

| Mode | What runs without asking | Set via |
|---|---|---|
| `default` | Reads only | Default; `--permission-mode default` |
| `acceptEdits` | Reads, file edits, common filesystem Bash (`mkdir`, `touch`, `rm`, `rmdir`, `mv`, `cp`, `sed`) | `Shift+Tab` once; `--permission-mode acceptEdits` |
| `plan` | Reads only (no edits — Claude proposes a plan first) | `Shift+Tab` twice; `--permission-mode plan`; `/plan` prefix |
| `auto` | Everything, with background safety classifier | `Shift+Tab` (after opt-in); `--permission-mode auto` |
| `dontAsk` | Only pre-approved tools | `--permission-mode dontAsk` (never in Shift+Tab cycle) |
| `bypassPermissions` | Everything (no permission layer) | `--dangerously-skip-permissions`; container/VM only |

**Protected paths** are never auto-approved in any mode except `bypassPermissions` — these guard repository state and Claude's config.

**Auto mode requirements:** Claude Code v2.1.83+, Max/Team/Enterprise/API plan (not Pro), admin-enabled for Team/Enterprise, supported model (Claude Sonnet 4.6, Opus 4.6, or Opus 4.7), Anthropic API only (not Bedrock/Vertex/Foundry).

**Setting a default mode** in `.claude/settings.json`:
```json
{
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

**Disabling a mode:**
- Disable `bypassPermissions`: `"disableBypassPermissionsMode": "disable"` in managed settings
- Disable `auto`: `"disableAutoMode": "disable"` in managed settings

## Authentication

| Method | Variable | Use case |
|---|---|---|
| Claude.ai OAuth | `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max/Pro/Team/Enterprise) |
| Anthropic API key | `ANTHROPIC_API_KEY` | API usage billing via Anthropic Console |
| AWS Bedrock | IAM / `awsAuthRefresh` / `awsCredentialExport` settings | Bedrock deployments |
| Google Vertex AI | GCP Application Default Credentials / `gcpAuthRefresh` | Vertex deployments |
| API key helper | `apiKeyHelper` setting | Custom/ephemeral keys |

Generate a long-lived OAuth token for CI: `claude setup-token`

## `~/.claude/` directory layout

| Path | Purpose |
|---|---|
| `~/.claude/settings.json` | User-scope settings (all projects) |
| `~/.claude/CLAUDE.md` | User-scope memory instructions |
| `~/.claude/commands/` | User-scope custom slash commands |
| `~/.claude/agents/` | User-scope custom subagent definitions |
| `~/.claude/skills/` | User-scope skills |
| `~/.claude/rules/` | User-scope rules (Markdown files) |
| `~/.claude/plans/` | Default plan storage |
| `~/.claude.json` | OAuth session, user-level MCP configs, per-project state, caches |

**Project-level layout** (inside project root):
| Path | Purpose |
|---|---|
| `.claude/settings.json` | Project-scope settings (committed) |
| `.claude/settings.local.json` | Personal project overrides (gitignored) |
| `.claude/CLAUDE.md` | Project memory (alternative to root `CLAUDE.md`) |
| `.claude/commands/` | Project slash commands |
| `.claude/agents/` | Project subagent definitions |
| `.claude/skills/` | Project skills |
| `.claude/rules/` | Project rules |
| `.claude/hooks/` | Project hook scripts |
| `.claude/worktrees/` | Isolated git worktrees |
| `.mcp.json` | Project-scope MCP server configs |

On Windows, `~/.claude` paths resolve to `%USERPROFILE%\.claude`.

## IDE integrations

| IDE | How to start |
|---|---|
| VS Code | Install "Claude Code" extension. Claude Code runs in integrated terminal |
| JetBrains | Install "Claude Code" plugin. Claude Code runs in IDE terminal |
| claude.ai/code | Cloud sessions directly in browser |

`claude --ide` auto-connects to IDE at startup when exactly one valid IDE is available.

## Cost and quota

- **Subscription**: Max/Pro/Team/Enterprise plans have usage limits. Check `/usage` inside Claude Code.
- **API billing**: Metered by token. Set `ANTHROPIC_API_KEY`. Use `--max-budget-usd` to cap spend in print mode.
- **Effort level**: `--effort xhigh` on Opus models incurs higher cost per turn (more extended thinking).

---

*Source: [code.claude.com/docs/en/cli-reference.md](https://code.claude.com/docs/en/cli-reference.md), [permissions.md](https://code.claude.com/docs/en/permissions.md), [permission-modes.md](https://code.claude.com/docs/en/permission-modes.md), [env-vars.md](https://code.claude.com/docs/en/env-vars.md)*
