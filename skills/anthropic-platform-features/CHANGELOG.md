# anthropic-platform-features — Changelog

All notable changes to this skill. The shared pipeline appends a
machine-generated entry on every successful daily run.

## 2026-05-19
- *(pending review — see draft PR on branch `auto/2026-05-19-pending-review`)* Sync to platform.claude.com docs — 10 new pages (page count 109 → 119): mcp-tunnels section (8 pages) added to SKILL-agents-and-tools.md, self-hosted-sandboxes (2 pages) added to SKILL-managed-agents.md; checkDiffSize gate tripped

## 2026-05-19 (run 1)
- Sync to platform.claude.com docs — 10 new pages (page count 109 → 119): added `agents-and-tools/mcp-tunnels/` section (8 pages: overview, quickstart, console, deploy-compose, deploy-helm, reference, security, troubleshooting) to SKILL-agents-and-tools.md; added `managed-agents/self-hosted-sandboxes.md` and `managed-agents/self-hosted-sandboxes-security.md` to SKILL-managed-agents.md

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
