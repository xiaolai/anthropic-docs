# anthropic-platform-features — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-28
- *(pending review — see PR auto/2026-05-28-pending-review)* Research agent audit (55 turns, $0.86) — check-docs-drift gate failed; proposed changes on draft branch pending human review

## 2026-05-27
- *(pending review — see PR auto/2026-05-27-pending-review)* Research agent audit (63 turns, $0.89) — check-docs-drift gate failed; proposed changes on draft branch pending human review

## 2026-05-26
- Daily maintenance run — no upstream changes detected; research agent audited 119 pages across 4 surfaces in 67 turns ($0.96), all gates pass

## 2026-05-25
- *(pending review — see PR auto/2026-05-25-pending-review)* Research agent audit (47 turns, $0.79) — check-docs-drift gate failed; proposed changes on draft branch pending human review

## 2026-05-24
- *(pending review — see PR auto/2026-05-24-pending-review)* Research agent audit (63 turns, $1.20) — check-docs-drift gate failed; proposed changes on draft branch pending human review

## 2026-05-23
- Daily maintenance run — no upstream changes detected; research agent audited 119 pages across 4 surfaces in 51 turns ($0.54), all gates pass

## 2026-05-22
- Daily maintenance run — no upstream changes detected; research agent audited 119 pages across 4 surfaces in 75 turns ($1.29), all gates pass

## 2026-05-21
- *(pending review — see PR auto/2026-05-21-pending-review)* Research agent audit (53 turns, $0.83) — check-docs-drift gate failed; changes on draft branch pending human review
- Daily maintenance run (2nd run) — check-docs-drift resolved; research agent audited 119 pages across 4 surfaces in 86 turns ($1.37), all gates pass
- *(pending review — see PR auto/2026-05-21-pending-review)* Research agent audit (87 turns, $1.44) — check-docs-drift gate failed again; changes on draft branch pending human review (3rd run today)

## 2026-05-20
- Sync to platform.claude.com docs — added 10 pages (8 MCP-tunnels pages under agents-and-tools, 2 self-hosted-sandboxes pages under managed-agents); page count 109 → 119; all 11 gates pass
- *(pending review — see PR auto/2026-05-20-pending-review)* Research agent audit (100 turns, $1.82) — check-docs-drift gate failed; changes on draft branch pending human review
- *(pending review — see PR auto/2026-05-20-pending-review)* Research agent re-run (64 turns, $0.80) — check-docs-drift still failing; updated changes on draft branch pending human review
- *(pending review — see PR auto/2026-05-20-pending-review)* Research agent re-run (44 turns, $0.57) — check-docs-drift still failing; draft branch pending human review (3rd consecutive review-mode run today)

## 2026-05-19
- Daily maintenance run — no upstream changes detected; research agent audited 109 pages across 4 surfaces in 49 turns ($0.76), all gates pass

## 2026-05-18
- Sync to platform.claude.com docs — added `build-with-claude/cache-diagnostics.md` (page count 108 → 109); all 11 gates pass

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
