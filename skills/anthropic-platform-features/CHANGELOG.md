# anthropic-platform-features — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-18 (run 2)
- *(pending review — see draft PR on `auto/2026-05-18-pending-review`)* Added `cache-diagnostics.md` to build-with-claude surface (109 pages); validateExamples gate failed, pending manual review

## 2026-05-18
- Research audit complete — 108 pages verified across all 4 surfaces (agents-and-tools, build-with-claude, manage-claude, managed-agents), no upstream changes detected; all gates pass

## [0.1.0] — 2026-05-17

### Added

- Scaffold created as part of the `autoupdated-anthropic-documentation-knowledge`
  multi-skill big-bang migration.
- Router `SKILL.md` with 4-surface dispatch (agents-and-tools,
  build-with-claude, manage-claude, managed-agents).
- Surface stubs for all 4 surfaces, pointing at the matching
  `platform.claude.com/docs/en/...` upstream paths.
- `config.json` declaring upstream sources and `docsPathFilter`
  `(agents-and-tools|build-with-claude|manage-claude|managed-agents)/`.
- `state.json` with `scaffoldComplete: false`.
