---
name: claude-code-cli
description: |
  Deep reference for Claude Code's CLI surface: command-line commands,
  flags, environment variables (ANTHROPIC_* / CLAUDE_*), permission
  modes (default / acceptEdits / plan / auto / dontAsk /
  bypassPermissions), the ~/.claude/ directory layout, IDE integration
  entry points, and authentication mechanisms. Read this file when the
  user asks about CLI invocation, env vars, permission modes,
  ~/.claude/ structure, or how Claude Code authenticates.
source: https://code.claude.com/docs/en/cli-reference.md
---

# Claude Code — CLI, environment, and layout

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for CLI / env / layout questions.*

## CLI commands

| Command | Description | Example |
|---|---|---|
| `claude` | Start interactive session | `claude` |
| `claude "query"` | Start interactive session with initial prompt | `claude "explain this project"` |
| `claude -p "query"` | Query via SDK, then exit | `claude -p "explain this function"` |
| `cat file \| claude -p "query"` | Process piped content | `cat logs.txt \| claude -p "explain"` |
| `claude -c` | Continue most recent conversation in current directory | `claude -c` |
| `claude -c -p "query"` | Continue via SDK | `claude -c -p "Check for type errors"` |
| `claude -r "<session>" "query"` | Resume session by ID or name | `claude -r "auth-refactor" "Finish this PR"` |
| `claude update` | Update to latest version | `claude update` |
| `claude install [version]` | Install/reinstall native binary. Accepts version like `2.1.118`, or `stable`/`latest` | `claude install stable` |
| `claude auth login` | Sign in. Flags: `--email`, `--sso`, `--console` | `claude auth login --console` |
| `claude auth logout` | Log out | `claude auth logout` |
| `claude auth status` | Show auth status as JSON (`--text` for human-readable); exits 0 if logged in, 1 if not | `claude auth status` |
| `claude agents` | Open agent view (research preview). Flags: `--cwd`, `--add-dir`, `--settings`, `--mcp-config`, `--plugin-dir`, `--permission-mode`, `--model`, `--effort`, `--dangerously-skip-permissions`. `--cwd <path>` scopes the session list to a directory. `--json` prints live sessions as JSON for scripting (tmux-resurrect, status bars, session pickers). | `claude agents --cwd ~/projects/my-app` |
| `claude attach <id>` | Attach to a background session | `claude attach 7c5dcf5d` |
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON | `claude auto-mode defaults > rules.json` |
| `claude daemon status` | Print background-session supervisor state | `claude daemon status` |
| `claude logs <id>` | Print recent output from a background session | `claude logs 7c5dcf5d` |
| `claude mcp` | Configure MCP servers. See [`SKILL-mcp.md`](SKILL-mcp.md) | `claude mcp add ...` |
| `claude plugin` | Manage plugins. Alias: `claude plugins`. See [`SKILL-plugins.md`](SKILL-plugins.md) | `claude plugin install code-review@claude-plugins-official` |
| `claude project purge [path]` | Delete all local state for a project. Flags: `--dry-run`, `-y`/`--yes`, `-i`/`--interactive`, `--all` | `claude project purge ~/work/repo --dry-run` |
| `claude remote-control` | Start Remote Control server (server mode, no local session) | `claude remote-control --name "My Project"` |
| `claude respawn <id>` | Restart a background session with conversation intact. `--all` restarts every running session | `claude respawn 7c5dcf5d` |
| `claude rm <id>` | Remove a background session from the list | `claude rm 7c5dcf5d` |
| `claude setup-token` | Generate long-lived OAuth token for CI/scripts. Requires Claude subscription | `claude setup-token` |
| `claude stop <id>` | Stop a background session. Also: `claude kill` | `claude stop 7c5dcf5d` |
| `claude ultrareview [target]` | Run ultrareview non-interactively. `--json` for raw payload; `--timeout <minutes>` (default 30) | `claude ultrareview 1234 --json` |

Source: `code.claude.com/docs/en/cli-reference.md`.

## CLI flags

`claude --help` does not list every flag; a flag's absence doesn't mean it's unavailable.

