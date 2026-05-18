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

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single recipe (e.g., "review my pull requests for
  security issues using my org's checklist").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").

Skills follow the [Agent Skills specification](https://agentskills.io/specification)
— an open, platform-agnostic standard. Skills you create can work
across any platform adopting that standard.

Source: [`skills/overview.md`](https://claude.com/docs/skills/overview.md).

## Plan availability

Skills require **Pro, Max, Team, or Enterprise** plan. The feature
also requires code execution to be enabled.

## Types of skills

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built for document creation (Excel, Word, PowerPoint, PDF); activate automatically |
| **Partner skills** | From partners like Notion, Figma, Atlassian; designed for MCP connector integration |
| **Organization-provisioned** | Deployed org-wide by Team/Enterprise admins |
| **Custom skills** | User-authored for specialized workflows |

## Context-efficiency loading model

Skills use progressive disclosure:

1. **Metadata loading** — Claude reads skill names and descriptions at startup (~100 tokens each).
2. **Activation** — when a task matches, Claude loads the full `SKILL.md`.
3. **Resource loading** — additional files (scripts, references) loaded only when needed.

## SKILL.md structure

Minimum: a directory containing a `SKILL.md` file:

```
brand-guidelines/
├── SKILL.md
├── scripts/        # Optional: executable code (Python / JS / Bash)
├── references/     # Optional: additional documentation
└── assets/         # Optional: templates, images, data
```

The directory name must match the `name` field in `SKILL.md`.

### Required frontmatter fields

```markdown
---
name: brand-guidelines          # lowercase, hyphens, max 64 chars; matches dir name
description: Apply Acme Corp brand voice…  # what it does and when to use it
---
```

**Description length limits:**
- **Claude.ai upload**: max **200 characters**
- **Agent Skills spec**: allows up to 1024 characters

### Optional frontmatter fields

```markdown
---
dependencies: python>=3.8, pandas>=1.5.0, matplotlib
---
```

`dependencies` — Claude installs these from PyPI / npm when loading the skill.

### Packaging for upload

ZIP the skill directory (directory must be inside the ZIP — not files at root):

```
# Correct
my-skill.zip
└── my-skill/
    ├── SKILL.md
    └── scripts/

# Wrong — files at ZIP root fail upload
my-skill.zip
├── SKILL.md
└── scripts/
```

### Validation

```bash
skills-ref validate ./my-skill
```

Validation tool: [github.com/agentskills/agentskills/tree/main/skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref).

Example skills library: [github.com/anthropics/skills](https://github.com/anthropics/skills/tree/main/skills).

Source: [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md).

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
