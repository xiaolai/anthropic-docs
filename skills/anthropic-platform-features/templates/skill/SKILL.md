---
name: my-skill
description: One-paragraph description of what this skill does and when Claude should activate it. Use specific intent triggers ("Use when the user asks about X, Y, Z"). The platform's skill matcher reads THIS field — write it for matching, not for marketing. Stay under 1024 chars. Include Skip clauses for adjacent intents that should NOT match.
---

# My Skill

> *Template starting point for an Agent Skill (.skill package).
> Customize the frontmatter above and the sections below.
> See rules/agent-skills.md for authoring rules.*

## What this skill does

A few paragraphs of conceptual overview. What domain does this cover?
What workflows does it support? What's the user's likely starting
context when activating?

## When to use

Be specific. List intent patterns:

- "How do I X" → ...
- "Fix Y" → ...
- File patterns: when editing `**/*.foo` → ...

## Workflows

Walk Claude through the typical patterns step by step. Keep it actionable.

### Workflow 1: ...

1. First step
2. Second step

### Workflow 2: ...

...

## Reference

Deep reference details belong in `references/X.md` (loaded on demand
via Read), not in this top-level SKILL.md. Linking pattern:

- For schema details, see [`references/schemas.md`](references/schemas.md)
- For API reference, see [`references/api.md`](references/api.md)

## Cross-references

If this skill cohabits with siblings, name them and when to defer:

- For X questions: use the `other-skill` skill instead
- For Y questions: this skill covers it
