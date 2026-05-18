# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## [1.29.0] — 2026-05-18

### Changed

- Updated `@modelcontextprotocol/sdk` npm package version reference from
  `0.0.0` (placeholder) to `1.29.0` in state.json.
- Docs index expanded: 116 → 118 pages.

### Added

- **SEP-2106** (Draft — Standards Track): *Tools `inputSchema` & `outputSchema`
  Conform to JSON Schema 2020-12* — proposes loosening schema restrictions so
  `inputSchema` supports composition keywords (`anyOf`, `oneOf`, `allOf`,
  `$ref`, etc.) while retaining `type: "object"`, `outputSchema` accepts any
  valid JSON Schema (removing the object-only constraint), and
  `structuredContent` accepts any JSON value (arrays, primitives, objects).
  Noted in `SKILL-tools-resources-prompts.md` and `SKILL-protocol.md`.
  Source: [`seps/2106`](https://modelcontextprotocol.io/seps/2106-json-schema-2020-12.md).
- **SEP-2164** (Draft — Standards Track): *Standardize Resource Not Found Error
  Code* — proposes standardising on `-32602` (Invalid Params) as the canonical
  resource-not-found error code across all SDKs, replacing the inconsistent mix
  of `-32002`, `-32602`, `-32603`, and `0` currently in use. Noted in
  `SKILL-protocol.md`.
  Source: [`seps/2164`](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md).

## 2026-05-18
- Pipeline run (success): Sync 0.0.0→1.29.0 — docs index 116→118 pages, SEP-2106 (JSON Schema 2020-12) and SEP-2164 (Resource Not Found Error) added to skill surfaces; all 11 gates passed

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
