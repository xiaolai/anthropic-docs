# Changelog

Human-curated history of the `claude-code-documentation-knowledge` skill.
The report agent appends a new entry at the top of this file whenever a
pipeline run modifies any user-facing file. Manual edits are allowed for
clarification or for capturing meta-events the pipeline doesn't observe
(scaffold milestones, design decisions, branch protection changes, etc.).

The newest entry is at the top.

---

## 2026-05-17 — codex audit-fix pass 2 (22 findings → CLEAN over 3 rounds)

Ran `/codex-toolkit:audit-fix --full` (9-dimension audit) and closed every
finding across three Claude→Codex verification rounds. Final codex
verdict: **CLEAN** — 0 NOT FIXED, 0 PARTIAL, 0 REGRESSED across all
22 findings (1 High, 10 Medium, 11 Low).

**Highest-impact catches:**

- **Sanitiser bug**: `agent/lib/sanitize.ts` line-leader regexes were not
  global — only the FIRST `Important:` line per input was neutralised,
  letting later ones through. Added `g` flag; converted the manual smoke
  script into 14 assertion-based tests + wired into `npm test`.
- **State-vs-prompt contradiction**: all 4 agent prompts said "log
  injection attempts to `agent/state.json.lastRunWarnings`" but the
  Constraints section forbade editing `agent/*`. Carved a narrow
  append-only exception in all 4 prompts + the `report-agent.ts`
  runtime user message.
- **Workflow state-handling**: report-agent failures were
  `continue-on-error: true` AND silently completed with exit 0 (the
  last command in the bash branch was a successful jq pipeline) — so
  `steps.report.outcome` read "success" even when the agent crashed.
  Added `exit "$EXIT_CODE"` in the failure branch; included `report` in
  the commit-step `GATES_FAILED` routing so a crashed report goes to
  draft PR instead of pushing stale state to main.
- **Bug-issue pagination skip**: `monitor.sh` capped at 30 issues per
  run AND advanced the checkpoint to "highest seen" — so if >30 new
  bugs arrived in a day, the older ones were permanently skipped.
  Now paginates up to 10×100 issues and only advances the checkpoint
  when pagination confirmed we reached known territory; otherwise
  leaves the checkpoint alone for next-run re-fetch.
- **Drift detection depth**: daily gate checks only the llms.txt
  index hash; per-page content can change without the index changing.
  Added `--deep` mode to `scripts/check-docs-drift.sh` (re-fetches
  each manifest page and compares per-page hash) and a separate
  `.github/workflows/weekly-deep-drift.yml` that runs the deep check
  Mondays 12:00 UTC.

**Maintainability safety nets (new):**

- `scripts/check-sanitizer-parity.sh` — asserts the comment-strip and
  tag-strip regex patterns are byte-identical across the 3 bash files
  that maintain them (`agent/monitor.sh`, `scripts/refresh-docs-snapshot.sh`,
  `scripts/check-docs-drift.sh`). Fails CI if one diverges.
- `scripts/check-gate-parity.sh` — asserts the safety-gate name list
  matches a canonical EXPECTED array across the 3 sources that maintain
  it (workflow YAML `outcomes` keys, `report-agent.ts` `gateNames`,
  `report-prompt.md` run-mode table). The codex audit caught a
  `checkDocsDrift` mismatch — added to the workflow but missed in the
  other two; this script prevents the next instance.
- Both wired into `npm run verify:all`.

**Smaller fixes:**

- `agent/monitor.sh` release fallback: preserve previous release state
  on `gh api` failure (was treating empty as a "real" change from old).
- `agent/monitor.sh` drift-check pattern: regex matches the router's
  `**Claude Code version**` table row format (was matching
  `claude-code@N.N.N` which never appears).
- Curl timeouts (`--connect-timeout 10 --max-time 60 --retry 2`) on
  every fetch in `monitor.sh`, `refresh-docs-snapshot.sh`,
  `check-docs-drift.sh`.
