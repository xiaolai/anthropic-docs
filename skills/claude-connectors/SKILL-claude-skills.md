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

Skills are specialized capability extensions that Claude dynamically
activates based on task requirements. They consist of directories
with instructions, scripts, and resources organised around specific
workflows. Once installed, Claude loads a skill's instructions when
the task matches its activation criteria.

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single workflow extension (e.g., document
  generation via a spreadsheet tool, or a Notion integration).
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").

## Plan availability

Skills require a **Pro, Max, Team, or Enterprise** plan. Code
execution must be enabled in your account settings.

## Skill categories

| Category | Description |
|---|---|
| **Anthropic** | Pre-built document-generation skills (spreadsheets, presentations, PDFs, word processors) |
| **Partner** | Integrations from companies like Notion, Figma, and Atlassian |
| **Organization-provisioned** | Administrator-deployed resources for Team and Enterprise users |
| **Custom** | User-created workflows for specialised tasks |

## Progressive loading model

The runtime manages context efficiently:

1. **Metadata only** (~100 tokens per skill) loaded at conversation start.
2. Full `SKILL.md` content loaded when a task matches the skill's activation criteria.
3. Additional resources loaded only as needed.

For the authoring spec of the `.skill` / `SKILL.md` package format,
see [`anthropic-platform-features → SKILL-agents-and-tools.md`](../anthropic-platform-features/SKILL-agents-and-tools.md).

## SKILL.md authoring constraints

Key limits enforced by Claude.ai (from [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md)):

| Field | Rule |
|---|---|
| `name` | Lowercase letters, numbers, and hyphens only; max **64 chars**; must match the directory name |
| `description` | Max **200 chars** on Claude.ai (Agent Skills spec allows 1024) |
| Body | Keep `SKILL.md` under **500 lines**; move reference material to separate files |

The directory name must match the `name` field in `SKILL.md`.

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

## Open standard

Skills follow the [Agent Skills specification](https://agentskills.io/specification),
a platform-agnostic open standard. Skills you create can work across any
platform that adopts the standard — not just Claude.

Source: [`skills/overview.md`](https://claude.com/docs/skills/overview.md).

## Cross-product availability

Skills work in:

- **Claude.ai (web)** — installed skills available in conversations
  (Pro/Max/Team/Enterprise; code execution required).
- **Claude Desktop** — same plan requirements.
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
