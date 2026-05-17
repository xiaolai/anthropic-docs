## Auto-update PR — review before merge

This PR was opened by the daily pipeline because one or more **safety gates failed**. The pipeline did not push the changes to `main` directly. Review the diff and decide:

1. **If the changes are correct as-is** — mark this PR Ready and merge.
2. **If the changes are wrong or partial** — close this PR. The next pipeline run (08:00 UTC tomorrow) will try again from the current `main` state.

## Reviewer checklist

- [ ] **Diff size** — every SKILL-*.md / rules/*.md change is intentional. Look for >20% rewrites of any single file; those are the trigger for routing here.
- [ ] **Schema-bound examples** — every fenced JSON block in `SKILL-settings.md` / `SKILL-mcp.md` / `SKILL-plugins.md` / `SKILL-hooks.md` validates against `schema/*.schema.json`. (CI output above shows which block failed.)
- [ ] **Template integrity** — every file under `templates/` parses cleanly.
- [ ] **Populated sections** — if `agent/state.json` has `scaffoldComplete: true`, no `*Populated by the research agent*` markers should remain.
- [ ] **Cross-references** — links between SKILL-*.md / rules/*.md still resolve.
- [ ] **No duplicate facts** — a schema field, event name, or flag should appear in exactly one SKILL-*.md.

## Failed gates

(The pipeline writes the failed gate list to the PR title and body. Read those for the specific signal.)

## If a gate is wrong

If a safety gate fires false-positive repeatedly (e.g., diff-size threshold too tight after a legitimate big upstream change), tune the threshold in `.github/workflows/cc-update-check.yml` (`DIFF_THRESHOLD_PCT`) rather than disabling the gate.
