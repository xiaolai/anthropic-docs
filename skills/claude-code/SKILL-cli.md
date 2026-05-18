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

## Top-level commands

Source: [`cli-reference.md`](https://code.claude.com/docs/en/cli-reference.md) — audited 2026-05-18.

| Command | Description |
|---|---|
| `claude` | Start interactive session |
| `claude "query"` | Start interactive session with initial prompt |
| `claude -p "query"` | Query in SDK/print mode (non-interactive, then exit) |
| `cat file \| claude -p "query"` | Process piped content |
| `claude -c` | Continue most recent conversation in current directory |
| `claude -c -p "query"` | Continue most recent conversation via SDK |
| `claude -r "<session>" "query"` | Resume session by ID or name |
| `claude update` | Update to latest version |
| `claude install [version]` | Install or reinstall native binary (`2.1.118`, `stable`, or `latest`) |
| `claude auth login` | Sign in (`--email`, `--sso`, `--console` flags) |
| `claude auth logout` | Log out |
| `claude auth status` | Auth status as JSON; `--text` for human-readable; exits 0 if logged in |
| `claude agents` | Open agent view; `--cwd <path>` to filter by directory |
| `claude attach <id>` | Attach to a background session |
| `claude auto-mode defaults` | Print built-in auto-mode classifier rules as JSON |
| `claude logs <id>` | Print recent output from a background session |
| `claude mcp` | Configure MCP servers (see § *MCP subcommands*) |
| `claude plugin` / `claude plugins` | Manage plugins |
| `claude project purge [path]` | Delete local Claude Code state for a project; `--dry-run`, `-y`/`--yes`, `-i`/`--interactive`, `--all` |
| `claude remote-control` | Start Remote Control server without local interactive session |
| `claude respawn <id>` | Restart a stopped background session; `--all` restarts all stopped |
| `claude rm <id>` | Remove a background session from list |
| `claude setup-token` | Generate long-lived OAuth token for CI (requires Claude subscription) |
| `claude stop <id>` | Stop background session (alias: `claude kill`) |
| `claude ultrareview [target]` | Run ultrareview non-interactively; `--json` for raw payload; `--timeout <minutes>` (default 30) |

## CLI flags

| Flag | Description |
|---|---|
| `--add-dir` | Add additional working directories (validates path exists; repeat for multiple) |
| `--agent` | Specify agent for current session (overrides `agent` setting) |
| `--agents` | Define custom subagents via JSON (same fields as subagent frontmatter plus `prompt`) |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to `Shift+Tab` cycle without starting in it |
| `--allowedTools` | Tools that execute without prompting (permission rule syntax) |
| `--append-system-prompt` | Append custom text to end of default system prompt |
| `--append-system-prompt-file` | Load additional system prompt text from file |
| `--bare` | Minimal mode: skip auto-discovery; sets `CLAUDE_CODE_SIMPLE` |
| `--betas` | Beta headers for API requests (API key users only) |
| `--bg` | Start session as background agent and return immediately |
| `--channels` | MCP servers to listen for channel notifications (space-separated `plugin:<name>@<marketplace>`) |
| `--chrome` | Enable Chrome browser integration |
| `--continue`, `-c` | Load most recent conversation in current directory |
| `--dangerously-skip-permissions` | Skip permission prompts; equivalent to `--permission-mode bypassPermissions` |
| `--debug` | Enable debug mode; optional category filter e.g. `"api,hooks"` or `"!statsig,!file"` |
| `--debug-file <path>` | Write debug logs to specific file (implicitly enables debug mode) |
| `--disable-slash-commands` | Disable all skills and commands for session |
| `--disallowedTools` | Tools removed from model context and cannot be used |
| `--effort` | Set effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `--exclude-dynamic-system-prompt-sections` | Move per-machine sections into first user message (improves cache reuse) |
| `--fallback-model` | Fallback model when default is overloaded (print mode only) |
| `--fork-session` | Create new session ID when resuming instead of reusing original |
| `--from-pr` | Resume sessions linked to a PR; accepts PR number, GitHub URL, GitLab MR URL, Bitbucket PR URL |
| `--ide` | Auto-connect to IDE on startup |
| `--init` | Run Setup hooks with `init` matcher before session (print mode only) |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--include-hook-events` | Include all hook lifecycle events in output stream (requires `--output-format stream-json`) |
| `--include-partial-messages` | Include partial streaming events (requires `--print` and `--output-format stream-json`) |
| `--input-format` | Input format for print mode: `text` or `stream-json` |
| `--json-schema` | Get validated JSON output matching a JSON Schema (print mode only) |
| `--maintenance` | Run Setup hooks with `maintenance` matcher (print mode only) |
| `--max-budget-usd` | Max dollars for API calls (print mode only) |
| `--max-turns` | Limit agentic turns (print mode only); no limit by default |
| `--mcp-config` | Load MCP servers from JSON files or strings (space-separated) |
| `--model` | Set model for session; alias `"sonnet"` or `"opus"` or full model name |
| `--name`, `-n` | Set display name for session |
| `--no-chrome` | Disable Chrome integration for session |
| `--no-session-persistence` | Disable session saving to disk (print mode only) |
| `--output-format` | Output format for print mode: `text`, `json`, or `stream-json` |
| `--permission-mode` | Begin in specified mode: `default`, `acceptEdits`, `plan`, `auto`, `dontAsk`, or `bypassPermissions` |
| `--permission-prompt-tool` | MCP tool to handle permission prompts in non-interactive mode |
| `--plugin-dir` | Load plugin from directory or `.zip` for session only (repeat for multiple) |
| `--plugin-url` | Fetch plugin `.zip` from URL for session only (repeat for multiple) |
| `--print`, `-p` | Print response without interactive mode |
| `--remote` | Create new web session on claude.ai |
| `--remote-control`, `--rc` | Start interactive session with Remote Control enabled |
| `--remote-control-session-name-prefix <prefix>` | Prefix for auto-generated Remote Control session names |
| `--replay-user-messages` | Re-emit user messages from stdin on stdout (requires `--input-format stream-json` and `--output-format stream-json`) |
| `--resume`, `-r` | Resume specific session by ID or name, or show picker |
| `--session-id` | Use specific session ID (must be valid UUID) |
| `--setting-sources` | Comma-separated list: `user`, `project`, `local` |
| `--settings` | Path to settings JSON file or inline JSON string |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config` |
| `--system-prompt` | Replace entire system prompt with custom text |
| `--system-prompt-file` | Load system prompt from file, replacing default |
| `--teleport` | Resume a web session in local terminal |
| `--teammate-mode` | Set teammate display mode: `auto`, `in-process`, or `tmux` |
| `--tmux` | Create tmux session for worktree (requires `--worktree`); `--tmux=classic` for traditional tmux |
| `--tools` | Restrict built-in tools: `""` for none, `"default"` for all, or comma-separated tool names |
| `--verbose` | Enable verbose logging |
| `--version`, `-v` | Output version number |
| `--worktree`, `-w` | Start in isolated git worktree; `#<number>` or GitHub PR URL to fetch PR |

### System prompt flags

| Flag | Behavior |
|---|---|
| `--system-prompt` | Replaces entire default prompt |
| `--system-prompt-file` | Replaces with file contents |
| `--append-system-prompt` | Appends to default prompt |
| `--append-system-prompt-file` | Appends file contents to default prompt |

`--system-prompt` and `--system-prompt-file` are mutually exclusive. Append flags can be combined with either replacement flag.

## MCP subcommands

```bash
claude mcp add --transport http <name> <url>
claude mcp add --transport sse <name> <url>
claude mcp add [options] <name> -- <command> [args...]
claude mcp add-json <name> '<json>'
claude mcp add-from-claude-desktop
claude mcp list
claude mcp get <name>
claude mcp remove <name>
claude mcp reset-project-choices
claude mcp serve   # use Claude Code as MCP server itself
```

Flags: `--scope local|project|user` (default `local`), `--env KEY=value`, `--header "Key: value"`, `--client-id`, `--client-secret`, `--callback-port`.

## Environment variables

Source: [`env-vars.md`](https://code.claude.com/docs/en/env-vars.md), [`settings.md`](https://code.claude.com/docs/en/settings.md).

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Metered API authentication |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max / Pro) OAuth authentication |
| `ANTHROPIC_MODEL` | Override default model (e.g. `claude-opus-4-7`) |
| `ANTHROPIC_SMALL_FAST_MODEL` | Model for background tasks; defaults to Haiku |
| `ANTHROPIC_BASE_URL` | Override API base URL (for LLM gateways, proxies) |
| `EDITOR` | External editor invoked for edit operations |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location (sandboxed / multi-account) |
| `CLAUDE_CODE_SIMPLE` | Set by `--bare`; minimal mode |
| `ENABLE_TOOL_SEARCH` | MCP tool deferral: `true`, `false`, `auto`, `auto:N` |
| `MAX_MCP_OUTPUT_TOKENS` | Override MCP output token limit (default 25 000) |
| `CLAUDE_CODE_USE_BEDROCK` | Route to Amazon Bedrock |
| `CLAUDE_CODE_USE_VERTEX` | Route to Google Vertex AI |
| `AWS_REGION` | AWS region for Bedrock |
| `ANTHROPIC_VERTEX_REGION` | GCP region for Vertex AI |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project for Vertex AI |

**Precedence (highest wins):** env var → `settings.local.json` → `settings.json` (project) → `settings.json` (user) → built-in default.

## Permission modes

Source: [`permission-modes.md`](https://code.claude.com/docs/en/permission-modes.md), [`permissions.md`](https://code.claude.com/docs/en/permissions.md).

| Mode | What runs without asking | Best for |
|---|---|---|
| `default` | Reads only | Getting started, sensitive work |
| `acceptEdits` | Reads, file edits, common filesystem commands | Iterating on code |
| `plan` | Reads only (cannot edit) | Exploring codebase before changing |
| `auto` | Everything, with background safety checks | Long tasks, reducing prompt fatigue |
| `dontAsk` | Only pre-approved tools | Locked-down CI/scripts |
| `bypassPermissions` | Everything | **Isolated containers/VMs only** |

### `acceptEdits` auto-approved commands

`mkdir`, `touch`, `rm`, `rmdir`, `mv`, `cp`, `sed` (and PowerShell equivalents: `Set-Content`, `Add-Content`, `Clear-Content`, `Remove-Item`). Only applies to paths inside working directory or `additionalDirectories`.

### `auto` mode requirements

- **Plan:** Max, Team, Enterprise, or API (not Pro)
- **Admin:** on Team/Enterprise, admin must enable in Claude Code admin settings
- **Model:** Claude Sonnet 4.6, Opus 4.6, or Opus 4.7 on Team/Enterprise/API; Claude Opus 4.7 only on Max
- **Provider:** Anthropic API only (not Bedrock, Vertex, Foundry)

### `auto` mode blocked by default

`curl | bash` patterns, sending sensitive data to external endpoints, production deploys and migrations, mass deletion on cloud storage, granting IAM/repo permissions, modifying shared infrastructure, force push or pushing directly to `main`.

### `bypassPermissions` constraints

- Cannot enter from a session started without enabling flag
- Linux/macOS: refuses to start as root or under `sudo`
- v2.1.126+: also includes writes to protected paths
- Circuit breaker: `rm -rf /` and `rm -rf ~` still prompt

### `Shift+Tab` cycle

`default → acceptEdits → plan` (+ `bypassPermissions` if enabled, + `auto` if available). `dontAsk` is never in the cycle — set via `--permission-mode dontAsk`.

## Authentication

Two authentication mechanisms:

| Mechanism | Env var / flag | Use case |
|---|---|---|
| OAuth (subscription) | `CLAUDE_CODE_OAUTH_TOKEN` | Claude Pro / Max / Team; generated via `claude setup-token` for CI |
| API key (metered) | `ANTHROPIC_API_KEY` | Pay-per-token; Bedrock/Vertex via IAM |

`claude auth login` supports: `--sso` for SAML/SSO orgs, `--console` for non-browser environments (accepts a pasted OAuth code), `--email` for pre-filling.

`claude auth status` exits 0 if logged in, 1 if not (useful for CI gating).

## `~/.claude/` directory layout

| Path | Purpose |
|---|---|
| `~/.claude/settings.json` | User-level settings |
| `~/.claude/commands/` | User-level slash commands (`<name>.md`) |
| `~/.claude/agents/` | User-level subagent definitions |
| `~/.claude/skills/` | User-level skills (`<name>/SKILL.md`) |
| `~/.claude/hooks/` | User-level hook scripts (referenced from settings) |
| `~/.claude/rules/` | User-level auto-correction rules |
| `~/.claude/memory/` | Auto-memory storage (CLAUDE.md accumulations) |
| `~/.claude/plans/` | Stored plans from `/plan` |
| `~/.claude/worktrees/` | Isolated worktree sessions |
| `~/.claude.json` | Global config (MCP servers, IDE prefs — see [`SKILL-settings.md`](SKILL-settings.md)) |

Project-level equivalents live at `<repo>/.claude/` with the same subdirectory names.

## IDE integrations

| IDE | Integration |
|---|---|
| VS Code | Extension from Marketplace; `claude --ide` auto-connects; enables inline diffs, `@`-mentions, plan review |
| JetBrains | Plugin from Marketplace; IntelliJ, PyCharm, WebStorm, etc. |
| Web | `claude.ai/code`; `--remote` to start web session; `--teleport` to resume in terminal |

---

*Source pages: [`cli-reference.md`](https://code.claude.com/docs/en/cli-reference.md), [`permissions.md`](https://code.claude.com/docs/en/permissions.md), [`permission-modes.md`](https://code.claude.com/docs/en/permission-modes.md), [`env-vars.md`](https://code.claude.com/docs/en/env-vars.md) — audited 2026-05-18.*
