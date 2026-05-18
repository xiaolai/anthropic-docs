---
name: claude-agent-sdk-known-issues
description: |
  Catalog of user-impacting bugs the daily research agent has confirmed
  in the Claude Agent SDK (TypeScript or Python). Entries link to the
  upstream GitHub issue, document the symptom + reproduction + a
  workaround if one exists.

  Use when a user reports an SDK error they didn't expect, mentions
  "doesn't work" / "broken" / "regression" / "hangs" with the SDK, or
  asks "is X a known issue?"

  Skip: questions about correct SDK usage (use SKILL-typescript or
  SKILL-python), edit-time correction patterns (use rules/*.md), feature
  requests.
source: https://github.com/anthropics/claude-agent-sdk-typescript/issues
---

# Claude Agent SDK — Known Issues

> Daily issue-tracker scans of
> [`anthropics/claude-agent-sdk-typescript`](https://github.com/anthropics/claude-agent-sdk-typescript)
> (the bug-tracker repo for this skill — see `config.json.upstream.bugTrackerRepo`)
> land confirmed user-impacting bugs here as `### KI N — <title>`
> entries. Python-SDK-specific issues are also surfaced here when they
> appear in the Python repo, prefixed with `(PY)`.

## How entries land here

The research agent's Part B reads new bug-labeled issues in the
upstream repo. For each:

- **`added_known_issue`** → a new `### KI N — <title>` section here.
- **`added_rule`** → if auto-correctable at edit time, becomes a rule
  in [`rules/claude-agent-sdk-ts.md`](rules/claude-agent-sdk-ts.md) or
  [`rules/claude-agent-sdk-py.md`](rules/claude-agent-sdk-py.md)
  instead.
- **`skipped`** → recorded in `state.json.researchedIssues` with a
  reason.

## Entries

### KI 1 — Native binary (≥0.2.110) exceeds Vercel/Lambda 250 MB size limit

**Source**: [anthropics/claude-agent-sdk-typescript#329](https://github.com/anthropics/claude-agent-sdk-typescript/issues/329)
**Status**: Open (2026-05-17)

**Symptom**: Deploying the Agent SDK to Vercel or AWS Lambda fails with a function size error. Since v0.2.110 (2026-04-15), the SDK ships a Bun-compiled native binary per platform via optional dependencies (`@anthropic-ai/claude-agent-sdk-darwin-arm64`, etc.). Each binary is ~230 MB, which pushes most apps past Vercel's 250 MB limit and close to Lambda's 250 MB unzipped cap.

**Reproduction**: Any Next.js/Vercel project importing `@anthropic-ai/claude-agent-sdk@>=0.2.110` exceeds the size limit during `vercel deploy`.

**Workaround**: No clean workaround yet. Options being explored:
- Use `pathToClaudeCodeExecutable` pointing to a separately installed `claude` binary and exclude the optional platform packages from the deploy bundle via `.vercelignore` or webpack externals.
- Run the SDK in a long-running container (ECS, Cloud Run) rather than a serverless function.
- Downgrade to ≤0.2.109 (JS-bundled distribution, not native binary) — note this loses native performance gains.

---

*See also: [`rules/claude-agent-sdk-ts.md`](rules/claude-agent-sdk-ts.md)
+ [`rules/claude-agent-sdk-py.md`](rules/claude-agent-sdk-py.md) for
edit-time auto-correction patterns, and
[`SKILL-typescript.md`](SKILL-typescript.md) /
[`SKILL-python.md`](SKILL-python.md) for the canonical API references.*
