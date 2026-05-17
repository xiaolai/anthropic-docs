# Migration to `anthropic-docs-skills-autoupdated` — full plan + progress

**Status:** Phase 1 complete (working state, commit ready). Phases 2–5 pending.
**Session checkpoint:** 2026-05-17, all 8 verify:all gates green under new layout.

## Goal

One repo, shared pipeline, **7 distinct skill payloads** covering the
whole Anthropic doc surface (everything with a real `llms.txt`):

| # | Skill | Source / scope | Pages | State |
|---|---|---|---|---|
| 1 | `claude-code` | `code.claude.com/*` excluding `agent-sdk/` | ~103 | ✅ migrated to `skills/claude-code/` |
| 2 | `claude-agent-sdk` | `code.claude.com/agent-sdk/*` + npm + PyPI | 29 + per-lang | ⏳ to migrate from predecessor (Phase 3) |
| 3 | `anthropic-api` | `platform.claude.com/docs/en/api/{messages,admin,compliance,beta,models}/*` | ~192 | ⏳ scaffold (Phase 4) |
| 4 | `anthropic-platform-features` | `platform.claude.com/docs/en/{agents-and-tools,build-with-claude,manage-claude,managed-agents}/*` | ~105 | ⏳ scaffold (Phase 4) |
| 5 | `claude-connectors` | `claude.com/docs/{connectors,skills,plugins}/*` (incl. Claude Desktop MCPB, MCP Apps design) | ~34 | ⏳ scaffold (Phase 4) |
| 6 | `claude-cowork` | `claude.com/docs/{cowork,office-agents}/*` | ~35 | ⏳ scaffold (Phase 4) |
| 7 | `mcp-spec` | `modelcontextprotocol.io/*` + spec repo | 116 | ⏳ scaffold (Phase 4) |

Excluded (deliberately):
- `platform.claude.com/api/{typescript,python,...}/*` — 8 × 123 = 984 auto-gen pages. Better via IDE type defs.
- `www.anthropic.com/{news,research}` — different content shape.
- `support.claude.com` Zendesk — low signal.
- `claude.com/llms.txt` itself — marketing.

## Current directory state (after Phase 1)

