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

> *Populated by the research agent.* `claude`, `claude -p`, `claude --resume`, etc.

## CLI flags

> *Populated by the research agent.* Every documented flag with type,
> default, and effect.

## Subcommands

> *Populated by the research agent.* `claude plugin`, `claude config`,
> `claude mcp`, etc.

## Session management

Claude Code saves conversations as sessions tied to a project directory. Sessions persist as JSONL transcripts so you can resume, branch, or export them.

### Resume flags

| Command / flag | What it does |
|---|---|
| `claude --continue` | Resume the most recent session in the current directory |
| `claude --resume` | Open the interactive session picker |
| `claude --resume <name>` | Resume a named session directly |
| `claude --resume <session-id>` | Resume by session ID (also works for headless/SDK sessions) |
| `claude --from-pr <number>` | Resume the session linked to that pull request number |
| `--fork-session` | Combined with `--continue` / `--resume` — creates a branch copy before resuming |

### Session naming

| When | How |
|---|---|
| At startup | `claude -n <name>` |
| During a session | `/rename <name>` |
| From session picker | Highlight session and press `Ctrl+R` |
| On plan accept | Auto-named from plan content if no name has been set |

### Session picker keyboard shortcuts (`/resume` or `claude --resume`)

| Shortcut | Action |
|---|---|
| `↑` / `↓` | Navigate sessions |
| `→` / `←` | Expand / collapse forked-session groups |
| `Enter` | Resume highlighted session |
| `Space` | Preview session content |
| `Ctrl+R` | Rename highlighted session |
| `/` or any printable character | Enter search / filter mode; paste a PR URL to find its session |
| `Ctrl+A` | Toggle: show all projects on this machine |
| `Ctrl+W` | Toggle: show all worktrees of this repo |
| `Ctrl+B` | Filter to sessions on current git branch |
| `Esc` | Exit picker or search mode |

### Branching sessions

From inside a session: `/branch [name]` — creates a copy and switches into it.  
From the CLI: `claude --continue --fork-session` (or `--resume <name> --fork-session`).

The original session is unchanged; both appear in the session picker. Permissions approved with "allow for this session" do **not** carry over to the branch.

### Session data location

Transcripts are stored at `~/.claude/projects/<project>/<session-id>.jsonl` (one JSONL line per message/tool-use/metadata). Override the base path with [`CLAUDE_CONFIG_DIR`](#environment-variables). Files are cleaned up after 30 days by default; change this with the `cleanupPeriodDays` setting in `settings.json`.

To suppress transcript writes: set `CLAUDE_CODE_SKIP_PROMPT_HISTORY=1` (env var) or pass `--no-session-persistence` in non-interactive mode.

Use `/export` inside a session to copy the conversation to the clipboard or write it to a file as human-readable text.

Source: `code.claude.com/docs/en/sessions.md`

## Environment variables

<!-- seed: replace on first real research pass -->

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Metered API authentication. Mutually exclusive with `CLAUDE_CODE_OAUTH_TOKEN`. |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max / Pro) authentication via OAuth. Preferred over API key when both are set. |
| `ANTHROPIC_MODEL` | Override the default model for the session (e.g. `claude-opus-4-7`). Equivalent to `model` in `settings.json` but takes precedence. |
| `EDITOR` | Editor invoked by `claude` when an edit needs an external editor. Common values: `code --wait`, `vim`, `nvim`. |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location. Useful for sandboxed / multi-account setups. |
| `CLAUDE_CODE_SKIP_PROMPT_HISTORY` | Set to `1` to suppress writing session transcripts to disk. |
| `CLAUDECODE` | Set to `1` by Claude Code for every Bash/PowerShell tool invocation; used by CLIs to detect they are running inside Claude Code (e.g. for [plugin hint emission](SKILL-plugins.md#plugin-hint-protocol)). |

Precedence (highest wins): env var > `settings.local.json` > `settings.json` (project) > `settings.json` (user) > built-in default.

Source: `code.claude.com/docs/en/settings.md` (environment section). The research agent expands this table as new env vars are documented.

## Permission modes

> *Populated by the research agent.* `default`, `acceptEdits`, `plan`,
> `bypassPermissions` — semantics and use cases.

## Authentication

> *Populated by the research agent.* OAuth (`CLAUDE_CODE_OAUTH_TOKEN`)
> vs API key (`ANTHROPIC_API_KEY`), subscription vs metered.

## `~/.claude/` directory layout

> *Populated by the research agent.* Every directory and file Claude
> Code creates or reads under `~/.claude/`.

## IDE integrations

> *Populated by the research agent.* VS Code, JetBrains, web app.

## Cost and quota

> *Populated by the research agent.* Subscription limits, API
> billing.

---

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `settings.md` (env section), `permissions.md`.*
