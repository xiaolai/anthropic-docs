# Changelog — repo-level

Per-skill history lives under `skills/<name>/CHANGELOG.md`. This file
tracks repo-level changes: the multi-skill platform itself, the shared
pipeline infrastructure, addition / removal / restructure of skills.

Newest entry on top.

---

## 2026-05-18 — anthropic-pulse: 8th skill (news + research digests)

Added an 8th skill — `anthropic-pulse` — for time-sensitive narrative content from anthropic.com/news and anthropic.com/research. Fundamentally different from the other 7 in three ways:

- **Deterministic render**: zero LLM cost per pipeline run. `pipeline/scripts/fetch-anthropic-pulse.sh` scrapes both HTML index pages, extracts items via targeted perl regex (`<h2-h6>` + `<span class="...title...">` heading variants for Anthropic's two card layouts, `<time>` for dates, `<span class="...subject|caption...">` for categories), caches as JSON, and renders `SKILL-news.md` + `SKILL-research.md` tables. No agent in the loop → no prompt-injection surface, no token spend.
- **Different upstream shape**: HTML pages, not llms.txt. Pipeline override flag `pipelineOverrides.skipMonitorDocsCheck: true` in `config.json` opts the skill out of `check-docs-drift.sh`'s MANIFEST-vs-llms.txt comparison (added that opt-out to the drift script).
- **Digest model**: each item is title + date + category + URL. Body content lives at the upstream URL — Claude WebFetches when a user needs depth on a specific post. No content redistribution; copyright-clean.

Initial fetch: 15 news items + 13 research items. UTF-8 round-tripping (`Claude's` not `Claudeâs`) required four iterations of perl encoding layers to get right — `binmode STDIN, ":encoding(UTF-8)"` + `:raw` STDOUT is the final answer (matching JSON::PP's "unicode-string in, UTF-8-bytes out" expectation).

Cross-linking added for the 3 sources that don't earn skill treatment:
- Root README "Learning resources" section lists [anthropic.skilljar.com](https://anthropic.skilljar.com/), [claude.com/resources/tutorials](https://claude.com/resources/tutorials), and [anthropic.com/economic-futures](https://www.anthropic.com/economic-futures) with the explicit reasoning for why each is a link not a skill.
- `claude-code/README.md` opens with a Skilljar callout.
- `claude-agent-sdk/README.md` opens with a Skilljar + tutorials callout.
- `anthropic-platform-features/README.md` opens with an economic-futures callout.

All 8 skills pass `verify:all` end-to-end.

---

## 2026-05-18 — Repo rename + audit fixes (B1-B5, M1-M3, H1, H2, H5)

**Repo renamed**: `anthropic-docs-skills-autoupdated` → `autoupdated-anthropic-documentation-knowledge`. Plus the predecessor refs to `claude-code-documentation-knowledge-autoupdated` that survived the previous rename. 35 files touched; 0 remaining stale refs.

**Audit fixes** (from the comprehensive skills/rules/hooks audit):

- **B1**: `skills/claude-agent-sdk/rules/*.md` had `paths:` instead of `appliesTo:` in frontmatter, plus missing `name:` fields. **412 lines of rules were silently inert** until this fix.
- **B2**: `skills/claude-code/SKILL.md` referenced a non-existent `claude-api` skill — fixed to `anthropic-api`, plus expanded the Skip clause to reference the actual 4 sibling skills.
- **B4**: `skills/claude-code/SKILL.md` frontmatter `name:` was `claude-code-documentation-knowledge` (mismatched its directory) — renamed to `claude-code` to match the other 6 skills.
- **B5**: stripped stale `v0.2.77` / `v0.1.49` version stamps from `claude-agent-sdk` rule descriptions; updated SKILL.md version row to current `v0.3.143` / `v0.2.82`.
- **H5**: rewrote `claude-agent-sdk` SKILL.md description from 45 words to ~180 with explicit Use-when / Skip clauses matching the other 6 skills' pattern.
- **M1**: normalized README first-headings on `claude-code` and `claude-agent-sdk` to lowercase `# <skill-name>` matching the other 5.
- **M2**: renamed `.github/workflows/daily.yml` → `pipeline.yml` (the file's title block already said "every 30 min"); updated check-gate-parity.sh to use the new path with fallbacks.

**Value-gap closures**:

- **H1** (5 skills had zero rules): authored 6 new rule files covering the most-common edit-time mistakes per skill:
  - `anthropic-platform-features/rules/tool-use.md` — 8 rules for Messages API tool definitions, cache_control, extended thinking, tool_use/tool_result, model IDs, tool_choice
  - `anthropic-platform-features/rules/agent-skills.md` — 6 rules for .skill package authoring
  - `claude-connectors/rules/mcpb-manifest.md` — 8 rules for MCPB manifest.json
  - `claude-connectors/rules/mcp-apps-design.md` — 8 rules for MCP App UI code
  - `claude-cowork/rules/mdm-config.md` — 8 rules for Cowork-on-3P MDM profiles
  - `mcp-spec/rules/mcp-server-impl.md` — 8 rules for MCP server implementations
  All 6 files have correct `appliesTo` globs and `name + description` frontmatter; wired into each skill's `config.json.rules[]`.

- **H2** (5 skills had zero templates): authored 6 new template files:
  - `anthropic-platform-features/templates/tool-definition.json` — canonical tool definition
  - `anthropic-platform-features/templates/skill/SKILL.md` — .skill package starter
  - `claude-connectors/templates/mcpb-manifest.json` — full MCPB manifest example
  - `claude-connectors/templates/mcp-app/index.tsx` — MCP App React widget example
  - `claude-cowork/templates/cowork-3p-mdm.plist` — full macOS MDM profile
  - `mcp-spec/templates/typescript-server.ts` + `python-server.py` — minimal stdio MCP servers in both SDKs

- **M3** (anthropic-platform-features had empty `schemas: {}`): authored 2 new JSONSchemas in `pipeline/schema/`:
  - `anthropic-tool.schema.json` — Anthropic Messages API tool definition shape
  - `agent-skill-frontmatter.schema.json` — Agent Skill SKILL.md frontmatter
  Wired the tool schema into `SKILL-agents-and-tools.md` via the dispatch; the surface now contains a validated fenced JSON example that `validate-examples.sh` PASS 1 enforces.

**Coverage delta**: rules grew from 8 files / 650 lines to 14 files / ~1130 lines across 6 skills (only `claude-code` rules unchanged); templates grew from 36 to 42 across 4 skills.

**All 7 skills still pass `verify:all` end-to-end.**

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

Renamed conceptual repo identity from `autoupdated-anthropic-documentation-knowledge` (single Claude Code skill) to `autoupdated-anthropic-documentation-knowledge` (multi-skill platform). On-disk dir name unchanged for the maintainer's local convenience; logical identifier in plugin.json, README, and workflow matches the new name.

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
