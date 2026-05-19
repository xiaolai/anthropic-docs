---
name: example-skill
description: Template example showing the SKILL.md structure — replace this description with one that names YOUR skill's concrete trigger condition ("Triggers when the user asks how to X, Y, Z"). Keep it ≤200 characters for best intent-matching.
user-invocable: false
---

# Example Skill

This is a minimal SKILL.md showing the required structure.

## What every skill needs

1. **YAML frontmatter** with `name` and `description`. `description` is what Claude reads at intent-match time, so make it specific and name the trigger condition.
2. **A short body** that Claude reads on activation. Keep it ≤2,000 tokens for the single-file case.

## When the skill is bigger than 2,000 tokens

Split into a router + per-surface deep references, and load them on demand:

```markdown
---
name: my-skill
description: Router for my-skill. Use when the user asks about X, Y, or Z.
---

# My Skill — Router

| Surface | Read when… |
|---|---|
| [`SKILL-foo.md`](SKILL-foo.md) | User asks about Foo |
| [`SKILL-bar.md`](SKILL-bar.md) | User asks about Bar |
```

The router stays small (≤100 lines), and Claude reads the surface files only when the dispatch table maps to them. This repo's own `SKILL.md` is an example of the pattern.

## Cross-reference

If a fact lives in another skill (e.g., a sibling deep reference), link to it with a markdown link rather than duplicating.
