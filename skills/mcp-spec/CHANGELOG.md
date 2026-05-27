# mcp-spec — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-27
- Research pass — `clients.md` updated: Codex now supports `Instructions` in addition to Resources/Tools/Elicitation (PR #2790); updated SKILL-clients.md "Existing clients" entry for Codex accordingly. MANIFEST.json regenerated via `refresh-docs-snapshot.sh` (121 pages, refreshedAt 14:09 UTC). Part B: 0 new bug issues (highest bug issue #2725 already researched); `lastScannedIssueNumber` updated to 2801. Part C: 5 spot-checked URLs HTTP 200, versions consistent (@modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 / spec 2025-11-25), validate-examples PASS, all cross-references valid, rules globs covered.
- [pipeline report] Docs index 119→121 pages (2 new: community/feature-lifecycle.md, community/tool-annotations/charter.md); SKILL-clients.md updated; all 11 gates pass; cost $2.35

## 2026-05-26
- Routine research pass (78 turns, 363s) — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; 0 new issues; all gates pass

## 2026-05-25 (run 2)
- Routine research pass (88 turns, 627s) — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; 0 new issues; all gates pass

## 2026-05-25
- Research pass — docs index SHA256 unchanged after sanitization (119 URLs identical); 3 spec pages updated (transports.md, extensions/overview.md, extensions/tasks/overview.md); Part A: corrected `io.modelcontextprotocol/tasks` extension table entry in SKILL-protocol.md (removed misleading "now a core protocol feature" claim; it is a separate extension from core spec Tasks); updated per-request `_meta` capabilities note to clarify Tasks Extension uses this pattern (not "earlier drafts only"); added Tasks Extension vs Core spec comparison table in SKILL-servers.md; added Experimental Extensions note in SKILL-protocol.md (repos with `experimental-ext-` prefix). Part B: no new bug issues (`newBugIssues: []`). Part C: 5 pre-existing URLs HTTP 200, 2 new URLs HTTP 200, validate-examples PASS, cross-references valid, diff-size ~5% on SKILL-protocol.md and ~5% on SKILL-servers.md — PASS.

## 2026-05-24
*(pending review — see PR auto/2026-05-24-pending-review)* Routine research pass (55 turns, 4m) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-23 (run 2)
*(pending review — see PR auto/2026-05-23-pending-review)* Routine research pass (86 turns, 364s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-23
- Research pass — docs index SHA256 updated (119 URLs identical; 4 spec pages changed by merged PR #2769 aligning schema with docs); added `context.arguments` optional field to completion/complete request in SKILL-tools-resources-prompts.md; MANIFEST.json page SHA256s updated for completion.md, tools.md, resources.md, prompts.md; Part B: 8 new issues (#2769–2778) evaluated, 7 skipped (low-signal SEP proposals/docs PRs), 1 `updated_existing` (content documented); Part C: 5 spot-checked URLs HTTP 200, versions consistent (@modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 / spec 2025-11-25), validate-examples PASS, no duplicate facts, diff-size 2% on SKILL-tools-resources-prompts.md — PASS

## 2026-05-22
- Routine research pass (107 turns, 411s) — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; 0 new issues; all gates pass

## 2026-05-21 (run 8)
- Routine research pass — llms.txt index SHA256 updated (1-byte cosmetic change, 119 URLs identical); MANIFEST.json and state.json updated with new indexSha256; Part B: `newBugIssues` empty per change-report.json, no issues to research; Part C: 5 spot-checked URLs all HTTP 200, versions consistent (@modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 / spec 2025-11-25), validate-examples PASS, cross-references valid, rules globs covered; no surface-file changes needed

## 2026-05-21 (run 7)
- Routine research pass — no upstream change; docs index SHA unchanged (2a3dc7cff742a978…, 119 pages); MANIFEST refreshed (new timestamp); 0 new bug issues (all issues ≤ #2759 already researched); Part C: 5 spot-checked URLs resolve HTTP 200/302, versions consistent (@modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 / spec 2025-11-25), validate-examples PASS, no duplicate facts, cross-references valid; updated state.json timestamps and lastScannedIssueNumber to 2759

## 2026-05-21 (run 6)
*(pending review — see PR auto/2026-05-21-pending-review)* Routine research pass (77 turns, 423s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-21 (run 5)
- Routine research pass — docs index SHA256 updated (cosmetic change in llms.txt, 119 URLs identical, MANIFEST already current at 05:00 UTC); no new bug issues (no open issues > #2756); Part C: all 3 spot-checked URLs resolve HTTP 200, versions consistent (SDK v1.29.0 / mcp v1.27.1 / spec 2025-11-25), no duplicate facts, all cross-references valid, rules globs cover documented patterns; updated docs.indexSha256 and lastScannedIssueNumber in state.json

## 2026-05-21 (run 4)
*(pending review — see PR auto/2026-05-21-pending-review)* Routine research pass (108 turns, 422s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-21 (run 3)
- Docs: SEP-2575 page updated (error code for unsupported protocol version changed from `-32602` to `-32004` in draft spec); added `-32003` (MissingRequiredClientCapability) and `-32004` (UnsupportedProtocolVersion) draft-only error codes to SKILL-protocol.md error codes table
- Docs: SEP-2577 (Final) — deprecation of Roots, Sampling, and Logging features (effective next spec revision, expected June 2026) — added deprecation notices to SKILL-protocol.md (SEP table), SKILL-tools-resources-prompts.md (Sampling section), SKILL-servers.md (Logging and server-initiated requests sections), and SKILL-clients.md (Sampling section)
- MANIFEST.json and state.json: updated index SHA256 and SEP-2575 page SHA256

## 2026-05-21 (run 2)
- Routine research pass (93 turns, 372s) — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; all gates pass

## 2026-05-21
- Routine research pass (102 turns, 402s) — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; all gates pass

## 2026-05-20 (run 14)
- Routine research pass (62 turns, 404s) — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; 1 issue evaluated, 0 added; all gates pass

## 2026-05-20 (run 13)
- Routine research pass (63 turns, 252s) — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; 5 issues evaluated, 0 added; all gates pass

## 2026-05-20 (run 12)
- Routine research pass (40 turns, 335s) — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; 5 issues evaluated, 0 added; all gates pass

## 2026-05-20 (run 11)
- Routine research pass (74 turns, 386s) — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; 5 issues evaluated, 0 added; all gates pass

## 2026-05-20 (run 10)
*(pending review — see PR auto/2026-05-20-pending-review)* Routine research pass (68 turns, 291s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-20 (run 9)
*(pending review — see PR auto/2026-05-20-pending-review)* Routine research pass (50 turns, 170s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-20 (run 8)
- Routine research pass — docs index SHA256 updated (cosmetic change in llms.txt, 119 URLs identical); MANIFEST.json already current; no new bug issues (change-report.json empty, no open bug issues > #2752); Part C: all 5 spot-checked URLs resolve HTTP 200, versions consistent (SDK 1.29.0 / mcp 1.27.1 / spec 2025-11-25), no duplicate facts, all cross-references valid, rules globs cover documented patterns; updated docs.indexSha256 and lastScannedIssueNumber in state.json

## 2026-05-20 (run 7)
*(pending review — see PR auto/2026-05-20-pending-review)* Routine research pass (86 turns, 468s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-20 (run 6)
*(pending review — see PR auto/2026-05-20-pending-review)* Routine research pass (65 turns, 271s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-20 (run 5)
*(pending review — see PR auto/2026-05-20-pending-review)* Routine research pass (80 turns, 320s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-20 (run 4)
*(pending review — see PR auto/2026-05-20-pending-review)* Routine research pass (50 turns, 164s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-20 (run 3)
- Routine research pass — docs index sha256 updated (cosmetic description change in llms.txt, 119 URLs unchanged, all page sha256s match MANIFEST); no new bug issues (change-report empty, no open issues >2752); Part C: all 5 spot-checked URLs resolve 200, versions consistent (SDK 1.29.0 / mcp 1.27.1 / spec 2025-11-25), no duplicate facts, cross-references valid; updated docs.indexSha256 and lastScannedIssueNumber in state.json

## 2026-05-20 (run 2)
*(pending review — see PR auto/2026-05-20-pending-review)* Routine research pass (102 turns, 393s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-20
- Routine research pass (94 turns, 402s) — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; all gates pass

## 2026-05-19 (run 9)
- Routine research pass (102 turns, 506s) — no upstream change; all gates pass; no new rules added

## 2026-05-19 (run 8)
*(pending review — see PR auto/2026-05-19-pending-review)* Routine research pass (68 turns, 275s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-19 (run 7)
*(pending review — see PR auto/2026-05-19-pending-review)* Routine research pass (58 turns, 223s) — no upstream change; checkDocsDrift gate failed; surface-file edits pending human review before merge

## 2026-05-19 (run 6)
- Routine research pass — no new pages (SHA256 changed cosmetically, 119 URLs unchanged); no new bug issues (change-report empty); all Part C checks pass: versions consistent (SDK 1.29.0, spec 2025-11-25), URLs resolve, no duplicate facts, cross-references valid; updated docs.indexSha256 in state.json

## 2026-05-19 (run 5)
*(pending review — see PR auto/2026-05-19-pending-review)* Research pass added 3 rules (NumberSchema types, HTTP fallback body-inspection, notifications/message scoping) — checkDocsDrift gate failed; changes pending human review before merge

## 2026-05-19 (run 4)
- Routine research pass — no upstream change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; all gates pass

## 2026-05-19 (run 3)
*(pending review — see PR auto/2026-05-19-pending-review)* Research pass updated skill surfaces — checkDocsDrift gate failed; changes pending human review before merge

## 2026-05-19 (run 2)
- Routine research pass — no version change; @modelcontextprotocol/sdk v1.29.0 / mcp v1.27.1 stable; all gates pass

## 2026-05-19
- Sync to @modelcontextprotocol/sdk v1.29.0 — 3 new draft SEPs (JSON Schema 2020-12, resource-not-found error code, feature lifecycle/deprecation policy), docs index 116→119 pages

## [1.29.0] — 2026-05-19

### Changed

- `state.json`: updated `@modelcontextprotocol/sdk` npm package version
  from `v0.0.0` to `v1.29.0`; updated docs-index SHA-256 hash and page
  count (116 → 119).

### Added

- **SEP-2106** (Draft): *Tools `inputSchema` & `outputSchema` Conform to
  JSON Schema 2020-12* — loosens `inputSchema` (keeps `type: "object"`,
  allows any additional JSON Schema keywords), `outputSchema` (any valid
  JSON Schema, not just objects), and `structuredContent` (any JSON value,
  not just objects). Documented in `SKILL-tools-resources-prompts.md` with
  a pending-SEP callout and compatibility guidance.
  ([seps/2106](https://modelcontextprotocol.io/seps/2106-json-schema-2020-12.md))

- **SEP-2164** (Draft): *Standardize Resource Not Found Error Code* —
  proposes changing the resource-not-found error code from `-32002` to
  `-32602` (Invalid Params) to eliminate cross-SDK inconsistency. Noted in
  `SKILL-protocol.md` (Error codes section) and
  `SKILL-tools-resources-prompts.md` (Resources error handling).
  ([seps/2164](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md))

- **SEP-2596** (Draft): *Specification Feature Lifecycle and Deprecation
  Policy* — introduces Active/Deprecated/Removed feature states with a
  12-month minimum deprecation window and a formal deprecated registry.
  Grandfathers the HTTP+SSE transport and `includeContext:
  "thisServer"/"allServers"` as formally Deprecated. Noted in
  `SKILL-protocol.md` (SEPs section).
  ([seps/2596](https://modelcontextprotocol.io/seps/2596-spec-feature-lifecycle-and-deprecation.md))

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
