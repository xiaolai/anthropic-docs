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

Skills are directories containing instructions, scripts, and resources
that Claude dynamically loads to handle specific tasks. Each skill has
a `SKILL.md` file defining when it should be activated and what
instructions Claude should follow.

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single recipe (e.g., "review my pull requests for
  security issues using my org's checklist").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").

## Availability

Skills are available for users on **Pro, Max, Team, and Enterprise** plans.
The Skills feature **requires code execution to be enabled**.

## Types of skills

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built for document creation (Excel, Word, PowerPoint, PDF); activate automatically |
| **Partner skills** | From Notion, Figma, Atlassian; designed for MCP connector integration |
| **Organization-provisioned** | Deployed org-wide by Team/Enterprise administrators |
| **Custom skills** | User-created for specialized workflows |

## Open standard

Skills follow the [Agent Skills specification](https://agentskills.io/specification)
— a platform-agnostic open standard. Skills you create can work across any
platform adopting the spec.

## SKILL.md schema

A skill is a directory; at minimum it must contain a `SKILL.md` file.
The directory name must match the `name` field.

```
brand-guidelines/
├── SKILL.md
├── scripts/        # Optional: executable code
├── references/     # Optional: additional documentation
└── assets/         # Optional: templates, images, data files
```

Required frontmatter fields in `SKILL.md`:

| Field | Constraint |
|---|---|
| `name` | Lowercase letters, numbers, hyphens only; max 64 chars; must match directory name |
| `description` | What the skill does and when to use it. **Max 200 chars on Claude.ai** (spec allows 1024) |

Optional frontmatter:

| Field | Purpose |
|---|---|
| `dependencies` | Package deps loaded at activation, e.g. `python>=3.8, pandas>=1.5.0` |

Keep the `SKILL.md` body under 500 lines. Move detailed references to separate files.

## Packaging for upload

Create a ZIP file with the skill directory nested inside (not files at ZIP root):

```
my-skill.zip
└── my-skill/     ← directory name = name field
    ├── SKILL.md
    └── scripts/
```

Validate with [`skills-ref validate ./my-skill`](https://github.com/agentskills/agentskills/tree/main/skills-ref)
before uploading.

## Activation model

Skills use progressive disclosure:

1. **Metadata loading** — Claude reads skill names and descriptions at startup (~100 tokens each).
2. **Activation** — When a task matches a skill's description, Claude loads the full `SKILL.md`.
3. **Resource loading** — Scripts and reference files load only when needed.

Two activation patterns:
1. **Always-on / auto** — skill loads when its description matches the task.
2. **User-invoked** — skill loads only when the user explicitly refers to it.

## Where users find skills

Source pages under
[`https://claude.com/docs/skills/`](https://claude.com/docs/skills/)
cover the user-facing surface:

- Browsing the skill directory.
- Installing a skill from the directory.
- Installing a custom skill from a URL or file.
- Managing installed skills (enable/disable, update, remove).
- Per-conversation skill control (turn a skill on/off for a single
  conversation).

## Cross-product availability

Skills work in:

- **Claude.ai (web)** — installed skills available in conversations.
- **Claude Desktop** — same.
- **Claude Code (CLI)** — skills resolve from `~/.claude/skills/` or
  project-local `.claude/skills/`.
- **Claude Cowork** — full skills support (see
  [`claude-cowork`](../claude-cowork/SKILL.md)).

For Cowork on 3P, skill distribution happens via MDM — see
[`claude-cowork → SKILL-cowork.md`](../claude-cowork/SKILL-cowork.md).

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
