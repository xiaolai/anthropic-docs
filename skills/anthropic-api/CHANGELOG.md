# anthropic-api — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-19
- Research-only run (×2 today): no upstream version change detected; research agent audited all surfaces (79 turns, $1.11 on latest run); all 8 quality gates passed.

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
