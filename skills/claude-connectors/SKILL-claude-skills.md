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
a `SKILL.md` file that defines when it should be activated and what
instructions Claude should follow.

Skills use **progressive disclosure** to stay efficient:

1. Claude reads skill names + descriptions at startup (~100 tokens each).
2. When a task matches a skill's description, Claude loads the full
   `SKILL.md` content.
3. Additional files (scripts, references) are loaded only when needed.

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single recipe (e.g., "review my pull requests for
  security issues using my org's checklist").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").
- **Skills cannot be submitted to the Connectors Directory on their own**
  — plugins are the distribution mechanism for skills.

## Plan availability

Skills require a **Pro, Max, Team, or Enterprise** plan. The Skills
feature also requires **code execution to be enabled** in account
settings. Skills are not available on Free plans.

Source: [`skills/overview.md`](https://claude.com/docs/skills/overview.md).

## Types of skills

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built skills for document creation (Excel, Word, PowerPoint, PDF) — activate automatically when relevant |
| **Partner skills** | Skills from partners like Notion, Figma, and Atlassian for seamless MCP connector integration |
| **Organization-provisioned** | Skills deployed org-wide by Team / Enterprise admins |
| **Custom skills** | Skills you create for specialized workflows |

## Open standard

Skills follow the [Agent Skills specification](https://agentskills.io/specification),
a platform-agnostic standard. Skills created for Claude can work
across any platform that adopts the standard.

## Skill format quick-ref

Source: [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md).

**Directory structure** (minimum `SKILL.md` required):

```
brand-guidelines/
├── SKILL.md          # required — frontmatter + instructions
├── scripts/          # optional — Python, JS, Bash
├── references/       # optional — additional documentation
└── assets/           # optional — templates, images, data
```

**`SKILL.md` required frontmatter fields:**

| Field | Constraints |
|---|---|
| `name` | Lowercase, hyphens only; max 64 chars; **must match directory name** |
| `description` | Max **200 chars** on Claude.ai (spec allows 1024) |

**Optional `dependencies` frontmatter** (for scripts):

```yaml
---
name: data-analysis
description: Analyze CSV files and generate visualizations.
dependencies: python>=3.8, pandas>=1.5.0, matplotlib
---
```

**Packaging for upload:**

```
my-skill.zip
└── my-skill/      ← skill directory INSIDE the zip
    └── SKILL.md
```

Files directly in the zip root (without a wrapping directory) will be
rejected. Validate before uploading with:
```bash
skills-ref validate ./my-skill
```

Example skills: [`github.com/anthropics/skills`](https://github.com/anthropics/skills/tree/main/skills).

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

## Activation model

Two activation patterns:

1. **Always-on** — the skill auto-loads when its trigger matches the
   conversation (e.g., a file path, a keyword, a tool call). Author
   configures this via the skill's frontmatter `appliesTo`.
2. **User-invoked** — the skill loads only when the user explicitly
   refers to it by name.

The Skills format spec (in
[`anthropic-platform-features`](../anthropic-platform-features/SKILL-agents-and-tools.md))
documents the activation field schema. This surface covers the
user-facing semantics.

## Cross-product availability

Requires Pro, Max, Team, or Enterprise plan plus code execution enabled.
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
