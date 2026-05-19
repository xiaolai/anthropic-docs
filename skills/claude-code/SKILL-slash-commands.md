---
name: claude-code-slash-commands
description: |
  Deep reference for authoring Claude Code skills and slash commands.
  Covers frontmatter schema (description, when_to_use, argument-hint,
  allowed-tools, model, disable-model-invocation, user-invocable),
  $ARGUMENTS and named argument substitution, the ! shell-prefix, the @
  file-reference prefix, skill discovery paths (user / project / plugin),
  and namespacing. Read this file when the user asks about writing or
  debugging a slash command or skill, skill frontmatter, or skill discovery.
source: https://code.claude.com/docs/en/skills.md
---

# Claude Code — Skills and Slash Commands

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for slash command / skill questions.*

> **Note:** "Custom commands" and "skills" are unified. A file at
> `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md`
> both create `/deploy` and work the same way. Skills are the recommended
> approach (they support supporting files and additional frontmatter features).

## Discovery paths

Skills are loaded from multiple locations (precedence: enterprise → personal → project):

| Scope | Path | Applies to |
|---|---|---|
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin is enabled |
| Legacy commands | `~/.claude/commands/<name>.md` | Personal commands (still work) |
| Legacy commands | `.claude/commands/<name>.md` | Project commands (still work) |

Claude Code also discovers skills from:
- Parent directories up to repo root (e.g., starting in a subdirectory still loads root-level skills)
- Nested subdirectories when you edit files in them (e.g., `packages/frontend/.claude/skills/`)
- `--add-dir` directories: `.claude/skills/` inside added dirs is loaded (exception to normal add-dir behavior)

Plugin skills use `plugin-name:skill-name` namespace (no conflicts). Skills and commands with the same name: skill takes precedence.

Source: [code.claude.com/docs/en/skills.md](https://code.claude.com/docs/en/skills.md)

## Frontmatter reference

A skill is a directory with `SKILL.md` as the entrypoint. All frontmatter fields are optional.

| Field | Notes |
|---|---|
| `name` | Display name (lowercase letters, numbers, hyphens; max 64 chars). Default: directory name. |
| `description` | **Recommended.** What the skill does; Claude uses this to decide when to auto-invoke. Combined with `when_to_use`, truncated to 1,536 chars in skill listing. |
| `when_to_use` | Additional context for when Claude should invoke (trigger phrases, example requests). Appended to `description` in listing. |
| `argument-hint` | Hint shown during autocomplete. Example: `"[issue-number]"` or `"[filename] [format]"`. |
| `arguments` | Named positional arguments for `$name` substitution. Space-separated string or YAML list. |
| `disable-model-invocation` | `true` = Claude cannot auto-load this skill; user must invoke with `/name`. Default: `false`. |
| `user-invocable` | `false` = hidden from `/` menu (background knowledge only). Default: `true`. |
| `allowed-tools` | Tools Claude can use without permission prompt while this skill is active. Space-separated or YAML list. |
| `model` | Model override while skill is active (e.g., `"claude-opus-4-7"`). Applies for current turn only. |
| `effort` | Effort level override: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"`. |
| `context` | `"fork"` to run in a forked subagent context. |

Minimal `SKILL.md`:

```markdown
---
description: Summarizes uncommitted changes and flags risky edits.
---

## Current changes

!`git diff HEAD`

## Instructions

Summarize the changes above in 2–3 bullet points, then list any risks you notice.
```

Legacy command file (`.claude/commands/wc.md` — still works):

```markdown
---
description: Count words in the given file.
argument-hint: "<file path>"
allowed-tools: Read
---

Count the words in $ARGUMENTS. Read the file and report `<path>: <N> words`.
```

## Argument substitution: `$ARGUMENTS`

`$ARGUMENTS` is replaced with everything the user typed after the command name:

```
/wc src/index.ts
```

In the skill body, `$ARGUMENTS` becomes `src/index.ts`.

**Named arguments** (using `arguments` frontmatter):

```yaml
---
arguments: filename format
---

Convert $filename to $format format.
```

Invoked as `/convert data.csv json`.

⚠️ **Security**: `$ARGUMENTS` is unsanitized user input. Never put it in a `!`-prefixed shell line (prompt injection / command injection risk). Prefer `Read` or other tools over `!` when the input touches `$ARGUMENTS`.

## Inline shell execution: `!` prefix

Lines starting with `!` (or backtick-fenced blocks starting with `` ```! ``) run a shell command and embed the output into the skill body before Claude processes it:

```markdown
---
description: Show git status with diff.
---

## Current state

!`git status`
!`git diff --stat`

Explain the changes above.
```

The shell output is injected at load time, so Claude sees real file content without needing to call a tool.

## File references: `@` prefix

Reference files in the skill body with `@path` syntax:

```markdown
Check @src/config.ts and update it to match the pattern in @examples/config-example.ts.
```

Claude reads these files and includes them in context.

## Namespacing and plugin-shipped commands

Plugin skills use `plugin-name:skill-name` syntax:
- Install: `/plugin install my-plugin@my-marketplace`
- Invoke: `/my-plugin:my-skill`

This prevents conflicts between plugins and standalone skills.

## Invoke a skill from the CLI

```bash
claude -p "/summarize-changes" --no-session-persistence
```

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

- Putting `$ARGUMENTS` in a `!` shell line — command injection risk.
- Using `allowed-tools: Read, Bash(git:*)` with a comma — the correct separator is a space, not a comma.
- Using `disable-model-invocation: true` when you want `user-invocable: false` — these do different things: `disable-model-invocation` prevents auto-loading; `user-invocable: false` hides from the `/` menu.
- Forgetting that skills in `~/.claude/skills/` take precedence over `.claude/skills/` when names conflict.

---

*Source pages: [code.claude.com/docs/en/skills.md](https://code.claude.com/docs/en/skills.md), [slash-commands.md](https://code.claude.com/docs/en/slash-commands.md).*
