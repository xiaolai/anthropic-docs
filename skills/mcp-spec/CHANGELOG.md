# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-19
- Sync to @modelcontextprotocol/sdk v1.29.0 — docs index expanded 116→119 pages, 3 new SEPs (JSON Schema 2020-12, resource-not-found error, spec feature lifecycle and deprecation)

## [2026-05-19]

### Changed

- Docs index updated: 116 → 119 pages. Three new SEPs published:
  [SEP-2106 JSON Schema 2020-12](https://modelcontextprotocol.io/seps/2106-json-schema-2020-12.md),
  [SEP-2164 resource-not-found error](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md),
  [SEP-2596 spec feature lifecycle and deprecation](https://modelcontextprotocol.io/seps/2596-spec-feature-lifecycle-and-deprecation.md).
- `@modelcontextprotocol/sdk` npm package updated to v1.29.0.

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