- `check-docs-drift.sh` missing manifest now exits 2 (per documented
  contract) with `SKIP_IF_NO_MANIFEST=1` bootstrap escape.
- `refresh-docs-snapshot.sh` refuses zero-page extraction (likely
  upstream format change) unless `ALLOW_EMPTY_SNAPSHOT=1`; prunes the
  snapshot dir before re-fetching so stale pages don't linger.
- `validate-examples.sh` PASS 2 now reads pages from
  `MANIFEST.json` (not by walking the snapshot dir), so orphan files
  don't pollute the schema cross-check.
- Workflow auth step now captures the auth method into a shell variable
  before logging — previously `${{ steps.auth.outputs.method }}` was
  evaluated BEFORE the step wrote its output, so the log always recorded
  "unknown".
- `package.json` + `agent/package.json` switched from caret ranges to
  exact-version pins; lockfiles regenerated; `verify:all` now includes
  diff-size + docs-drift + sanitizer-parity + gate-parity + agent tests.
- `LICENSE` file added (MIT) so the declaration in `plugin.json` /
  README has matching content on disk.
- README safety-gates table now lists all 5 gates (was missing docs-drift).
- `dev-docs/scaffold-design.md` opening paragraph now names the
  post-refactor architecture inline + carries an explicit pointer to
  the Post-scaffold evolution section.
- CHANGELOG line claiming the sanitiser was "unit-tested" reworded to
  acknowledge it was a manual smoke script (now upgraded in this entry).

## 2026-05-17 — docs-snapshot baseline + schema cross-check

Adds a committed, version-pinned local mirror of the upstream Claude Code
docs so schemas + seeded examples can be validated against ground truth,
not just against themselves. Caught and removed a hallucinated schema
field (`disableTelemetry`) and tightened two over-permissive enums
(`editorMode` had a fake `"emacs"` value; `forceLoginMethod` was an
unconstrained string) on the very first pass — the audit value was
immediate.

- `docs-snapshot/code.claude.com/` — 132 pages, ~4 MB, fetched from
  `https://code.claude.com/llms.txt` and individual page URLs. Sanitised
  at fetch time via the same defang pipeline `agent/monitor.sh` uses
  (HTML comments + `<system>`/`<important>`/etc. tags stripped — see
  `agent/lib/sanitize.ts` for the threat model).
- `docs-snapshot/MANIFEST.json` — per-page sha256, byte count, and a
  top-level `indexSha256` + `refreshedAt` so drift can be detected by
  comparing one hash against the live `llms.txt`.
- `scripts/refresh-docs-snapshot.sh` — manual refresh script (NOT
  auto-run by CI; refresh deliberately requires a human review the diff).
- `scripts/check-docs-drift.sh` — compares snapshot index sha256 against
  live upstream. Fails loud + names added/removed pages when drift is
  detected. Wired into the daily workflow as a safety gate; failure
  routes the run to a draft PR like all other gate failures.
- `scripts/validate-examples.sh` — extended with PASS 2 (informational):
  walks every `schema/*.schema.json` top-level property key and greps
  the snapshot to verify upstream documents it. Caught
  `disableTelemetry` as hallucinated.
- Schema cleanup: removed `disableTelemetry` and `theme` (neither
  exists in upstream `settings.md`); fixed `editorMode` enum to only
  `["normal", "vim"]`; fixed `forceLoginMethod` to enum
  `["claudeai", "console"]`; added documented `attribution` object;
  marked `includeCoAuthoredBy` as DEPRECATED per upstream docs.
- `agent/verify.sh` — `docs-snapshot/MANIFEST.json` added to required-
  files list so deletions are caught.
- README — new "For maintainers / Refreshing the upstream docs snapshot"
  subsection documenting the manual refresh workflow.

Snapshot pin: index sha256 `0b1ca29a9d37e3e9…`, 132 pages, refreshed
2026-05-17T07:08:36Z.

## 2026-05-17 — codex NL audit-fix pass (15 findings closed)

