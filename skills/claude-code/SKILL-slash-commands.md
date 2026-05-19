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

Claude Code discovers commands from these locations (in order):

| Scope | Path | Shared with team? |
|---|---|---|
| User | `~/.claude/commands/` | No |
| Project | `<project>/.claude/commands/` | Yes (committed) |
| Plugin-shipped | Plugin's `commands/` directory | Via plugin install |

Commands are discovered by filename. A file `~/.claude/commands/wc.md` becomes `/wc`. Plugin commands are namespaced: `plugin:command`.

Bundled skills (pre-installed by Anthropic) are also surfaced as commands. They use the same Markdown-with-frontmatter format. See [commands.md](https://code.claude.com/docs/en/commands.md) for the full built-in command list.

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

`$ARGUMENTS` is replaced with the text following the command name when the user invokes it. Example: `/wc src/app.ts` → `$ARGUMENTS` = `src/app.ts`.

**Safety:** Never put `$ARGUMENTS` in a `!`-prefixed shell line — caller input is unsanitised. Use `Read` or other tools to access the file instead.

## Inline shell execution: `!` prefix

A line starting with `!` runs a shell command and embeds its stdout into the command body before Claude sees it:

```markdown
Current branch: !`git branch --show-current`
Files changed: !`git diff --stat`
```

Disable with `disableSkillShellExecution: true` in managed settings.

## File references: `@` prefix

`@path/to/file.md` in the command body embeds the file's content. The path is resolved relative to the project root.

## Namespacing and plugin-shipped commands

Plugin commands are namespaced as `plugin-name:command-name`. Example: a command `commands/review.md` in plugin `code-tools` becomes `/code-tools:review`.

Built-in commands use no namespace. User and project commands use no namespace but project commands take precedence over user commands of the same name.

## Key built-in commands reference

| Command | Purpose |
|---|---|
| `/clear` | Start new conversation; old session stays in `/resume`. Aliases: `/reset`, `/new` |
| `/compact [instructions]` | Summarize context to free window space |
| `/context` | Visualize context usage |
| `/diff` | Interactive diff viewer |
| `/doctor` | Diagnose installation and settings |
| `/effort [level]` | Set model effort (`low`, `medium`, `high`, `xhigh`, `max`) |
| `/goal [condition]` | Keep Claude working until condition is met |
| `/hooks` | View hook configurations |
| `/init` | Generate starter `CLAUDE.md` |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md files and manage auto-memory |
| `/model [model]` | Select or change model |
| `/permissions` | Manage allow/ask/deny rules |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/reload-plugins` | Reload plugins without restarting |
| `/resume [session]` | Resume a conversation by ID or name |
| `/rewind` | Roll back code and conversation. Aliases: `/checkpoint`, `/undo` |
| `/sandbox` | Toggle sandbox mode |
| `/skills` | List available skills |
| `/status` | Show Settings (Status tab): version, model, account |
| `/tasks` | List background tasks |
| `/ultrareview [PR]` | Deep multi-agent cloud code review |

Source: [commands.md](https://code.claude.com/docs/en/commands.md).

## Worked examples

> *Populated by the research agent.* See also:
> [`templates/commands/`](templates/commands/).

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/slash-commands.md`.*
