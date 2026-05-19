---
name: claude-code-cli
description: |
  Deep reference for Claude Code's CLI surface: command-line flags,
  subcommands, environment variables (ANTHROPIC_* / CLAUDE_*),
  permission modes (default / acceptEdits / plan / auto / dontAsk /
  bypassPermissions), the ~/.claude/ directory layout, IDE integration
  entry points, and authentication mechanisms. Read this file when the
  user asks about CLI invocation, env vars, permission modes, ~/.claude/
  structure, or how Claude Code authenticates.
source: https://code.claude.com/docs/en/cli-reference.md
---

# Claude Code — CLI, environment, and layout

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for CLI / env / layout questions.*

## Top-level invocation

| Command | Description | Example |
|---|---|---|
| `claude` | Start interactive session | `claude` |
| `claude "query"` | Start interactive session with initial prompt | `claude "explain this project"` |
| `claude -p "query"` | Query via SDK, then exit (non-interactive/print mode) | `claude -p "explain this function"` |
| `cat file \| claude -p "query"` | Process piped content | `cat logs.txt \| claude -p "explain"` |
| `claude -c` | Continue most recent conversation in current directory | `claude -c` |
| `claude -c -p "query"` | Continue via SDK | `claude -c -p "Check for type errors"` |
| `claude -r "<session>" "query"` | Resume session by ID or name | `claude -r "auth-refactor" "Finish this PR"` |
| `claude update` | Update to latest version | `claude update` |

Source: [code.claude.com/docs/en/cli-reference.md](https://code.claude.com/docs/en/cli-reference.md)

## CLI flags

`claude --help` does not list every flag; absence from `--help` does not mean unavailable.

| Flag | Description |
|---|---|
| `--add-dir` | Add additional working directories (grants file access, not config discovery) |
| `--agent` | Specify a named agent for this session |
| `--agents` | Define custom subagents dynamically via JSON |
| `--allow-dangerously-skip-permissions` | Add `bypassPermissions` to Shift+Tab cycle without starting in it |
| `--allowedTools` | Tools that execute without permission prompt (uses permission rule syntax) |
| `--append-system-prompt` | Append custom text to the default system prompt |
| `--append-system-prompt-file` | Load additional system prompt text from a file |
| `--bare` | Minimal mode: skip auto-discovery of hooks, skills, plugins, MCP, auto memory, and subagents |
| `--bg` | Start as a background agent and return immediately |
| `--channels` | MCP servers whose channel notifications Claude should listen to |
| `--chrome` | Enable Chrome browser integration |
| `--dangerously-skip-permissions` | Skip all permission prompts (equivalent to `--permission-mode bypassPermissions`) |
| `--debug` | Enable debug mode with optional category filtering |
| `--debug-file <path>` | Write debug logs to a specific file path |
| `--disable-slash-commands` | Disable all skills and commands for this session |
| `--disallowedTools` | Tools removed from model context (cannot be used) |
| `--effort` | Set effort level: `"low"`, `"medium"`, `"high"`, `"xhigh"` |
| `--fallback-model` | Enable automatic fallback to a specified model when default is overloaded |
| `--fork-session` | When resuming, create a new session ID instead of reusing original |
| `--from-pr` | Resume sessions linked to a specific pull request |
| `--ide` | Automatically connect to IDE on startup |
| `--init` | Run Setup hooks with `init` matcher before session |
| `--init-only` | Run Setup and SessionStart hooks, then exit |
| `--input-format` | Specify input format for print mode: `text` or `stream-json` |
| `--json-schema` | Get validated JSON output matching a JSON Schema after agent completes |
| `--maintenance` | Run Setup hooks with `maintenance` matcher before session |
| `--max-budget-usd` | Maximum dollar amount to spend on API calls before stopping (print mode only) |
| `--max-turns` | Limit the number of agentic turns (print mode only) |
| `--mcp-config` | Load MCP servers from JSON files or strings (space-separated) |
| `--model` | Sets model for the session (`sonnet` or `opus` for latest aliases) |
| `--no-chrome` | Disable Chrome browser integration for this session |
| `--no-session-persistence` | Disable session persistence (sessions not saved, cannot be resumed) |
| `--output-format` | Output format for print mode: `text`, `json`, or `stream-json` |
| `--permission-mode` | Begin in a specified permission mode (see § *Permission modes*) |
| `--permission-prompt-tool` | Specify an MCP tool to handle permission prompts in non-interactive mode |
| `--plugin-dir` | Load a plugin from a directory or `.zip` archive for this session only |
| `--plugin-url` | Fetch a plugin `.zip` archive from a URL for this session only |
| `--remote` | Create a new web session on claude.ai with the provided task |
| `--session-id` | Use a specific session ID (must be a valid UUID) |
| `--setting-sources` | Comma-separated list of setting sources to load: `user`, `project`, `local` |
| `--settings` | Path to a settings JSON file or inline JSON string |
| `--strict-mcp-config` | Only use MCP servers from `--mcp-config`, ignoring all other MCP configurations |
| `--system-prompt` | Replace the entire system prompt with custom text |
| `--system-prompt-file` | Load system prompt from a file, replacing the default prompt |
| `--teleport` | Resume a web session in your local terminal |
| `--tools` | Restrict which built-in tools Claude can use (`""` to disable all, `"default"` for all) |
| `--verbose` | Enable verbose logging, shows full turn-by-turn output |
| `--worktree` | Run the session in a new git worktree |

## Environment variables

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Metered API authentication. Mutually exclusive with `CLAUDE_CODE_OAUTH_TOKEN`. |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max / Pro) authentication via OAuth. Preferred over API key when both are set. |
| `ANTHROPIC_MODEL` | Override the default model for the session. Highest precedence over settings. |
| `EDITOR` | Editor invoked when an edit needs an external editor (e.g., `code --wait`, `vim`). |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location. Useful for sandboxed / multi-account setups. |
| `ANTHROPIC_BASE_URL` | Override the API base URL (for LLM gateway / proxy setups). |
| `CLAUDE_PROJECT_DIR` | Set by Claude Code in hook/MCP environments to point to the project root. |

