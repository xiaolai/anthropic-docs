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

Block-style YAML lists (`tools:\n  - Read\n  - Grep`) have not been verified across Claude Code versions — prefer one of the two forms above until upstream docs confirm block-list parsing.

---

*Last reviewed: <pipeline-stamp>.*
