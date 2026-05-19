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
| `claude "query"` | Start interactive session with an initial prompt |
| `claude -p "query"` | Non-interactive (SDK/print) mode — run query and exit |
| `cat file \| claude -p "query"` | Pipe content into non-interactive mode |
| `claude -c` | Continue the most recent conversation in the current directory |
| `claude -c -p "query"` | Continue via SDK (non-interactive) |
| `claude -r "<session>"` | Resume session by ID or name (interactive picker if no arg) |
| `claude -r "auth-refactor" "query"` | Resume and send an initial message |
| `claude --resume <id> --fork-session` | Resume but create a new session ID (fork) |
| `claude --from-pr 123` | Resume sessions linked to a pull request |
| `claude update` | Update to latest version |
| `claude install [version]` | Install/reinstall binary (`stable`, `latest`, or `2.1.118`) |

## CLI flags

`claude --help` does not list every flag. All documented flags:

| Flag | Description |
|---|---|
| `--add-dir` | Add additional working directories for file access (repeatable) |
| `--agent <name>` | Specify a subagent for this session |
| `--agents '<json>'` | Define custom subagents dynamically via JSON |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to Shift+Tab cycle without starting in it |
| `--allowedTools` | Tools that run without a permission prompt (pattern list) |
| `--append-system-prompt <text>` | Append text to end of default system prompt |
| `--append-system-prompt-file <path>` | Append file contents to default system prompt |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, auto-memory, CLAUDE.md |
| `--betas <headers>` | Beta headers for API requests (API key users only) |
| `--bg` | Start as background agent and return immediately |
| `--channels <list>` | MCP channel plugins to listen for (research preview) |
| `--chrome` | Enable Chrome browser integration |
| `--continue`, `-c` | Load most recent conversation in current directory |
| `--dangerously-skip-permissions` | Skip all permission prompts (= `--permission-mode bypassPermissions`) |
| `--debug [categories]` | Enable debug mode, optional category filter (`"api,hooks"`, `"!statsig"`) |
| `--debug-file <path>` | Write debug logs to a specific file (also enables debug mode) |
| `--disable-slash-commands` | Disable all skills/commands for this session |
| `--disallowedTools` | Tools removed from model context entirely |
| `--effort <level>` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves cache reuse) |
| `--fallback-model <model>` | Auto-fallback model on overload (print mode and background sessions) |
| `--fork-session` | When resuming, create a new session ID |
| `--from-pr <ref>` | Resume sessions linked to a PR (number, GitHub/GitLab/Bitbucket URL) |
| `--ide` | Auto-connect to IDE on startup |
| `--init` | Run Setup hooks with `init` matcher before session (print mode only) |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--include-hook-events` | Include hook lifecycle events in output (requires `--output-format stream-json`) |
| `--include-partial-messages` | Include partial streaming events (requires `-p` and `stream-json`) |
| `--input-format <format>` | Input format for print mode: `text`, `stream-json` |
| `--json-schema '<schema>'` | Validated JSON output matching schema (print mode only) |
| `--maintenance` | Run Setup hooks with `maintenance` matcher before session (print mode only) |
| `--max-budget-usd <n>` | Maximum dollar spend on API calls before stopping (print mode only) |
| `--max-turns <n>` | Limit agentic turns (print mode only); exits with error at limit |
| `--mcp-config <file>` | Load MCP servers from JSON files or strings |
| `--model <model>` | Set model for session; alias `sonnet` or `opus`, or full model name |
| `--name`, `-n` | Set display name for session (also usable with `--resume`) |
| `--no-chrome` | Disable Chrome browser integration for this session |
| `--no-session-persistence` | Do not save session to disk (print mode only) |
| `--output-format <format>` | Output format for print mode: `text`, `json`, `stream-json` |
| `--permission-mode <mode>` | Start in specified permission mode (see Permission modes section) |
| `--permission-prompt-tool <tool>` | MCP tool to handle permission prompts in non-interactive mode |
| `--plugin-dir <path>` | Load a plugin from directory or `.zip` for this session |
| `--plugin-url <url>` | Fetch a plugin `.zip` from URL for this session |
| `--print`, `-p` | Non-interactive print mode (SDK usage) |
| `--remote <task>` | Create a new web session on claude.ai with the task description |
| `--remote-control`, `--rc` | Start with Remote Control enabled (optionally pass a name) |
| `--replay-user-messages` | Re-emit user messages from stdin on stdout (requires `stream-json` I/O) |
| `--resume`, `-r` | Resume session by ID or name, or show interactive picker |
| `--session-id <uuid>` | Use a specific UUID for the session |
| `--setting-sources <list>` | Comma-separated setting sources to load: `user`, `project`, `local` |
| `--settings <path-or-json>` | Path to settings JSON file or inline JSON string |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config`; ignore all others |
| `--system-prompt <text>` | Replace entire default system prompt with custom text |
| `--system-prompt-file <path>` | Replace default system prompt with file contents |
| `--teleport` | Resume a web session in the local terminal |
| `--teammate-mode <mode>` | Agent team display mode: `auto`, `in-process`, `tmux` |
| `--tmux` | Create a tmux session for a worktree (requires `--worktree`) |
| `--tools <list>` | Restrict available built-in tools (`""` for none, `"Bash,Edit,Read"`) |
| `--verbose` | Enable verbose turn-by-turn logging |
| `--version`, `-v` | Output version number |
| `--worktree`, `-w` | Start in isolated git worktree at `<repo>/.claude/worktrees/<name>` |

