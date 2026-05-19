# claude-connectors — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-19
*(pending review — see branch `auto/2026-05-19-pending-review`)* — Docs index content updated (34 pages, no additions/removals); check-diff-size gate failed, changes held for human review before merge to main

## [Unreleased] — 2026-05-19

### Changed

- `SKILL-connectors-building.md`: added transport detail (Streamable
  HTTP preferred; HTTP+SSE being deprecated), supported auth spec
  versions (2025-03-26, 2025-06-18, 2025-11-25), protocol feature
  tables (supported / not-yet-supported), technical limits table
  (tool result sizes, timeouts), OAuth callback URLs, DCR note, and
  `mcp-server-dev` plugin tip — all sourced from updated
  `connectors/building/index.md`.
- `SKILL-claude-skills.md`: rewrote to match upstream `skills/overview.md`
  — skills are now described as directories (not just "task recipes"),
  with progressive-disclosure loading, plan availability (Pro/Max/Team/
  Enterprise, requires code execution), four skill types (Anthropic,
  Partner, org-provisioned, custom), and the Agent Skills open spec.
- `SKILL-claude-plugins.md`: updated to match upstream
  `plugins/overview.md` — added Anthropic's 11 open-sourced plugins
  table, Cowork "research preview" availability note, plugin-components
  table, and corrected availability (Claude Code + Cowork only).

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