| Flag | Description | Example |
|---|---|---|
| `--add-dir` | Add additional working directories (file access only, not `.claude/` config discovery) | `claude --add-dir ../apps ../lib` |
| `--agent` | Specify a named subagent for the current session | `claude --agent my-custom-agent` |
| `--agents` | Define custom subagents via JSON | `claude --agents '{"reviewer":{"description":"...","prompt":"..."}}' ` |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to `Shift+Tab` cycle without starting in it | |
| `--allowedTools` | Tools that execute without prompting | `"Bash(git log *)" "Read"` |
| `--append-system-prompt` | Append text to the end of the default system prompt | `claude --append-system-prompt "Always use TypeScript"` |
| `--append-system-prompt-file` | Load additional system prompt text from file and append | `claude --append-system-prompt-file ./extra-rules.txt` |
| `--bare` | Skip auto-discovery of hooks, skills, plugins, MCP, auto memory, CLAUDE.md. Sets `CLAUDE_CODE_SIMPLE` | `claude --bare -p "query"` |
| `--betas` | Beta headers for API requests (API key users only) | `claude --betas interleaved-thinking` |
| `--bg` | Start as background agent and return immediately | `claude --bg "investigate the flaky test"` |
| `--channels` | MCP servers whose channel notifications Claude listens for | `claude --channels plugin:my-notifier@my-marketplace` |
| `--chrome` | Enable Chrome browser integration | `claude --chrome` |
| `--continue`, `-c` | Load the most recent conversation in the current directory | `claude --continue` |
| `--dangerously-load-development-channels` | Enable channels not on the approved allowlist for local development. Accepts `plugin:<name>@<marketplace>` and `server:<name>` entries. Prompts for confirmation | `claude --dangerously-load-development-channels server:webhook` |
| `--dangerously-skip-permissions` | Skip permission prompts (= `--permission-mode bypassPermissions`) | `claude --dangerously-skip-permissions` |
| `--debug` | Enable debug mode with optional category filtering | `claude --debug "api,mcp"` |
| `--debug-file <path>` | Write debug logs to file. Implicitly enables debug mode | `claude --debug-file /tmp/claude-debug.log` |
| `--disable-slash-commands` | Disable all skills and commands for this session | |
| `--disallowedTools` | Tools removed from model context entirely | `"Bash(git log *)" "Edit"` |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` | `claude --effort high` |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections to first user message (improves prompt-cache reuse in `-p` scripts) | |
| `--fallback-model` | Auto-fallback model when default is overloaded (print mode + background sessions) | `claude -p --fallback-model sonnet "query"` |
| `--fork-session` | Create new session ID instead of reusing original (use with `--resume`/`--continue`) | |
| `--from-pr` | Resume sessions linked to a PR. Accepts PR number, GitHub/GitLab/Bitbucket URL | `claude --from-pr 123` |
| `--ide` | Auto-connect to IDE on startup if exactly one valid IDE is available | |
| `--init` | Run Setup hooks with `init` matcher before session (print mode only) | `claude -p --init "query"` |
| `--init-only` | Run Setup and SessionStart hooks, then exit | `claude --init-only` |
| `--include-hook-events` | Include hook lifecycle events in output stream. Requires `--output-format stream-json` | |
| `--include-partial-messages` | Include partial streaming events. Requires `-p` + `--output-format stream-json` | |
| `--input-format` | Input format for print mode: `text`, `stream-json` | `claude -p --input-format stream-json` |
| `--json-schema` | Get validated JSON matching a JSON Schema after agent completes (print mode only) | `claude -p --json-schema '{"type":"object"}' "query"` |
| `--maintenance` | Run Setup hooks with `maintenance` matcher before session (print mode only) | `claude -p --maintenance "query"` |
| `--max-budget-usd` | Maximum dollar amount on API calls before stopping (print mode only) | `claude -p --max-budget-usd 5.00 "query"` |
| `--max-turns` | Limit agentic turns (print mode only). No limit by default | `claude -p --max-turns 3 "query"` |
| `--mcp-config` | Load MCP servers from JSON files or strings | `claude --mcp-config ./mcp.json` |
| `--model` | Set model for current session. Overrides `model` setting and `ANTHROPIC_MODEL` | `claude --model claude-sonnet-4-6` |
| `--name`, `-n` | Set session display name | `claude -n "my-feature-work"` |
| `--no-chrome` | Disable Chrome browser integration | |
| `--no-session-persistence` | Disable session persistence (print mode only) | `claude -p --no-session-persistence "query"` |
| `--output-format` | Output format for print mode: `text`, `json`, `stream-json` | `claude -p "query" --output-format json` |
| `--permission-mode` | Start in a permission mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions` | `claude --permission-mode plan` |
| `--permission-prompt-tool` | MCP tool to handle permission prompts in non-interactive mode | `claude -p --permission-prompt-tool mcp_auth_tool "query"` |
| `--plugin-dir` | Load plugin from directory or `.zip` archive for this session only. Repeat for multiple | `claude --plugin-dir ./my-plugin` |
| `--plugin-url` | Fetch plugin `.zip` from URL for this session only. Repeat or space-separated | `claude --plugin-url https://example.com/plugin.zip` |
| `--print`, `-p` | Print response without interactive mode | `claude -p "query"` |
| `--remote` | Create a new web session on claude.ai with provided task | `claude --remote "Fix the login bug"` |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled | `claude --remote-control "My Project"` |
| `--remote-control-session-name-prefix <prefix>` | Prefix for auto-generated Remote Control session names when no explicit name is set (defaults to machine hostname). Same effect as `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` | `claude remote-control --remote-control-session-name-prefix dev-box` |
| `--replay-user-messages` | Re-emit user messages from stdin back on stdout. Requires `--input-format stream-json` and `--output-format stream-json` | |
| `--resume`, `-r` | Resume session by ID or name, or show interactive picker | `claude --resume auth-refactor` |
| `--session-id` | Use a specific session UUID | `claude --session-id "550e8400-..."` |
| `--setting-sources` | Comma-separated setting sources to load: `user`, `project`, `local` | `claude --setting-sources user,project` |
| `--settings` | Path to settings JSON file or inline JSON string | `claude --settings ./settings.json` |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config`, ignore all other MCP | |
| `--system-prompt` | Replace entire system prompt with custom text | `claude --system-prompt "You are a Python expert"` |
| `--system-prompt-file` | Load system prompt from file, replacing default | `claude --system-prompt-file ./custom-prompt.txt` |
| `--teleport` | Resume a web session in local terminal | `claude --teleport` |
| `--teammate-mode` | Agent team display: `auto`, `in-process`, or `tmux` | `claude --teammate-mode in-process` |
| `--tmux` | Create tmux session for the worktree. Requires `--worktree` | `claude -w feature-auth --tmux` |
| `--tools` | Restrict built-in tools: `""` (disable all), `"default"` (all), or tool names | `claude --tools "Bash,Edit,Read"` |
| `--verbose` | Enable verbose logging; overrides `viewMode` setting | |
| `--version`, `-v` | Output the version number | `claude -v` |
| `--worktree`, `-w` | Start in isolated git worktree. Pass `#<number>` or PR URL to fetch that PR | `claude -w feature-auth` |