### System prompt flags

| Flag | Behavior |
|---|---|
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can combine with either replacement flag. Use append flags when Claude should remain a coding assistant; use replacement flags when deploying a different identity in a pipeline.

## Subcommands

| Subcommand | Description |
|---|---|
| `claude auth login` | Sign in. Options: `--email`, `--sso`, `--console` (API billing) |
| `claude auth logout` | Log out |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable); exits 0 if logged in |
| `claude agents [--cwd <path>]` | Open agent view for background sessions |
| `claude attach <id>` | Attach to a background session in this terminal |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON |
| `claude auto-mode config` | Show effective auto mode config (with settings applied) |
| `claude daemon status` | Print background supervisor state and diagnostics |
| `claude install [version]` | Install/reinstall binary (`stable`, `latest`, or specific version) |
| `claude logs <id>` | Print recent output from a background session |
| `claude mcp add [options] <name> [-- <cmd>]` | Add an MCP server |
| `claude mcp add-json <name> '<json>'` | Add an MCP server from JSON config |
| `claude mcp add-from-claude-desktop` | Import servers from Claude Desktop config (macOS and WSL only) |
| `claude mcp get <name>` | Show details for a specific MCP server |
| `claude mcp list` | List all configured MCP servers |
| `claude mcp remove <name>` | Remove an MCP server |
| `claude mcp reset-project-choices` | Reset approval choices for project-scoped MCP servers |
| `claude mcp serve` | Start Claude Code itself as an MCP server (stdio) |
| `claude plugin install <name>` | Install a plugin (alias: `claude plugins`) |
| `claude plugin list` | List installed plugins |
| `claude project purge [path]` | Delete all local Claude Code state for a project |
| `claude remote-control [--name <name>]` | Start a Remote Control server (server mode, no local session) |
| `claude respawn <id>` | Restart a background session with its conversation intact |
| `claude rm <id>` | Remove a background session from the list |
| `claude setup-token` | Generate a long-lived OAuth token for CI (printed, not saved) |
| `claude stop <id>` | Stop a background session (alias: `claude kill`) |
| `claude ultrareview [target]` | Run ultrareview non-interactively; `--json`, `--timeout <minutes>` |
| `claude update` | Update to latest version |

If you mistype a subcommand, Claude Code suggests the closest match and exits.

## Environment variables

Set before launching `claude`, or configure in `settings.json` under the `env` key to apply to every session.

Precedence (highest wins): env var > `settings.local.json` > `settings.json` (project) > `settings.json` (user) > built-in default.

### Authentication

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | API key sent as `X-Api-Key`. Overrides subscription even if logged in. In `-p` mode, always used when present. |
| `ANTHROPIC_AUTH_TOKEN` | Custom `Authorization` header value (prefixed with `Bearer `) |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth access token for Claude.ai auth. Overrides keychain credentials. Generate with `claude setup-token`. |
| `CLAUDE_CODE_OAUTH_REFRESH_TOKEN` | OAuth refresh token. Use with `CLAUDE_CODE_OAUTH_SCOPES` for automated provisioning. |
| `CLAUDE_CODE_OAUTH_SCOPES` | Space-separated OAuth scopes for the refresh token. Required with `CLAUDE_CODE_OAUTH_REFRESH_TOKEN`. |

