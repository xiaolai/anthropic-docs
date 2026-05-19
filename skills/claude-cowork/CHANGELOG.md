# claude-cowork — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## [Unreleased] — 2026-05-19

### Changed

- Removed `office-agents/overview.md` from the page index in
  `SKILL-office-agents.md` — Anthropic removed this page from the upstream
  docs index (page count: 35 → 34). The `source:` frontmatter field pointing
  to that URL has been dropped from the surface file.

## 2026-05-19
- *(pending review — see branch `auto/2026-05-19-pending-review`)* Removed `office-agents/overview.md` from skill surface after upstream docs index dropped the page (35 → 34 pages); check-diff-size gate triggered review mode

## [0.1.0] — 2026-05-17

### Added

- Scaffold created as part of the `autoupdated-anthropic-documentation-knowledge`
  multi-skill big-bang migration.
- Router `SKILL.md` with 2-surface dispatch (cowork, office-agents).
- Surface stubs for both surfaces.
- `config.json` declaring upstream sources and `docsPathFilter`
  `(cowork|office-agents)/`.
- `state.json` with `scaffoldComplete: false`.
