# anthropic-api — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-18

*(pending review — see draft PR `auto/2026-05-18-pending-review`)* Research agent completed first full baseline audit of all six surfaces (73 turns, 218 s); `check-diff-size` gate failed — changes await human review before merge to `main`.

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
