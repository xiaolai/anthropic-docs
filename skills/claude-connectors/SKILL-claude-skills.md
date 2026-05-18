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

Skills extend Claude's capabilities by bundling specialized
instructions, scripts, and resources. Each skill has a `SKILL.md`
file that defines activation triggers and the instructions Claude
should follow when the skill activates.

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single recipe (e.g., "review my pull requests for
  security issues using my org's checklist").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").

Skills follow the **Agent Skills specification** — a platform-agnostic
standard enabling portability across adopting platforms.

## Skill categories

| Category | Description |
|---|---|
| **Anthropic skills** | Pre-built capabilities (document creation: Excel, Word, PowerPoint, PDF) |
| **Partner skills** | Integrations with platforms like Notion, Figma, Atlassian |
| **Organization-provisioned skills** | Admin-deployed for Team / Enterprise users, often distributed via MDM |
| **Custom skills** | User-created workflows for specialized tasks |

## SKILL.md authoring quick reference

> Source: [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md) and the [Agent Skills specification](https://agentskills.io/specification).

### Required frontmatter fields

| Field | Constraints |
|---|---|
| `name` | Lowercase letters, numbers, hyphens only; max **64 chars**; must match directory name |
| `description` | What the skill does + when to use it; max **200 chars** on Claude.ai (Agent Skills spec allows 1024) |

```yaml
---
name: brand-guidelines
description: Apply Acme Corp brand guidelines to presentations and documents.
---
```

> **Claude.ai hard limit:** descriptions > 200 characters are truncated — Claude may fail to activate the skill. The platform-agnostic spec allows up to 1024, but claude.com enforces 200.

### Optional frontmatter fields

| Field | Purpose |
|---|---|
| `dependencies` | Packages to install at skill-load time — e.g. `python>=3.8, pandas>=1.5.0` or npm package identifiers |

### Directory structure

```
my-skill/          ← directory name must match `name` field
├── SKILL.md       ← required
├── scripts/       ← optional: executable Python, JS, or Bash
├── references/    ← optional: extra docs Claude can read on demand
└── assets/        ← optional: templates, images, lookup tables
```

Keep `SKILL.md` under 500 lines; move detailed reference material to `references/` or `assets/`.

### Packaging for upload

Create a ZIP with the **directory inside** (not files at the root):

```
# Correct
my-skill.zip → my-skill/ → SKILL.md, scripts/, …

# Wrong — files directly in the ZIP root break skill detection
my-skill.zip → SKILL.md, scripts/, …
```

### Validation

```bash
skills-ref validate ./my-skill   # CLI validation tool
```

Validation tool: [github.com/agentskills/agentskills/tree/main/skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref).

Example skills: [github.com/anthropics/skills](https://github.com/anthropics/skills/tree/main/skills).

---

## Activation model — progressive disclosure

Skills use progressive disclosure to manage context efficiently:

| Stage | What loads | Approximate cost |
|---|---|---|
| Startup | Skill name + description (metadata) | ~100 tokens per skill |
| Activation | Full skill content (when task matches description) | Varies by skill |
| Resource loading | Additional files linked from the skill | On-demand only |

This prevents context overload while delivering specialized behaviour
on demand. Two activation patterns:

1. **Always-on / auto-trigger** — skill loads when the conversation
   matches its `appliesTo` trigger (file path, keyword, tool call).
   Author configures this via the skill's frontmatter.
2. **User-invoked** — skill loads only when the user explicitly names
   it.

The activation field schema is documented in the Skills format spec —
see [`anthropic-platform-features → SKILL-agents-and-tools.md`](../anthropic-platform-features/SKILL-agents-and-tools.md).

## Requirements

Skills require a **Pro, Max, Team, or Enterprise** plan subscription.
Code execution must be enabled in account settings.

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
