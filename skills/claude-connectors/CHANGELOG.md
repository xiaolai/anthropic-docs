# claude-connectors — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-20 (run 12)
Research agent succeeded (476 s, 83 turns); 34 pages audited; docs_index hash rotated (33c21db→84b7d4e, no page additions/removals); all gates passed — clean push to main

## 2026-05-20 (run 11)
*(pending review — see PR auto/2026-05-20-pending-review)* — Research agent succeeded (527 s, 74 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-20 (run 10)
Research agent succeeded (643 s, 106 turns); 34 pages audited; no upstream changes; all gates passed — clean push to main

## 2026-05-20 (run 9)
Research agent succeeded (269 s, 52 turns); 34 pages audited; no upstream changes; all gates passed — clean push to main

## 2026-05-20 (run 8)
Research agent succeeded (265 s, 76 turns); 34 pages audited; all gates passed — clean push to main

## 2026-05-20 (run 7)
*(pending review — see PR auto/2026-05-20-pending-review)* — Research agent succeeded (254 s, 51 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-20 (run 6)
*(pending review — see PR auto/2026-05-20-pending-review)* — Research agent succeeded (260 s, 52 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-20 (run 5)
*(pending review — see PR auto/2026-05-20-pending-review)* — Research agent succeeded (474 s, 73 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-20 (run 4)
Research agent succeeded (476 s, 71 turns); 34 pages audited; all gates passed — first clean push to main for 2026-05-20

## 2026-05-20 (run 3)
*(pending review — see PR auto/2026-05-20-pending-review)* — Research agent succeeded (239 s, 60 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-20 (run 2)
*(pending review — see PR auto/2026-05-20-pending-review)* — Research agent succeeded (182 s, 47 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-20
*(pending review — see PR auto/2026-05-20-pending-review)* — Research agent succeeded (219 s, 51 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-19 (run 9)
*(pending review — see PR auto/2026-05-19-pending-review)* — Research agent succeeded (321 s, 66 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-19 (run 8)
*(pending review — see PR auto/2026-05-19-pending-review)* — Research agent succeeded (266 s, 61 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-19 (run 7)
*(pending review — see PR auto/2026-05-19-pending-review)* — Research agent succeeded (214 s, 51 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-19 (run 6)
*(pending review — see PR auto/2026-05-19-pending-review)* — Research agent succeeded (388 s, 87 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-19 (run 5)
*(pending review — see PR auto/2026-05-19-pending-review)* — Research agent succeeded (309 s, 61 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-19 (run 4)
*(pending review — see PR auto/2026-05-19-pending-review)* — Research agent succeeded (294 s, 72 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-19 (run 3)
*(pending review — see PR auto/2026-05-19-pending-review)* — Research agent succeeded (220 s, 60 turns); 34 pages audited; check-docs-drift gate failed — content on review branch pending inspection

## 2026-05-19 (run 2)
*(pending review — see PR auto/2026-05-19-pending-review)* — Research agent crash (SDK runtime error); check-docs-drift gate failed; no content changes applied

## 2026-05-19
*(pending review — see PR auto/2026-05-19-pending-review)* — Docs index content sync: 34 pages audited and refreshed; check-diff-size gate triggered review branch (no pages added or removed)

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
