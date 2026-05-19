---
name: claude-code-slash-commands
description: |
  Deep reference for authoring Claude Code slash commands. Covers
  frontmatter schema (description, argument-hint, allowed-tools,
  model), `$ARGUMENTS` substitution, the `!` shell-prefix, the `@`
  file-reference prefix, command discovery paths (user / project /
  plugin), and namespacing. Read this file when the user asks about
  writing or debugging a slash command, command frontmatter, or
  command discovery.
source: https://code.claude.com/docs/en/slash-commands.md
---

# Claude Code — Slash Commands

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for slash command questions.*

## Discovery paths

Commands are discovered from these locations (in priority order):

| Location | Who sees it |
|---|---|
| `~/.claude/commands/` | You, across all projects |
| `<project>/.claude/commands/` | All collaborators (committed to git) |
| Plugin-shipped commands | Anyone with that plugin enabled |

A command file `foo.md` in any of those locations becomes `/foo`. Plugin commands are namespaced: `/plugin-name:foo` or `/p:foo` (short form).

## Frontmatter schema

<!-- seed: replace on first real research pass -->

A slash command is a Markdown file with YAML frontmatter. Common keys:

| Key | Type | Notes |
|---|---|---|
| `description` | string | One-line summary shown in command lists. Keep ≤120 chars. |
| `argument-hint` | string | Placeholder text shown after the command name, e.g. `"<file path>"`. |
| `allowed-tools` | string | Comma-separated tool list (e.g. `Read, Bash(git:*)`). Restricts what the command can call. The `<Tool>(<matcher>)` parenthetical narrows a tool to specific invocations (see `SKILL-settings.md` `permissions` block for the matcher grammar). |
| `model` | string | Optional model override for this command's invocation. |

Minimal command (`~/.claude/commands/wc.md`):

```markdown
---
description: Count words in the given file.
argument-hint: "<file path>"
allowed-tools: Read
---

Count the words in $ARGUMENTS. Read the file and report `<path>: <N> words`.
```

**Avoid putting `$ARGUMENTS` into a `!`-prefixed shell line.** The `!` prefix invokes a shell, and `$ARGUMENTS` is unsanitised caller input — `foo.txt; rm -rf ~` parses as three commands. The `allowed-tools` matcher constrains which tool the model can invoke; it does not escape arguments. Prefer `Read` (this example) over `!`-shell when the input touches `$ARGUMENTS`. The fuller risk analysis is in [`templates/commands/example.md`](templates/commands/example.md) under "Safety note".

Source: `code.claude.com/docs/en/slash-commands.md`.

## Argument substitution: `$ARGUMENTS`

Text after the command name is passed as `$ARGUMENTS`. The entire string (no parsing). Example: if the user types `/wc src/foo.ts`, then `$ARGUMENTS` = `"src/foo.ts"`.

⚠️ **Security**: Never use `$ARGUMENTS` in a `!`-prefixed shell line — shell injection risk. Use tool calls instead.

## Inline shell execution: `!` prefix and `` ` `` prefix

- **`! <command>`** — runs shell command in the command body and embeds its stdout.
- **`` !`<command>` ``** — inline backtick variant, substituted inline in the text.
- **`` ```! ... ``` ``** — code fence with `!` language tag: runs block, embeds output.

Shell execution in user/project/plugin commands can be disabled by admins with `disableSkillShellExecution: true` in managed settings.

## File references: `@` prefix

`@<path>` in a command body expands to the file contents at that path, relative to the project root. Useful for injecting templates or reference files into a command's context.

## Namespacing and plugin-shipped commands

Plugin commands are namespaced as `/<plugin-name>:<command-name>`. Short form: `/p:<command-name>` when unambiguous. Plugin commands appear in the `/` picker and can be invoked the same as built-in commands.

## Built-in commands (selected key commands)

These are coded into the CLI, not skill files:

| Command | Purpose |
|---|---|
| `/add-dir <path>` | Add working directory for file access this session. |
| `/agents` | Manage subagent configurations. |
| `/background [prompt]` | Detach session to run as background agent. |
| `/batch <instruction>` | [Skill] Orchestrate large-scale changes in parallel worktrees. |
| `/branch [name]` | Create a branch of the current conversation. Alias: `/fork`. |
| `/btw <question>` | Side question without adding to conversation history. |
| `/clear [name]` | Start fresh conversation. Aliases: `/reset`, `/new`. |
| `/compact [instructions]` | Summarize conversation to free context. |
| `/config` | Open Settings interface. Alias: `/settings`. |
| `/context [all]` | Visualize context usage. |
| `/copy [N]` | Copy last assistant response (or Nth-latest) to clipboard. |
| `/debug` | [Skill] Enable debug logging and troubleshoot issues. |
| `/diff` | Interactive diff viewer for uncommitted changes. |
| `/doctor` | Diagnose Claude Code installation and settings. |
| `/effort [level\|auto]` | Set model effort level. |
| `/export [filename]` | Export conversation as plain text. |
| `/fast [on\|off]` | Toggle fast mode. |
| `/feedback` | Submit feedback. Alias: `/bug`. |
| `/fewer-permission-prompts` | [Skill] Scan transcripts and add allow rules to reduce prompts. |
| `/focus` | Toggle focus view (fullscreen only). |
| `/goal [condition\|clear]` | Set a completion condition; Claude keeps working until met. |
| `/hooks` | View hook configurations. |
| `/init` | Initialize CLAUDE.md for project. |
| `/loop [interval] [prompt]` | [Skill] Run prompt repeatedly or self-pacing. Alias: `/proactive`. |
| `/mcp` | Manage MCP server connections and OAuth. |
| `/memory` | Edit CLAUDE.md files and manage auto-memory. |
| `/model [model]` | Select or change AI model. |
| `/permissions` | Manage allow/ask/deny rules. Alias: `/allowed-tools`. |
| `/plan [description]` | Enter plan mode directly. |
| `/plugin` | Manage plugins. |
| `/reload-plugins` | Reload all active plugins without restarting. |
| `/remote-control` | Enable Remote Control from claude.ai. Alias: `/rc`. |
| `/rename [name]` | Rename current session. |
| `/resume [session]` | Resume conversation by ID or name. Alias: `/continue`. |
| `/review [PR]` | Review a pull request locally. |
| `/rewind` | Rewind conversation/code to a previous point. Aliases: `/checkpoint`, `/undo`. |
| `/sandbox` | Toggle sandbox mode. |
| `/schedule [description]` | Create/manage routines (cloud-scheduled). Alias: `/routines`. |
| `/simplify [focus]` | [Skill] Review recently changed files for quality and fix issues. |
| `/skills` | List available skills. Press `Space` to hide/show a skill. |
| `/status` | Open Settings Status tab (version, model, account, connectivity). |
| `/statusline` | Configure status line. |
| `/tasks` | List and manage background tasks. |
| `/team-onboarding` | Generate team onboarding guide from usage history. |
| `/teleport` | Pull web session into terminal. Alias: `/tp`. |
| `/theme` | Change color theme. |
| `/tui [default\|fullscreen]` | Set terminal UI renderer. |
| `/ultraplan <prompt>` | Draft plan in cloud session, review in browser. |
| `/ultrareview [PR]` | Deep multi-agent cloud code review. |
| `/usage` | Show session cost and plan usage. Aliases: `/cost`, `/stats`. |
| `/voice [hold\|tap\|off]` | Toggle voice dictation. |

Source: `code.claude.com/docs/en/commands.md`.

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/slash-commands.md`.*
