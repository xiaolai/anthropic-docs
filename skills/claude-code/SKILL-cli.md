---
name: claude-code-cli
description: |
  Deep reference for Claude Code's CLI surface: command-line flags,
  subcommands, environment variables (ANTHROPIC_* / CLAUDE_*),
  permission modes (default / acceptEdits / plan / auto / bypassPermissions),
  the ~/.claude/ directory layout, IDE integration entry points, and
  authentication mechanisms. Read this file when the user asks about
  CLI invocation, env vars, permission modes, ~/.claude/ structure,
  or how Claude Code authenticates.
source: https://code.claude.com/docs/en/cli-reference.md
---

# Claude Code — CLI, environment, and layout

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for CLI / env / layout questions.*

Source: [`code.claude.com/docs/en/cli-reference.md`](https://code.claude.com/docs/en/cli-reference.md), [`code.claude.com/docs/en/env-vars.md`](https://code.claude.com/docs/en/env-vars.md), [`code.claude.com/docs/en/permissions.md`](https://code.claude.com/docs/en/permissions.md)

## CLI commands (subcommands)

| Command | Description | Example |
|---|---|---|
| `claude` | Start interactive session | `claude` |
| `claude "query"` | Start interactive session with initial prompt | `claude "explain this project"` |
| `claude -p "query"` | Print mode (SDK): query then exit | `claude -p "explain this function"` |
| `cat file \| claude -p "query"` | Process piped content | `cat logs.txt \| claude -p "explain"` |
| `claude -c` | Continue most recent conversation in current directory | `claude -c` |
| `claude -r "<session>" "query"` | Resume session by ID or name | `claude -r "auth-refactor" "Finish this PR"` |
| `claude update` | Update to latest version | `claude update` |
| `claude install [version]` | Install/reinstall native binary. Accepts version like `2.1.118`, `stable`, or `latest` | `claude install stable` |
| `claude auth login` | Sign in to Anthropic account. Flags: `--email`, `--sso`, `--console` | `claude auth login --console` |
| `claude auth logout` | Log out | `claude auth logout` |
| `claude auth status` | Show auth status as JSON. `--text` for human-readable. Exit 0 if logged in, 1 if not | `claude auth status` |
| `claude agents` | Open agent view for parallel background sessions. `--cwd <path>` to filter | `claude agents` |
| `claude attach <id>` | Attach to a background session in this terminal | `claude attach 7c5dcf5d` |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON | `claude auto-mode defaults > rules.json` |
| `claude logs <id>` | Print recent output from a background session | `claude logs 7c5dcf5d` |
| `claude mcp` | Configure MCP servers. See [SKILL-mcp.md](SKILL-mcp.md) | — |
| `claude plugin` | Manage plugins. Alias: `claude plugins`. See plugins-reference for subcommands | `claude plugin install code-review@claude-plugins-official` |
| `claude project purge [path]` | Delete all local Claude Code state for a project. Flags: `--dry-run`, `-y`, `-i`, `--all` | `claude project purge ~/work/repo --dry-run` |
| `claude remote-control` | Start a Remote Control server (no local interactive session) | `claude remote-control --name "My Project"` |
| `claude respawn <id>` | Restart a stopped background session with its conversation intact. `--all` for all stopped | `claude respawn 7c5dcf5d` |
| `claude rm <id>` | Remove a background session from the list | `claude rm 7c5dcf5d` |
| `claude setup-token` | Generate a long-lived OAuth token for CI/scripts. Requires Claude subscription | `claude setup-token` |
| `claude stop <id>` | Stop a background session. Also accepts `claude kill` | `claude stop 7c5dcf5d` |
| `claude ultrareview [target]` | Run ultrareview non-interactively. `--json` for raw payload, `--timeout <minutes>` | `claude ultrareview 1234 --json` |

If you mistype a subcommand, Claude Code suggests the closest match (e.g. `claude udpate` → `Did you mean claude update?`).

## CLI flags

`claude --help` does not list every flag; a flag's absence from `--help` does not mean it's unavailable.

| Flag | Description | Example |
|---|---|---|
| `--add-dir` | Add additional working directories for read/edit. Use `permissions.additionalDirectories` in settings to persist | `claude --add-dir ../apps ../lib` |
| `--agent` | Specify agent for current session (overrides `agent` setting) | `claude --agent my-custom-agent` |
| `--agents` | Define custom subagents dynamically via JSON | `claude --agents '{"reviewer":{...}}'` |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to `Shift+Tab` cycle without starting in it | `claude --permission-mode plan --allow-dangerously-skip-permissions` |
| `--allowedTools` | Tools that execute without permission prompts. Supports permission rule syntax | `"Bash(git log *)" "Read"` |
| `--append-system-prompt` | Append custom text to end of default system prompt | `claude --append-system-prompt "Always use TypeScript"` |
| `--append-system-prompt-file` | Load additional system prompt text from a file and append | `claude --append-system-prompt-file ./extra-rules.txt` |
| `--bare` | Minimal mode: skip auto-discovery of hooks, skills, plugins, MCP, memory, CLAUDE.md. Sets `CLAUDE_CODE_SIMPLE` | `claude --bare -p "query"` |
| `--betas` | Beta headers for API requests (API key users only) | `claude --betas interleaved-thinking` |
| `--bg` | Start as background agent, return immediately. Prints session ID | `claude --bg "investigate the flaky test"` |
| `--channels` | MCP servers whose channel notifications to listen for | `claude --channels plugin:my-notifier@my-marketplace` |
| `--chrome` | Enable Chrome browser integration | `claude --chrome` |
| `--continue`, `-c` | Load most recent conversation in current directory | `claude --continue` |
| `--dangerously-skip-permissions` | Skip permission prompts (equivalent to `--permission-mode bypassPermissions`) | `claude --dangerously-skip-permissions` |
| `--debug` | Enable debug mode. Optional category filtering (e.g. `"api,hooks"` or `"!statsig,!file"`) | `claude --debug "api,mcp"` |
| `--debug-file <path>` | Write debug logs to specific file. Implicitly enables debug mode | `claude --debug-file /tmp/claude-debug.log` |
| `--disable-slash-commands` | Disable all skills and commands for this session | `claude --disable-slash-commands` |
| `--disallowedTools` | Tools removed from model context and unavailable | `"Edit" "Bash(curl *)"` |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max`. Overrides `effortLevel` setting for session | `claude --effort high` |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves cache reuse). Use with `-p` | `claude -p --exclude-dynamic-system-prompt-sections "query"` |
| `--fallback-model` | Fallback model when default is overloaded (print mode only) | `claude -p --fallback-model sonnet "query"` |
| `--fork-session` | When resuming, create new session ID instead of reusing original | `claude --resume abc123 --fork-session` |
| `--from-pr` | Resume sessions linked to a PR. Accepts PR number, GitHub/GitLab/Bitbucket URL | `claude --from-pr 123` |
| `--ide` | Auto-connect to IDE on startup if exactly one valid IDE is available | `claude --ide` |
| `--init` | Run Setup hooks with `init` matcher before session (print mode only) | `claude -p --init "query"` |
| `--init-only` | Run Setup and SessionStart hooks then exit without starting conversation | `claude --init-only` |
| `--include-hook-events` | Include hook lifecycle events in output stream. Requires `--output-format stream-json` | `claude -p --output-format stream-json --include-hook-events "query"` |
| `--include-partial-messages` | Include partial streaming events. Requires `-p` and `--output-format stream-json` | — |
| `--input-format` | Input format for print mode: `text`, `stream-json` | `claude -p --input-format stream-json` |
| `--json-schema` | Get validated JSON output matching a JSON Schema (print mode only) | `claude -p --json-schema '{"type":"object",...}' "query"` |
| `--maintenance` | Run Setup hooks with `maintenance` matcher before session (print mode only) | `claude -p --maintenance "query"` |
| `--max-budget-usd` | Max dollar amount for API calls (print mode only) | `claude -p --max-budget-usd 5.00 "query"` |
| `--max-turns` | Limit agentic turns (print mode only). Exits with error on limit | `claude -p --max-turns 3 "query"` |
| `--mcp-config` | Load MCP servers from JSON files or strings | `claude --mcp-config ./mcp.json` |
| `--model` | Set model with alias (`sonnet`, `opus`) or full name. Overrides `model` setting and `ANTHROPIC_MODEL` | `claude --model claude-sonnet-4-6` |
| `--name`, `-n` | Set display name for session (shown in `/resume` and terminal title) | `claude -n "my-feature-work"` |
| `--no-chrome` | Disable Chrome browser integration | `claude --no-chrome` |
| `--no-session-persistence` | Disable session persistence (print mode only). Also: `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | `claude -p --no-session-persistence "query"` |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` | `claude -p "query" --output-format json` |
| `--permission-mode` | Begin in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` | `claude --permission-mode plan` |
| `--permission-prompt-tool` | MCP tool to handle permission prompts in non-interactive mode | `claude -p --permission-prompt-tool mcp_auth_tool "query"` |
| `--plugin-dir` | Load plugin from directory or `.zip` archive for this session only | `claude --plugin-dir ./my-plugin` |
| `--plugin-url` | Fetch plugin `.zip` from a URL for this session only | `claude --plugin-url https://example.com/plugin.zip` |
| `--print`, `-p` | Print mode (SDK): print response without interactive mode | `claude -p "query"` |
| `--remote` | Create a new web session on claude.ai with provided task | `claude --remote "Fix the login bug"` |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled | `claude --remote-control "My Project"` |
| `--replay-user-messages` | Re-emit user messages from stdin on stdout. Requires stream-json formats | — |
| `--resume`, `-r` | Resume session by ID or name, or show interactive picker | `claude --resume auth-refactor` |
| `--session-id` | Use specific session ID (must be a valid UUID) | `claude --session-id "550e8400-..."` |
| `--setting-sources` | Comma-separated list of setting sources to load: `user`, `project`, `local` | `claude --setting-sources user,project` |
| `--settings` | Path to settings JSON or inline JSON string. Overrides file-based values for this session | `claude --settings ./settings.json` |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config`, ignoring all other MCP configs | `claude --strict-mcp-config --mcp-config ./mcp.json` |
| `--system-prompt` | Replace entire system prompt with custom text | `claude --system-prompt "You are a Python expert"` |
| `--system-prompt-file` | Load system prompt from a file, replacing default | `claude --system-prompt-file ./custom-prompt.txt` |
| `--teleport` | Resume a web session in your local terminal | `claude --teleport` |
| `--teammate-mode` | Agent team display: `auto` (default), `in-process`, `tmux` | `claude --teammate-mode in-process` |
| `--tmux` | Create tmux session for worktree. Requires `--worktree`. Use `--tmux=classic` for traditional tmux | `claude -w feature-auth --tmux` |
| `--tools` | Restrict which built-in tools Claude can use. `""` for none, `"default"` for all | `claude --tools "Bash,Edit,Read"` |
| `--verbose` | Enable verbose logging (full turn-by-turn output). Overrides `viewMode` setting | `claude --verbose` |
| `--version`, `-v` | Output the version number | `claude -v` |
| `--worktree`, `-w` | Start in isolated git worktree. Pass `#<number>` or PR URL to fetch that PR | `claude -w feature-auth` |

### System prompt flags

| Flag | Behavior |
|---|---|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag.

## Permission modes

| Mode | Description |
|---|---|
| `default` | Asks before running commands and editing files (default) |
| `acceptEdits` | Auto-approves file edits, still asks for commands |
| `plan` | Planning-only mode; Claude proposes actions without executing |
| `auto` | Auto mode: classifier decides what to allow/deny without prompting |
| `dontAsk` | Skips all permission prompts (less restrictive than bypassPermissions) |
| `bypassPermissions` | Skips all permission checks. Use `--dangerously-skip-permissions` or `--permission-mode bypassPermissions` |

Cycle modes in CLI with `Shift+Tab`. Change for session with `--permission-mode`. Persist via `permissions.defaultMode` in settings.

## Key environment variables

Full reference: [`code.claude.com/docs/en/env-vars.md`](https://code.claude.com/docs/en/env-vars.md)

### Authentication

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | API key (metered billing). Overrides subscription even when logged in. Use `unset` to go back to subscription |
| `ANTHROPIC_AUTH_TOKEN` | Custom `Authorization: Bearer <value>` header |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth access token for Claude.ai. Takes precedence over keychain. Generate with `claude setup-token` |
| `CLAUDE_CODE_OAUTH_REFRESH_TOKEN` | OAuth refresh token. Requires `CLAUDE_CODE_OAUTH_SCOPES` |

### Model and API

| Variable | Purpose |
|---|---|
| `ANTHROPIC_MODEL` | Override default model for session (e.g. `claude-opus-4-7`) |
| `ANTHROPIC_BASE_URL` | Override API endpoint (proxy/gateway). Disables MCP tool search by default on non-first-party hosts |
| `ANTHROPIC_BETAS` | Comma-separated beta headers. Works with all auth methods (unlike `--betas`) |
| `API_TIMEOUT_MS` | API request timeout in ms. Default: 600000 (10 min) |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget. `0` = disable thinking |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max`, `auto`. Overrides `/effort` and `effortLevel` setting |

### Provider-specific

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex AI endpoint |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID for Vertex AI |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full base URL for Foundry resource |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Foundry resource name |
| `CLAUDE_CODE_USE_ANTHROPIC_AWS` | Use Claude Platform on AWS |

### Session and storage

| Variable | Purpose |
|---|---|
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location. Default: `~/.claude` |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Set `1` to skip writing prompt history and transcripts to disk |
| `CLAUDE_CODE_SESSION_ID` | Set automatically in Bash subprocesses to current session ID |

### Behavior

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_SIMPLE` | Set `1` for minimal system prompt with only Bash/file tools. `--bare` sets this |
| `BASH_DEFAULT_TIMEOUT_MS` | Default timeout for long-running bash commands. Default: 120000 (2 min) |
| `BASH_MAX_TIMEOUT_MS` | Maximum timeout model can set. Default: 600000 (10 min) |
| `BASH_MAX_OUTPUT_LENGTH` | Max chars in bash output before saving to file |
| `DISABLE_AUTOUPDATER` | Set `1` to disable background auto-updates. Manual `claude update` still works |
| `DISABLE_UPDATES` | Set `1` to block ALL updates including manual `claude update` |
| `DISABLE_TELEMETRY` | Set `1` to opt out of telemetry |
| `DO_NOT_TRACK` | Set `1` to opt out (equivalent to `DISABLE_TELEMETRY`) |
| `DISABLE_AUTO_COMPACT` | Set `1` to disable automatic compaction |
| `DISABLE_COMPACT` | Set `1` to disable ALL compaction including manual `/compact` |
| `DISABLE_PROMPT_CACHING` | Set `1` to disable prompt caching for all models |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens in MCP tool responses. Default: 25000 |
| `MCP_TIMEOUT` | MCP server startup timeout in ms. Default: 30000 |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout in ms. Default: 100000000 (≈28 hours) |
| `CLAUDECODE` | Set to `1` in shell environments Claude Code spawns. Not set in hooks or status line commands |

### Debugging and telemetry

| Variable | Purpose |
|---|---|
| `DEBUG` | Set `1` to enable debug mode. Logs written to `~/.claude/debug/<session-id>.txt` |
| `CLAUDE_CODE_DEBUG_LOGS_DIR` | Override debug log file path |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set `1` to enable OpenTelemetry data collection |
| `OTEL_METRICS_EXPORTER` | OTel metrics exporter (e.g. `otlp`) |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTel exporter endpoint |
| `OTEL_LOG_RAW_API_BODIES` | `1` for inline truncated bodies; `file:<dir>` for full bodies on disk |
| `OTEL_LOG_TOOL_CONTENT` | Set `1` to include tool inputs/outputs in OTel spans |
| `OTEL_LOG_USER_PROMPTS` | Set `1` to include user prompt text in OTel traces |

### Networking

| Variable | Purpose |
|---|---|
| `HTTP_PROXY` | HTTP proxy server |
| `HTTPS_PROXY` | HTTPS proxy server |
| `NO_PROXY` | Domains/IPs to bypass proxy |
| `CLAUDE_CODE_CERT_STORE` | CA certificate sources: `bundled` (Mozilla CA), `system` (OS trust store). Default: `bundled,system` |
| `CLAUDE_CODE_CLIENT_CERT` | Path to client certificate file for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Path to client private key for mTLS |

### Plugin-related

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_PLUGIN_CACHE_DIR` | Override plugins root directory. Default: `~/.claude/plugins` |
| `CLAUDE_CODE_PLUGIN_GIT_TIMEOUT_MS` | Timeout for git operations when installing plugins. Default: 120000 |
| `CLAUDE_CODE_PLUGIN_PREFER_HTTPS` | Set `1` to clone GitHub plugin sources over HTTPS instead of SSH |
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | Pre-populated plugins directories for container images (`:` separated) |

## `~/.claude/` directory layout

| Path | Contents |
|---|---|
| `~/.claude/settings.json` | User-scope settings |
| `~/.claude/CLAUDE.md` | User-scope memory instructions |
| `~/.claude/commands/` | User-scope slash commands |
| `~/.claude/agents/` | User-scope custom subagents |
| `~/.claude/skills/` | User-scope skills |
| `~/.claude/rules/` | User-scope auto-correction rules |
| `~/.claude/plugins/` | Installed plugin cache |
| `~/.claude/debug/` | Debug log files (`<session-id>.txt`) |
| `~/.claude.json` | OAuth session, user-scoped MCP configs, per-project state, trust settings, caches |

Project-scoped MCP servers are stored in `.mcp.json` at the project root. Project settings live in `.claude/settings.json` (committed) or `.claude/settings.local.json` (gitignored).

## IDE integrations

| IDE | Integration |
|---|---|
| VS Code | Extension available. `CLAUDE_CODE_AUTO_CONNECT_IDE` to override auto-connect |
| JetBrains IDEs (IntelliJ, PyCharm, WebStorm, etc.) | Plugin available. Same auto-connect behavior |
| External terminal | Use `--ide` flag or set `autoConnectIde: true` in `~/.claude.json` |

## Authentication

| Method | Description |
|---|---|
| Claude.ai subscription (Max/Pro/Team/Enterprise) | `claude auth login`. Stores OAuth token in keychain. Or use `CLAUDE_CODE_OAUTH_TOKEN` |
| Anthropic API key (metered) | Set `ANTHROPIC_API_KEY`. Use `claude auth login --console` for Console |
| Long-lived token | `claude setup-token` — generates OAuth token without saving. Paste into `CLAUDE_CODE_OAUTH_TOKEN` |
| Custom auth script | `apiKeyHelper` setting — runs script to generate auth value |

---

*Source pages: [`code.claude.com/docs/en/cli-reference.md`](https://code.claude.com/docs/en/cli-reference.md), [`code.claude.com/docs/en/env-vars.md`](https://code.claude.com/docs/en/env-vars.md), [`code.claude.com/docs/en/permissions.md`](https://code.claude.com/docs/en/permissions.md), [`code.claude.com/docs/en/permission-modes.md`](https://code.claude.com/docs/en/permission-modes.md)*
