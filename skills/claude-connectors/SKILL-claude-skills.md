---
name: claude-skills-user-facing
description: |
  Deep reference for user-facing Agent Skills in Claude — what
  skills are (directory-based, SKILL.md format), how they are
  activated (description-based dynamic loading), the four types
  (Anthropic, Partner, Org-provisioned, Custom), how to create and
  upload them, platform availability, and the agentskills.io spec.
source: https://claude.com/docs/skills/overview.md
---

# Claude Skills — User-Facing

> *Router lives in [`SKILL.md`](SKILL.md). For the technical spec,
> see the [Agent Skills specification](https://agentskills.io/specification)
> and the [skills reference repo](https://github.com/agentskills/agentskills).
> This surface covers what users and skill authors need to know.*

## What Skills are

Skills are **directories** containing instructions, scripts, and
resources that Claude dynamically loads to handle specific tasks.
Each skill has a `SKILL.md` file that defines when it should be
activated and what instructions Claude should follow.

Skills use **progressive disclosure** to manage context efficiently:

1. **Metadata loading** — Claude reads skill names and descriptions
   at startup (~100 tokens each).
2. **Activation** — When a task matches a skill's description, Claude
   loads the full `SKILL.md` content.
3. **Resource loading** — Additional files (scripts, references) are
   loaded only when needed.

This prevents context-window overload while providing specialized
capabilities on demand.

Skills are the lightweight, scoped counterpart to plugins:

- A **skill** is a single workflow directory (e.g., "apply brand
  guidelines to presentations using Acme Corp's official colors").
- A **plugin** bundles multiple skills, connectors, slash commands,
  and sub-agents (e.g., "the entire DevOps team's standard toolkit").

## Types of skills

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built skills for document creation (Excel, Word, PowerPoint, PDF) — activate automatically when relevant |
| **Partner skills** | From partners like Notion, Figma, Atlassian — designed for seamless MCP connector integration |
| **Organization-provisioned** | Deployed organization-wide by Team and Enterprise admins |
| **Custom skills** | Skills you create for specialized workflows (emails, brand guidelines, JIRA/Linear integrations, etc.) |

## Skill structure

```
my-skill/
├── SKILL.md          # required — frontmatter + instructions
├── scripts/          # optional: Python, Node.js, or Bash scripts
├── references/       # optional: additional documentation
└── assets/           # optional: templates, images, data files
```

The directory name must match the `name` field in `SKILL.md`.

### SKILL.md frontmatter

```markdown
---
name: brand-guidelines
description: Apply Acme Corp brand guidelines to presentations and documents.
---
```

**`name`** — lowercase letters, numbers, and hyphens; max 64 characters;
must match the directory name.

**`description`** — Claude uses this to decide when to load the skill.
Claude.ai limits descriptions to **200 characters** (the
[agentskills.io spec](https://agentskills.io/specification) allows 1024).

**`dependencies`** (optional) — declare Python/npm packages Claude should
install when loading the skill:

```markdown
---
name: data-analysis
description: Analyze CSV files and generate visualizations.
dependencies: python>=3.8, pandas>=1.5.0, matplotlib
---
```

## Activation model

Claude loads skills based on the `description` field — when the
user's task matches the description, Claude loads the full
`SKILL.md`. No explicit user invocation needed.

After uploading, enable the skill in **Settings → Capabilities**,
then test with prompts that should trigger it.

## Creating and uploading a custom skill

1. Create the directory structure above.
2. Write `SKILL.md` with frontmatter + instructions.
3. Optionally validate: `skills-ref validate ./my-skill`
   ([validation tool](https://github.com/agentskills/agentskills/tree/main/skills-ref)).
4. Package as a ZIP (the directory must be _inside_ the ZIP, not at root).
5. Upload in **Settings → Capabilities**.

Source: [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md).

## Platform availability

Skills are available on **Pro, Max, Team, and Enterprise** plans.
The Skills feature requires **code execution to be enabled**.

| Platform | Support |
|---|---|
| **Claude.ai (web)** | Install and use skills via Settings → Capabilities |
| **Claude Desktop** | Same |
| **Claude Code (CLI)** | Skills from `~/.claude/skills/` or project-local `.claude/` |
| **Claude Cowork** | Full skills support |

For Cowork on 3P, skill distribution happens via MDM — see
[`claude-cowork`](../claude-cowork/SKILL-cowork.md).

## Open standard

Skills follow the [Agent Skills specification](https://agentskills.io/specification),
a platform-agnostic open standard. Skills you create can work across
any platform that adopts the standard.

See [github.com/anthropics/skills](https://github.com/anthropics/skills/tree/main/skills)
for example skills to use as templates.

## Skills vs. other features

| Feature | Purpose |
|---|---|
| **Skills** | Task-specific procedures that load dynamically |
| **[Plugins](SKILL-claude-plugins.md)** | Shareable packages that bundle skills, connectors, slash commands, and sub-agents |
| **Projects** | Static background knowledge always loaded in specific chats |
| **MCP** | Connects Claude to external services |
| **Custom Instructions** | Broad preferences applied to all conversations |

## Related surfaces

- [`SKILL-claude-plugins.md`](SKILL-claude-plugins.md) — plugins
  (which bundle skills + connectors + more).
- [`SKILL-connectors-overview.md`](SKILL-connectors-overview.md) —
  connectors (the action-taking layer that skills compose).

## Page index

Source pages under
[`https://claude.com/docs/skills/`](https://claude.com/docs/skills/):

- `overview.md` — this surface's primary source
- `how-to.md` — creating custom skills, packaging, testing

---

*Source pages: under `claude.com/docs/skills/`.*
