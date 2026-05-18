# claude-cowork — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-18

*(pending review — see PR auto/2026-05-18-pending-review)* First-run docs population — research agent indexed all 35 cowork + office-agents pages; check-diff-size gate triggered review mode.

## [0.1.0] — 2026-05-17

### Added

- Scaffold created as part of the `autoupdated-anthropic-documentation-knowledge`
  multi-skill big-bang migration.
- Router `SKILL.md` with 2-surface dispatch (cowork, office-agents).
- Surface stubs for both surfaces.
- `config.json` declaring upstream sources and `docsPathFilter`
  `(cowork|office-agents)/`.
- `state.json` with `scaffoldComplete: false`.
