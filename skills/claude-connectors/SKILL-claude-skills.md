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

Skills are reusable task recipes — packaged instructions that teach
Claude how to perform a specific workflow. Once installed, a user
can invoke a skill in any conversation by referring to it; Claude
loads the skill's instructions and follows them.

**Availability**: Pro, Max, Team, and Enterprise plans. Requires
code execution to be enabled.

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single recipe (e.g., "review my pull requests for
  security issues using my org's checklist").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").

## Types of skills

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built by Anthropic for document creation (Excel, Word, PowerPoint, PDF) — activate automatically when relevant |
| **Partner skills** | From partners like Notion, Figma, Atlassian; designed for MCP connector integration |
| **Organization-provisioned** | Deployed org-wide by Team/Enterprise administrators |
| **Custom skills** | User-created for specialized workflows |

## SKILL.md schema

A skill is a directory. At minimum it contains a `SKILL.md` file.
The **directory name must match the `name` field**.

```
brand-guidelines/      ← directory name = skill name
├── SKILL.md
├── scripts/           # optional: executable code (.py/.js/.sh)
├── references/        # optional: docs Claude reads on demand
└── assets/            # optional: templates, images, data
```

**Required frontmatter fields:**

| Field | Constraints |
|---|---|
| `name` | Lowercase, numbers, hyphens only; max 64 chars; must match directory name |
| `description` | Max **200 chars** on Claude.ai; 1024 chars per the [Agent Skills spec](https://agentskills.io/specification) |

**Optional frontmatter:**
- `dependencies` — e.g. `python>=3.8, pandas>=1.5.0` (packages Claude installs from PyPI/npm)

**Packaging for upload**: ZIP the skill directory (not the files
directly). The ZIP must have the directory as the first level:

```
my-skill.zip
└── my-skill/      ← correct: directory inside ZIP
    └── SKILL.md
```

**Validate before upload**: `skills-ref validate ./my-skill`
([validation tool](https://github.com/agentskills/agentskills/tree/main/skills-ref)).

**Open standard**: Skills follow the [Agent Skills specification](https://agentskills.io/specification).
Example skills: [github.com/anthropics/skills](https://github.com/anthropics/skills/tree/main/skills).

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

## Activation model (progressive disclosure)

Skills use three-stage loading to keep context efficient:

1. **Metadata** — Claude reads name + description at startup
   (~100 tokens each).
2. **Activation** — When a task matches the skill's description,
   Claude loads the full `SKILL.md`.
3. **Resources** — Additional files (scripts, references, assets)
   loaded only when needed by Claude.

Source: [`skills/overview.md`](https://claude.com/docs/skills/overview.md).

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
