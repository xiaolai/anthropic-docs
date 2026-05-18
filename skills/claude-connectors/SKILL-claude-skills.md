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
a `SKILL.md` file defining when it activates and what instructions to
follow.

Skills follow the [Agent Skills specification](https://agentskills.io/specification)
— a platform-agnostic open standard so skills can work across any platform
adopting it.

**Availability:** Pro, Max, Team, and Enterprise plans. Code execution must
be enabled.

**Skill types:**

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built for document creation (Excel, Word, PowerPoint, PDF); activate automatically |
| **Partner skills** | From partners like Notion, Figma, Atlassian; designed for MCP connector integration |
| **Organization-provisioned** | Deployed org-wide by Team/Enterprise admins |
| **Custom skills** | You create for specialized workflows |

**Progressive disclosure model** — skills use three-stage loading to manage
context efficiently:
1. Metadata loading: skill names + descriptions (~100 tokens each) at startup.
2. Activation: when a task matches, full `SKILL.md` content is loaded.
3. Resource loading: additional files (scripts, references) loaded on demand.

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single recipe (e.g., "review my pull requests for
  security issues using my org's checklist").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").

## Skill package format (`SKILL.md`)

A skill is a directory named to match the skill's `name` field, containing:

```
brand-guidelines/
├── SKILL.md          # required
├── scripts/          # optional: executable code
├── references/       # optional: additional docs
└── assets/           # optional: templates, images, data
```

`SKILL.md` starts with YAML frontmatter:

```yaml
---
name: brand-guidelines        # lowercase, hyphens; max 64 chars
description: Apply Acme Corp brand guidelines to presentations.
             # max 200 chars on claude.ai (spec allows 1024)
---
```

Keep the main `SKILL.md` under 500 lines; move detailed reference material
to separate files.

Source: [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md)

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
