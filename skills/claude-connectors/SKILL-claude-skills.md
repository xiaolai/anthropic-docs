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

Skills are reusable capability packages — directories containing
instructions, scripts, and resources that Claude dynamically loads
for specific tasks. Each skill is rooted by a `SKILL.md` file that
defines what the skill does and when to activate it.

Once installed, Claude automatically uses a skill when a task
matches the skill's description; users can also invoke skills
directly by name in any conversation.

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single capability (e.g., "review my pull requests
  for security issues using my org's checklist").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").

### Plan requirements

Skills require **code execution** to be enabled and are available
on Pro, Max, Team, and Enterprise plans.

### Skill types

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built offerings for document creation (Excel, Word, PowerPoint, PDF) |
| **Partner skills** | Integrations with platforms like Notion, Figma, and Atlassian |
| **Organization-provisioned** | Deployed enterprise-wide by administrators |
| **Custom skills** | User-created workflows for specialized tasks |

## Where users find skills

Source pages under
[`https://claude.com/docs/skills/`](https://claude.com/docs/skills/)
cover the user-facing surface:

- Browsing the skill directory (Anthropic and partner skills).
- Installing a skill from the directory.
- Installing a custom skill by uploading a ZIP file via
  **Settings → Capabilities**.
- Managing installed skills (enable/disable, update, remove).
- Per-conversation skill control (turn a skill on/off for a single
  conversation).

### Skill directory structure (for custom skills)

```
skill-name/
├── SKILL.md        # required — metadata + instructions
├── scripts/        # optional — executable code
├── references/     # optional — documentation
└── assets/         # optional — templates / images
```

Package as `skill-name.zip` with the root directory inside (not loose
files at the ZIP root). Upload via **Settings → Capabilities** in Claude.ai.

### SKILL.md frontmatter fields

| Field | Required | Constraint |
|---|---|---|
| `name` | Yes | Lowercase alphanumeric + hyphens; max 64 characters; must match directory name |
| `description` | Yes | Used as activation trigger; max 200 characters on Claude.ai (spec allows 1024) |
| `dependencies` | No | Declare required Python / Node.js / Bash packages |

The markdown body of `SKILL.md` should be kept **under 500 lines**. Move detailed reference
material to separate files in `references/` or `assets/` to avoid overloading the context window.

## Activation model

Skills use a **progressive disclosure** loading model:

1. Metadata loads at startup (~100 tokens per skill).
2. The full `SKILL.md` activates when the task matches the skill's
   `description` field — this is the primary activation trigger.
   Claude automatically decides when to load a skill based on
   semantic match.
3. Additional referenced files load only when needed.

Users can also invoke skills explicitly by name in a conversation.

The Skills format spec (in
[`anthropic-platform-features`](../anthropic-platform-features/SKILL-agents-and-tools.md))
documents the full field schema. This surface covers the
user-facing semantics.

## Open standard

Skills follow the [Agent Skills specification](https://agentskills.io/specification), a
platform-agnostic open standard. Skills you create can work across any platform that
adopts the standard. The spec allows descriptions up to 1024 characters; Claude.ai caps
them at 200 (per the warning in `creating custom skills`).

Validate a skill locally before uploading:

```bash
skills-ref validate ./my-skill
```

Validation tool: [github.com/agentskills/agentskills/tree/main/skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref).

Example skills you can use as templates: [github.com/anthropics/skills/tree/main/skills](https://github.com/anthropics/skills/tree/main/skills).

Source: [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md), [`skills/overview.md`](https://claude.com/docs/skills/overview.md).

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
