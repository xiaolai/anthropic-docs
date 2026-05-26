# anthropic-api — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-26
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (125 turns, 479s, $1.35); llms.txt SHA unchanged, no schema changes; 0 new bug issues; all 8 quality gates passed.

## 2026-05-25
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (77 turns, 379s, $1.00); llms.txt SHA unchanged, 2 cosmetic doc-page size changes (models/list.md +241b, compliance/activities.md −1945b), no schema changes; 0 new bug issues; all 8 quality gates passed.

## 2026-05-24
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (36 turns, 140s, $0.54); llms.txt SHA unchanged, no schema changes; 0 new bug issues; all 8 quality gates passed.

## 2026-05-23
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (101 turns, 455s, $1.45); llms.txt SHA unchanged, no schema changes; 0 new bug issues; all 8 quality gates passed.

## 2026-05-21
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (94 turns, 475s, $1.10); added CitationSearchResultLocationParam (type: search_result_location) citation type to SKILL-messages.md; issue #995 skipped (code-change label); all 8 quality gates passed.
- Research-only run: no upstream version change detected; research agent confirmed surfaces current (81 turns, 285s, $0.82); llms.txt SHA unchanged, cosmetic trailing-newline diffs only; 0 new bug issues; all 8 quality gates passed.

## 2026-05-20
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (69 turns, 263s, $0.83); all 8 quality gates passed.
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (127 turns, 441s, $1.93); all 8 quality gates passed; GitHub issues API 403 (no issue scan).
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (110 turns, 451s, $1.62); all 8 quality gates passed; GitHub issues API 403 (no issue scan).
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (88 turns, 402 s, $1.47); all 8 quality gates passed; GitHub issues API 403 (no issue scan).
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (91 turns, 436 s, $1.46); all 8 quality gates passed; GitHub issues API 403 (no issue scan).
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (65 turns, 249 s, $0.75); all 8 quality gates passed; GitHub issues API 403 (no issue scan).
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (50 turns, 194 s, $0.78); all 8 quality gates passed; GitHub issues API 403 (no issue scan).
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (67 turns, 362 s, $1.11); all 8 quality gates passed.
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (91 turns, 399 s, $1.30); all 8 quality gates passed.
- Research-only run: no upstream version change detected; research agent audited all 6 surfaces (64 turns, 317 s, $0.72); all 8 quality gates passed.
- Research-only run (earlier): no upstream version change detected; research agent audited all 6 surfaces (54 turns, 167s, $0.69); all 8 quality gates passed.
- Research-only run (earliest): no upstream version change detected; research agent audited all 6 surfaces (100 turns, 331s, $1.41); all 8 quality gates passed.

## 2026-05-19
- Research-only run (run 6): no upstream version change detected; research agent audited all 6 surfaces (105 turns, 423s, $1.44); all 8 quality gates passed.
- Research-only run (run 5): no upstream version change detected; research agent audited all 6 surfaces (86 turns, 340s, $1.04); all 8 quality gates passed.
- Research-only run (run 4): no upstream version change detected; research agent audited all 6 surfaces (75 turns, 266s, $1.13); all 8 quality gates passed.
- Research-only run (run 3): no upstream version change detected; research agent audited all 6 surfaces (52 turns, 206s, $0.66); all 8 quality gates passed.
- Research-only run (run 2): no upstream version change detected; research agent audited all 6 surfaces (59 turns, 198s, $0.60); all 8 quality gates passed.
- Research-only run (run 1): no upstream version change detected; research agent audited all 6 surfaces (57 turns, $0.81); all 8 quality gates passed.

## 2026-05-18

*(pending review — see draft PR `auto/2026-05-18-pending-review`)* Research agent performed first full baseline audit of all surfaces; diff size exceeded gate threshold — changes await human review before merge.

## [0.1.0] — 2026-05-17

### Added

- Scaffold created as part of the `autoupdated-anthropic-documentation-knowledge`
  multi-skill big-bang migration.
- Router `SKILL.md` with 5-surface dispatch (messages, admin, compliance,
  beta, models).
- Surface stubs for all 5 surfaces, pointing at the matching
  `platform.claude.com/docs/en/api/...` upstream paths.
- Rule file `rules/messages-api.md` covering 6 correctness rules for
  code that calls `client.messages.create()` or `POST /v1/messages`
  directly (system field, tool_result IDs, streaming, max_tokens,
  count_tokens schema parity, cache breakpoint limit).
- `config.json` declaring upstream sources and `docsPathFilter`
  `api/(messages|admin|compliance|beta|models)/`.
- `state.json` with `scaffoldComplete: false` — flips to `true` after
  first successful daily run populates surfaces from upstream.
