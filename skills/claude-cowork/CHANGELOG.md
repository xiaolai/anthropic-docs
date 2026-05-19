# claude-cowork — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## [Unreleased] — 2026-05-19

### Changed

- `SKILL-office-agents.md`: removed `overview.md` from the page index
  (page was removed from `claude.com/docs/office-agents/`); source page
  count updated from 11 to 10; frontmatter `source:` updated to
  `office-agents/excel.md`.
- `state.json`: docs index hash and page count updated to reflect the
  removal of `https://claude.com/docs/office-agents/overview.md`
  (35 → 34 pages).

## 2026-05-19
*(pending review — see PR auto/2026-05-19-pending-review)* Dropped `office-agents/overview.md` from docs index (35 → 34 pages); check-diff-size gate triggered draft-PR review

## [0.1.0] — 2026-05-17

### Added

- Scaffold created as part of the `autoupdated-anthropic-documentation-knowledge`
  multi-skill big-bang migration.
- Router `SKILL.md` with 2-surface dispatch (cowork, office-agents).
- Surface stubs for both surfaces.
- `config.json` declaring upstream sources and `docsPathFilter`
  `(cowork|office-agents)/`.
- `state.json` with `scaffoldComplete: false`.