Ran `/codex-toolkit:audit-nlp` (full, high effort) across the repo and
addressed every actionable finding (13 from codex + 2 surfaced by a
follow-up `/nlpm:score`). The audit found real gaps left by the earlier
security-hardening pass — the security pass had covered update + mending
agents but missed the report agent, leaving an inconsistent prompt-
injection defence. Audit also surfaced two workflow state-handling bugs
that would have caused real first-run failures.

**HIGH (load-bearing first-run blockers):**

- `agent/report-prompt.md` — Security Boundary expanded to full parity
  with the other 3 agent prompts (5 hard rules: no git ops, no secret
  access, no exfiltration, no CI edits, no tool-permission changes; plus
  injection-attempt logging to `lastRunWarnings`).
- `agent/report-agent.ts` — rewritten to import `defangAndWrap` +
  `defangJsonValue` and wrap all 5 input blocks. Removed the
  `git log` / `git diff` instruction (conflicted with the prompt's no-
  git rule). Dropped `Bash` from `allowedTools` — report agent has no
  legitimate shell need. Replaced the predecessor's
  `updateReadmeCostLog` (targeted a `## Cost Log` section that didn't
  exist in our README) with `updateReadmeActivity` that updates the
  actual "Recent activity" table in the shape it was scaffolded with.
- `.github/workflows/cc-update-check.yml` — replaced the
  `cp /tmp/fresh-state.json state.json` step with a `jq`-based merge
  that preserves research-agent-owned fields (`researchedIssues`,
  `lastRunWarnings`, `scaffoldComplete`). Without this, every research
  pass's writes were silently erased.
- New workflow step `Flip scaffoldComplete on first successful
  population`: counts residual `*Populated by the research agent*`
  markers after research success; flips `scaffoldComplete: false → true`
  the first time the count hits zero. Without this, `check-populated.sh`
  could have stayed in scaffold-mode skip forever.
- `agent/monitor.sh` — preserves `scaffoldComplete` and `lastRunWarnings`
  from the live state when building `/tmp/fresh-state.json` so the merge
  step has both halves available.

**MEDIUM (correctness):**

- `agent/research-agent.ts:51` — runtime user message no longer references
  the deleted single `rules/claude-code.md`; names the post-refactor
  multi-file architecture.
- `check-diff-size` step moved BEFORE finalize-log + report-agent in the
  workflow, so the report agent sees its outcome in `/tmp/pipeline-log.json`.
- `agent/monitor.sh` drift-check pattern rewritten — was matching
  `claude-code@[0-9.]+` which never appears in the router (router stores
  version as `v<version>` in a table row). Now greps the router table
  row directly.
