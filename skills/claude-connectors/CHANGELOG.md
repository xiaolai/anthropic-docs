# claude-connectors — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## [0.1.0] — 2026-05-17

### Added

- Scaffold created as part of the `anthropic-docs-skills-autoupdated`
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
