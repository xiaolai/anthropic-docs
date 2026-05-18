# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-18
- Sync to @modelcontextprotocol/sdk v1.29.0 — skill initialized, docs index 116→118 pages, 2 new SEPs added (json-schema-2020-12, resource-not-found-error)

## [1.29.0] — 2026-05-18

### Changed

- TypeScript SDK (`@modelcontextprotocol/sdk`) bumped to v1.29.0.

### Added

- SEP-2106 (Draft): Loosen `inputSchema`, `outputSchema`, and
  `structuredContent` to support full JSON Schema 2020-12 — composition
  keywords (`anyOf`, `oneOf`, `allOf`), `outputSchema` of any type (not
  just `"object"`), and `structuredContent` of any JSON value.
- SEP-2164 (Draft): Standardize resource-not-found error code to
  `-32602` (Invalid Params) across all MCP SDKs.

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
