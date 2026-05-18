---
name: claude-code-slash-commands
description: |
  Deep reference for Claude Code slash commands and skills. Covers
  skill authoring (SKILL.md frontmatter schema, description, when_to_use,
  allowed-tools, model, invocation control), dynamic context injection
  with !`...` and ` ```! ` blocks, $ARGUMENTS substitution, the @
  file-reference prefix, skill discovery paths (user / project / plugin),
  namespacing, and the complete catalog of built-in commands.
  Read this file when the user asks about writing or debugging a slash
  command or skill, skill frontmatter, command discovery, or what
  built-in commands are available.
source: https://code.claude.com/docs/en/skills.md
---

# Claude Code — Slash Commands and Skills

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here for slash command / skill questions.*

## Skills overview

Skills extend what Claude can do. A skill is a `SKILL.md` file (with optional supporting files in the same directory) that gives Claude instructions. Claude uses skills when relevant, or you invoke one directly with `/skill-name`.

**Custom commands have merged into skills.** A file at `.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy` and work the same way. Existing `.claude/commands/` files keep working. Skills add: a directory for supporting files, frontmatter to control invocation, and the ability for Claude to auto-load them.

Claude Code skills follow the [Agent Skills](https://agentskills.io) open standard.

Source: `code.claude.com/docs/en/skills.md` (note: docs URL `slash-commands.md` redirects here)

## Discovery paths

| Location | Scope | Command prefix |
|---|---|---|
| `~/.claude/skills/<name>/SKILL.md` | User (all projects) | `/<name>` |
| `~/.claude/commands/<name>.md` | User (all projects) | `/<name>` |
| `.claude/skills/<name>/SKILL.md` | Project | `/<name>` |
| `.claude/commands/<name>.md` | Project | `/<name>` |
| Plugin `skills/<name>/SKILL.md` | When plugin is enabled | `/<plugin>:<name>` |
| Plugin `commands/<name>.md` | When plugin is enabled | `/<plugin>:<name>` |

The directory name (or filename without `.md`) becomes the slash command name.

## Frontmatter schema

A `SKILL.md` file has YAML frontmatter between `---` markers followed by the skill body:

| Key | Required | Notes |
|---|---|---|
| `description` | yes (for auto-invoke) | One-line summary. Claude uses this to decide when to auto-load the skill. Keep clear and specific. |
| `when_to_use` | no | Longer description of when Claude should invoke the skill automatically. Shown when the skill listing is not truncated. |
| `argument-hint` | no | Placeholder text shown after the command name, e.g., `"<file path>"`. |
| `allowed-tools` | no | Comma-separated tool list (e.g., `Read, Bash(git:*)`). Restricts what the command can call. `Bash(<matcher>)` narrows to specific subcommands. |
| `model` | no | Optional model override for this skill's invocation. |
| `user-invocable` | no | `true` (default) = user can invoke with `/name`. `false` = Claude-only, not shown to user. |
| `disableSummarization` | no | If `true`, the skill body is never summarized/compacted away. |
| `tools` | no | Restrict which built-in tools this skill can use (same syntax as `--tools` CLI flag). |

Minimal skill (`~/.claude/skills/summarize-changes/SKILL.md`):

```markdown
---
description: Summarizes uncommitted changes and flags risks. Use when the user asks what changed or wants a commit message.
argument-hint: "[branch]"
allowed-tools: Read, Bash(git diff *)
---

## Current changes

!`git diff HEAD`

## Instructions

Summarize the changes in 2–3 bullet points. Flag risks like missing error handling, hardcoded values, or tests that need updating.
```

## Dynamic context injection: `!` prefix

The `!` prefix on a line runs a shell command and inlines the output into the skill body **before** Claude sees it.

**Inline shell execution:**
```markdown
!`git diff HEAD`
```
Replaced with: the actual diff output.

**Fenced shell block** (multi-line):
````markdown
```!
git log --oneline -10
```
````

**Variables are expanded** but the result is embedded at load time, not at runtime.

**Security:** `disableSkillShellExecution: true` in managed settings blocks `!` execution and replaces with `[shell command execution disabled by policy]`. This applies to user, project, and plugin skills (not bundled/managed skills).

## Argument substitution: `$ARGUMENTS`

`$ARGUMENTS` is replaced with whatever text the user types after the command name.

```markdown
---
description: Count words in a file.
argument-hint: "<file path>"
allowed-tools: Read
---

