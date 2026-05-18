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

## Top-level invocation

| Command | Description | Example |
|---|---|---|
| `claude` | Start interactive session | `claude` |
| `claude "query"` | Start with initial prompt | `claude "explain this project"` |
| `claude -p "query"` | Query via SDK, then exit | `claude -p "explain this function"` |
| `cat file \| claude -p "query"` | Process piped content | `cat logs.txt \| claude -p "summarize"` |
| `claude --continue` | Resume most recent session | `claude -c` |
| `claude --resume <id>` | Resume a specific session by ID | |
| `claude --version` | Show version and exit | |

Source: `code.claude.com/docs/en/cli-reference.md`

## Key CLI flags

`claude --help` does not list every flag; a flag's absence from `--help` does not mean it is unavailable.

| Flag | Description |
|---|---|
| `--add-dir <path>` | Add additional working directories (grants file access; most `.claude/` config not discovered from these dirs) |
| `--agent <name>` | Run the session as a named subagent |
| `--agents '<json>'` | Define custom subagents dynamically via JSON |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to the `Shift+Tab` cycle without activating it |
| `--allowedTools <tools>` | Tools that run without prompting (e.g. `"Bash(git log *)" "Read"`) |
| `--append-system-prompt <text>` | Append text to the default system prompt |
| `--bare` | Minimal mode: skip hooks, skills, plugins, MCP, auto-memory, CLAUDE.md. Sets `CLAUDE_CODE_SIMPLE`. |
| `--bg` | Start as a background agent; prints session ID and returns immediately |
| `--channels <plugins>` | MCP channel plugins to listen for (research preview) |
| `--chrome` | Enable Chrome browser integration |
| `--continue`, `-c` | Load most recent conversation in the current directory |
| `--dangerously-skip-permissions` | Equivalent to `--permission-mode bypassPermissions` |
| `--debug` | Enable debug output |
| `--debug-file <path>` | Write debug logs to file |
| `--disable-slash-commands` | Disable all slash command discovery |
| `--disallowedTools <tools>` | Tools that are blocked |
| `--effort <level>` | Set effort level (`low`/`medium`/`high`/`xhigh`) |
| `--enable-auto-mode` | Enable auto mode for the session |
| `--fork-session` | Fork the current session into a new one |
| `--from-pr <url>` | Start session from a PR URL |
| `--ide <name>` | Connect to a specific IDE extension |
| `--init` | Initialize CLAUDE.md via interactive flow |
| `--json-schema <file>` | Enforce structured JSON output matching a schema |
| `--maintenance` | Run maintenance operations |
| `--max-budget-usd <N>` | Cap spend for the session in USD |
| `--max-turns <N>` | Cap agentic turns |
| `--mcp-config <file>` | Load additional `.mcp.json` file |
| `--model <name>` | Override model (e.g. `claude-opus-4-7`) |
| `--name <name>` | Name this session |
| `--no-session-persistence` | Don't save session to disk |
| `--output-format <fmt>` | Output format for `-p` mode: `text` / `json` / `stream-json` |
| `--permission-mode <mode>` | Set permission mode: `default`/`acceptEdits`/`plan`/`auto`/`dontAsk`/`bypassPermissions` |
| `--plugin-dir <path-or-zip>` | Load a plugin from a directory or `.zip` archive (v2.1.128+) |
| `--plugin-url <url>` | Fetch and load a plugin archive from a URL for this session (v2.1.128+) |
| `--print`, `-p` | Non-interactive / SDK mode |
| `--remote` | Connect to a remote cloud session |
| `--remote-control` | Start in Remote Control host mode |
| `--resume <id>` | Resume a session by ID |
| `--session-id <id>` | Set a specific session ID |
| `--settings <file>` | Load extra settings file |
| `--strict-mcp-config` | Disallow MCP servers not in the config file |
| `--system-prompt <text>` | Replace the default system prompt |
| `--system-prompt-file <file>` | Load system prompt from file |
| `--tools <tools>` | Restrict which tools are available |
| `--verbose` | Verbose output |
| `--worktree` | Run in an isolated git worktree |

Source: `code.claude.com/docs/en/cli-reference.md`

## Environment variables

### Authentication

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Metered API authentication |
| `ANTHROPIC_AUTH_TOKEN` | Alternative API authentication token |
| `CLAUDE_CODE_OAUTH_TOKEN` | OAuth access token for Claude.ai (subscription) |
| `CLAUDE_CODE_OAUTH_REFRESH_TOKEN` | OAuth refresh token for Claude.ai |
| `ANTHROPIC_BASE_URL` | Override API base URL (for LLM gateways) |
| `ANTHROPIC_WORKSPACE_ID` | Anthropic workspace ID |

### Model and behavior

