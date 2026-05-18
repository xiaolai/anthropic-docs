# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-18
- Sync to @modelcontextprotocol/sdk v1.29.0 — docs index +2 SEP pages (2106 JSON Schema 2020-12, 2164 resource-not-found error), all gates passed

## [1.29.0] — 2026-05-18

### Changed

- Bumped `@modelcontextprotocol/sdk` (npm) from v0.0 to v1.29.0.
- Docs index updated: 2 new pages added (total 118 pages).

### Added

- SEP-2106 (Draft): Tools `inputSchema` & `outputSchema` Conform to
  JSON Schema 2020-12 — proposes loosening type restrictions on
  `inputSchema`, `outputSchema`, and `structuredContent` to support the
  full JSON Schema 2020-12 vocabulary (composition keywords, array/primitive
  return types). Documented in `SKILL-tools-resources-prompts.md`.
- SEP-2164 (Draft): Standardize Resource Not Found Error Code — proposes
  using `-32602` (Invalid Params) as the canonical error code for
  "resource not found" to replace inconsistent per-SDK usage.
  Documented in `SKILL-protocol.md`.

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