### Model and API routing

| Variable | Purpose |
|---|---|
| `ANTHROPIC_MODEL` | Override the default model (e.g., `claude-sonnet-4-6`) |
| `ANTHROPIC_BASE_URL` | Override API endpoint to route through a proxy or gateway |
| `ANTHROPIC_BETAS` | Comma-separated additional `anthropic-beta` header values |
| `ANTHROPIC_CUSTOM_HEADERS` | Custom headers (`Name: Value` format, newline-separated) |
| `ANTHROPIC_WORKSPACE_ID` | Workspace ID for workload identity federation |
| `ANTHROPIC_SMALL_FAST_MODEL` | [DEPRECATED] Haiku-class model for background tasks |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Override the pinned Sonnet model |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Override the pinned Opus model |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Override the pinned Haiku model |
| `ANTHROPIC_CUSTOM_MODEL_OPTION` | Model ID to add as a custom entry in the `/model` picker |
| `ANTHROPIC_CUSTOM_MODEL_OPTION_NAME` | Display name for the custom model picker entry |
| `ANTHROPIC_CUSTOM_MODEL_OPTION_DESCRIPTION` | Display description for the custom model picker entry |
| `API_TIMEOUT_MS` | API request timeout in ms (default: 600000; max: 2147483647) |

### Cloud providers

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `ANTHROPIC_BEDROCK_BASE_URL` | Override Bedrock endpoint URL |
| `ANTHROPIC_BEDROCK_SERVICE_TIER` | Bedrock service tier: `default`, `flex`, or `priority` |
| `AWS_BEARER_TOKEN_BEDROCK` | Bedrock API key authentication |
| `CLAUDE_CODE_SKIP_BEDROCK_AUTH` | Skip AWS auth (e.g., when using an LLM gateway) |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `ANTHROPIC_VERTEX_BASE_URL` | Override Vertex AI endpoint URL |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID for Vertex AI |
| `CLAUDE_CODE_SKIP_VERTEX_AUTH` | Skip Google auth (e.g., when using an LLM gateway) |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Full Foundry resource base URL |
| `ANTHROPIC_FOUNDRY_RESOURCE` | Foundry resource name (required if `ANTHROPIC_FOUNDRY_BASE_URL` not set) |
| `ANTHROPIC_FOUNDRY_API_KEY` | Microsoft Foundry API key |
| `CLAUDE_CODE_SKIP_FOUNDRY_AUTH` | Skip Azure auth (e.g., when using an LLM gateway) |
| `CLAUDE_CODE_USE_ANTHROPIC_AWS` | Use Claude Platform on AWS |
| `ANTHROPIC_AWS_API_KEY` | Workspace API key for Claude Platform on AWS |
| `ANTHROPIC_AWS_WORKSPACE_ID` | Required workspace ID for Claude Platform on AWS |
| `ANTHROPIC_AWS_BASE_URL` | Override Claude Platform on AWS endpoint URL |
| `CLAUDE_CODE_SKIP_ANTHROPIC_AWS_AUTH` | Skip client-side auth for Claude Platform on AWS |
| `CLAUDE_CODE_USE_MANTLE` | Use Bedrock Mantle endpoint |
| `ANTHROPIC_BEDROCK_MANTLE_BASE_URL` | Override Bedrock Mantle endpoint URL |
| `CLAUDE_CODE_SKIP_MANTLE_AUTH` | Skip AWS auth for Bedrock Mantle |

### MCP

| Variable | Purpose |
|---|---|
| `MCP_TIMEOUT` | MCP server startup timeout in ms (default: 30000) |
| `MCP_TOOL_TIMEOUT` | MCP tool execution timeout in ms (default: ~28 hours) |
| `MCP_CONNECT_TIMEOUT_MS` | How long blocking MCP startup waits for connection batch (default: 5000) |
| `MCP_CONNECTION_NONBLOCKING` | Set `0` to restore blocking 5-second connection wait at startup |
| `MCP_REMOTE_SERVER_CONNECTION_BATCH_SIZE` | Max HTTP/SSE servers to connect in parallel at startup (default: 20) |
| `MCP_SERVER_CONNECTION_BATCH_SIZE` | Max stdio servers to connect in parallel at startup (default: 3) |
| `MAX_MCP_OUTPUT_TOKENS` | Max tokens in MCP tool responses (default: 25000; warning at 10000) |
| `ENABLE_TOOL_SEARCH` | Control MCP tool search deferral: unset (default defer), `true`, `auto`, `auto:N`, `false` |
| `ENABLE_CLAUDEAI_MCP_SERVERS` | Set `false` to disable claude.ai MCP servers in Claude Code |
| `MCP_CLIENT_SECRET` | OAuth client secret for MCP servers with pre-configured credentials |
| `MCP_OAUTH_CALLBACK_PORT` | Fixed port for OAuth redirect callback (alternative to `--callback-port`) |
| `CLAUDE_CODE_MCP_ALLOWLIST_ENV` | Set `1` to spawn stdio servers with only a safe baseline environment |
| `CLAUDE_AGENT_SDK_MCP_NO_PREFIX` | Set `1` to skip `mcp__<server>__` prefix on SDK-created MCP tools |

