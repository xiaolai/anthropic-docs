---
name: claude-skills-user-facing
description: |
  Deep reference for user-facing Agent Skills in Claude — how
  users discover, install, manage, and invoke Skills inside the
  Claude app. Includes the skill directory, per-conversation
  control, and the relationship between user-facing Skills and the
  Skills format spec (which lives in anthropic-platform-features).
source: https://claude.com/docs/skills/overview.md
---

# Claude Skills — User-Facing

> *Router lives in [`SKILL.md`](SKILL.md). For the *authoring* spec
> of the .skill package format, see
> [`anthropic-platform-features → SKILL-agents-and-tools.md`](../anthropic-platform-features/SKILL-agents-and-tools.md).
> This surface covers what users see and do.*

## What Skills are (user view)

Skills are directories containing a `SKILL.md` file plus optional
scripts, references, and assets. Claude dynamically loads a skill's
instructions when the task matches the skill's description.

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single recipe (e.g., "apply Acme Corp brand
  guidelines to presentations").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire sales team's standard toolkit").

Skills follow the open [Agent Skills specification](https://agentskills.io/specification),
a platform-agnostic standard — skills you create can work across any
platform adopting the standard.

Source: [`skills/overview.md`](https://claude.com/docs/skills/overview.md),
[`skills/how-to.md`](https://claude.com/docs/skills/how-to.md).

## Availability

Skills are available to users on **Pro, Max, Team, and Enterprise**
plans. **Code execution must be enabled** for the skill to load and
run scripts.

## Types of skills

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built for document creation (Excel, Word, PowerPoint, PDF) — activate automatically when relevant |
| **Partner skills** | From partners like Notion, Figma, and Atlassian, designed for MCP connector integration |
| **Organization-provisioned** | Deployed org-wide by Team / Enterprise admins |
| **Custom skills** | User-created for specialized workflows (email generation, brand guidelines, JIRA integration, etc.) |

## SKILL.md structure

Every skill is a directory whose name matches the `name` field in
`SKILL.md`. Minimum structure:

```
brand-guidelines/
├── SKILL.md          # required
├── scripts/          # optional: executable code
├── references/       # optional: additional docs
└── assets/           # optional: templates, images, data
```

Required frontmatter fields:

| Field | Constraint |
|---|---|
| `name` | Lowercase letters, numbers, hyphens; max 64 chars; must match the directory name |
| `description` | When to invoke the skill; **max 200 chars on Claude.ai** (spec allows 1024) |

Optional frontmatter: `dependencies` (e.g. `python>=3.8, pandas>=1.5.0`).

Keep the main `SKILL.md` body under 500 lines; move detailed reference
material to separate files.

## Packaging and upload

To upload a skill to Claude.ai:

1. Ensure the directory name matches the `name` field.
2. Create a ZIP containing the skill directory (the directory must be
   inside the ZIP, not files directly at the ZIP root).
3. Upload via **Settings → Capabilities** → install skill.
4. Validate locally first: `skills-ref validate ./my-skill` ([validation tool](https://github.com/agentskills/agentskills/tree/main/skills-ref)).

**Correct ZIP structure:**
```
my-skill.zip
└── my-skill/
    ├── SKILL.md
    └── scripts/
```

## Activation model

Claude uses progressive disclosure:

1. **Metadata loading** — reads skill `name` + `description` at startup (~100 tokens each).
2. **Activation** — when a task matches the `description`, loads the full `SKILL.md`.
3. **Resource loading** — additional files loaded only when referenced.

Multiple skills can activate together automatically for composite tasks.

## Cross-product availability

| Platform | Support |
|---|---|
| **Claude.ai (web)** | Full — manage via Settings → Capabilities |
| **Claude Desktop** | Full |
| **Claude Code (CLI)** | Full — skills in `~/.claude/skills/` or project `.claude/skills/` |
| **Claude Cowork** | Full — org distribution via MDM for Cowork on 3P |

## Example skills

Community examples: [`github.com/anthropics/skills`](https://github.com/anthropics/skills/tree/main/skills).

## Related surfaces

- [`SKILL-claude-plugins.md`](SKILL-claude-plugins.md) — plugins
  (which bundle skills + connectors + more).
- [`SKILL-connectors-overview.md`](SKILL-connectors-overview.md) —
  connectors (the action-taking layer that skills compose).
- [`anthropic-platform-features → SKILL-agents-and-tools.md`](../anthropic-platform-features/SKILL-agents-and-tools.md)
  — the `.skill` package format spec.

## Page index

All source pages under
[`https://claude.com/docs/skills/`](https://claude.com/docs/skills/)
— see the directory listing for the current set.

---

*Source pages: under `claude.com/docs/skills/`.*