### System prompt flags

| Flag | Behavior |
|---|---|
| `--system-prompt` | Replaces the entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to the default prompt |
| `--append-system-prompt-file` | Appends file contents to the default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. The append flags can be combined with either replacement flag.

## Environment variables

Environment variables can also be set in `settings.json` under `env`. See `code.claude.com/docs/en/env-vars.md` for the full list.

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Metered API authentication |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max / Pro) authentication via OAuth |
| `ANTHROPIC_MODEL` | Override default model (e.g. `claude-opus-4-7`) |
| `ANTHROPIC_BASE_URL` | Override API base URL (for LLM gateways, proxies) |
| `EDITOR` | Editor invoked for external editing (`code --wait`, `vim`, etc.) |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Enable OpenTelemetry (`"1"`) |
| `DISABLE_AUTOUPDATER` | Disable auto-updates (`"1"`) |
| `CLAUDE_CODE_SIMPLE` | Set by `--bare` flag; skips auto-discovery |
| `MCP_TIMEOUT` | MCP server startup timeout (milliseconds) |
| `MAX_MCP_OUTPUT_TOKENS` | Override MCP tool output size limit (default: 10,000) |
| `CLAUDE_CODE_EFFORT_LEVEL` | Override effort level for one session |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Disable session persistence in any mode |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Refresh interval for `apiKeyHelper` script |
| `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS` | Refresh interval for `otelHeadersHelper` script |
| `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` | Prefix for Remote Control auto-generated session names |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen renderer |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | Enable PowerShell tool |
| `CLAUDE_CODE_DISABLE_THINKING` | Force extended thinking off |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | Enable session recap on return |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Suppress session quality survey |
| `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` | Skip IDE extension auto-install |
| `CLAUDE_CODE_AUTO_CONNECT_IDE` | Auto-connect to IDE on startup |
| `ENABLE_TOOL_SEARCH` | Set to `false` to disable MCP tool search |
| `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` | Set to `1` to pin `/fast` mode to Opus 4.6 instead of the default Opus 4.7 |

### Prompt caching environment variables

Source: `code.claude.com/docs/en/prompt-caching.md`.

