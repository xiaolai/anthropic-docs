# Changelog — repo-level

Per-skill history lives under `skills/<name>/CHANGELOG.md`. This file
tracks repo-level changes: the multi-skill platform itself, the shared
pipeline infrastructure, addition / removal / restructure of skills.

Newest entry on top.

---

## 2026-05-17 — Phases 2-5: ecosystem expansion (7 skills shipping)

Big-bang completion of the multi-skill migration. The repo now ships **seven skills** in a single matrix-driven workflow.

**Phase 2 — workflow matrix fan-out:**
- `.github/workflows/daily.yml` rewritten as a matrix over `skills/*` with `fail-fast: false` and `max-parallel: 1`. A `discover-skills` job emits the JSON matrix dynamically from the directory listing.
- Per-skill draft-PR branch naming: `auto/${SKILL_NAME}/${TODAY}-pending-review-${run_id}-${run_attempt}`.
- Per-skill commit message format: `auto[$SKILL_NAME]: …`.
- `.github/workflows/weekly-deep-drift.yml` rewritten to iterate `--deep` mode across skills (`max-parallel: 2`).
- Replaces the legacy `cc-update-check.yml` (deleted).

**Phase 3 — predecessor migration:**
- `skills/claude-agent-sdk/` populated from the prior `claude-agent-sdk-skill-autoupdated` repo. SKILL-typescript.md (1797 lines) + SKILL-python.md (1541 lines) + 2 rule files + 29-page `docs-snapshot/` baseline.
- `config.json` declares `docsPathFilter: agent-sdk/`, both SDKs as packages (`@anthropic-ai/claude-agent-sdk`, `claude-agent-sdk`), and both repos for bug-issue surfacing.

**Phase 4 — 5 new skills scaffolded:**
- `anthropic-api` — Messages API + admin/compliance/beta/models (5 surfaces + 1 rule file).
- `anthropic-platform-features` — agents-and-tools / build-with-claude / manage-claude / managed-agents (4 surfaces).
- `claude-connectors` — connectors directory + custom + Desktop MCPB + MCP Apps design + user-facing Skills + Plugins (5 surfaces).
- `claude-cowork` — Claude for Work multi-cloud + Office agents (2 surfaces).
- `mcp-spec` — MCP open spec (protocol / clients / servers / transport / primitives) (5 surfaces).
- Each new skill gets: `config.json`, `state.json` (scaffoldComplete=false), router `SKILL.md`, surface stubs, README.md, CHANGELOG.md, stub `docs-snapshot/MANIFEST.json`.

**Phase 5 — pipeline + verification:**
- `pipeline/scripts/check-populated.sh` made multi-skill aware (reads targets from `config.json` surfaces/rules; old hardcoded claude-code paths removed).
- `pipeline/scripts/check-docs-drift.sh` — added scaffold-mode bypass (matches `check-populated.sh` pattern via `state.scaffoldComplete`) and made the URL-extraction host-generic (derives host regex from `DOCS_INDEX_URL` so platform.claude.com / claude.com/docs / modelcontextprotocol.io all work).
- `pipeline/scripts/refresh-docs-snapshot.sh` — uses skill's `config.json.upstream.docsPathFilter` with PCRE-lookahead fallback to `perl`.
- `pipeline/agent/verify.sh` — reads surfaces + rules from `config.json` (no hardcoded list), splits per-skill vs repo-root required files, bash 3.2-safe.
- **All 7 skills pass `verify:all` end-to-end (8 gates each).**

**Status:** Multi-skill platform complete. Daily workflow will populate the 5 scaffold skills from upstream on next run.

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
