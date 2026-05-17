# Changelog

Human-curated history of the `claude-code-documentation-knowledge` skill.
The report agent appends a new entry at the top of this file whenever a
pipeline run modifies any user-facing file. Manual edits are allowed for
clarification or for capturing meta-events the pipeline doesn't observe
(scaffold milestones, design decisions, branch protection changes, etc.).

The newest entry is at the top.

---

## 2026-05-17 — security hardening (pre-first-push)

Addresses all 9 findings from the initial security scan (4 High, 3 Medium, 2 Low). The pipeline was previously vulnerable to a no-auth prompt-injection chain: an attacker posts a crafted public GitHub issue, the monitor captures the title, the research agent reads the full body via `gh api`, and the body's payload runs in the agent's `Bash`-allowed, `bypassPermissions` context. Closed by layered defence:

- **Sanitisation library** (`agent/lib/sanitize.ts`): strips `<system>` / `<important>` / `<instructions>` tags, HTML comments, imperative line-leads, and triple-backtick fences from untrusted content; wraps results in nonce-tagged `<UNTRUSTED_EXTERNAL_CONTENT>` blocks before LLM ingestion. Unit-tested via `agent/lib/sanitize.test.ts`.
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
