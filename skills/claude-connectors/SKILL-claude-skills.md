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

Skills follow the [Agent Skills specification](https://agentskills.io/specification),
a platform-agnostic open standard.

**Requirements:** Available on Pro, Max, Team, and Enterprise plans.
**Code execution must be enabled** for skills to work.

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single recipe (e.g., "review my pull requests for
  security issues using my org's checklist").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").

## Skill types

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built for document creation (Excel, Word, PowerPoint, PDF); activate automatically |
| **Partner skills** | From partners like Notion, Figma, Atlassian; designed for seamless MCP integration |
| **Organization-provisioned** | Deployed org-wide by Team/Enterprise admins |
| **Custom skills** | Created by the user for specialized workflows |

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

## Activation model — progressive disclosure

Skills use progressive disclosure to manage context efficiently:

1. **Metadata loading** — Claude reads skill names + descriptions at
   startup (~100 tokens each).
2. **Activation** — when a task matches a skill's description, Claude
   loads the full `SKILL.md` content.
3. **Resource loading** — additional files (scripts, references,
   assets) are loaded only when needed.

This prevents context-window overload while providing specialized
capabilities on demand.

## SKILL.md schema

A `SKILL.md` starts with YAML frontmatter:

```yaml
---
name: brand-guidelines          # lowercase, numbers, hyphens; max 64 chars; must match dir name
description: Apply Acme Corp…   # Claude uses this for activation; max 200 chars on Claude.ai
dependencies: pandas>=1.5.0     # optional; for scripts (Python/JS/Bash)
---
```

`description` max is 200 characters on Claude.ai (the Agent Skills spec
allows 1024, but Claude.ai enforces 200).

### Directory structure

```
my-skill/
├── SKILL.md          # required; keep under 500 lines
├── scripts/          # optional; Python, Node.js, or Bash
├── references/       # optional; extra docs Claude reads on demand
└── assets/           # optional; templates, images, data files
```

### Packaging for upload

ZIP must contain the skill *directory* (not files at root):

```
✅  my-skill.zip → my-skill/ → SKILL.md
❌  my-skill.zip → SKILL.md   (flat — rejected)
```

Validate before uploading: `skills-ref validate ./my-skill`
([validation tool](https://github.com/agentskills/agentskills/tree/main/skills-ref)).

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
