# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## [1.29.0] — 2026-05-18

### Changed

- Synced tracked `@modelcontextprotocol/sdk` version to v1.29.0.
- Docs index updated (116 → 119 pages); three new SEP pages registered in `state.json`.

### Added

- `SKILL-protocol.md`: notable-SEP summary table added for SEP-2106 (JSON Schema 2020-12
  tool schemas), SEP-2164 (resource-not-found error code standardisation), and SEP-2596
  (feature lifecycle & deprecation policy); SEP-2164 resource-not-found note added
  below the error codes table.
- `SKILL-tools-resources-prompts.md`: SEP-2106 draft callout added below the tool schema
  section explaining the proposed loosening of `inputSchema`/`outputSchema`/`structuredContent`.
- `SKILL-transport.md`: SEP-2596 formal deprecation-timeline note added to the SSE
  transport section.

## 2026-05-18
- Sync to @modelcontextprotocol/sdk v1.29.0 — docs index 116→119 pages, 3 new SEP pages (JSON Schema 2020-12, resource-not-found error, feature lifecycle/deprecation), 3 SKILL surfaces updated, all 23 verify checks passed

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
