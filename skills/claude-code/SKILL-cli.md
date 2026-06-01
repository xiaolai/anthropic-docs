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
| `claude auto-mode defaults` | Print built-in auto mode classifier rules as JSON. `claude auto-mode config` shows your effective config with any settings applied | `claude auto-mode defaults > rules.json` |
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
| `--add-dir` | Add additional working directories. Skills from added dirs load automatically; CLAUDE.md and rules load only when `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` is set. See `code.claude.com/docs/en/large-codebases.md` | `claude --add-dir ../apps ../lib` |
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
| `--exec` | Run a shell command as a PTY-backed background job instead of starting a Claude session. Use with `--bg` to launch from the shell | `claude --exec "npm test"` |
| `--fallback-model` | Switch to this model for the rest of the session when the primary model is not found, instead of failing every request (v2.1.150+; previously only applied to print mode + background sessions) | `claude -p --fallback-model sonnet "query"` |
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
| `--prompt-suggestions` | Emit a `prompt_suggestion` message after each turn with a predicted next user prompt. Requires `--print`, `--output-format stream-json`, and `--verbose` | |
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
| `MAX_MCP_OUTPUT_TOKENS` | Override MCP tool output size limit. Default max is 25,000 tokens; warning fires above 10,000 tokens. Cross-reference: [`SKILL-mcp.md`](SKILL-mcp.md) § *Dynamic features* |
| `CLAUDE_CODE_EFFORT_LEVEL` | Override effort level for one session |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Disable session persistence in any mode |
| `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` | Refresh interval for `apiKeyHelper` script |
| `CLAUDE_CODE_OTEL_HEADERS_HELPER_DEBOUNCE_MS` | Refresh interval for `otelHeadersHelper` script |
| `CLAUDE_REMOTE_CONTROL_SESSION_NAME_PREFIX` | Prefix for Remote Control auto-generated session names |
| `CLAUDE_CODE_NO_FLICKER` | Enable fullscreen renderer |
| `CLAUDE_CODE_USE_POWERSHELL_TOOL` | Enable PowerShell tool. Enabled by default on Windows for Bedrock, Vertex, and Foundry users (as of v2.1.149); opt out with `CLAUDE_CODE_USE_POWERSHELL_TOOL=0` |
| `CLAUDE_CODE_DEBUG_LOG_LEVEL` | Minimum log level written to the debug log file: `verbose`, `debug` (default), `info`, `warn`, `error`. Set to `verbose` for high-volume hook-matching diagnostics. Source: `code.claude.com/docs/en/env-vars.md` |
| `CLAUDE_CODE_DEBUG_LOGS_DIR` | Override the debug log file path (accepts a file path, not a directory). Requires debug mode enabled separately via `--debug` or the `DEBUG` env var; `--debug-file` does both at once. Defaults to `~/.claude/debug/<session-id>.txt`. Source: `code.claude.com/docs/en/env-vars.md` |
| `CLAUDE_CODE_DISABLE_THINKING` | Force extended thinking off |
| `CLAUDE_CODE_ENABLE_AWAY_SUMMARY` | Enable session recap on return |
| `CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY` | Suppress session quality survey |
| `CLAUDE_CODE_IDE_SKIP_AUTO_INSTALL` | Skip IDE extension auto-install |
| `CLAUDE_CODE_AUTO_CONNECT_IDE` | Auto-connect to IDE on startup |
| `ENABLE_TOOL_SEARCH` | Set to `false` to disable MCP tool search |
| `CLAUDE_CODE_OPUS_4_6_FAST_MODE_OVERRIDE` | Set to `1` to pin `/fast` mode to Opus 4.6 instead of the default Opus 4.8. Note: Opus 4.6 fast mode is deprecated as of v2.1.150 |
| `CLAUDE_CODE_SUBAGENT_MODEL` | Override the model used by subagents in multi-agent sessions. See [Model configuration](https://code.claude.com/docs/en/model-config.md). Source: `code.claude.com/docs/en/env-vars.md` |
| `CLAUDE_CODE_WORKFLOWS` | Set to `1` to enable the `Workflow` tool for deterministic multi-agent orchestration (off by default; v2.1.159+) |
| `CLAUDE_CODE_ENABLE_AUTO_MODE` | Set to `1` to enable auto permission mode on Bedrock, Vertex, and Foundry (v2.1.159+). Supported models: Opus 4.7 and Opus 4.8. Has no effect on Anthropic API connections; see the *Auto mode requirements* note under *Permission modes*. |
| `CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN` | Set to `1` to disable fullscreen rendering and use the classic main-screen renderer. The conversation stays in the terminal's native scrollback so `Cmd+f` and tmux copy mode work normally. Takes precedence over `CLAUDE_CODE_NO_FLICKER` and the `tui` setting. You can also switch with `/tui default`. Source: `code.claude.com/docs/en/env-vars.md` |
| `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE` | Set to `1` to let Claude Code run your package manager's upgrade command in the background when a new version is available. Applies to Homebrew and WinGet installations. Other package managers continue to show the upgrade command without running it. Source: `code.claude.com/docs/en/env-vars.md` |
| `CLAUDE_CODE_SESSION_ID` | Set automatically in Bash and PowerShell tool subprocesses and in hook command subprocesses to the current session ID. Matches the `session_id` field in the hook JSON input. Updated on `/clear`. Use to correlate scripts and external tools with the Claude Code session that launched them. Source: `code.claude.com/docs/en/env-vars.md` |
| `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD` | Set to `1` to also load CLAUDE.md and rules files from directories added with `--add-dir` or `/add-dir`. Has no effect on directories listed in the `additionalDirectories` setting (those never load CLAUDE.md/rules). Source: `code.claude.com/docs/en/large-codebases.md` |

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
| `acceptEdits` | Reads, file edits, common filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `sed`, etc.). When the PowerShell tool is enabled, also auto-approves `Set-Content`, `Add-Content`, `Clear-Content`, and `Remove-Item` on in-scope paths | Yes |
| `plan` | Reads only; Claude proposes but doesn't edit | Yes |
| `auto` | Everything, with background classifier checks | Optional (requires requirements) |
| `dontAsk` | Only pre-approved tools from `permissions.allow` | Never in cycle; `--permission-mode dontAsk` only |
| `bypassPermissions` | Everything (no safety checks). **Isolated containers/VMs only** | Optional (requires enabling flag) |

