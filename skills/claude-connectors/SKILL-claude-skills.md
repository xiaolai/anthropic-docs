---
name: claude-skills-user-facing
description: |
  Deep reference for user-facing Agent Skills in Claude — how
  users discover, install, manage, and create Skills inside the
  Claude app. Covers the Agent Skills spec, skill directory
  structure (SKILL.md frontmatter, description limit, packaging
  as ZIP), types of skills (Anthropic, Partner, org-provisioned,
  custom), testing workflow, and the skills-ref validate tool.
source: https://claude.com/docs/skills/overview.md
---

# Claude Skills — User-Facing

> *Router lives in [`SKILL.md`](SKILL.md). This surface covers
> the product-level Skills feature on claude.com (Pro, Max,
> Team, Enterprise plans). For the Claude Code CLI skills
> mechanism (`~/.claude/skills/`), see
> [`claude-code → SKILL-plugins.md`](../claude-code/SKILL-plugins.md).*

## What Skills are

Skills are directories containing instructions, scripts, and
resources that Claude dynamically loads to handle specific tasks.
Each skill has a `SKILL.md` file that defines when the skill
should be activated and what instructions Claude should follow.

Skills use **progressive disclosure** to manage context
efficiently:

1. **Metadata loading** — Claude reads skill names and
   descriptions at startup (~100 tokens each).
2. **Activation** — When a task matches a skill's description,
   Claude loads the full `SKILL.md` content.
3. **Resource loading** — Additional files (scripts, references)
   are loaded only when needed.

Source: [`skills/overview.md`](https://claude.com/docs/skills/overview.md).

## Availability

Skills are available for users on **Pro, Max, Team, and
Enterprise** plans. The Skills feature requires **code
execution** to be enabled.

## Types of skills

| Type | Description |
|---|---|
| **Anthropic skills** | Pre-built skills for document creation (Excel, Word, PowerPoint, PDF) — activate automatically when relevant |
| **Partner skills** | Skills from partners such as Notion, Figma, and Atlassian, designed for seamless MCP connector integration |
| **Organization-provisioned** | Skills deployed organization-wide by Team/Enterprise admins |
| **Custom skills** | Skills you create for specialized workflows (emails, brand guidelines, JIRA/Linear integration, etc.) |

## Skills vs. other features

| Feature | Purpose |
|---|---|
| **Skills** | Task-specific procedures that load dynamically |
| **[Plugins](SKILL-claude-plugins.md)** | Shareable packages that bundle skills, connectors, slash commands, and sub-agents |
| **Projects** | Static background knowledge always loaded in specific chats |
| **MCP** | Connects Claude to external services |
| **Custom Instructions** | Broad preferences applied to all conversations |

## Open standard

Skills follow the [Agent Skills specification](https://agentskills.io/specification),
a platform-agnostic standard. Skills you create can work across
any platform that adopts the standard.

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

## SKILL.md format

`SKILL.md` must start with YAML frontmatter followed by markdown
instructions.

### Required frontmatter fields

```markdown
---
name: brand-guidelines
description: Apply Acme Corp brand guidelines to presentations and documents, including official colors, fonts, and logo usage.
---
```

| Field | Notes |
|---|---|
| `name` | Lowercase letters, numbers, and hyphens only. Max 64 characters. Must match the directory name. |
| `description` | Explains what the skill does and when to use it. Claude uses this to decide when to invoke the skill. |

> **Description length limit**: Claude.ai enforces a **200-character** maximum on skill descriptions. The [Agent Skills spec](https://agentskills.io/specification) allows up to 1024 characters, but skills uploaded to Claude.ai must use the shorter limit.

### Optional frontmatter: dependencies

Skills can declare package dependencies (installed at load time):

```markdown
---
name: data-analysis
description: Analyze CSV files and generate visualizations.
dependencies: python>=3.8, pandas>=1.5.0, matplotlib
---
```

## Packaging and uploading

To upload a skill to Claude:

1. Ensure the directory name matches the skill's `name` field.
2. Create a ZIP file with the **skill directory** inside (not files at the root):

```
# Correct
my-skill.zip
└── my-skill/
    ├── SKILL.md
    └── scripts/

# Incorrect — files at ZIP root won't install
my-skill.zip
├── SKILL.md
└── scripts/
```

3. Enable the skill in **Settings → Capabilities** after upload.

## Testing your skill

### Before uploading

- Review `SKILL.md` for clarity.
- Verify the description accurately reflects when Claude should
  use the skill.
- Check that all referenced files exist.
- Validate with the reference tool:

```bash
skills-ref validate ./my-skill
```

([skills-ref validation tool](https://github.com/agentskills/agentskills/tree/main/skills-ref))

### After uploading

1. Enable the skill in **Settings → Capabilities**.
2. Try prompts that should trigger it.
3. Review Claude's thinking to confirm it loads the skill.
4. Iterate on the description if Claude doesn't invoke it when
   expected.

## Best practices

- **Keep it focused**: Create separate skills for different
  workflows. Multiple focused skills compose better than one
  large skill.
- **Write clear descriptions**: Be specific about when the
  skill applies. Include keywords that help Claude identify
  relevant tasks.
- **Start simple**: Begin with markdown instructions before
  adding scripts.
- **Use examples**: Include example inputs and outputs.
- **Test incrementally**: Test after each significant change.
- **Leverage composability**: Claude can use multiple skills
  together automatically.

## Security

- Don't hardcode sensitive information (API keys, passwords).
- Review downloaded skills before enabling them.
- Use MCP connections for external service access.

## Example skills

See [github.com/anthropics/skills](https://github.com/anthropics/skills/tree/main/skills)
for example skills you can use as templates.

## Related surfaces

- [`SKILL-claude-plugins.md`](SKILL-claude-plugins.md) —
  plugins (which bundle skills + connectors + more).
- [`SKILL-connectors-overview.md`](SKILL-connectors-overview.md) —
  connectors (the action-taking layer that skills compose).
- [Agent Skills specification](https://agentskills.io/specification) —
  platform-agnostic spec for the `.skill` format.

## Page index

Source pages under
[`https://claude.com/docs/skills/`](https://claude.com/docs/skills/):

- `skills/overview.md` — availability, types, how skills work
- `skills/how-to.md` — creating custom skills

---

*Source pages: `claude.com/docs/skills/overview.md` and
`claude.com/docs/skills/how-to.md`.*