| Variable | Effect |
|---|---|
| `ENABLE_PROMPT_CACHING_1H` | Set to `1` to opt into the one-hour cache TTL (API key / Bedrock / Vertex / Foundry). Subscription users get this automatically. |
| `FORCE_PROMPT_CACHING_5M` | Set to `1` to force the five-minute TTL regardless of auth method. Useful for debugging or overriding an `ENABLE_PROMPT_CACHING_1H` set in managed settings. |
| `DISABLE_PROMPT_CACHING` | Set to `1` to disable prompt caching for all models. |
| `DISABLE_PROMPT_CACHING_HAIKU` | Set to `1` to disable prompt caching for Haiku only. |
| `DISABLE_PROMPT_CACHING_SONNET` | Set to `1` to disable prompt caching for Sonnet only. |
| `DISABLE_PROMPT_CACHING_OPUS` | Set to `1` to disable prompt caching for Opus only. |

Cache invalidation triggers (cause one slow uncached turn): switching models, connecting/disconnecting an MCP server, running `/compact`, upgrading Claude Code. Actions that keep the cache: editing files, changing output style mid-session, invoking skills/commands, `/recap`, `/rewind`. See `code.claude.com/docs/en/prompt-caching.md` for the full reference.

Precedence (highest wins): CLI flags > `settings.local.json` > `settings.json` (project) > `settings.json` (user) > built-in default.

## Permission modes

| Mode | What runs without asking | `Shift+Tab` cycle |
|---|---|---|
| `default` | Reads only | Yes (default position) |
| `acceptEdits` | Reads, file edits, common filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `sed`, etc.) | Yes |
| `plan` | Reads only; Claude proposes but doesn't edit | Yes |
| `auto` | Everything, with background classifier checks | Optional (requires requirements) |
| `dontAsk` | Only pre-approved tools from `permissions.allow` | Never in cycle; `--permission-mode dontAsk` only |
| `bypassPermissions` | Everything (no safety checks). **Isolated containers/VMs only** | Optional (requires enabling flag) |

**Auto mode requirements:** Claude Code v2.1.83+, Max/Team/Enterprise/API plan (not Pro), Anthropic API only (not Bedrock/Vertex/Foundry), and an eligible model. Model availability depends on plan: Team/Enterprise/API allow Sonnet 4.6, Opus 4.6, or Opus 4.7; Max allows Opus 4.7 only (Haiku and claude-3 models are not supported on any plan). Team/Enterprise require an admin to enable it in Claude Code admin settings.

Source: `code.claude.com/docs/en/permission-modes.md`.

**`defaultMode: "auto"` is ignored in `.claude/settings.json` and `.claude/settings.local.json`** — a repository cannot grant itself auto mode. Use `~/.claude/settings.json` instead.

`bypassPermissions` requires starting with `--dangerously-skip-permissions`, `--permission-mode bypassPermissions`, or `--allow-dangerously-skip-permissions`. Cannot enter it mid-session without these flags. Refused when running as root/sudo (skipped inside recognized sandbox).

**Protected paths** (never auto-approved in any mode except `bypassPermissions`): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `/commands`, `/agents`, `/skills`, `/worktrees`), plus files like `.gitconfig`, `.mcp.json`, `.bashrc`, `.zshrc`, etc.

Set mode at startup: `claude --permission-mode plan`
Set as default: `{ "permissions": { "defaultMode": "acceptEdits" } }` in `settings.json`
Switch during session: `Shift+Tab`

Source: `code.claude.com/docs/en/permission-modes.md`.

## Authentication

Two authentication methods:

| Method | Credential | Use case |
|---|---|---|
| OAuth (subscription) | `CLAUDE_CODE_OAUTH_TOKEN` | Claude Max / Pro subscription |
| API key (metered) | `ANTHROPIC_API_KEY` | Console API usage billing |

`claude auth login --console` for API billing. `claude setup-token` generates a long-lived OAuth token for CI/scripts.

Third-party providers (Bedrock, Vertex AI, Foundry, Microsoft Foundry) use provider-specific credentials instead.

> **Note:** Remote Control, `/schedule`, Claude.ai MCP connectors, and notification preferences are disabled when `ANTHROPIC_API_KEY`, `apiKeyHelper`, or `ANTHROPIC_AUTH_TOKEN` is set — even if a Claude.ai login is also present. Unset the API key to use these features.

## `~/.claude/` directory layout

