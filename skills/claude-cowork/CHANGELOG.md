# claude-cowork — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-20 (run 2)
*(pending review — see branch `auto/2026-05-20-pending-review`)* Research agent re-ran (66 turns, 311 s, $0.93); check-docs-drift still failing — surface edits pending human review before merge.

## 2026-05-20
*(pending review — see branch `auto/2026-05-20-pending-review`)* Research agent re-ran (71 turns, 481 s, $1.32); check-docs-drift still failing — surface edits from research agent pending human review before merge.

## 2026-05-19 (run 8)
*(pending review — see branch `auto/2026-05-19-pending-review`)* Research agent re-ran (57 turns, 287 s, $0.77); check-docs-drift still failing — surface edits from research agent pending human review before merge.

## 2026-05-19 (run 7)
*(pending review — see branch `auto/2026-05-19-pending-review`)* Research agent re-ran (43 turns, 170 s, $0.43); check-docs-drift still failing — surface edits from research agent pending human review before merge.

## 2026-05-19 (run 6)
*(pending review — see branch `auto/2026-05-19-pending-review`)* Research agent re-ran (69 turns, 376 s, $1.07); check-docs-drift still failing — surface edits from research agent pending human review before merge.

## 2026-05-19 (run 5)
*(pending review — see branch `auto/2026-05-19-pending-review`)* Research agent re-ran (45 turns, 233 s, $0.51); check-docs-drift still failing — surface edits from research agent pending human review before merge.

## 2026-05-19 (run 4)
*(pending review — see branch `auto/2026-05-19-pending-review`)* Research agent re-ran (36 turns, 138 s, $0.41); check-docs-drift still failing — surface edits from research agent pending human review before merge.

## 2026-05-19 (run 3)
*(pending review — see PR on branch `auto/2026-05-19-pending-review`)* Research agent re-ran (90 turns, 499 s, $1.47); check-docs-drift still failing — surface edits from research agent pending human review before merge.

## 2026-05-19 (run 2)
*(pending review — see PR on branch `auto/2026-05-19-pending-review`)* Research agent audited 34 pages against unchanged docs index 33c21db3; surface edits flagged by check-docs-drift gate, awaiting human review.

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
