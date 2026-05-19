# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-19
*(pending review — see draft PR on branch `auto/2026-05-19-pending-review`)* — Initial population to @modelcontextprotocol/sdk v1.29.0 — docs 116→119 pages, 3 new SEP pages (JSON Schema 2020-12, resource-not-found error, spec feature lifecycle); check-docs-drift gate failed

## [1.29.0] — 2026-05-19

### Changed

- `@modelcontextprotocol/sdk` npm package updated from v0.0.0 to v1.29.0.
- Docs index updated: page count 116 → 119 (3 new SEP pages added).

### Added

- SEP-2106 (Draft): Tools `inputSchema` & `outputSchema` conform to JSON Schema 2020-12 — loosens schema restrictions to allow composition keywords (`anyOf`, `oneOf`, `allOf`) in `inputSchema`, any JSON Schema in `outputSchema`, and any JSON value in `structuredContent`. Noted in `SKILL-tools-resources-prompts.md`.
- SEP-2164 (Draft): Standardize resource not-found error code — proposes `-32602` (Invalid Params) as the canonical error for a resource URI that doesn't exist, replacing the inconsistent `-32002` used by most SDKs. Noted in `SKILL-protocol.md`.
- SEP-2596 (Draft): Specification feature lifecycle and deprecation policy — formalises Active / Deprecated / Removed states for individual spec features, with a minimum 12-month deprecation window. Grandfathers existing informal deprecations (HTTP+SSE transport, `includeContext` sampling values). Noted in `SKILL-protocol.md`.

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
