---
name: anthropic-api-known-issues
description: |
  Catalog of user-impacting bugs the daily research agent has confirmed
  in the Anthropic API or its TypeScript / Python SDKs. Entries link to
  the upstream GitHub issue, document the symptom + reproduction + a
  workaround if one exists.

  Use when a user reports an error they didn't expect, mentions
  "doesn't work" / "broken" / "regression", or asks "is X a known
  issue?"

  Skip: questions about correct API usage (use SKILL-messages),
  questions about admin / compliance (use SKILL-admin /
  SKILL-compliance), feature requests.
source: https://github.com/anthropics/anthropic-sdk-typescript/issues
---

# Anthropic API & SDK — Known Issues

> Daily issue-tracker scans of
> [`anthropics/anthropic-sdk-typescript`](https://github.com/anthropics/anthropic-sdk-typescript)
> (the bug-tracker repo for this skill — see `config.json.upstream.bugTrackerRepo`)
> land confirmed user-impacting bugs here as `### KI N — <title>` entries.

## How entries land here

The research agent's Part B reads new bug-labeled issues in the upstream
repo. For each:

- **`added_known_issue`** → a new `### KI N — <title>` section is added
  here with symptom / reproduction / workaround / link.
- **`added_rule`** → if the bug is auto-correctable at edit time, the
  fix becomes a new rule in [`rules/messages-api.md`](rules/messages-api.md)
  instead of an entry here.
- **`skipped`** → recorded in `state.json.researchedIssues` with a
  reason; not added here (typically feature requests, environment-
  specific, or already documented).

## Entries

> *No confirmed user-impacting bugs surfaced yet. First entries will
> appear after the research agent's first run that detects a
> substantive bug worth surfacing.*

---

*See also: [`rules/messages-api.md`](rules/messages-api.md) for
auto-correction rules that fire at edit time, and
[`SKILL-messages.md`](SKILL-messages.md) for the canonical API
reference.*
