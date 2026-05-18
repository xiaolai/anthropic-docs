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

Claude Code discovers commands and skills from these paths (in search order):

| Path | Scope | Notes |
|---|---|---|
| `~/.claude/commands/` | User (all projects) | Personal commands |
| `~/.claude/skills/` | User (all projects) | Personal skills |
| `.claude/commands/` | Project | Team-shared (git-committed) |
| `.claude/skills/` | Project | Team-shared (git-committed) |
| Plugin `commands/` and `skills/` | When plugin enabled | Namespaced as `/<plugin>:<name>` |

A standalone skill (non-plugin) in `.claude/skills/hello/SKILL.md` is invoked as `/hello`. A plugin skill is `/my-plugin:hello`.

Source: `code.claude.com/docs/en/skills.md`, `code.claude.com/docs/en/commands.md`.

## Frontmatter schema

<!-- seed: replace on first real research pass -->

A slash command is a Markdown file with YAML frontmatter. Common keys:

| Key | Type | Notes |
|---|---|---|
| `description` | string | One-line summary shown in command lists. Keep ≤120 chars. |
| `argument-hint` | string | Placeholder text shown after the command name, e.g. `"<file path>"`. |
| `allowed-tools` | string | Comma-separated tool list (e.g. `Read, Bash(git:*)`). Restricts what the command can call. The `<Tool>(<matcher>)` parenthetical narrows a tool to specific invocations (see `SKILL-settings.md` `permissions` block for the matcher grammar). |
| `model` | string | Optional model override for this command's invocation. |

Additional frontmatter fields for skills (`.claude/skills/<name>/SKILL.md`):

| Key | Type | Notes |
|---|---|---|
| `description` | string | One-line summary shown in `/` menu and to Claude for auto-invocation. |
| `when_to_use` | string | Longer description of when Claude should auto-invoke this skill. |
| `argument-hint` | string | Placeholder text after the command name in the UI. |
| `allowed-tools` | string | Comma-separated allowed tools, e.g. `"Read, Bash(git:*)"`. |
| `model` | string | Optional model override for this invocation. |
| `user-invocable` | boolean | If `false`, hides from the `/` menu (Claude can still auto-invoke). Default: `true`. |
| `disable-model-invocation` | boolean | If `true`, runs as a pure template/macro — no model call. |

Source: `code.claude.com/docs/en/skills.md`.

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

`$ARGUMENTS` in the skill/command body is replaced with everything the user types after the command name.

Example: if the skill body contains `"Fix $ARGUMENTS"` and the user types `/fix auth-bug`, Claude receives `"Fix auth-bug"`.

**Security note**: never use `$ARGUMENTS` directly in a `!`-prefixed shell line. `$ARGUMENTS` is unsanitized caller input — `foo.txt; rm -rf ~` would execute as three commands. Use `allowed-tools: Read` (or another non-Bash tool) when the input touches `$ARGUMENTS`.

Source: `code.claude.com/docs/en/skills.md`.

## Inline shell execution: `!` prefix

A line starting with `!` in a skill body is executed as a shell command, and its stdout is substituted in place before Claude sees the prompt.

Example:
```markdown
!git log --oneline -20
```
Expands to the last 20 git log lines in Claude's context.

A `` `!command` `` backtick form also works inline.

**Security**: inline shell execution in skills from user, project, plugin, or additional-directory sources can be disabled by setting `disableSkillShellExecution: true` in managed settings. Bundled and managed skills are unaffected.

Source: `code.claude.com/docs/en/skills.md`.

## File references: `@` prefix

In interactive input, `@<path>` includes the contents of a file in your message. Tab-completes from files in your project.

Example: `@src/auth.ts explain this file`

`respectGitignore` setting (default: `true`) controls whether `.gitignore` patterns exclude files from `@` autocomplete.

Source: `code.claude.com/docs/en/settings.md`, `code.claude.com/docs/en/commands.md`.

## Namespacing and plugin-shipped commands

Plugin commands/skills are always namespaced with the plugin name: `/<plugin-name>:<command-name>`. This prevents conflicts between plugins that have commands with the same name.

To change the namespace prefix, update the `name` field in `plugin.json`.

Standalone commands (not in a plugin) use bare names: `/hello`, `/deploy`.

Source: `code.claude.com/docs/en/plugins.md`.

## Worked examples

> *Populated by the research agent.* See also:
> [`templates/commands/`](templates/commands/).

## Built-in commands reference (key subset)

The full command reference is at [`SKILL-slash-commands.md` source: commands.md](https://code.claude.com/docs/en/commands.md). Key commands:

| Command | Purpose |
|---|---|
| `/clear` | Start fresh (previous conversation available via `/resume`) |
| `/compact [instructions]` | Free up context by summarizing |
| `/config` | Open settings interface |
| `/context` | Visualize context window usage |
| `/diff` | Interactive diff viewer |
| `/doctor` | Diagnose installation issues |
| `/hooks` | View hook configurations |
| `/init` | Initialize CLAUDE.md for the project |
| `/mcp` | Manage MCP server connections |
| `/memory` | Edit CLAUDE.md files and auto-memory |
| `/model [model]` | Select or change the AI model |
| `/permissions` | Manage allow/ask/deny rules |
| `/plan [description]` | Enter plan mode |
| `/plugin` | Manage plugins |
| `/reload-plugins` | Reload plugins without restarting |
| `/resume [session]` | Resume a previous conversation |
| `/rewind` | Rewind code/conversation to a checkpoint |
| `/skills` | List available skills |
| `/usage` | Show session cost and limits |

MCP prompts appear as `/mcp__<server>__<prompt>` commands.

Source: `code.claude.com/docs/en/commands.md`.

## Common mistakes (auto-corrected by `rules/skills-agents-commands.md`)

> *Populated by the research agent.*

---

*Source pages: `code.claude.com/docs/en/slash-commands.md`.*
