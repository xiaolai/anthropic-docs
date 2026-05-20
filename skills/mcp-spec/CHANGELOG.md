# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-20 (run 2)
*(pending review — see PR auto/2026-05-20-pending-review)* Routine research pass (102 turns, 393s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-20
- Routine research pass (94 turns, 402s) — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; all gates pass

## 2026-05-19 (run 9)
- Routine research pass (102 turns, 506s) — no upstream change; all gates pass; no new rules added

## 2026-05-19 (run 8)
*(pending review — see PR auto/2026-05-19-pending-review)* Routine research pass (68 turns, 275s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-19 (run 7)
*(pending review — see PR auto/2026-05-19-pending-review)* Routine research pass (58 turns, 223s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-19 (run 6)
- Routine research pass — no new pages (SHA256 changed cosmetically, 119 URLs unchanged); no new bug issues (change-report empty); all Part C checks pass: versions consistent (SDK 1.29.0, spec 2025-11-25), URLs resolve, no duplicate facts, cross-references valid; updated docs.indexSha256 in state.json

## 2026-05-19 (run 5)
*(pending review — see PR auto/2026-05-19-pending-review)* Research pass added 3 rules (NumberSchema types, HTTP fallback body-inspection, notifications/message scoping) — checkDocsDrift gate failed; changes pending human review before merge

## 2026-05-19 (run 4)
- Routine research pass — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; all gates pass

## 2026-05-19 (run 3)
*(pending review — see PR auto/2026-05-19-pending-review)* Research pass updated skill surfaces — checkDocsDrift gate failed; changes pending human review before merge

## 2026-05-19 (run 2)
- Routine research pass — no version change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; all gates pass

## 2026-05-19
- Sync to @modelcontextprotocol/sdk v1.29.0 — 3 new draft SEPs (JSON Schema 2020-12, resource-not-found error code, feature lifecycle/deprecation policy), docs index 116→119 pages

## [1.29.0] — 2026-05-19

### Changed

- `state.json`: updated `@modelcontextprotocol/sdk` npm package version
  from `v0.0.0` to `v1.29.0`; updated docs-index SHA-256 hash and page
  count (116 → 119).

### Added

- **SEP-2106** (Draft): *Tools `inputSchema` & `outputSchema` Conform to
  JSON Schema 2020-12* — loosens `inputSchema` (keeps `type: "object"`,
  allows any additional JSON Schema keywords), `outputSchema` (any valid
  JSON Schema, not just objects), and `structuredContent` (any JSON value,
  not just objects). Documented in `SKILL-tools-resources-prompts.md` with
  a pending-SEP callout and compatibility guidance.
  ([seps/2106](https://modelcontextprotocol.io/seps/2106-json-schema-2020-12.md))

- **SEP-2164** (Draft): *Standardize Resource Not Found Error Code* —
  proposes changing the resource-not-found error code from `-32002` to
  `-32602` (Invalid Params) to eliminate cross-SDK inconsistency. Noted in
  `SKILL-protocol.md` (Error codes section) and
  `SKILL-tools-resources-prompts.md` (Resources error handling).
  ([seps/2164](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md))

- **SEP-2596** (Draft): *Specification Feature Lifecycle and Deprecation
  Policy* — introduces Active/Deprecated/Removed feature states with a
  12-month minimum deprecation window and a formal deprecated registry.
  Grandfathers the HTTP+SSE transport and `includeContext:
  "thisServer"/"allServers"` as formally Deprecated. Noted in
  `SKILL-protocol.md` (SEPs section).
  ([seps/2596](https://modelcontextprotocol.io/seps/2596-spec-feature-lifecycle-and-deprecation.md))

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
