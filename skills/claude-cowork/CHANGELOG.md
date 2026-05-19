# claude-cowork — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-19
- Sync to docs index 33c21db3 — removed office-agents/overview.md (35 → 34 pages); all 19 verify checks pass.

## [0.1.0] — 2026-05-17

### Added

- Scaffold created as part of the `autoupdated-anthropic-documentation-knowledge`
  multi-skill big-bang migration.
- Router `SKILL.md` with 2-surface dispatch (cowork, office-agents).
- Surface stubs for both surfaces.
- `config.json` declaring upstream sources and `docsPathFilter`
  `(cowork|office-agents)/`.
- `state.json` with `scaffoldComplete: false`.
