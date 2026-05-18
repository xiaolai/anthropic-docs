# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-18
*(pending review — see PR auto/2026-05-18-pending-review)* First cold-start sync: `@modelcontextprotocol/sdk` 0.0.0→1.29.0, docs 116→119 pages, 3 new SEPs (2106, 2164, 2596); check-diff-size gate failed due to large initial diff

## [1.29.0] — 2026-05-18

### Changed

- Bumped tracked npm package `@modelcontextprotocol/sdk` from `0.0.0` to `1.29.0`.
- Updated docs index hash and page count (116 → 119 pages).

### Added

- Three newly indexed SEPs (all **Draft** status):
  - [SEP-2106](https://modelcontextprotocol.io/seps/2106-json-schema-2020-12.md) — Tools `inputSchema`/`outputSchema` conform to JSON Schema 2020-12; `structuredContent` loosened to any JSON value.
  - [SEP-2164](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md) — Standardize resource-not-found error code to `-32602` (Invalid Params) across all SDKs.
  - [SEP-2596](https://modelcontextprotocol.io/seps/2596-spec-feature-lifecycle-and-deprecation.md) — Formal feature lifecycle and deprecation policy (Active → Deprecated → Removed, minimum 12-month window); formalizes HTTP+SSE transport as Deprecated with earliest removal 3 months after SEP-2596 is Final (12-month window waived as already served).
- Notes for the three new SEPs in `SKILL-protocol.md` (SEPs section), `SKILL-tools-resources-prompts.md` (tool schema section), and `SKILL-transport.md` (SSE deprecation section).

## [0.1.0] — 2026-05-17

### Added

- Scaffold created as part of the `autoupdated-anthropic-documentation-knowledge`
  multi-skill big-bang migration.
- Router `SKILL.md` with 5-surface dispatch (protocol, clients,
  servers, transport, tools-resources-prompts).
- Surface stubs for all 5 surfaces.
- `config.json` declaring `modelcontextprotocol.io` as the docs index,
  with `@modelcontextprotocol/sdk` (npm) and `mcp` (PyPI) packages and
  the spec/TS-SDK/Python-SDK GitHub repos tracked.
- `state.json` with `scaffoldComplete: false`.
