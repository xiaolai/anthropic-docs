# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## [1.29.0] — 2026-05-18

### Changed

- Bumped tracked TypeScript SDK to `@modelcontextprotocol/sdk` v1.29.0.

### Added

- Three new SEP pages indexed from `modelcontextprotocol.io/seps/`:
  - **SEP-2106** (Draft, Standards Track) — *Tools `inputSchema` & `outputSchema` Conform to JSON Schema 2020-12*: proposes loosening tool schema restrictions so `inputSchema` keeps `type: "object"` but allows all JSON Schema 2020-12 composition keywords; `outputSchema` supports any valid JSON Schema; `structuredContent` can be any JSON value (not just an object).
  - **SEP-2164** (Draft, Standards Track) — *Standardize Resource Not Found Error Code*: proposes standardising the resource-not-found error on `-32602` (Invalid Params) across all SDK implementations to replace the current inconsistency.
  - **SEP-2596** (Draft, Process) — *Specification Feature Lifecycle and Deprecation Policy*: defines Active / Deprecated / Removed states for spec features, a minimum 12-month deprecation window, and formalises the HTTP+SSE transport and `includeContext` `"thisServer"`/`"allServers"` as Deprecated.
- Noted new SEPs in `SKILL-protocol.md` SEPs section.
- Added draft-proposal callout for SEP-2106 in `SKILL-tools-resources-prompts.md` under Tools.
- Updated `SKILL-transport.md` legacy SSE section to reference SEP-2596 deprecation lifecycle.

## 2026-05-18
- Sync to @modelcontextprotocol/sdk v1.29.0 — added 3 SEP pages (JSON Schema 2020-12, Resource Not Found Error, Feature Lifecycle &amp; Deprecation), all 11 gates passed, 23 verify checks clean

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