```
anthropic-docs-skills-autoupdated/    ← logical name; local dir still claude-code-documentation-knowledge-autoupdated
├── pipeline/
│   ├── agent/                        ✅ moved (TS agents, prompts, monitor.sh, verify.sh, sanitiser, package.json)
│   │   ├── update-agent.ts           ✅ parameterised by SKILL_NAME env
│   │   ├── research-agent.ts         ✅ parameterised
│   │   ├── mending-agent.ts          ✅ parameterised
│   │   ├── report-agent.ts           ✅ parameterised
│   │   ├── monitor.sh                🚧 NOT YET parameterised — still single-skill assumptions inline
│   │   ├── verify.sh                 ✅ parameterised (reads SKILL_NAME, scopes to skills/<name>/, reads config.json)
│   │   ├── lib/sanitize.ts + test    ✅ unchanged, universal
│   │   ├── system-prompt.md          🚧 still claude-code-specific (lists SKILL-settings.md etc.). Genericise in Phase 3.
│   │   ├── research-prompt.md        🚧 same
│   │   ├── mending-prompt.md         🚧 same
│   │   ├── report-prompt.md          🚧 same
│   │   ├── package.json + lockfile   ✅ moved
│   │   └── tsconfig.json             ✅ moved
│   ├── scripts/                      ✅ moved + parameterised
│   │   ├── validate-examples.sh      ✅ reads SKILL_NAME, schemas from skills/<name>/config.json
│   │   ├── typecheck-templates.sh    ✅ scopes to skills/<name>/templates/
│   │   ├── check-populated.sh        ✅ scopes to skills/<name>/
│   │   ├── check-diff-size.sh        ✅ TARGETS built from config.json
│   │   ├── check-docs-drift.sh       ✅ docsIndexUrl from config; per-skill snapshot
│   │   ├── refresh-docs-snapshot.sh  ✅ per-skill, host-derived snapshot dir
│   │   ├── check-sanitizer-parity.sh ✅ paths updated (pipeline/agent + pipeline/scripts)
│   │   └── check-gate-parity.sh      ✅ paths updated; workflow path now .github/workflows/daily.yml (with cc-update-check.yml fallback)
│   └── schema/                       ✅ moved (settings, mcp, plugin, hook-input)
├── skills/
│   └── claude-code/                  ✅ all content moved here
│       ├── config.json               ✅ NEW — upstream + dispatch + schemas
│       ├── SKILL.md + SKILL-*.md     ✅
│       ├── rules/*.md                ✅
│       ├── templates/                ✅
│       ├── docs-snapshot/            ✅ 132 pages preserved
│       ├── state.json                ✅
│       ├── README.md                 ✅ (was repo-root README)
│       └── CHANGELOG.md              ✅ (was repo-root CHANGELOG with full audit-fix history)
├── README.md                         ✅ NEW — describes the multi-skill repo
├── CHANGELOG.md                      ✅ NEW — repo-level history (per-skill history in skills/<name>/CHANGELOG.md)
├── LICENSE                           ✅ unchanged
├── package.json + lockfile           ✅ scripts updated to pipeline/scripts/* paths; renamed to anthropic-docs-skills-autoupdated
├── .claude-plugin/plugin.json        ✅ renamed to anthropic-docs-skills-autoupdated
├── .gitignore                        ✅ unchanged
├── .github/
│   ├── workflows/
│   │   ├── cc-update-check.yml       🚧 still single-skill; rewrite to daily.yml matrix in Phase 2
│   │   └── weekly-deep-drift.yml     🚧 still single-skill paths
│   └── PULL_REQUEST_TEMPLATE/        ✅ unchanged
├── dev-docs/
│   ├── scaffold-design.md            ✅ unchanged (historical)
│   └── multi-skill-migration.md      ✅ this file
└── .claude/                          ✅ unchanged (project-local settings)
```

## Verification: Phase 1 working state

```
$ SKILL_NAME=claude-code npm run verify:all
✅ verify:examples         PASS 1 4/4 schema-bound blocks; PASS 2 30/30 keys in snapshot
✅ verify:templates        9/9 templates pass
✅ verify:populated        scaffold mode — skips
✅ verify:diff-size        within 20% per-file
✅ verify:docs-drift       index hash matches upstream
✅ verify:sanitizer-parity 3 bash sanitisers identical
✅ verify:gate-parity      9-gate canonical set across workflow/TS/prompt
✅ verify:agent-tests      14/14 sanitiser assertions
```

All 8 gates green. Backward-compat: `SKILL_NAME` defaults to `claude-code` so existing local invocations work unchanged.

## Phases 2–5: continuation plan

### Phase 2 — Workflow matrix fan-out

**Goal:** Rewrite `.github/workflows/cc-update-check.yml` to matrix-iterate over `skills/*`. End of phase: workflow still only has `claude-code` in matrix, but the structure supports fan-out.

**Files to edit:**
- Rename `.github/workflows/cc-update-check.yml` → `.github/workflows/daily.yml` (matches the new `check-gate-parity.sh` lookup)
- Restructure into one `daily-run` job with `strategy.matrix.skill: [claude-code]` — each matrix entry sets `SKILL_NAME` env
- Update `working-directory` references: `agent/` → `pipeline/agent/`
- Update `npm install` paths: `agent/` → `pipeline/agent/`; root `npm install` stays
- Update all script-call paths: `bash scripts/*.sh` → `bash pipeline/scripts/*.sh`
- Update commit step: per-matrix-entry commit message including skill name; PR branch name includes skill name to prevent collision
- Update README sed step: now targets `skills/<SKILL_NAME>/README.md`, not repo-root
- Update the weekly-deep-drift workflow similarly: matrix over skills, run `bash pipeline/scripts/check-docs-drift.sh --deep`