### Session and context behavior

| Variable | Purpose |
|---|---|
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location (all settings, credentials, history live here) |
| `CLAUDECODE` | Set to `1` in shell environments Claude Code spawns (not in hooks) |
| `CLAUDE_CODE_SESSION_ID` | Set in Bash/PowerShell subprocesses to the current session ID |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Set `1` to skip writing transcripts and prompt history to disk |
| `CLAUDE_CODE_SHELL` | Override automatic shell detection |
| `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` | Return to original working directory after each Bash/PowerShell command |
| `BASH_DEFAULT_TIMEOUT_MS` | Default timeout for long-running bash commands (default: 120000) |
| `BASH_MAX_TIMEOUT_MS` | Maximum timeout the model can set for bash commands (default: 600000) |
| `BASH_MAX_OUTPUT_LENGTH` | Max characters in bash output before spilling to file |
| `CLAUDE_CODE_MAX_TURNS` | Cap agentic turns (equivalent to `--max-turns`; `--max-turns` takes precedence) |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Percentage (1-100) of context at which auto-compaction triggers (default ~95%) |
| `DISABLE_AUTO_COMPACT` | Set `1` to disable automatic compaction (manual `/compact` still works) |
| `DISABLE_COMPACT` | Set `1` to disable all compaction including manual `/compact` |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | Context capacity in tokens used for compaction calculations |
| `MAX_THINKING_TOKENS` | Override extended thinking token budget (`0` to disable) |
| `CLAUDE_CODE_DISABLE_THINKING` | Set `1` to force-disable extended thinking |
| `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` | Set `1` to disable adaptive reasoning on Opus 4.6/Sonnet 4.6 |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max`, `auto` |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents |
| `CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS` | Stall timeout for background subagents (default: 600000) |
| `TASK_MAX_OUTPUT_LENGTH` | Max characters in subagent output (default: 32000; max: 160000) |

### Prompts and caching

| Variable | Purpose |
|---|---|
| `DISABLE_PROMPT_CACHING` | Set `1` to disable prompt caching for all models |
| `DISABLE_PROMPT_CACHING_SONNET` | Set `1` to disable caching for Sonnet models |
| `DISABLE_PROMPT_CACHING_OPUS` | Set `1` to disable caching for Opus models |
| `DISABLE_PROMPT_CACHING_HAIKU` | Set `1` to disable caching for Haiku models |
| `ENABLE_PROMPT_CACHING_1H` | Set `1` to request 1-hour cache TTL (API/Bedrock/Vertex users) |
| `FORCE_PROMPT_CACHING_5M` | Set `1` to force 5-minute TTL even when 1-hour would otherwise apply |
| `CLAUDE_CODE_ATTRIBUTION_HEADER` | Set `0` to omit attribution block from system prompt (improves cache hits via gateways) |

### Updates and telemetry

| Variable | Purpose |
|---|---|
| `DISABLE_AUTOUPDATER` | Set `1` to disable automatic background updates |
| `DISABLE_UPDATES` | Set `1` to block all updates including manual `claude update` |
| `DISABLE_TELEMETRY` | Set `1` to opt out of telemetry |
| `DO_NOT_TRACK` | Set `1` to opt out of telemetry (standard cross-tool convention) |
| `DISABLE_ERROR_REPORTING` | Set `1` to opt out of Sentry error reporting |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Equivalent to setting `DISABLE_AUTOUPDATER`, `DISABLE_FEEDBACK_COMMAND`, `DISABLE_ERROR_REPORTING`, and `DISABLE_TELEMETRY` |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set `1` to enable OpenTelemetry data collection |

### Networking and TLS

| Variable | Purpose |
|---|---|
| `HTTP_PROXY` | HTTP proxy server |
| `HTTPS_PROXY` | HTTPS proxy server |
| `NO_PROXY` | Domains/IPs to bypass proxy |
| `CLAUDE_CODE_CERT_STORE` | CA certificate sources: `bundled`, `system`, or `bundled,system` (default) |
| `CLAUDE_CODE_CLIENT_CERT` | Path to client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Path to client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted client key |

### OpenTelemetry

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set `1` to enable OTel collection |
| `OTEL_LOG_RAW_API_BODIES` | Set `1` for inline bodies (truncated at 60 KB) or `file:<dir>` for full bodies on disk |
| `OTEL_LOG_TOOL_CONTENT` | Set `1` to include tool input/output in OTel span events |
| `OTEL_LOG_TOOL_DETAILS` | Set `1` to include tool input args and MCP server names in traces |
| `OTEL_LOG_USER_PROMPTS` | Set `1` to include user prompt text in OTel traces |
| `CLAUDE_CODE_OTEL_FLUSH_TIMEOUT_MS` | Timeout for flushing pending OTel spans (default: 5000) |
| `CLAUDE_CODE_OTEL_SHUTDOWN_TIMEOUT_MS` | Timeout for OTel exporter shutdown (default: 2000) |

Standard OTel exporter variables (`OTEL_METRICS_EXPORTER`, `OTEL_LOGS_EXPORTER`, `OTEL_EXPORTER_OTLP_ENDPOINT`, `OTEL_EXPORTER_OTLP_PROTOCOL`, `OTEL_EXPORTER_OTLP_HEADERS`, `OTEL_METRIC_EXPORT_INTERVAL`, `OTEL_RESOURCE_ATTRIBUTES`) are also supported.

### Debug and display

| Variable | Purpose |
|---|---|
| `DEBUG` | Set `1` to enable debug mode (logs to `~/.claude/debug/<session-id>.txt`) |
| `CLAUDE_CODE_DEBUG_LOGS_DIR` | Override debug log file path (requires debug mode enabled separately) |
| `CLAUDE_CODE_DEBUG_LOG_LEVEL` | Minimum log level: `verbose`, `debug` (default), `info`, `warn`, `error` |
| `CLAUDE_CODE_SIMPLE` | Set `1` for minimal system prompt and only Bash/file tools (equivalent to `--bare`) |
| `CLAUDE_CODE_HIDE_CWD` | Set `1` to hide working directory in startup logo |
| `CLAUDE_CODE_DISABLE_TERMINAL_TITLE` | Set `1` to disable automatic terminal title updates |
| `CLAUDE_CODE_ACCESSIBILITY` | Set `1` to keep native terminal cursor visible (for screen magnifiers) |
| `CLAUDE_CODE_NO_FLICKER` | Set `1` to enable fullscreen rendering (reduces flicker in long sessions) |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | Set `1` to use classic main-screen renderer (keeps terminal scrollback) |
| `CLAUDE_CODE_DISABLE_MOUSE` | Set `1` to disable mouse tracking in fullscreen rendering |
| `CLAUDE_CODE_SCROLL_SPEED` | Mouse wheel scroll multiplier in fullscreen (1-20) |
| `IS_DEMO` | Set `1` to hide email/org and skip onboarding (for screenshares) |
| `DISABLE_COST_WARNINGS` | Set `1` to disable cost warning messages |

## Permission modes

Permission modes control how often Claude pauses to ask for approval. Set as default with `--permission-mode <mode>` flag or `permissions.defaultMode` in `settings.json`. Cycle interactively with `Shift+Tab`.

| Mode | What runs without asking | Best for |
|---|---|---|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits in working dir, common filesystem commands (`mkdir`, `touch`, `rm`, `mv`, `cp`, `sed`) | Iterating on code; review via `git diff` after the fact |
| `plan` | Reads only — Claude proposes changes but does not edit files | Exploring a codebase before changing it |
| `auto` | Everything, with background classifier safety checks | Long tasks, reducing prompt fatigue (research preview) |
| `dontAsk` | Only pre-approved tools from `permissions.allow` rules and built-in read-only commands | Locked-down CI and scripts |
| `bypassPermissions` | Everything (only `rm -rf /` and `rm -rf ~` still prompt as circuit breakers) | Isolated containers and VMs only |

**Semantics:**

- **`default`**: Prompts on first use of each tool. "Yes, don't ask again" for Bash saves a permanent per-project rule; for file edits saves until session end.
- **`acceptEdits`**: Auto-approves file edits and common filesystem Bash commands for paths inside `cwd` or `additionalDirectories`. All other Bash still prompts. Protected paths (`.git`, `.claude`, `.mcp.json`, shell config files) always prompt.
- **`plan`**: Claude reads and explores (runs read-only shell commands) but never edits source files. On plan completion, you choose: approve and switch to `auto`, `acceptEdits`, or `default`; or keep planning.
- **`auto`**: A classifier model reviews each action before it runs. Blocks: `curl | bash`, production deploys, mass deletion, IAM changes, force push to main. Allows: local file operations, dependency installs from manifests, read-only HTTP. Falls back to prompting after 3 consecutive or 20 total blocks. Only available on Max, Team, Enterprise, and API plans; Sonnet 4.6, Opus 4.6, or Opus 4.7 on Anthropic API.
- **`dontAsk`**: Auto-denies anything that would prompt, including explicit `ask` rules. Only pre-approved `allow` rules and built-in read-only commands run. Fully non-interactive; suitable for strict CI pipelines.
- **`bypassPermissions`**: Disables the permission layer entirely. Cannot enter this mode from a session started without `--permission-mode bypassPermissions` or `--dangerously-skip-permissions`. Refused when running as root/sudo (except inside recognized sandbox). Administrators can block it with `permissions.disableBypassPermissionsMode: "disable"` in managed settings.

Protected paths that never auto-approve in all modes except `bypassPermissions`: `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `commands/`, `agents/`, `skills/`, `worktrees/`), `.gitconfig`, `.gitmodules`, `.bashrc`, `.zshrc`, `.profile`, `.mcp.json`, `.claude.json`.

