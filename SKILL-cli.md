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

## Environment variables

<!-- seed: replace on first real research pass -->

| Variable | Purpose |
|---|---|
| `ANTHROPIC_API_KEY` | Metered API authentication. Mutually exclusive with `CLAUDE_CODE_OAUTH_TOKEN`. |
| `CLAUDE_CODE_OAUTH_TOKEN` | Subscription (Max / Pro) authentication via OAuth. Preferred over API key when both are set. |
| `ANTHROPIC_MODEL` | Override the default model for the session (e.g. `claude-opus-4-7`). Equivalent to `model` in `settings.json` but takes precedence. |
| `EDITOR` | Editor invoked by `claude` when an edit needs an external editor. Common values: `code --wait`, `vim`, `nvim`. |
| `CLAUDE_CONFIG_DIR` | Override `~/.claude/` location. Useful for sandboxed / multi-account setups. |

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

*Source pages: `code.claude.com/docs/en/cli-reference.md`, `settings.md` (env section), `permissions.md`. Last reviewed: <pipeline-stamp>.*