| Variable | Purpose |
|---|---|
| `ANTHROPIC_MODEL` | Override default model (e.g. `claude-opus-4-7`) |
| `ANTHROPIC_SMALL_FAST_MODEL` | Override the small/fast model used internally |
| `CLAUDE_CODE_EFFORT_LEVEL` | Set effort level: `low`/`medium`/`high`/`xhigh` |
| `CLAUDE_EFFORT` | Read-only: set in Bash subprocess and hooks to the active effort level (v2.1.128+) |
| `CLAUDE_CODE_MAX_CONTEXT_TOKENS` | Override assumed context window size |
| `CLAUDE_CODE_MAX_OUTPUT_TOKENS` | Cap output tokens per request |
| `CLAUDE_CODE_MAX_TURNS` | Cap agentic turns (equivalent to `--max-turns`) |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Model for subagents (see model-config docs) |
| `CLAUDE_CODE_DISABLE_1M_CONTEXT` | `1` = disable 1M context window |
| `CLAUDE_CODE_DISABLE_THINKING` | `1` = force-disable extended thinking |
| `CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING` | `1` = disable adaptive reasoning |

### UI and rendering

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | `1` = disable fullscreen alternate-screen renderer, use terminal scrollback (v2.1.128+) |
| `CLAUDE_CODE_ACCESSIBILITY` | `1` = keep native terminal cursor, disable TUI overlay |
| `CLAUDE_CODE_NO_FLICKER` | `1` = enable fullscreen rendering (research preview) |
| `CLAUDE_CODE_NATIVE_CURSOR` | `1` = show terminal's own cursor at input caret |
| `CLAUDE_CODE_DISABLE_MOUSE` | `1` = disable mouse tracking |
| `CLAUDE_CODE_DISABLE_TERMINAL_TITLE` | `1` = disable automatic terminal title updates |
| `CLAUDE_CODE_TMUX_TRUECOLOR` | `1` = allow 24-bit truecolor inside tmux |
| `CLAUDE_CODE_FORCE_SYNC_OUTPUT` | `1` = force synchronized output mode |
| `CLAUDE_CODE_SCROLL_SPEED` | Mouse wheel scroll multiplier in fullscreen mode |

### Configuration and paths

| Variable | Purpose |
|---|---|
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location (default: `~/.claude`) |
| `CLAUDE_CODE_DEBUG_LOGS_DIR` | Override debug log file path |
| `CLAUDE_CODE_DEBUG_LOG_LEVEL` | Min log level for debug file: `verbose`/`debug`/`info`/`warn`/`error` |
| `CLAUDE_CODE_PLUGIN_CACHE_DIR` | Override plugins root directory |
| `CLAUDE_CODE_PLUGIN_SEED_DIR` | Path to read-only plugin seed directories (`:` separated) |
| `CLAUDE_CODE_TMPDIR` | Override temp directory |
| `EDITOR` | External editor for in-line edits |

### Network and security

| Variable | Purpose |
|---|---|
| `ANTHROPIC_CUSTOM_HEADERS` | Extra headers added to every API request |
| `CLAUDE_CODE_CERT_STORE` | Comma-separated CA certificate sources for TLS |
| `CLAUDE_CODE_CLIENT_CERT` | Path to client certificate for mTLS |
| `CLAUDE_CODE_CLIENT_KEY` | Path to client private key for mTLS |
| `CLAUDE_CODE_CLIENT_KEY_PASSPHRASE` | Passphrase for encrypted `CLAUDE_CODE_CLIENT_KEY` |
| `CLAUDE_CODE_EXTRA_BODY` | JSON object merged into every API request body |

### Cloud provider auth

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_USE_BEDROCK` | Use Amazon Bedrock |
| `ANTHROPIC_BEDROCK_BASE_URL` | Bedrock endpoint override |
| `CLAUDE_CODE_USE_VERTEX` | Use Google Vertex AI |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project for Vertex |
| `ANTHROPIC_VERTEX_BASE_URL` | Vertex endpoint override |
| `CLAUDE_CODE_USE_FOUNDRY` | Use Microsoft Foundry |
| `ANTHROPIC_FOUNDRY_BASE_URL` | Foundry endpoint override |
| `CLAUDE_CODE_USE_ANTHROPIC_AWS` | Use Claude Platform on AWS |

### Session and process

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_SESSION_ID` | Read-only: set in Bash/PowerShell subprocess and hook commands to the current session ID (v2.1.128+) |
| `CLAUDE_CODE_SIMPLE` | `1` = minimal system prompt + only Bash, Read, Edit tools (set by `--bare`) |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | `1` = don't write prompt history or transcripts to disk |
| `CLAUDE_CODE_NO_SESSION_PERSISTENCE` | Skip session persistence for the run |
| `CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR` | Return to original working dir after each Bash call |
| `CLAUDE_ENV_FILE` | Path to shell script run before each Bash tool invocation |
| `CLAUDE_CODE_SHELL` | Override automatic shell detection |
| `CLAUDE_CODE_SHELL_PREFIX` | Command prefix wrapping shell commands |
| `CLAUDE_CODE_GIT_BASH_PATH` | Windows only: path to Git Bash `bash.exe` |

