---
name: claude-code-slash-commands
description: |
  Deep reference for authoring Claude Code slash commands and skills.
  Covers SKILL.md frontmatter schema (description, when_to_use,
  argument-hint, allowed-tools, model, user-invocable), `$ARGUMENTS`
  substitution, the `!` shell-prefix for dynamic context injection,
  the `@` file-reference prefix, command/skill discovery paths
  (user / project / plugin / additional-dir), and namespacing.
  Read this file when the user asks about writing or debugging a slash
  command, skill SKILL.md, command frontmatter, or command discovery.
  Note: custom commands (.claude/commands/) and skills
  (.claude/skills/<name>/SKILL.md) are unified; skills are the
  recommended format.
source: https://code.claude.com/docs/en/skills.md
---

# Claude Code — Skills and Slash Commands

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for slash command / skill questions.*

> **Skills are the unified format for custom commands.** Files in `.claude/commands/deploy.md`
> and skills at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way.
> Your existing `.claude/commands/` files keep working. Skills add: a directory for supporting
> files, frontmatter to control invocation, and ability for Claude to load them automatically.
> Source: `code.claude.com/docs/en/skills.md`.

## Discovery paths

Source: `code.claude.com/docs/en/skills.md`.

| Level | Path | Who can use it |
|---|---|---|
| Enterprise | Admin-managed | All users in org |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Personal (legacy) | `~/.claude/commands/<name>.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Project (legacy) | `.claude/commands/<name>.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |

Skills also load from parent directories up to the repo root, and from nested `.claude/skills/` under directories being edited (monorepo support). Skills from `--add-dir` directories are also loaded. Claude Code watches for file changes during a session — no restart needed for edits to existing skills.

Plugin skills use `plugin-name:skill-name` namespace to avoid conflicts. Skill takes precedence if a skill and command share the same name.

## Frontmatter schema

A skill is a `SKILL.md` file (or a flat `.md` file in `commands/`) with YAML frontmatter. Source: `code.claude.com/docs/en/skills.md`.

| Key | Type | Notes |
|---|---|---|
| `description` | string | One-line summary. Helps Claude decide when to auto-invoke the skill. |
| `when_to_use` | string | Longer explanation of when Claude should invoke this skill automatically. |
| `argument-hint` | string | Placeholder text shown after the skill name (e.g. `"<file path>"`). |
| `allowed-tools` | string | Comma-separated tool list (e.g. `Read, Bash(git:*)`). Restricts what the skill can invoke. |
| `model` | string | Optional model override for this skill's invocation. |
| `user-invocable` | boolean | If `false`, Claude can only invoke it automatically; users cannot type `/skill-name`. Default: `true`. |
| `agent` | string | Run this skill in the named subagent (e.g. `agent: general-purpose`). |

Minimal skill (`~/.claude/skills/count-words/SKILL.md`):

```markdown
---
description: Count words in a file. Use when user asks about word count.
argument-hint: "<file path>"
allowed-tools: Read
---

Count the words in $ARGUMENTS. Read the file and report `<path>: <N> words`.
```

**Avoid putting `$ARGUMENTS` into a `!`-prefixed shell line.** The `!` prefix invokes a shell and `$ARGUMENTS` is unsanitized caller input — injection risk.

## Argument substitution: `$ARGUMENTS`

`$ARGUMENTS` is replaced with everything the user typed after the skill name. For example, `/count-words src/main.py` sets `$ARGUMENTS` to `src/main.py`. Multiple words are included verbatim.

**Safety:** Do not put `$ARGUMENTS` in a `!`-prefixed shell line — it is unsanitized and allows injection. Use `Read($ARGUMENTS)` or pass it to Claude as prose.

## Inline shell execution: `!` prefix

Lines starting with `` ! `` or `` !` `` (backtick) in skill body are replaced with shell command output before Claude sees the skill content. This injects dynamic context:

```markdown
## Current changes

!`git diff HEAD`
```

The inline shell execution runs at invocation time, not at definition time. The `disableSkillShellExecution: true` managed setting blocks this for user/project/plugin skills.

## File references: `@` prefix

Use `@filename` in the skill body to inline file contents. Claude Code expands the reference before sending to the model.

## Namespacing and plugin-shipped commands

Plugin skills are namespaced as `plugin-name:skill-name` (e.g. `/my-plugin:deploy`). If you type `/deploy` and both a project skill and a plugin skill have that name, the project skill wins.

Plugin skills are defined in `<plugin>/skills/<skill-name>/SKILL.md` and activate when the plugin is enabled.

## Worked examples

Simple workflow skill (project-level, `.claude/skills/pr-review/SKILL.md`):

```markdown
---
description: Review the current branch's changes for bugs and regressions.
---

Review the git diff against the main branch. Focus on: logic errors,
missing error handling, test coverage gaps, and performance regressions.

!`git diff main..HEAD --stat`
!`git diff main..HEAD`
```

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

> *Populated by the research agent from issue tracker.*

---

*Source pages: `code.claude.com/docs/en/slash-commands.md`.*