**Risk:** workflow YAML is long; matrix-rewrite is non-trivial. Test by running `yamllint` + `python3 -c "import yaml; yaml.safe_load(open('...'))"`.

### Phase 3 — Migrate predecessor into `skills/claude-agent-sdk/`

**Source:** `/Users/joker/github/xiaolai/myprojects/claude-agent-sdk-skill-autoupdated/`

**Steps:**
1. `cp -r` predecessor's `SKILL.md`, `SKILL-typescript.md`, `SKILL-python.md`, `rules/`, `templates/` into `skills/claude-agent-sdk/`
2. Write `skills/claude-agent-sdk/config.json`:
   ```json
   {
     "name": "claude-agent-sdk",
     "displayName": "Claude Agent SDK (TypeScript + Python)",
     "upstream": {
       "docsIndexUrl": "https://code.claude.com/llms.txt",
       "docsPathFilter": "agent-sdk/",
       "npmPackages": ["@anthropic-ai/claude-agent-sdk"],
       "pypiPackages": ["claude-agent-sdk"],
       "githubRepos": ["anthropics/claude-agent-sdk-typescript", "anthropics/claude-agent-sdk-python"],
       "bugTrackerRepo": "anthropics/claude-agent-sdk-typescript"
     },
     "router": "SKILL.md",
     "surfaces": ["SKILL-typescript.md", "SKILL-python.md"],
     "rules": ["rules/claude-agent-sdk-ts.md", "rules/claude-agent-sdk-py.md"],
     "dispatch": { "...per-page mapping from agent-sdk docs to TS or Py surface..." },
     "schemas": {}
   }
   ```