**Auto mode requirements (Anthropic API):** Claude Code v2.1.83+, Max/Pro/Team/Enterprise/API plan, and an eligible model. Model availability depends on plan: Team/Enterprise/API allow Sonnet 4.6, Opus 4.6, Opus 4.7, or Opus 4.8; Max and Pro allow Sonnet 4.6, Opus 4.7, and Opus 4.8 (Haiku and claude-3 models are not supported on any plan). Team/Enterprise require an admin to enable it in Claude Code admin settings.

**Auto mode on Bedrock / Vertex / Foundry (v2.1.159+):** Auto mode is now available on Bedrock, Vertex, and Foundry for Opus 4.7 and Opus 4.8. Opt in by setting `CLAUDE_CODE_ENABLE_AUTO_MODE=1`.

Source: `code.claude.com/docs/en/permission-modes.md`.

**`defaultMode: "auto"` is ignored in `.claude/settings.json` and `.claude/settings.local.json`** — a repository cannot grant itself auto mode. Use `~/.claude/settings.json` instead.

`bypassPermissions` requires starting with `--dangerously-skip-permissions`, `--permission-mode bypassPermissions`, or `--allow-dangerously-skip-permissions`. Cannot enter it mid-session without these flags. Refused when running as root/sudo (skipped inside recognized sandbox).

**Protected paths** (never auto-approved in any mode except `bypassPermissions`): `.git`, `.vscode`, `.idea`, `.husky`, `.claude` (except `/commands`, `/agents`, `/skills`, `/worktrees`), plus files like `.gitconfig`, `.mcp.json`, `.bashrc`, `.zshrc`, etc.

Set mode at startup: `claude --permission-mode plan`
Set as default: `{ "permissions": { "defaultMode": "acceptEdits" } }` in `settings.json`
Switch during session: `Shift+Tab`

Source: `code.claude.com/docs/en/permission-modes.md`.

## PowerShell permission rules

When the PowerShell tool is enabled (`CLAUDE_CODE_USE_POWERSHELL_TOOL=1`), permission rules follow the same `Tool(specifier)` syntax as Bash:

```json
{
  "permissions": {
    "allow": ["PowerShell(Get-ChildItem *)", "PowerShell(git commit *)"],
    "deny": ["PowerShell(Remove-Item *)"]
  }
}
```

Key behaviors:
- Wildcards with `*` match at any position; `:*` suffix is equivalent to a trailing ` *`; bare `PowerShell` or `PowerShell(*)` matches every command
- Common aliases are canonicalized: `PowerShell(Get-ChildItem *)` also matches `gci`, `ls`, `dir`; matching is case-insensitive
- Claude Code parses the PowerShell AST and checks each command in a compound statement independently. Pipeline `|`, separators `;`, and (PowerShell 7+) `&&`/`||` split compound commands into subcommands — a rule must match **every** subcommand for the compound to be allowed

Source: `code.claude.com/docs/en/permissions.md`.

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

## Sandbox environments

