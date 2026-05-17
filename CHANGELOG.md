# Changelog — repo-level

Per-skill history lives under `skills/<name>/CHANGELOG.md`. This file
tracks repo-level changes: the multi-skill platform itself, the shared
pipeline infrastructure, addition / removal / restructure of skills.

Newest entry on top.

---

## 2026-05-17 — Phase 1: multi-skill platform foundation

Renamed conceptual repo identity from `claude-code-documentation-knowledge-autoupdated` (single Claude Code skill) to `anthropic-docs-skills-autoupdated` (multi-skill platform). On-disk dir name unchanged for the maintainer's local convenience; logical identifier in plugin.json, README, and workflow matches the new name.

**Architectural refactor:**
- `agent/` → `pipeline/agent/` (shared TS agents + sanitiser + monitor + verify)
- `scripts/` → `pipeline/scripts/` (shared verification toolchain)
- `schema/` → `pipeline/schema/` (shared JSONSchemas)
- Previously root-level skill content → `skills/claude-code/`:
  - `SKILL.md` + 7 surface `SKILL-*.md`
  - `rules/*.md` (5 files)
  - `templates/`
  - `docs-snapshot/` (132-page upstream mirror)
  - `state.json` (was `agent/state.json`)
  - `README.md` + `CHANGELOG.md` (per-skill history preserved)
- New `skills/claude-code/config.json` — declares the skill's upstream sources, dispatch table, and schema mappings.

**Pipeline parameterisation:**
- `SKILL_NAME` env var selects which `skills/<name>/` payload to operate on.
- Default `SKILL_NAME=claude-code` preserves the original single-skill behaviour for local invocations.
- All 4 TS agents (update, research, mending, report) updated to derive `SKILL_ROOT` from `SKILL_NAME`.
- `pipeline/agent/verify.sh` and pipeline scripts adapted to per-skill paths.
- Workflow: pending matrix wiring in Phase 2.

**What's preserved from the prior 7 commits of work:**
- All audit-fix findings closed (54 codex findings across 4 passes)
- All 26 NL artifacts scored 100/100 (snapshot 7)
- 14/14 sanitiser tests pass
- All 8 verify:all gates still pass locally for `SKILL_NAME=claude-code`

**Status:** Phase 1 of 5 (foundation). Phases 2-5 (matrix workflow, predecessor migration, scaffold 5 new skills, multi-skill verification) tracked in [`dev-docs/multi-skill-migration.md`](dev-docs/multi-skill-migration.md).
