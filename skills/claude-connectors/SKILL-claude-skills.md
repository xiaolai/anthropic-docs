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

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single recipe (e.g., "review my pull requests for
  security issues using my org's checklist").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").

## Availability

Skills require code execution to be enabled. Available on **Pro, Max,
Team, and Enterprise** plans.
Source: [`skills/overview.md`](https://claude.com/docs/skills/overview.md).

## Skill types

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built skills (e.g. document creation for Excel, Word, PowerPoint, PDF); activate automatically when relevant |
| **Partner skills** | From partners (Notion, Figma, Atlassian, …); designed for seamless MCP connector integration |
| **Organization-provisioned skills** | Deployed organization-wide by Team / Enterprise admins |
| **Custom skills** | User-created for specialized workflows |

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

## SKILL.md schema

Every skill is a directory with a `SKILL.md` file. The directory name
must match the `name` field.
Source: [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md).

### Required frontmatter fields

| Field | Constraints | Purpose |
|---|---|---|
| `name` | Max 64 chars; lowercase letters, numbers, hyphens only; must match directory name | Identifier — Claude uses it to resolve the skill |
| `description` | **Max 200 chars on Claude.ai** (spec allows 1024) | Claude reads this to decide when to invoke the skill |

### Optional frontmatter fields

| Field | Example | Purpose |
|---|---|---|
| `dependencies` | `python>=3.8, pandas>=1.5.0` | Packages to install; Claude pulls from PyPI / npm at load time |

### Directory structure

```
my-skill/
├── SKILL.md            # required
├── scripts/            # optional — Python / JS / Bash
├── references/         # optional — extra docs Claude reads on demand
└── assets/             # optional — templates, images, data files
```

Keep `SKILL.md` under 500 lines; move detailed reference material to `references/`.

### Packaging to upload to Claude.ai

ZIP with the skill directory **inside** (not files at root):

```
my-skill.zip
└── my-skill/
    └── SKILL.md
```

Validate before uploading: `skills-ref validate ./my-skill`
([agentskills/agentskills repo](https://github.com/agentskills/agentskills/tree/main/skills-ref)).

## Activation model

Claude loads a skill's `SKILL.md` when the `description` matches the
task at hand. Progressive disclosure:

1. **Metadata loading** — Claude reads `name` + `description` at startup (~100 tokens each).
2. **Activation** — when a task matches the description, Claude loads the full `SKILL.md`.
3. **Resource loading** — referenced files in `references/` / `scripts/` are loaded only when needed.

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
