# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-19
*(pending review — see PR auto/2026-05-19-pending-review)* — First-run bootstrap from 0.0.0 → @modelcontextprotocol/sdk v1.29.0; 3 new SEPs ingested (2106, 2164, 2596); check-diff-size gate failed, draft PR opened for human review.

## [0.1.1] — 2026-05-19

### Added

- Three new SEPs published to the upstream docs index (page count: 116 → 119):
  - **[SEP-2106](https://modelcontextprotocol.io/seps/2106-json-schema-2020-12.md)** (Draft, Standards Track) — Tools `inputSchema` & `outputSchema` conform to JSON Schema 2020-12: proposes loosening schema restrictions to allow composition keywords (`anyOf`, `oneOf`, `allOf`), `$ref`, and non-object `structuredContent`.
  - **[SEP-2164](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md)** (Draft, Standards Track) — Standardize Resource Not Found error code: proposes `-32602` (Invalid Params) as the canonical code for resource-not-found, replacing the inconsistent `-32002` / `0` used across SDKs today.
  - **[SEP-2596](https://modelcontextprotocol.io/seps/2596-spec-feature-lifecycle-and-deprecation.md)** (Draft, Process) — Specification Feature Lifecycle and Deprecation Policy: introduces formal feature states (Active, Deprecated, Removed) with a minimum 12-month deprecation window, grandfathering the HTTP+SSE transport and `sampling/createMessage` `includeContext` values as already-deprecated.
- Tracked `@modelcontextprotocol/sdk` npm package version updated to v1.29.0.

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
