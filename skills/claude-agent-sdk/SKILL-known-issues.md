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

### KI 1 — Empty thinking blocks emitted on AWS Bedrock (v0.3.152+)

**Symptom**: SDK v0.3.152+ emits `thinking` blocks with `thinking: ""` (empty string) when
using AWS Bedrock with adaptive or enabled thinking. The raw stream contains only a
`signature_delta` and no `thinking_delta` text. Consumers that render or persist thinking
blocks receive a completed block with no displayable content.

**Trigger**: Requires all of:
- AWS Bedrock provider (does **not** reproduce on direct Anthropic provider)
- SDK ≥ v0.3.152 (v0.3.150 produced non-empty thinking)
- `thinking: { type: "adaptive" }` / `thinking: { type: "enabled", ... }` with any `display` value

**Workaround**: Filter empty thinking blocks before rendering or persisting:
```typescript
if (block.type === "thinking" && !block.thinking.trim()) {
  // suppress — signature-only block with no displayable content
}
```

**Status**: Open (regressed in v0.3.152, still present through v0.3.157+; Bedrock-specific).
**Link**: [#337](https://github.com/anthropics/claude-agent-sdk-typescript/issues/337)

---

### KI 2 — Truncated assistant message on interrupt with no discriminator

**Symptom**: When `query.interrupt()` aborts an in-flight model stream, the SDK emits a
truncated `SDKAssistantMessage` (with `stop_reason: null`) **before** the abort actually lands.
The truncated message is structurally indistinguishable from a normal completed assistant
message because `stop_reason` is also `null` for normal completions in the SDK wrapper.

**Trigger**: Call `session.interrupt()` while the model is streaming a long response.

**Workaround**: Listen for `result.terminal_reason === 'aborted_streaming'` as a retroactive
signal that the immediately preceding assistant message was truncated. Buffer the assistant
message and discard/replace it after this signal arrives:
```typescript
let lastAssistant: SDKAssistantMessage | null = null;
for await (const msg of session) {
  if (msg.type === "assistant") lastAssistant = msg;
  if (msg.type === "result" && msg.terminal_reason === "aborted_streaming") {
    lastAssistant = null; // was truncated — discard
  }
}
```

**Status**: Open. No SDK-side fix yet.
**Link**: [#338](https://github.com/anthropics/claude-agent-sdk-typescript/issues/338)

---

### KI 3 — Missing `result` event after subagent + `end_turn` via AsyncIterable prompt

**Symptom**: The `query()` async iterator closes without yielding a terminal `SDKResultMessage`
when all three hold: (1) the main agent invoked the built-in `Agent` tool (subagent), (2) the
main agent produced additional assistant content after the subagent returned, and (3) the
driving `AsyncIterable<SDKUserMessage>` had no follow-up user message buffered when the main
agent reached `end_turn`.

**Trigger**: Confirmed in production at 100% reproduction rate over a multi-hour window on
v0.2.76. Not yet retested on v0.3.x.

**Workaround**: (a) Add a defensive fallback emit in the consumer if the iterator ends without
a `result` event:
```typescript
let sawResult = false;
for await (const msg of q) {
  if (msg.type === "result") sawResult = true;
  // ...handle messages...
}
if (!sawResult) {
  // iterator ended cleanly but without result — treat as success
}
```
(b) Avoid the `Agent` tool; run subagent logic inline in the main agent turn.

**Status**: Open. Confirmed on v0.2.76; version status on v0.3.x unknown.
**Link**: [#339](https://github.com/anthropics/claude-agent-sdk-typescript/issues/339)

---

*See also: [`rules/claude-agent-sdk-ts.md`](rules/claude-agent-sdk-ts.md)
+ [`rules/claude-agent-sdk-py.md`](rules/claude-agent-sdk-py.md) for
edit-time auto-correction patterns, and
[`SKILL-typescript.md`](SKILL-typescript.md) /
[`SKILL-python.md`](SKILL-python.md) for the canonical API references.*