3. Write `skills/claude-agent-sdk/README.md` (per-skill story — adapt predecessor's README)
4. Write `skills/claude-agent-sdk/CHANGELOG.md` (preserve predecessor's history; add migration entry)
5. Bootstrap docs-snapshot: `SKILL_NAME=claude-agent-sdk bash pipeline/scripts/refresh-docs-snapshot.sh` (fetches 29 agent-sdk pages from code.claude.com)
6. Add `claude-agent-sdk` to workflow matrix
7. Genericise the 4 system prompts (or move to per-skill `skills/<name>/prompts/`): the prompts currently hardcode the claude-code surface file list. Two paths:
   - **Per-skill prompts**: `skills/<name>/prompts/system.md` etc., loaded by agents based on SKILL_NAME
   - **Generic prompts + config-driven user message**: prompts say "follow the dispatch table in your config.json"; user message built from config

**Recommendation:** Per-skill prompts. Lower-risk than fully generic; preserves the deep, specific guidance each skill needs. Move prompts to `skills/<name>/prompts/` and update TS agents to load `resolve(SKILL_ROOT, "prompts", "<name>.md")`.

8. `monitor.sh` needs significant expansion: currently single npm package + single GH repo. Predecessor needs npm + PyPI + 2 GH repos. Generalise to iterate over arrays from config.json.

9. Predecessor repo's eventual fate: add deprecation banner to its README pointing here. Out of this work's scope.

### Phase 4 — Scaffold 5 new skills

For each of: `anthropic-api`, `anthropic-platform-features`, `claude-connectors`, `claude-cowork`, `mcp-spec`:

1. `mkdir skills/<name>/{rules,templates}`
2. Write `skills/<name>/config.json` with upstream + dispatch + schemas
3. Write `skills/<name>/SKILL.md` router with dispatch table
4. Write `skills/<name>/SKILL-<surface>.md` stubs for each topic cluster (based on the cluster analysis in this doc — see "Sources / scope" column)
5. Write `skills/<name>/rules/*.md` if any (some skills won't have rules — e.g., mcp-spec is reference-only)
6. Write `skills/<name>/README.md` + `CHANGELOG.md`
7. Bootstrap docs-snapshot: `SKILL_NAME=<name> bash pipeline/scripts/refresh-docs-snapshot.sh`
8. Initial `skills/<name>/state.json` (scaffoldComplete: false)
9. Add `<name>` to workflow matrix

**Per-skill structure suggestions (from earlier analysis):**

**`anthropic-api`** (192 pages):
- Router + surfaces: `SKILL-messages.md` (9 pages), `SKILL-admin.md` (37), `SKILL-compliance.md` (37), `SKILL-beta.md` (107), `SKILL-models.md` (2)
- Schemas: write `pipeline/schema/messages-request.schema.json` (Messages API request body schema)
- Rules: per-endpoint usage rules

**`anthropic-platform-features`** (105 pages):
- Router + surfaces: `SKILL-agents-and-tools.md`, `SKILL-build-with-claude.md`, `SKILL-manage-claude.md`, `SKILL-managed-agents.md`
- Sub-clusters: agent-skills, mcp-connector, tool-use under agents-and-tools

**`claude-connectors`** (34 pages — incl. Desktop + Design):
- Router + surfaces: `SKILL-connectors-overview.md`, `SKILL-connectors-building.md`, `SKILL-mcp-apps.md` (incl. design guidelines + Desktop MCPB), `SKILL-claude-skills.md`, `SKILL-claude-plugins.md`

**`claude-cowork`** (35 pages):
- Router + surfaces: `SKILL-cowork.md` (24 pages cowork/3p), `SKILL-office-agents.md` (11 pages)

**`mcp-spec`** (116 pages):
- Router + surfaces: split by topic — `SKILL-clients.md`, `SKILL-servers.md`, `SKILL-transport.md`, `SKILL-protocol.md`, `SKILL-tools.md`, `SKILL-resources.md`, etc. (TBD after inspecting upstream)
- Track packages: `@modelcontextprotocol/sdk` (npm), `mcp` (PyPI)
- Track repos: `modelcontextprotocol/modelcontextprotocol`, `modelcontextprotocol/typescript-sdk`, `modelcontextprotocol/python-sdk`

### Phase 5 — Multi-skill verification + commit

1. Run `SKILL_NAME=<each> npm run verify:all` for every skill, confirm exit 0
2. Run `bash pipeline/scripts/check-docs-drift.sh --deep` for each skill (one-time deep verification of fresh snapshots)
3. Update root `README.md` with current skill matrix + statuses
4. Update root `CHANGELOG.md` with the full multi-skill rollout entry
5. Commit (suggested: one commit per phase for clean history, or one big-bang commit if reviewing as a unit)
6. Bump `package.json` version from 0.2.0 → 1.0.0 to mark the multi-skill release

## What's NOT done in Phase 1 (Pre-existing, needs Phase 3+ work)

- `pipeline/agent/monitor.sh` is NOT yet skill-aware (still has single-source assumptions baked in)
- `pipeline/agent/system-prompt.md` and the 3 sibling prompts still list claude-code-specific files
- `.github/workflows/cc-update-check.yml` still references old paths (works only because Phase 1 made claude-code the default; doesn't fan out)
- The 6 unbuilt skills don't exist yet

## Open questions for next session

1. **Per-skill prompts vs generic + config-driven?** Recommend per-skill (Phase 3 design decision).
2. **MCP spec skill: how to track upstream?** The repo `modelcontextprotocol/modelcontextprotocol` is the spec; the SDK repos are reference impls. Each has its own release cadence. Probably need 3 GitHub repo trackings + 2 package trackings in `monitor.sh`.
3. **Anthropic API skill: include or exclude the 984 auto-gen per-language SDK pages?** Recommend exclude (already in dev memo).
4. **Workflow matrix: parallel or sequential?** Parallel runs ~7× faster but burns 7× concurrent Max-20x quota. Sequential is slower but uses one-at-a-time quota. Start sequential; parallelise once first run lands.

## Continuation handoff

Pick up at Phase 2 by:
1. Reading this file
2. Renaming the workflow to `daily.yml` and converting to matrix
3. Smoke testing the workflow YAML locally (`yamllint` + path checks)
4. Continuing through Phase 3 → 4 → 5 as outlined above

All Phase 1 work is committed and `npm run verify:all` is the canary — if you break it, you'll know immediately.
