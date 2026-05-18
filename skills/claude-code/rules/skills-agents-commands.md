---
name: claude-code-skills-agents-commands-edits
description: Auto-correction rules that fire when Claude authors or edits SKILL.md files, agent definitions, or slash commands. Catches frontmatter typos, wrong tool names, missing required fields, and convention drift documented in the upstream issue tracker.
appliesTo:
  - "**/.claude/skills/**/SKILL.md"
  - "**/skills/**/SKILL.md"
  - "**/.claude/agents/**/*.md"
  - "**/agents/**/*.md"
  - "**/.claude/commands/**/*.md"
  - "**/commands/**/*.md"
---

# Rules: editing skills, agents, and slash commands

> *This file is auto-updated. The research agent adds rules as it
> finds common mistakes in `anthropics/claude-code` issues.*

## Cross-reference

For slash command frontmatter, see [`SKILL-slash-commands.md`](../SKILL-slash-commands.md).
For agent and skill conventions, the upstream docs at
`code.claude.com/docs/en/skills.md` and `agents.md` are authoritative.

## Rules

<!-- seed: replace on first real research pass -->

### Frontmatter `description` is the intent-match surface — make it specific

Claude reads `description` to decide whether to load the skill / agent / command. Vague descriptions ("helps with code") match weakly and lose ranking to more specific siblings. Name the concrete trigger condition: "Use when the user asks about X, Y, or Z. Skip when the user asks about A."

### Skill file must be named `SKILL.md` exactly

Case-sensitive on Linux. `Skill.md`, `skill.md`, or `SKILLS.md` will not be discovered. The file must live at `.claude/skills/<name>/SKILL.md` (project) or `~/.claude/skills/<name>/SKILL.md` (user).

### Slash command `allowed-tools` uses PascalCase tool names

Tool names match Claude Code's internal capitalisation: `Read`, `Write`, `Edit`, `Bash`, `Grep`, `Glob`, `WebFetch`, `WebSearch`. Lowercase (`read`, `bash`) is silently treated as "no allowlist", which permits all tools — the opposite of the author's intent.

### Agent frontmatter `tools`: prefer the comma-separated form

The comma-separated string form is the canonical and most widely-tested format:

```yaml
tools: Read, Grep, Glob       # canonical
tools: [Read, Grep, Glob]     # also accepted (YAML flow sequence)
```

Block-style YAML lists (`tools:\n  - Read\n  - Grep`) are valid YAML and the Claude Code parser accepts them the same as the other two forms. The comma-separated form is just the convention you'll see in the docs and most existing agents — pick it for grep-ability and consistency, but all three forms work.

### Never put `$ARGUMENTS` in a `!`-prefixed shell line

`$ARGUMENTS` is unsanitized caller input. Putting it in an inline shell (`` !`command $ARGUMENTS` ``) is a shell-injection vector — a caller input like `foo.txt; rm -rf ~` runs as three shell commands. Use the `Read` tool or another built-in tool instead of `!`-shell when the argument is a file path or other user-controlled input.

### `disable-model-invocation` vs `user-invocable`: two different gates

`disable-model-invocation: true` prevents Claude from triggering the skill automatically — users can still invoke it with `/skill-name`. `user-invocable: false` hides the skill from the `/` menu — Claude can still auto-trigger it. To make a skill Claude-only (not user-invocable, not auto-triggered), combine both: `user-invocable: false` and `disable-model-invocation: true`.

### `skillOverrides` in project settings affects all team members

`skillOverrides` is read from `settings.json` (project scope), which is committed to git. Setting `"skill-name": "off"` in a project `.claude/settings.json` hides that skill for every collaborator on the repo. To override only for yourself, put `skillOverrides` in `.claude/settings.local.json` (gitignored). Requires v2.1.129+.
