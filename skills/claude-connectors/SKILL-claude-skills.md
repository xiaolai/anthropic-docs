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

Skills are **directories** containing a `SKILL.md` file plus optional
scripts, references, and assets. They extend Claude with specialized
knowledge and workflows. Claude uses progressive disclosure to manage
context:

1. **Metadata loading** — Claude reads skill names and descriptions at
   startup (~100 tokens each).
2. **Activation** — when a task matches a skill's `description`, Claude
   loads the full `SKILL.md` body.
3. **Resource loading** — additional files (`scripts/`, `references/`,
   `assets/`) are loaded only when referenced.

Availability: **Pro, Max, Team, Enterprise** plans. Requires **code
execution** to be enabled.

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single workflow directory.
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (see [`SKILL-claude-plugins.md`](SKILL-claude-plugins.md)).

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

## SKILL.md format

Minimal valid `SKILL.md` (frontmatter + markdown body):

```markdown
---
name: brand-guidelines
description: Apply Acme Corp brand guidelines to presentations and
  documents, including official colors, fonts, and logo usage.
---

# Brand Guidelines
[...instructions...]
```

Required frontmatter fields:

| Field | Constraint |
|---|---|
| `name` | Lowercase letters, numbers, hyphens only; max 64 characters; must match the directory name |
| `description` | Tells Claude when to activate the skill; **max 200 characters on Claude.ai** (Agent Skills spec allows 1024) |

Optional: `dependencies` (e.g. `python>=3.8, pandas>=1.5.0`) — Claude
installs from PyPI/npm on load.

Source: [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md).

## Types of skills

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built for document creation (Excel, Word, PowerPoint, PDF); auto-activate when relevant |
| **Partner skills** | From partners (Notion, Figma, Atlassian) designed for MCP connector integration |
| **Organization-provisioned** | Deployed org-wide by Team / Enterprise administrators |
| **Custom skills** | User-created for specialized workflows |

## Open standard

Skills follow the [Agent Skills specification](https://agentskills.io/specification),
a platform-agnostic standard that works across any platform that adopts
it. Example skills: [github.com/anthropics/skills](https://github.com/anthropics/skills/tree/main/skills).

## Packaging and validation

1. Create a ZIP file containing the skill directory (directory name
   must match `name`).
2. Validate: `skills-ref validate ./my-skill`
   ([validation tool](https://github.com/agentskills/agentskills/tree/main/skills-ref))
3. Upload via **Settings → Capabilities** and enable the skill.
4. Test by trying prompts that should trigger it.

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
