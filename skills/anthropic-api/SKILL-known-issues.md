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

### KI 1 — Streaming responses missing `cache_creation` TTL breakdown

**Status:** Open (PR #1048 claims fix, not yet merged as of 2026-05-19)

**Symptom:** When using the beta extended cache TTL feature (`extended-cache-ttl-2025-04-11`) with streaming responses, the `BetaMessageDeltaUsage` object in `message_delta` events includes only `cache_creation_input_tokens` (total) but omits the `cache_creation` sub-object with per-TTL breakdowns (`ephemeral_5m_input_tokens`, `ephemeral_1h_input_tokens`). Non-streaming responses include the full breakdown.

**Reproduction:**
```typescript
const stream = await client.beta.messages.stream({
  model: "claude-3-5-sonnet-20241022",
  messages: [{ role: "user", content: [{ type: "text", text: "Hello",
    cache_control: { type: "ephemeral", ttl: "1h" } }] }],
  max_tokens: 100
});
// message_delta events → usage.cache_creation is undefined
// even though the 1h TTL cache was charged at 2× base price
```

**Impact:** Cannot distinguish 5-minute (1.25× base) from 1-hour (2× base) cache costs in streaming mode.

**Workaround:** Use non-streaming (`stream: false`) when you need per-TTL cache cost accounting. Non-streaming responses include the full `cache_creation` breakdown.

**Link:** [anthropics/anthropic-sdk-typescript#793](https://github.com/anthropics/anthropic-sdk-typescript/issues/793) | Fix in progress: PR #1048

---

*See also: [`rules/messages-api.md`](rules/messages-api.md) for
auto-correction rules that fire at edit time, and
[`SKILL-messages.md`](SKILL-messages.md) for the canonical API
reference.*