- README "What it does" bullets rewritten to name multi-file architecture
  (router + 7 surface files + 5 rules/*.md) and the safety gates
  explicitly. Added "For maintainers" section with `nlpm@xiaolai`
  install path.
- `dev-docs/scaffold-design.md` — added "Post-scaffold evolution"
  postscript explaining the multi-file refactor + security hardening
  + scaffoldComplete mechanism. Added `(superseded — see § Post-
  scaffold evolution)` cross-refs to the two stale file-structure
  rows so a reader scanning the table cold sees the bridge.

**LOW (polish):**

- `scripts/typecheck-templates.sh` — replaced the over-permissive
  `^[A-Z][A-Z0-9_-]*$` sidecar exemption (was incorrectly skipping
  `templates/skills/example/SKILL.md`) with an explicit list
  (README, CHANGELOG, LICENSE, NOTICE, CONTRIBUTING, MCP-PINNING).
- README crontab snippet uses idiomatic `crontab -l || true` so a
  fresh user with no existing crontab doesn't trip a confusing path.

## 2026-05-17 — security hardening (pre-first-push)

Addresses all 9 findings from the initial security scan (4 High, 3 Medium, 2 Low). The pipeline was previously vulnerable to a no-auth prompt-injection chain: an attacker posts a crafted public GitHub issue, the monitor captures the title, the research agent reads the full body via `gh api`, and the body's payload runs in the agent's `Bash`-allowed, `bypassPermissions` context. Closed by layered defence:

- **Sanitisation library** (`agent/lib/sanitize.ts`): strips `<system>` / `<important>` / `<instructions>` tags, HTML comments, imperative line-leads, and triple-backtick fences from untrusted content; wraps results in nonce-tagged `<UNTRUSTED_EXTERNAL_CONTENT>` blocks before LLM ingestion. Manual smoke test shipped at `agent/lib/sanitize.test.ts` (converted to assertion-based tests + wired into `npm test` in the 2026-05-17 audit-fix-2 entry below).
- **Wired into `update-agent.ts` and `mending-agent.ts`**: change-report content is defanged + wrapped before embedding in the user message. The user message preamble names the wrapping nonce so the LLM treats matching blocks as inert data.
- **Defence-in-depth defang in `monitor.sh`**: GitHub release bodies and issue titles are sanitised (jq + Oniguruma regex) before landing in `/tmp/change-report.json`. Coarser pass than the TS layer; insurance against a TS regression.
- **Security Boundary sections** added to all four agent prompts (`system-prompt.md`, `research-prompt.md`, `mending-prompt.md`, `report-prompt.md`): explicit refusal rules for git operations, secret access, exfiltration, CI changes, and tool-permission changes — regardless of what any external content instructs. Injection attempts logged to `state.json.lastRunWarnings`.
- **Workflow token scoping**: `CLAUDE_CODE_OAUTH_TOKEN` and `ANTHROPIC_API_KEY` no longer written to `$GITHUB_ENV` (which would expose them to every step). Now injected per-step via step-level `env:` blocks on only the four agent-invoking steps.
- **Workflow permission tightening**: top-level permissions dropped from `contents: write, pull-requests: write` to `contents: read`. Job-level scope grants the writes only for `daily-run`.
- **Lockfile enforcement**: `agent/package-lock.json` generated; workflow `npm install` → `npm ci` in both root and `agent/`. Stops the supply-chain path through caret-range `^0.3.0` resolution on every CI run.
- **Pinned global Claude Code CLI**: `npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_CLI_VERSION}` (env-var pinned in the workflow, currently `2.1.143`) instead of unpinned auto-latest.
- **MCP template version pinning**: `templates/.mcp.json` now uses exact-version pins for `@modelcontextprotocol/server-{filesystem,github}`; sidecar `templates/MCP-PINNING.md` documents the rationale; `SKILL-mcp.md` example updated to teach the pinned pattern.

## 2026-05-17 — initial scaffold

- Multi-file SKILL architecture: router `SKILL.md` + 7 surface files (`SKILL-settings.md`, `SKILL-hooks.md`, `SKILL-slash-commands.md`, `SKILL-mcp.md`, `SKILL-plugins.md`, `SKILL-cli.md`, `SKILL-known-issues.md`).
- Per-surface auto-correction rules: `rules/settings.md`, `rules/mcp.md`, `rules/plugins.md`, `rules/hooks.md`, `rules/skills-agents-commands.md`.
- Verification toolchain: `schema/settings.schema.json`, `schema/mcp.schema.json`, `schema/plugin.schema.json`, `schema/hook-input.schema.json`; `scripts/validate-examples.sh`, `scripts/typecheck-templates.sh`, `scripts/check-populated.sh`, `scripts/check-diff-size.sh`.
- Executable templates: `templates/settings.json`, `templates/settings.local.json`, `templates/.mcp.json`, `templates/.claude-plugin/plugin.json`, `templates/hooks/pre-tool-use.sh`, `templates/agents/example.md`, `templates/commands/example.md`, `templates/skills/example/SKILL.md`.
- Pipeline safety gates wired into `.github/workflows/cc-update-check.yml`: any gate failure routes the run to a draft PR on branch `auto/<date>-pending-review` instead of pushing to main.
- Pre-first-run scaffold state: `agent/state.json.scaffoldComplete = false`. The first successful pipeline run flips this to `true`, after which `check-populated.sh` enforces no residual stub markers.