### Package manager updates

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` | `1` = let Homebrew/WinGet run upgrade in background and prompt to restart (v2.1.128+) |

### OTEL / observability

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | `1` = enable OpenTelemetry collection |
| `CLAUDE_CODE_OTEL_FLUSH_TIMEOUT_MS` | Timeout for flushing pending OTEL spans |
| `CLAUDE_CODE_OTEL_SHUTDOWN_TIMEOUT_MS` | Timeout for OTEL exporter shutdown |

> **Note (v2.1.128+):** Subprocesses (Bash, hooks, MCP, LSP) no longer inherit `OTEL_*` env vars — OTEL-instrumented apps run via Bash tool no longer pick up the CLI's own OTLP endpoint.

Precedence (highest wins): env var > `settings.local.json` > `settings.json` (project) > `settings.json` (user) > built-in default.

Source: `code.claude.com/docs/en/env-vars.md`

## Permission modes

Six permission modes control how often Claude pauses for approval. Switch with `Shift+Tab` (CLI) or the mode selector (VS Code / Desktop / Web).

| Mode | What runs without asking | Best for |
|---|---|---|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `rm`, `rmdir`, `sed`) | Iterating on code you're reviewing |
| `plan` | Reads only (but Claude won't edit) | Exploring a codebase before changing it |
| `auto` | Everything, with background safety checks from a classifier | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools (from `permissions.allow`); explicit `ask` rules are denied | Locked-down CI and scripts |
| `bypassPermissions` | Everything (including protected paths as of v2.1.126) | Isolated containers and VMs **only** |

### Switching modes

```bash
# At startup
claude --permission-mode acceptEdits

# As a project default (settings.json)
{ "permissions": { "defaultMode": "acceptEdits" } }
```

CLI cycle with `Shift+Tab`: `default` → `acceptEdits` → `plan`. `auto` and `bypassPermissions` require opt-in before appearing in the cycle.

### Auto mode

Auto mode requires v2.1.83+, and Claude Sonnet 4.6 / Opus 4.6 / Opus 4.7 on Anthropic API only (not Bedrock/Vertex/Foundry). Available on Max, Team, Enterprise, API plans — **not Pro**.

A classifier model checks actions before they run. **Blocked by default:** `curl | bash`, sending sensitive data externally, production deploys, mass cloud storage deletion, IAM changes, force-push to `main`. **Allowed by default:** local file ops in working directory, installing locked dependencies, read-only HTTP, pushing to the current branch.

**Hard deny rules** (v2.1.128+): `settings.autoMode.hard_deny` rules block matching actions unconditionally, even when broader allow rules would permit them.

### bypassPermissions mode

As of v2.1.126, writes to protected paths are also bypassed. Claude Code refuses to start in this mode as root/sudo on Linux/macOS. Admins can block it via `permissions.disableBypassPermissionsMode: "disable"` in managed settings.

### Protected paths (never auto-approved except in bypassPermissions)

**Directories:** `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`)

**Files:** `.gitconfig`, `.gitmodules`, `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`, `.ripgreprc`, `.mcp.json`, `.claude.json`

Source: `code.claude.com/docs/en/permission-modes.md`

## Authentication

| Method | Variable / flag | Plans |
|---|---|---|
| Claude.ai subscription (OAuth) | `CLAUDE_CODE_OAUTH_TOKEN` / `claude auth login` | Pro, Max, Team, Enterprise |
| Anthropic API key | `ANTHROPIC_API_KEY` | API plans |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS auth | Enterprise |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP auth | Enterprise |
| Microsoft Foundry | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure auth | Enterprise |

## `~/.claude/` directory layout

```
~/.claude/
  settings.json        ← user-scope settings
  CLAUDE.md            ← user-scope memory / instructions
  commands/            ← user-scope slash commands
  agents/              ← user-scope subagent definitions
  skills/              ← user-scope skills
  plugins/             ← installed plugin directories
  projects/            ← session transcripts and state
  statsig/             ← feature-flag cache
  todos/               ← persistent todo storage
  worktrees/           ← isolated worktree sessions
```

Project-level config lives at `<project>/.claude/`:

```
<project>/.claude/
  settings.json        ← project-scope settings (tracked in git)
  settings.local.json  ← local overrides (gitignored)
  CLAUDE.md            ← project memory / instructions
  commands/            ← project slash commands
  agents/              ← project subagent definitions
  skills/              ← project skills
  hooks/               ← project hooks (also declarable in settings.json)
```

Source: `code.claude.com/docs/en/claude-directory.md`

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `env-vars.md`, `permission-modes.md`, `permissions.md`.*
