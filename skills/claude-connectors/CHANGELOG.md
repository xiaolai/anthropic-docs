# claude-connectors — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-19
*(pending review — see PR auto/2026-05-19-pending-review)* — 34 pages audited by research agent; no upstream version change; check-docs-drift gate failed, triggering review branch

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
