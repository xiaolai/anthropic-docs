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

> *Populated by the research agent.* Covers `~/.claude/commands/`,
> `<project>/.claude/commands/`, and plugin-shipped commands.

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

> *Populated by the research agent.*

## Inline shell execution: `!` prefix

> *Populated by the research agent.* `! <command>` runs the shell
> command and embeds its output into the command body.

## File references: `@` prefix

> *Populated by the research agent.*

## Namespacing and plugin-shipped commands

> *Populated by the research agent.* Covers `plugin:command` syntax.

## Worked examples

> *Populated by the research agent.* See also:
> [`templates/commands/`](templates/commands/).

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/slash-commands.md`. Last reviewed: <pipeline-stamp>.*
