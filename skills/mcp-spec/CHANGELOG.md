# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## [Unreleased] — 2026-05-18

### Added

- **SEP-2106** (Draft): Noted proposed JSON Schema 2020-12 support for
  tool `inputSchema`/`outputSchema`/`structuredContent` in
  `SKILL-tools-resources-prompts.md`. Servers should wrap non-object
  outputs until this SEP is accepted.
- **SEP-2164** (Draft): Noted proposed standardisation of the
  resource-not-found error code to `-32602` in `SKILL-protocol.md`
  (error codes section and SEPs table) and `SKILL-tools-resources-prompts.md`
  (resources reading section).
- Updated `state.json`: docs index hash → `f4a9feb8…`, page count 116 → 118,
  two new SEP pages added to `knownPages`, `@modelcontextprotocol/sdk`
  registry version recorded as `1.29.0`, `lastAuditedVersion` → `1.29.0`.

## 2026-05-18
*(pending review — see PR auto/2026-05-18-pending-review)* — First baseline sync to @modelcontextprotocol/sdk v1.29.0; documented SEP-2106 (JSON Schema 2020-12) and SEP-2164 (resource-not-found error) across protocol and tools-resources-prompts surfaces; docs index 116 → 118 pages.

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