| Path | Contents |
|---|---|
| `~/.claude/settings.json` | User-scope settings |
| `~/.claude/agents/` | User-scope custom subagents |
| `~/.claude/commands/` | User-scope slash commands |
| `~/.claude/skills/` | User-scope skills |
| `~/.claude/plans/` | Plan files (configurable via `plansDirectory`) |
| `~/.claude.json` | OAuth session, per-project MCP servers, user-scope MCP servers, per-project state (allowed tools, trust settings), various caches |

Note: `~/.claude.json` is separate from `~/.claude/settings.json`. Project-scoped MCP servers live in `.mcp.json` in the project root.

Claude Code creates timestamped backups of config files and retains the 5 most recent.

## Session management

Sessions are saved conversations tied to a project directory, stored as JSONL transcripts locally.

Source: [`code.claude.com/docs/en/sessions.md`](https://code.claude.com/docs/en/sessions.md)

### Resume entry points

| Command | What it does |
|---|---|
| `claude --continue` | Resumes the most recent session in the current directory |
| `claude --resume` | Opens the interactive session picker |
| `claude --resume <name>` | Resumes the named session directly |
| `claude --from-pr <number>` | Resumes the session linked to that pull request |
| `/resume` | Switches to a different conversation from inside an active session |

Sessions created with `claude -p` or the Agent SDK do not appear in the session picker, but can still be resumed by passing their session ID to `claude --resume <session-id>`.

### Naming sessions

| When | How |
|---|---|
| At startup | `claude -n auth-refactor` |
| During a session | `/rename auth-refactor` |
| From the session picker | Highlight a session and press `Ctrl+R` |
| On plan accept | Plan content is used as the name if no name is already set |

Once named, return to a session with `claude --resume <name>` or `/resume <name>`.

### Session picker keyboard shortcuts

Open with `claude --resume` or `/resume`. By default, shows interactive sessions from the current worktree plus sessions that added the current directory with `/add-dir`.

| Shortcut | Action |
|---|---|
| `↑` / `↓` | Navigate between sessions |
| `→` / `←` | Expand or collapse grouped sessions |
| `Enter` | Resume the highlighted session |
| `Space` | Preview session content |
| `Ctrl+R` | Rename the highlighted session |
| `/` or any printable non-Space char | Enter search mode; paste a GitHub/GitLab/Bitbucket PR URL to find its session |
| `Ctrl+A` | Show sessions from all projects on this machine (press again to return) |
| `Ctrl+W` | Show sessions from all worktrees of the current repository (multi-worktree repos only) |
| `Ctrl+B` | Filter to sessions from the current git branch |
| `Esc` | Exit the picker or search mode |

Name resolution: `claude --resume <name>` looks for an exact match across the current repository and its worktrees, resuming directly if found. An ambiguous name opens the picker pre-filled with the search term. `/resume <name>` with an ambiguous name reports an error — run `/resume` without arguments instead.

### Branching a session

Create a copy of the conversation so far without losing the original:

```bash
# From inside a session
/branch try-streaming-approach

# From the command line
claude --continue --fork-session
```

The original session is unchanged and available in the picker. Permissions approved for "this session" do not carry over to the branch. If the same session is resumed in two terminals without forking, messages from both interleave into one transcript.

### Managing context within a session

| Command | Effect |
|---|---|
| `/clear` | Start fresh with empty context; previous conversation is saved and resumable |
| `/compact [instructions]` | Replace history with a summary, optionally focused |
| `/context` | Show what is currently consuming context |
| `/export` | Copy conversation to clipboard or write to a file (pass a filename to write directly) |

### Transcript storage

Transcripts are stored as JSONL at:

```
~/.claude/projects/<project>/<session-id>.jsonl
```

where `<project>` is derived from the working directory path. Set `CLAUDE_CONFIG_DIR` to override the `~/.claude/` location. Local files are removed after 30 days by default; change this with [`cleanupPeriodDays`](SKILL-settings.md) in settings.

To suppress transcript writes entirely: set `CLAUDE_CODE_SKIP_PROMPT_HISTORY`, or use `--no-session-persistence` in non-interactive mode.

## IDE integrations

| IDE | Notes |
|---|---|
| VS Code | Extension auto-installs from VS Code terminal. `claude --ide` to connect manually. Mode indicator at bottom of prompt box |
| JetBrains | Runs Claude Code in IDE terminal; same CLI modes |
| Web / claude.ai | Full cloud sessions (auto accept edits + plan mode) or Remote Control sessions (local machine) |

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `settings.md` (env section), `permissions.md`, `permission-modes.md`, `sessions.md`.*
