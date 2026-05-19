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

Skills are directories containing instructions, scripts, and
resources that Claude dynamically loads to handle specific tasks.
Each skill's core is a `SKILL.md` file with YAML frontmatter plus
a markdown body of step-by-step procedures, examples, and templates.
Claude loads skill metadata at startup, activates matching skills
when the conversation task fits, and pulls in resource files on demand
— keeping the context window lean while delivering specialized
behavior when it's needed.

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single recipe (e.g., "review my pull requests for
  security issues using my org's checklist").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").

## Plan availability

Skills are available to **Pro, Max, Team, and Enterprise** plan
subscribers. Code execution must be enabled to use skills that
declare executable dependencies.
Source: [`skills/overview.md`](https://claude.com/docs/skills/overview.md).

## Skill categories

| Category | Description |
|---|---|
| **Anthropic skills** | Built by Anthropic; auto-activate for document creation tasks (Excel, Word, PowerPoint, PDF) |
| **Partner skills** | Third-party offerings from companies such as Notion, Figma, and Atlassian |
| **Organization skills** | Deployed by Team/Enterprise admins to all members of an org |
| **Custom skills** | User-created tools for personal workflows; upload via Settings |

Source: [`skills/overview.md`](https://claude.com/docs/skills/overview.md).

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

Three-step context management at runtime:

1. **Metadata loading** — at startup, Claude loads name, description,
   and frontmatter for every installed skill.
2. **Activation matching** — when the conversation task matches a
   skill's description/triggers, that skill is activated.
3. **Resource loading** — only the activated skill's full instructions
   and resource files are loaded into the context window.

This keeps the context window lean: skills that don't match the
current task consume no context.

Two authoring-level activation patterns:

- **Always-on** — the skill auto-activates when its triggers match
  (via the `appliesTo` frontmatter field).
- **User-invoked** — the skill activates only when the user
  explicitly invokes it by name or slash command.

The Agent Skills specification (open standard) governs the full
activation field schema. See
[`anthropic-platform-features → SKILL-agents-and-tools.md`](../anthropic-platform-features/SKILL-agents-and-tools.md).

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

## Custom skill structure

A custom skill is a directory containing:

```
my-skill/
  SKILL.md          ← required; frontmatter + instructions
  scripts/          ← optional; Python/JS/Bash executables
  references/       ← optional; reference material files
  assets/           ← optional; images and other assets
```

Required `SKILL.md` frontmatter fields:

| Field | Constraint |
|---|---|
| `name` | Lowercase letters, numbers, hyphens; max 64 chars; must match directory name |
| `description` | Max 200 chars for Claude.ai uploads (Agent Skills spec allows up to 1024) |

The markdown body should include step-by-step procedures, input/output
examples, templates, and edge-case handling. Keep the main file under
500 lines; move detailed material into `references/`.

Skills can declare executable dependencies for Python, JavaScript, or
Bash. Example: `python>=3.8, pandas>=1.5.0`.

Before uploading, validate with:
```bash
skills-ref validate ./my-skill
```
Tool: [`agentskills/agentskills/tree/main/skills-ref`](https://github.com/agentskills/agentskills/tree/main/skills-ref).
Then enable in **Settings → Capabilities** and verify Claude invokes it.

Example skills as templates: [`anthropics/skills/tree/main/skills`](https://github.com/anthropics/skills/tree/main/skills).

Source: [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md).

## Open standard

Skills follow the **Agent Skills specification** — an open standard
that enables cross-platform compatibility and shareability. Specification:
[`agentskills.io/specification`](https://agentskills.io/specification).

## Page index

All source pages under
[`https://claude.com/docs/skills/`](https://claude.com/docs/skills/):

- `overview.md` — skill categories, plan availability, activation model
- `how-to.md` — custom skill creation, structure, validation, deployment

---

*Source pages: under `claude.com/docs/skills/`.*
