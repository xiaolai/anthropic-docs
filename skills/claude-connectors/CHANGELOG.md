# claude-connectors — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-19
*(pending review — see branch auto/2026-05-19-pending-review)* Docs index content refresh across 34 tracked pages — checkDiffSize gate failed; awaiting human review before merge to main.

## [0.2.0] — 2026-05-19

### Changed

- **SKILL-claude-skills.md**: Major update to reflect current
  docs. Added Agent Skills specification reference
  (agentskills.io/specification), plan availability (Pro, Max,
  Team, Enterprise; requires code execution), types of skills
  (Anthropic, Partner, org-provisioned, custom), SKILL.md
  directory structure and frontmatter spec (name/description
  required; 200-char description limit on Claude.ai),
  packaging as ZIP, `skills-ref validate` tool,
  Settings → Capabilities activation flow, and example skills
  at github.com/anthropics/skills. Removed Claude Code-centric
  `~/.claude/skills/` and `appliesTo` activation details
  (those belong in claude-code skill).
- **SKILL-claude-plugins.md**: Major update to reflect current
  docs. Added Anthropic's 11 open-sourced plugins table,
  plugin directory URL (claude.com/plugins-for/cowork),
  Cowork research-preview availability note, three distribution
  paths (direct / marketplace / directory), Anthropic Verified
  badge system, directory terms & conditions links, submission
  process (`claude plugin validate`, GitHub or ZIP upload,
  claude.ai/settings/plugins/submit). Removed outdated
  `~/.claude/plugins/` scope table.
- **SKILL-connectors-overview.md**: Updated Self-serve local
  MCP row to describe the MCPB / plugin-with-.mcp.json
  distribution guidance instead of just "(not
  directory-listable)".

## [0.1.0] — 2026-05-17

### Added

- Scaffold created as part of the `autoupdated-anthropic-documentation-knowledge`
  multi-skill big-bang migration.
- Router `SKILL.md` with 5-surface dispatch (overview, building,
  mcp-apps, skills, plugins).
- Surface stubs for all 5 surfaces.
- `SKILL-mcp-apps.md` intentionally bundles Desktop MCPB packaging and
  MCP Apps visual/interaction design guidelines into one surface —
  these are consulted together when building a Desktop app.
- `config.json` declaring upstream sources and `docsPathFilter`
  `(connectors|skills|plugins)/`.
- `state.json` with `scaffoldComplete: false`.