## Authentication

| Method | How to use |
|---|---|
| Claude.ai subscription (Max/Pro/Team/Enterprise) | `claude auth login` (browser OAuth flow) |
| OAuth token for CI/automation | `claude setup-token` (generates long-lived token); set as `CLAUDE_CODE_OAUTH_TOKEN` |
| API key (metered) | Set `ANTHROPIC_API_KEY`; takes precedence over subscription even if logged in |
| Refresh token (automated provisioning) | Set `CLAUDE_CODE_OAUTH_REFRESH_TOKEN` and `CLAUDE_CODE_OAUTH_SCOPES` |

In interactive mode, if `ANTHROPIC_API_KEY` is set, Claude Code prompts once to approve using the key instead of the subscription. In `-p` mode, the key is always used when present.

## `~/.claude/` directory layout

`CLAUDE_CONFIG_DIR` overrides the default `~/.claude/` location. On Windows, `~/.claude` resolves to `%USERPROFILE%\.claude`.

### Configuration files (user-authored)

| Path | Purpose | Committed |
|---|---|---|
| `~/.claude.json` | App state: OAuth session, theme, UI toggles, personal MCP servers, per-project trust decisions | No (local only) |
| `~/.claude/settings.json` | Default settings for all projects: permissions, hooks, env vars, model | No (local only) |
| `~/.claude/CLAUDE.md` | Personal instructions loaded into every session in every project | No (local only) |
| `~/.claude/rules/*.md` | User-level rules with optional `paths:` frontmatter for path-gating | No (local only) |
| `~/.claude/skills/<name>/SKILL.md` | Personal reusable prompts available in every project | No (local only) |
| `~/.claude/commands/*.md` | Personal single-file commands available in every project | No (local only) |
| `~/.claude/agents/*.md` | Personal subagent definitions available in every project | No (local only) |
| `~/.claude/agent-memory/` | Persistent memory for subagents with `memory: user` frontmatter | No (local only) |
| `~/.claude/output-styles/*.md` | Custom system-prompt style sections | No (local only) |
| `~/.claude/keybindings.json` | Custom keyboard shortcuts (hot-reloaded) | No (local only) |
| `~/.claude/themes/*.json` | Custom color themes (hot-reloaded) | No (local only) |