Claude Code supports several isolation approaches that control what a session can read, write, and reach on the network. They range from a lightweight per-command sandbox to a full virtual machine.

Source: [`code.claude.com/docs/en/sandbox-environments.md`](https://code.claude.com/docs/en/sandbox-environments.md)

| Approach | What is isolated | Requires Docker | Setup effort |
|---|---|---|---|
| [Sandboxed Bash tool](https://code.claude.com/docs/en/sandboxing.md) | Bash commands and child processes | No | Minimal (macOS); low (Linux / WSL2) |
| [Sandbox runtime](#sandbox-runtime) | Entire Claude Code process — file tools, MCP servers, hooks | No | Low (beta preview) |
| Dev container | Full development environment | Yes | Medium |
| Custom container | Full development environment | Yes | Medium to high |
| Virtual machine | Full operating system | No | High |
| Claude Code on the web | Full OS, hosted by Anthropic | No | None — requires Claude subscription + GitHub |

The **sandboxed Bash tool** restricts only Bash commands; built-in file tools (Read, Edit, WebFetch), MCP servers, and hooks still run on the host. Every other approach puts the whole Claude Code process inside the isolation boundary.

### Choosing an approach

| Goal | Recommended approach |
|---|---|
| Reduce permission prompts during everyday work | Sandboxed Bash tool — enable with `/sandbox` |
| Unattended runs with `--dangerously-skip-permissions` | Dev container, custom container, VM, or sandbox runtime |
| Isolate MCP servers and hooks without Docker | Sandbox runtime |
| Untrusted repository | Dedicated VM or Claude Code on the web |
| Standardize environment across a team | Preconfigured dev container committed to your repo |
| Use Claude Code from a device with no local setup | Claude Code on the web |
| Enforce isolation for every developer | Managed settings or device management tools |
| Native Windows host | Container, VM, or run the Bash sandbox inside WSL2 |

### How isolation relates to permission modes

[Permission modes](#permission-modes) decide **whether** a tool call runs and whether you are prompted first. Isolation restricts **what** a command can access once it runs. The two work together: when a permission mode allows actions without prompting, the isolation boundary limits what those actions can reach.

`--dangerously-skip-permissions` removes all per-action review, so an isolation boundary is the only limit on what Claude can do. Always pair it with a container, VM, or the sandbox runtime so that file tools, MCP servers, and hooks are also inside the boundary.

`auto` mode uses a background classifier to review and block escalating actions; it does not require an isolation boundary the way `--dangerously-skip-permissions` does, but adding one provides defense in depth for unattended runs.

### Sandbox runtime

The [`@anthropic-ai/sandbox-runtime`](https://github.com/anthropic-experimental/sandbox-runtime) package (beta research preview) wraps an entire process in the same Seatbelt (macOS) or bubblewrap (Linux / WSL2) isolation used by the built-in Bash sandbox. Running Claude Code through it constrains every tool, hook, and MCP server in the session — not only Bash.

Configure allowed paths and domains in `~/.srt-settings.json` (or a file passed with `--settings`), then launch:

```bash
npx @anthropic-ai/sandbox-runtime claude
```

The runtime denies all write and network access by default. At minimum allow your project directory, `~/.claude`, `~/.claude.json`, and `api.anthropic.com` (or your configured provider endpoint). See the package [README](https://github.com/anthropic-experimental/sandbox-runtime) for the full configuration schema.

### Enforcing sandbox isolation across an organization

| Approach | Enforcement mechanism |
|---|---|
| Built-in Bash sandbox | Deliver `sandbox.*` keys via [managed settings](https://code.claude.com/docs/en/server-managed-settings.md) or MDM. See [Enforce sandboxing with managed settings](https://code.claude.com/docs/en/sandboxing.md#enforce-sandboxing-with-managed-settings). |
| Dev container | Commit the [example dev container](https://code.claude.com/docs/en/devcontainer.md) to your repositories (convention, not hard enforcement). |
| Custom container / VM | Distribute Claude Code through an approved image; use device management or software allowlisting to prevent installation outside it. |

For all sandbox settings keys (`sandbox.enabled`, `sandbox.filesystem.*`, `sandbox.network.*`, etc.), see [`SKILL-settings.md`](SKILL-settings.md) § *sandbox block*.

## IDE integrations

| IDE | Notes |
|---|---|
| VS Code | Extension auto-installs from VS Code terminal. `claude --ide` to connect manually. Mode indicator at bottom of prompt box |
| JetBrains | Runs Claude Code in IDE terminal; same CLI modes |
| Web / claude.ai | Full cloud sessions (auto accept edits + plan mode) or Remote Control sessions (local machine) |

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `settings.md` (env section), `permissions.md`, `permission-modes.md`, `sessions.md`, `sandbox-environments.md`.*
