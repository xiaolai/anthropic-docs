---
name: claude-skills-user-facing
description: |
  Deep reference for user-facing Agent Skills in Claude — how
  users create, upload, activate, and manage Skills. Covers the
  four skill types (Anthropic, Partner, Org-provisioned, Custom),
  plan availability (Pro/Max/Team/Enterprise), the SKILL.md
  directory format, the Agent Skills open standard, and the
  relationship between Skills and Plugins.
source: https://claude.com/docs/skills/overview.md
---

# Claude Skills — User-Facing

> *Router lives in [`SKILL.md`](SKILL.md). For building and
> distributing skills, see also
> [`SKILL-claude-plugins.md`](SKILL-claude-plugins.md) (plugins
> bundle skills). This surface covers what users see and do.*

## What Skills are

Skills are directories containing instructions, scripts, and
resources that Claude dynamically loads to handle specific tasks.
Each skill has a `SKILL.md` file that defines when it should be
activated and what instructions Claude should follow.

Effective skills:
- Solve a specific, repeatable task.
- Have clear instructions Claude can follow.
- Include examples when helpful.
- Define when they should be used.
- Focus on one workflow rather than trying to do everything.

Skills are the task-specific counterpart to plugins:

| Feature | Purpose |
|---|---|
| **Skills** | Task-specific procedures that load dynamically |
| **[Plugins](SKILL-claude-plugins.md)** | Shareable packages that bundle skills, connectors, slash commands, and sub-agents |
| **Projects** | Static background knowledge always loaded in specific chats |
| **MCP** | Connects Claude to external services |
| **Custom Instructions** | Broad preferences applied to all conversations |

## Availability

Skills are available for users on **Pro, Max, Team, and Enterprise**
plans. The Skills feature requires **code execution** to be enabled
(Settings → Capabilities).

## Types of skills

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built skills for document creation (Excel, Word, PowerPoint, PDF) that activate automatically when relevant |
| **Partner skills** | Skills from partners like Notion, Figma, and Atlassian designed for seamless MCP connector integration |
| **Organization-provisioned skills** | Skills deployed organization-wide by Team and Enterprise administrators |
| **Custom skills** | Skills you create for specialized workflows — generating emails, applying brand guidelines, integrating with tools like JIRA or Linear, and more |

## Skill structure

A skill is a directory containing at minimum a `SKILL.md` file:

```
brand-guidelines/
├── SKILL.md
├── scripts/        # Optional: executable code
├── references/     # Optional: additional documentation
└── assets/         # Optional: templates, images, data files
```

The `SKILL.md` file must start with YAML frontmatter:

```markdown
---
name: brand-guidelines
description: Apply Acme Corp brand guidelines to presentations and documents, including official colors, fonts, and logo usage.
---
```

> **Claude.ai limit**: descriptions are capped at **200 characters**.
> The [Agent Skills specification](https://agentskills.io/specification)
> allows up to 1024 characters, but skills uploaded to Claude.ai must
> use the shorter limit.

Skills can include executable scripts in Python, JavaScript/Node.js,
or Bash (declared under `scripts/`), with dependencies specified in
the frontmatter `dependencies` field.

## Packaging and uploading

To upload a skill to Claude:

1. Ensure the directory name matches your skill's `name` field.
2. Create a ZIP file containing the skill directory (directory must
   be at the ZIP root — not files directly at root).
3. Upload via **Settings → Capabilities → Skills**.
4. Enable the skill, then test with prompts that should trigger it.

Validate your skill before uploading with:
```bash
skills-ref validate ./my-skill
```
([validation tool](https://github.com/agentskills/agentskills/tree/main/skills-ref))

## Activation model

Skills use progressive disclosure to manage context efficiently:

1. **Metadata loading** — Claude reads skill names and descriptions
   at startup (~100 tokens each).
2. **Activation** — When a task matches a skill's description,
   Claude loads the full `SKILL.md` content.
3. **Resource loading** — Additional files (scripts, references) are
   loaded only when needed.

This prevents context window overload while providing specialized
capabilities on demand.

## Open standard

Skills follow the [Agent Skills specification](https://agentskills.io/specification),
a platform-agnostic standard. Skills you create can work across any
platform adopting the standard.

Example skills: [github.com/anthropics/skills](https://github.com/anthropics/skills/tree/main/skills).

## Related surfaces

- [`SKILL-claude-plugins.md`](SKILL-claude-plugins.md) — plugins
  (which bundle skills + connectors + more).
- [`SKILL-connectors-overview.md`](SKILL-connectors-overview.md) —
  connectors (the action-taking layer that skills compose).

## Page index

Source pages under [`https://claude.com/docs/skills/`](https://claude.com/docs/skills/):

| Page | Topic |
|---|---|
| [`skills/overview.md`](https://claude.com/docs/skills/overview.md) | Overview, types, availability |
| [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md) | Creating custom skills — structure, packaging, testing |

---

*Source pages: 2 under `claude.com/docs/skills/`.*
