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

Source: [`code.claude.com/docs/en/skills.md`](https://code.claude.com/docs/en/skills.md), [`commands.md`](https://code.claude.com/docs/en/commands.md)

| Path | Scope | Invocation |
|---|---|---|
| `~/.claude/commands/<name>.md` | User (all projects) | `/<name>` |
| `<project>/.claude/commands/<name>.md` | Project | `/<name>` |
| Plugin `commands/<name>.md` | Plugin | `/<plugin>:<name>` |

Subdirectories create namespaces: `commands/deploy/staging.md` → `/deploy:staging`. Plugin commands are always namespaced with the plugin name to prevent conflicts.

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

`$ARGUMENTS` in a command body is replaced verbatim with everything the user types after the command name. Example: `/deploy staging` with `$ARGUMENTS` in the body becomes `staging`.

⚠️ **Do NOT put `$ARGUMENTS` into a `!`-prefixed shell line.** `$ARGUMENTS` is unsanitised caller input — `foo; rm -rf ~` executes as three shell commands. Use `Read` or `Bash` tool calls with the model inspecting the value instead.

## Inline shell execution: `!` prefix

A line starting with `!` in the command body is executed as a shell command, and its stdout is embedded into the prompt. Example: `` !git log --oneline -10 `` embeds the last 10 commits.

Use `` `!<command>` `` for inline shell substitution within a sentence. Full fenced code blocks with `` ```! `` also work.

**`disableSkillShellExecution`** managed setting blocks all `!` / `` ` `` execution from user/project/plugin commands (bundled and managed skills are exempt).

## File references: `@` prefix

`@<path>` in a command body includes the file contents in the prompt. Path is relative to project root. Example: `@src/config.ts` embeds that file.

## Namespacing and plugin-shipped commands

- Standalone commands: `/<name>` or `/<namespace>:<name>` (for subdirectory commands)
- Plugin commands: `/<plugin-name>:<name>` (always namespaced)
- Use `/help` to list all available commands and their descriptions

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

See [`rules/skills-agents-commands.md`](rules/skills-agents-commands.md) — covers: SKILL.md casing, PascalCase tool names in `allowed-tools`, agent `tools` frontmatter format, specific `description` text.

---

*Source pages: `code.claude.com/docs/en/slash-commands.md`.*
