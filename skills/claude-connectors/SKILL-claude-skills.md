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

Skills follow the open [Agent Skills specification](https://agentskills.io/specification).

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single recipe (e.g., "review my pull requests for
  security issues using my org's checklist").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").

## Availability

Skills require a **Pro, Max, Team, or Enterprise** Claude plan.
The feature also requires **code execution to be enabled** for the
account.
Source: [`skills/overview.md`](https://claude.com/docs/skills/overview.md).

## How skills load (progressive disclosure)

1. **Metadata phase** — at conversation start Claude reads each skill's
   `name` + `description` (~100 tokens per skill).
2. **Activation** — when a task matches a description, Claude loads the
   full `SKILL.md`.
3. **Resource loading** — additional files (`scripts/`, `references/`,
   `assets/`) are loaded only when needed.

## Types of skills

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built (Excel, Word, PowerPoint, PDF); auto-activate when relevant |
| **Partner skills** | From Notion, Figma, Atlassian, etc.; designed for MCP connector integration |
| **Organization-provisioned** | Deployed org-wide by Team/Enterprise admins |
| **Custom skills** | Created by users for specialized workflows |

## Authoring quick-reference

Source: [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md).

### Directory layout

```
my-skill/           ← directory name must match `name` field
├── SKILL.md        ← required
├── scripts/        ← optional: Python / Node.js / Bash scripts
├── references/     ← optional: additional docs Claude can read
└── assets/         ← optional: templates, images, data files
```

### SKILL.md frontmatter fields

| Field | Required | Constraint |
|---|---|---|
| `name` | ✅ | Lowercase letters, numbers, hyphens only; max **64 chars**; must match directory name |
| `description` | ✅ | Max **200 chars** on Claude.ai (up to 1024 in the Agent Skills spec) |
| `dependencies` | optional | `python>=3.8, pandas>=1.5.0` style — installed on skill load |

### Packaging for upload

1. Ensure the directory name matches `name`.
2. Create a ZIP with the skill directory inside: `my-skill.zip → my-skill/SKILL.md …`
3. Upload via Claude app.

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