Count the words in $ARGUMENTS. Read the file and report `<path>: <N> words`.
```

**Safety warning:** Never put `$ARGUMENTS` into a `!`-prefixed shell line. The `!` prefix invokes a shell, and `$ARGUMENTS` is unsanitized caller input — `foo.txt; rm -rf ~` would be three commands. Use `allowed-tools: Read` (like above) instead of `!cat $ARGUMENTS`.

## File references: `@` prefix

In the input box, `@<path>` inlines a file reference. In skill bodies, this is less common but the `@` syntax can reference supporting files in the same skill directory.

## Namespacing and plugin-shipped skills

Skills shipped by plugins use `<plugin-name>:<skill-name>` syntax: `/my-plugin:deploy`.

To invoke a project-level skill that conflicts with a user-level skill, use the project qualifier.

## Control who invokes a skill

- `user-invocable: true` (default) — shows in `/` completion, user can invoke
- `user-invocable: false` — Claude auto-invokes only, not shown in `/` list

## Run skills in a subagent

Add `isolation: worktree` or `subagent: true` to frontmatter to run the skill in an isolated subagent context (uses a git worktree or separate agent process).

## Built-in commands (selected)

Built-in commands are coded into the CLI (not prompt-based). Bundled skills are prompt-based and marked **[Skill]**. Full list: `code.claude.com/docs/en/commands.md`.

| Command | Purpose |
|---|---|
| `/add-dir <path>` | Add a working directory for file access this session |
| `/agents` | Manage subagent configurations |
| `/background [prompt]` | Detach session to run as background agent |
| `/batch <instruction>` | **[Skill]** Orchestrate large-scale changes in parallel worktrees |
| `/branch [name]` | Create a branch of current conversation |
| `/btw <question>` | Ask a side question without adding to conversation |
| `/clear [name]` | Start new conversation with empty context |
| `/compact [instructions]` | Summarize conversation to free context |
| `/config` | Open Settings interface |
| `/context [all]` | Visualize context usage |
| `/debug [description]` | **[Skill]** Enable debug logging and troubleshoot |
| `/diff` | Interactive diff viewer |
| `/doctor` | Diagnose installation and settings |
| `/effort [level\|auto]` | Set model effort level |
| `/feedback [report]` | Submit feedback / bug report |
| `/fewer-permission-prompts` | **[Skill]** Add allowlist rules to reduce prompts |
| `/goal [condition]` | Set a completion condition; Claude works until met |
| `/hooks` | View hook configurations |
| `/init` | Initialize CLAUDE.md |
| `/keybindings` | Open/create keybindings config |
| `/loop [interval] [prompt]` | **[Skill]** Run prompt repeatedly on a schedule |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md, manage auto-memory |
| `/model [model]` | Select/change AI model |
| `/permissions` | Manage allow/ask/deny rules |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/recap` | Generate session summary on demand |
| `/remote-control` | Make session available for remote control |
| `/resume` | Return to or fork an earlier conversation |
| `/rewind` | Roll code and conversation back to a checkpoint |
| `/review` | **[Skill]** Deep read-only code review |
| `/security-review` | **[Skill]** Security-focused code review |
| `/simplify` | **[Skill]** Review recent files and apply quality fixes |
| `/skills` | Manage skill visibility |
| `/teleport` | Pull a web session into this terminal |
| `/tui` | Toggle fullscreen rendering mode |
| `/ultrareview [target]` | **[Skill]** Multi-agent cloud code review |
| `/usage` | Show usage/cost breakdown |

Full built-in command list: `code.claude.com/docs/en/commands.md`

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

See [`rules/skills-agents-commands.md`](rules/skills-agents-commands.md). Key pitfalls:
- Don't put `$ARGUMENTS` in `!`-prefixed shell lines (injection risk)
- `allowed-tools` must be a string, not an array
- Frontmatter `---` delimiters must be on their own lines

---

*Source pages: `code.claude.com/docs/en/skills.md`, `code.claude.com/docs/en/commands.md`.*