Precedence (highest wins): env var > `settings.local.json` > `settings.json` (project) > `settings.json` (user) > built-in default.

Source: [code.claude.com/docs/en/cli-reference.md](https://code.claude.com/docs/en/cli-reference.md), [env-vars.md](https://code.claude.com/docs/en/env-vars.md)

## Permission modes

Six permission modes control how often Claude pauses to ask for approval:

| Mode | What runs without asking | Best for | How to activate |
|---|---|---|---|
| `default` | Reads only | Getting started, sensitive work | Default; Shift+Tab cycles to it |
| `acceptEdits` | Reads, file edits, common filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `rm`, `sed`) | Iterating on code you're reviewing | Shift+Tab or `--permission-mode acceptEdits` |
| `plan` | Reads only (no edits) | Exploring a codebase before changing it | Shift+Tab, `/plan` prefix, or `--permission-mode plan` |
| `auto` | Everything, with background safety checks from a classifier model | Long tasks, reducing prompt fatigue | Shift+Tab (if enabled), or set `defaultMode: "auto"` in `~/.claude/settings.json` |
| `dontAsk` | Only pre-approved tools (allow rules + read-only Bash) | Locked-down CI scripts | `--permission-mode dontAsk` only |
| `bypassPermissions` | Everything (no safety checks) | Isolated containers/VMs only | `--permission-mode bypassPermissions` or `--dangerously-skip-permissions` |

### Auto mode requirements

Auto mode requires all of:
- **Plan**: Max, Team, Enterprise, or API (not Pro)
- **Admin**: On Team/Enterprise, admin must enable in Claude Code admin settings
- **Model**: Claude Sonnet 4.6, Opus 4.6, or Opus 4.7 (not Haiku or claude-3 models)
- **Provider**: Anthropic API only (not Bedrock, Vertex, or Foundry)

`defaultMode: "auto"` is **ignored** in project and local settings; must be in `~/.claude/settings.json`.

### Protected paths

In every mode except `bypassPermissions`, writes to these paths never auto-approve:

- `.git`, `.vscode`, `.idea`, `.husky`
- `.claude` (except `.claude/commands`, `.claude/agents`, `.claude/skills`, `.claude/worktrees`)
- `.gitconfig`, `.gitmodules`, `.bashrc`, `.bash_profile`, `.zshrc`, `.zprofile`, `.profile`
- `.ripgreprc`, `.mcp.json`, `.claude.json`

### acceptEdits auto-approved Bash commands

In `acceptEdits` mode, these Bash commands run without prompting (within working directory):
`mkdir`, `touch`, `rm`, `rmdir`, `mv`, `cp`, `sed`

Also auto-approved when prefixed with safe env vars (`LANG=C`, `NO_COLOR=1`) or wrappers (`timeout`, `nice`, `nohup`). PowerShell equivalents are also auto-approved when the PowerShell tool is enabled.

Source: [code.claude.com/docs/en/permission-modes.md](https://code.claude.com/docs/en/permission-modes.md), [permissions.md](https://code.claude.com/docs/en/permissions.md)

## Authentication

Two methods (mutually exclusive):
- **OAuth (subscription)**: `CLAUDE_CODE_OAUTH_TOKEN` — for Max/Pro/Team/Enterprise plans.
- **API key (metered)**: `ANTHROPIC_API_KEY` — charges per token.

Run `claude auth login` to authenticate interactively. The `claude auth status` command shows which method is active.

## `~/.claude/` directory layout

```
~/.claude/
├── settings.json        # user-scope settings
├── settings.local.json  # (per project, in project dir) local overrides
├── skills/              # personal skills (cross-project)
│   └── <skill-name>/
│       └── SKILL.md
├── commands/            # legacy personal commands (merged into skills)
│   └── <command-name>.md
├── agents/              # personal subagent definitions
│   └── <agent-name>.md
├── hooks/               # hook scripts (referenced from settings.json hooks)
├── plans/               # plan files (default location)
├── sessions/            # session transcripts and state
└── memories/            # auto memory storage (default)
```

Project-level config lives in `<project>/.claude/`:

```
<project>/.claude/
├── settings.json        # project-scope settings (commit to git)
├── settings.local.json  # gitignored personal overrides
├── CLAUDE.md            # (also at project root) project instructions
├── skills/              # project-specific skills
├── commands/            # project-specific commands
├── agents/              # project-specific subagents
└── hooks/               # project hook scripts
```

## IDE integrations

- **VS Code**: Install the Claude Code extension. Mode selector at bottom of prompt box.
- **JetBrains**: Plugin runs Claude Code in IDE terminal; Shift+Tab to cycle modes.
- **Web (claude.ai/code)**: Cloud sessions support `acceptEdits` and `plan` modes only.

---

*Source pages: [code.claude.com/docs/en/cli-reference.md](https://code.claude.com/docs/en/cli-reference.md), [permission-modes.md](https://code.claude.com/docs/en/permission-modes.md), [permissions.md](https://code.claude.com/docs/en/permissions.md), [env-vars.md](https://code.claude.com/docs/en/env-vars.md).*