### Project-level config files (at project root or in `.claude/`)

| Path | Purpose | Committed |
|---|---|---|
| `CLAUDE.md` (or `.claude/CLAUDE.md`) | Project instructions loaded every session | Yes |
| `.mcp.json` | Team-shared MCP server configurations | Yes |
| `.worktreeinclude` | Gitignored files to copy into new worktrees | Yes |
| `.claude/settings.json` | Project permissions, hooks, env vars, model defaults | Yes |
| `.claude/settings.local.json` | Personal project overrides (auto-gitignored) | No |
| `.claude/rules/*.md` | Topic-scoped instructions with optional `paths:` gating | Yes |
| `.claude/skills/<name>/SKILL.md` | Project-scoped reusable prompts | Yes |
| `.claude/commands/*.md` | Project-scoped single-file commands | Yes |
| `.claude/agents/*.md` | Project subagent definitions | Yes |
| `.claude/agent-memory/<name>/MEMORY.md` | Project-scoped subagent persistent memory | Yes |
| `.claude/output-styles/*.md` | Project-scoped output style sections | Yes |
| `CLAUDE.local.md` | Private personal project instructions (add to `.gitignore` manually) | No |

### Application data written by Claude Code (under `~/.claude/`)

Cleaned up after `cleanupPeriodDays` (default 30 days):

