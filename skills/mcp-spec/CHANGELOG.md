# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-18
*(pending review — see draft PR on branch `auto/2026-05-18-pending-review`)* — Docs index 116→119 pages; 3 new SEPs: JSON Schema 2020-12, resource-not-found error, spec feature lifecycle/deprecation; SDK baseline @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1

## [0.2.0] — 2026-05-18

### Added

- `SKILL-tools-resources-prompts.md`: Document SEP-2106 (Draft) — JSON Schema
  2020-12 support for tool `inputSchema` / `outputSchema` / `structuredContent`,
  including backward-compatibility guidance for servers using array or primitive
  structured content.
- `SKILL-protocol.md`: Document SEP-2164 (Draft) — proposed standardisation of
  the resource-not-found error code to `-32602`; cross-SDK inconsistency table
  and client workaround guidance.
- `SKILL-protocol.md`: Document SEP-2596 (Draft) — formal feature lifecycle
  (Active / Deprecated / Removed) with 12-month minimum deprecation window,
  deprecated registry, Tier 1 SDK obligations, and transition rules for the
  HTTP+SSE transport and `includeContext` soft-deprecated values.

### Source

Docs index updated (116 → 119 pages). Three new SEP pages added:
`seps/2106-json-schema-2020-12.md`,
`seps/2164-resource-not-found-error.md`,
`seps/2596-spec-feature-lifecycle-and-deprecation.md`.

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
