# claude-connectors — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-19

*(pending review — see draft PR on branch `auto/2026-05-19-pending-review`)*

- Docs content refresh: expanded `rules/mcp-apps-design.md` (+28%, display-mode API / CSP / touch-target rules), `SKILL-claude-skills.md` (+29%, availability section + skill types table), `SKILL-claude-plugins.md` (+33%, availability note + 11-plugin directory table); routed to draft PR due to diff-size gate failure

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