| Path | Contents |
|---|---|
| `projects/<project>/<session>.jsonl` | Full conversation transcript (messages, tool calls, tool results) |
| `projects/<project>/<session>/subagents/` | Subagent conversation transcripts |
| `projects/<project>/<session>/tool-results/` | Large tool outputs spilled to separate files |
| `projects/<project>/memory/MEMORY.md` | Auto memory index file (Claude writes/maintains) |
| `projects/<project>/memory/*.md` | Auto memory topic files (Claude writes/maintains) |
| `file-history/<session>/` | Pre-edit file snapshots for checkpoint restore (`/rewind`) |
| `plans/` | Plan files written during plan mode |
| `debug/` | Per-session debug logs (only when `--debug` or `/debug` is active) |
| `paste-cache/`, `image-cache/` | Large paste and attached image contents |
| `session-env/` | Per-session environment metadata |
| `tasks/` | Per-session task lists |
| `shell-snapshots/` | Captured shell environments for the Bash tool |
| `backups/` | Timestamped copies of `~/.claude.json` before config migrations |
| `feedback-bundles/` | Redacted transcripts for `/feedback` on third-party providers |

Kept until manually deleted:

| Path | Contents |
|---|---|
| `history.jsonl` | Every prompt typed with timestamp and project path (up-arrow recall) |
| `stats-cache.json` | Aggregated token and cost counts for `/usage` |
| `remote-settings.json` | Cached server-managed settings for the organization |
| `plugins/` | Installed plugin versions and marketplace caches |
| `todos/` | Legacy task lists (not written by current versions; safe to delete) |

**Do not delete** `~/.claude.json`, `~/.claude/settings.json`, or `~/.claude/plugins/` — these hold auth, preferences, and installed plugins.

To purge all state for a single project: `claude project purge ~/work/my-repo` (supports `--dry-run`, `--yes`, `--all`, `-i`).

## IDE integrations

| IDE | How to connect |
|---|---|
| VS Code | Install the Claude Code extension; Claude Code auto-connects when launched in the integrated terminal. Set `CLAUDE_CODE_AUTO_CONNECT_IDE=false` to disable. |
| JetBrains | Plugin runs Claude Code in IDE terminal; same CLI modes/flags apply. |
| Web (claude.ai/code) | `claude --remote "<task>"` creates a web session; `claude --teleport` brings a web session to local terminal. |
| Remote Control | `claude --remote-control` or `claude remote-control --name "My Project"` for control from claude.ai or the Claude app. |

Auto-installation of extensions can be disabled with `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL=1` or the `autoInstallIdeExtension: false` setting.

## Cost and quota

- **Subscription (Max/Pro/Team/Enterprise)**: usage counted against your plan's included usage. Rate limits apply per plan tier.
- **API key (metered)**: billed per token. `--max-budget-usd <n>` (print mode only) limits spend per invocation.
- Background tasks and subagents use the same model and billing as the main session unless `CLAUDE_CODE_SUBAGENT_MODEL` is set.
- Token and cost totals visible in-session with `/usage`. Aggregated history in `~/.claude/stats-cache.json`.
- Set `DISABLE_COST_WARNINGS=1` to suppress cost warning messages.

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `env-vars.md`, `permissions.md`, `permission-modes.md`, `claude-directory.md`.*
