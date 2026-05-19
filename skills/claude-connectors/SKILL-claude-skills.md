---
name: claude-skills-user-facing
description: |
  Deep reference for user-facing Agent Skills in Claude — how
  users discover, install, manage, and invoke Skills inside the
  Claude app. Covers skill types (Anthropic, partner, org-provisioned,
  custom), the directory structure of a skill package, the SKILL.md
  frontmatter schema, progressive-disclosure loading, packaging,
  testing, and the Agent Skills open specification.
source: https://claude.com/docs/skills/overview.md
---

# Claude Skills — User-Facing

> *Router lives in [`SKILL.md`](SKILL.md). For building and authoring
> skills (the `.skill` package format, frontmatter schema, scripts),
> see [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md)
> and the [Agent Skills specification](https://agentskills.io/specification).
> This surface covers what users see and do.*

## What Skills are

Skills are **directories** containing instructions, scripts, and
resources that Claude dynamically loads to handle specific tasks.
Each skill has a `SKILL.md` file that defines when it should be
activated and what instructions Claude should follow.

Skills are distinct from other Claude features:

| Feature | Purpose |
|---|---|
| **Skills** | Task-specific procedures that load dynamically |
| **[Plugins](SKILL-claude-plugins.md)** | Shareable packages that bundle skills, connectors, slash commands, and sub-agents |
| **Projects** | Static background knowledge always loaded in specific chats |
| **MCP** | Connects Claude to external services |
| **Custom Instructions** | Broad preferences applied to all conversations |

## Availability

Skills are available for users on **Pro, Max, Team, and Enterprise**
plans. The Skills feature requires **code execution to be enabled**.

## How skills load (progressive disclosure)

Skills use progressive disclosure to manage context efficiently:

1. **Metadata loading** — Claude reads skill names and descriptions
   at startup (~100 tokens each).
2. **Activation** — when a task matches a skill's description, Claude
   loads the full `SKILL.md` content.
3. **Resource loading** — additional files (scripts, references) are
   loaded only when needed.

This approach prevents context-window overload while providing
specialized capabilities on demand.

## Types of skills

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built skills for document creation (Excel, Word, PowerPoint, PDF) that activate automatically when relevant |
| **Partner skills** | Skills from partners like Notion, Figma, and Atlassian, designed for seamless MCP connector integration |
| **Organization-provisioned** | Skills deployed organization-wide by Team and Enterprise administrators |
| **Custom skills** | Skills you create for specialized workflows — generating emails, applying brand guidelines, integrating with tools like JIRA or Linear |

## Skill directory structure

A skill is a directory containing at minimum a `SKILL.md` file:

```
brand-guidelines/
├── SKILL.md
├── scripts/        # Optional: executable code
├── references/     # Optional: additional documentation
└── assets/         # Optional: templates, images, data files
```

The directory name must match the `name` field in `SKILL.md`.

## SKILL.md frontmatter

```markdown
---
name: brand-guidelines
description: Apply Acme Corp brand guidelines to presentations and documents.
---
```

- **`name`** — lowercase letters, numbers, hyphens only; max 64 chars;
  must match directory name.
- **`description`** — Claude uses this to decide when to invoke the
  skill. Claude.ai limits descriptions to **200 characters**.

Full frontmatter schema (including `dependencies`, `appliesTo`, and
more) is in the
[Agent Skills specification](https://agentskills.io/specification).

## Packaging and uploading

1. Ensure the directory name matches the skill's `name` field.
2. Create a ZIP file with the skill directory inside (not files at
   the ZIP root).
3. Upload via **Settings → Capabilities**.

## Testing

- Enable the skill in **Settings → Capabilities**.
- Try prompts that should trigger it.
- Review Claude's thinking to confirm it's loading the skill.
- Iterate on the description if Claude isn't using it when expected.

## Open standard

Skills follow the [Agent Skills specification](https://agentskills.io/specification),
a platform-agnostic standard — skills you create can work across
any platform adopting the standard.

See [`skills/how-to.md`](https://claude.com/docs/skills/how-to.md)
for the complete authoring guide, or bundle skills into
[plugins](SKILL-claude-plugins.md) to share them with your team.

## Cross-product availability

| Platform | Skills support |
|---|---|
| **Claude.ai (web)** | Installed skills available in conversations |
| **Claude Desktop** | Same as web |
| **Claude Code (CLI)** | Skills resolve from `~/.claude/skills/` or project-local `.claude/skills/` |
| **Claude Cowork** | Full skills support |

## Related surfaces

- [`SKILL-claude-plugins.md`](SKILL-claude-plugins.md) — plugins
  (which bundle skills + connectors + more).
- [`SKILL-connectors-overview.md`](SKILL-connectors-overview.md) —
  connectors (the action-taking layer that skills compose).

## Page index

Source pages under
[`https://claude.com/docs/skills/`](https://claude.com/docs/skills/):

| Page | Topic |
|---|---|
| `overview.md` | This surface's source |
| `how-to.md` | Creating custom skills — frontmatter schema, scripts, packaging, testing |

---

*Source pages: under `claude.com/docs/skills/`.*
