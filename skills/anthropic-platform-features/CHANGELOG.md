# anthropic-platform-features — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-19
*(pending review — see branch auto/2026-05-19-pending-review)* Docs index 109 → 119 pages — added 8 MCP Tunnels pages (`agents-and-tools/mcp-tunnels/*`) and 2 Self-Hosted Sandboxes pages (`managed-agents/self-hosted-sandboxes*`); checkDiffSize gate failed due to large batch size

## 2026-05-18
- Sync to platform.claude.com docs — added `build-with-claude/cache-diagnostics.md` (page count 108 → 109); all 11 gates pass

## [0.1.0] — 2026-05-17

### Added

- Scaffold created as part of the `autoupdated-anthropic-documentation-knowledge`
  multi-skill big-bang migration.
- Router `SKILL.md` with 4-surface dispatch (agents-and-tools,
  build-with-claude, manage-claude, managed-agents).
- Surface stubs for all 4 surfaces, pointing at the matching
  `platform.claude.com/docs/en/...` upstream paths.
- `config.json` declaring upstream sources and `docsPathFilter`
  `(agents-and-tools|build-with-claude|manage-claude|managed-agents)/`.
- `state.json` with `scaffoldComplete: false`.
