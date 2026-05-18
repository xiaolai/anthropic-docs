# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-18
*(pending review — see PR auto/2026-05-18-pending-review)* First full populate 0.0.0→1.29.0: synced all 6 surfaces, added 3 new SEP pages (SEP-2106, SEP-2164, SEP-2596), docs index 116→119 pages

## [1.29.0] — 2026-05-18

### Changed

- TypeScript SDK `@modelcontextprotocol/sdk` updated to v1.29.0.

### Added

- SEP-2106 (Draft — Standards Track): Tools `inputSchema` & `outputSchema`
  loosened to support full JSON Schema 2020-12 vocabulary; `structuredContent`
  widened from object-only to any JSON value.
- SEP-2164 (Draft — Standards Track): Standardises the resource-not-found
  error code to `-32602` (Invalid Params) for consistency across all SDKs.
- SEP-2596 (Draft — Process): Defines a formal feature lifecycle
  (Active / Deprecated / Removed) with a 12-month minimum deprecation window
  and a new deprecated-feature registry.
- Docs index updated to 119 pages (was 116).

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
