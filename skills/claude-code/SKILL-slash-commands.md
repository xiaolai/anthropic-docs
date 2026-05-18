---
name: claude-code-slash-commands
description: |
  Deep reference for authoring Claude Code slash commands (skills).
  Covers SKILL.md frontmatter schema (description, argument-hint,
  allowed-tools, disable-model-invocation, user-invocable, name,
  when_to_use, arguments, context), $ARGUMENTS / $name substitution,
  the ! shell-prefix for dynamic context injection, command discovery
  paths (user / project / plugin), and namespacing. Read this file
  when the user asks about writing or debugging a slash command or
  skill, SKILL.md frontmatter, or skill discovery.
source: https://code.claude.com/docs/en/skills.md
---

# Claude Code — Slash Commands (Skills)

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for slash command / skill questions.*

## Overview

Skills (slash commands) extend Claude's capabilities. A skill is a directory containing a `SKILL.md` file. Claude loads skills automatically when relevant, or you invoke them directly with `/skill-name`.

**Custom commands have been merged into skills.** Files at `.claude/commands/deploy.md` and `.claude/skills/deploy/SKILL.md` both create `/deploy` and work identically. Existing `.claude/commands/` files continue to work. Skills add features: a directory for supporting files, frontmatter control over invocation, and subagent execution.

## Discovery paths

| Scope | Path | Invocation |
|---|---|---|
| Enterprise | Managed settings | All users in org |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled — namespaced as `/plugin-name:skill-name` |

Also discovered (legacy): `~/.claude/commands/<name>.md`, `.claude/commands/<name>.md`.

**Priority when names conflict:** enterprise > personal > project. Plugin skills cannot conflict (namespaced).

**Live detection:** Claude Code watches skill directories for changes. Adding or editing a skill takes effect within the current session without restarting.

## `SKILL.md` frontmatter schema

Source: [`skills.md`](https://code.claude.com/docs/en/skills.md) — audited 2026-05-18.

```yaml
---
name: my-skill
description: What this skill does and when to use it.
when_to_use: Additional trigger phrases or example requests.
argument-hint: "[filename] [format]"
arguments: filename format
disable-model-invocation: true
user-invocable: false
allowed-tools: Read Grep
context: fork
---

Skill body goes here.
```

| Field | Required | Description |
|---|---|---|
| `name` | No | Display name. Lowercase letters, numbers, hyphens; max 64 chars. Defaults to directory name. |
| `description` | **Recommended** | What the skill does. Claude uses this for automatic invocation. Combined `description` + `when_to_use` truncated at 1,536 chars in skill listing. |
| `when_to_use` | No | Additional context for automatic invocation (trigger phrases, example requests). Appended to `description`. |
| `argument-hint` | No | Hint in autocomplete (e.g. `"[issue-number]"` or `"[filename] [format]"`). |
| `arguments` | No | Named positional arguments for `$name` substitution. Space-separated string or YAML list. |
| `disable-model-invocation` | No | `true` = prevent Claude from loading this skill automatically; also blocks preloading into subagents. Default: `false`. |
| `user-invocable` | No | `false` = hide from `/` menu (background knowledge). Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without permission prompts when skill is active. Space-separated string or YAML list. |
| `context` | No | `"fork"` = run skill in an isolated subagent context. |

Also applies to `.claude/commands/*.md` legacy files (same frontmatter support).

## Argument substitution

### `$ARGUMENTS` (positional, all args as a string)

```markdown
---
description: Count words in a file.
argument-hint: "<file path>"
allowed-tools: Read
---

Count the words in $ARGUMENTS and report `<path>: <N> words`.
```

When invoked as `/wc src/main.ts`, `$ARGUMENTS` → `"src/main.ts"`.

### `$name` substitution (named arguments)

```yaml
---
arguments: filename format
---

Convert $filename to $format format.
```

`$ARGUMENTS` is still available as the full positional string.

### `$SELECTION` substitution

`$SELECTION` is replaced with the currently selected text in the editor (VS Code / JetBrains integration).

## Dynamic context injection: `!` prefix

A line starting with `` !`<command>` `` runs the shell command and replaces the line with its output before Claude sees the skill content:

```markdown
## Current git status

!`git status`

## Current diff

!`git diff HEAD`
```

**Safety:** Never use `$ARGUMENTS` inside a `!`-prefixed shell line. `$ARGUMENTS` is unsanitised caller input — `foo.txt; rm -rf ~` would execute. Prefer tool-based access when arguments touch the shell.

## `@` file references

`@path/to/file.md` inline in skill body causes Claude Code to load that file's contents into the skill context when the skill loads.

## Plugin-namespaced commands

Plugin skills use `/plugin-name:skill-name` syntax. They cannot conflict with personal or project skills. Install via:

```bash
claude plugin install <name>@<marketplace>
```

## Supporting files

Beyond `SKILL.md`, a skill directory can contain any files:

```
my-skill/
├── SKILL.md           # Required — main instructions
├── template.md        # Template for Claude to fill in
├── examples/
│   └── sample.md      # Example output
└── scripts/
    └── validate.sh    # Script Claude can execute
```

Reference supporting files from `SKILL.md` so Claude knows they exist.

## Skill content lifecycle

Once a skill loads, its content stays in context across turns — each line is a recurring token cost. Keep the skill body concise. State what to do rather than narrating how or why.

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

- `SKILL.md` must be named exactly `SKILL.md` (case-sensitive on Linux).
- `allowed-tools` uses PascalCase tool names: `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`, `WebFetch`, `WebSearch`.
- Vague `description` ("helps with code") loses ranking against specific skills. Put the key use case first.
- Do NOT put `$ARGUMENTS` inside a `!`-shell line (injection risk).
- Skill directory name = the command name (e.g. directory `deploy` → `/deploy`). Special chars in directory names may cause invocation issues.

---

*Source pages: [`skills.md`](https://code.claude.com/docs/en/skills.md), [`commands.md`](https://code.claude.com/docs/en/commands.md), [`sub-agents.md`](https://code.claude.com/docs/en/sub-agents.md) — audited 2026-05-18.*
