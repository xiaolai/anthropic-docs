---
name: anthropic-platform-tool-use
description: Edit-time correctness rules for code that defines or calls Anthropic API tools — tool input_schema shape, cache_control breakpoint hygiene, extended-thinking budget, and tool_use / tool_result round-trip discipline. Catches the mistakes most commonly logged in Anthropic SDK GitHub issues.
appliesTo:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
  - "**/*.js"
  - "**/*.mjs"
  - "**/*.py"
---

# Anthropic Platform — Tool Use & Build-with-Claude Rules

## Rule 1 — `input_schema` requires `type: "object"`

Tool definitions are JSON Schema objects. The Messages API rejects schemas
without an explicit `type: "object"` at the top level.

**WRONG:**
```json
{
  "name": "search",
  "description": "...",
  "input_schema": {
    "properties": { "query": { "type": "string" } }
  }
}
```

**RIGHT:**
```json
{
  "name": "search",
  "description": "...",
  "input_schema": {
    "type": "object",
    "properties": { "query": { "type": "string" } },
    "required": ["query"]
  }
}
```

## Rule 2 — Declare `required` on input_schema properties that are required

The platform respects JSON Schema's `required` array. Omitting it makes
every property optional — the model can skip them, which surfaces as
"the tool got called with no arguments."

If a tool needs a required field, list it in `required: [...]`.

## Rule 3 — `cache_control` is per-block, not per-message

A `cache_control: { type: "ephemeral" }` breakpoint lives on a content
block, not on the message object. Up to **4 breakpoints per request**.
Placing one on the system role's string form is also wrong — convert
`system` to the array form first.

**WRONG (cache_control on message):**
```json
{ "role": "user", "cache_control": { "type": "ephemeral" }, "content": "..." }
```

**RIGHT (on the block):**
```json
{
  "role": "user",
  "content": [
    { "type": "text", "text": "<long context>",
      "cache_control": { "type": "ephemeral" } }
  ]
}
```

## Rule 4 — Extended thinking: manual `budget_tokens` not supported on Opus 4.7

**Claude Opus 4.7** does NOT accept `thinking: {type: "enabled", budget_tokens: N}` —
it returns a 400 error. Use `thinking: {type: "adaptive"}` combined with the
effort parameter instead:

```python
# Opus 4.7 — adaptive thinking (CORRECT)
response = client.messages.create(
    model="claude-opus-4-7",
    thinking={"type": "adaptive"},
    output_config={"effort": "xhigh"},
    max_tokens=64000, ...
)

# Opus 4.7 — manual budget_tokens (WRONG — 400 error)
response = client.messages.create(
    model="claude-opus-4-7",
    thinking={"type": "enabled", "budget_tokens": 4000},  # 400!
)
```

For **Opus 4.6 / Sonnet 4.6**: manual `budget_tokens` is deprecated but still
functional. Prefer adaptive thinking + effort. The `budget_tokens` form will
be removed in a future model release.

For **all other models** (Claude 3.x, Haiku, etc.): manual extended thinking
with `thinking: {type: "enabled", budget_tokens: N}` is still valid.
`N` must be > 0 and **less than `max_tokens`**.

## Rule 5 — `tool_result` must carry the matching `tool_use_id`

Every `tool_result` content block must reference the `id` of the
corresponding `tool_use` block from the previous assistant turn. The
platform rejects mismatched / missing IDs with a 400.

```python
# Assistant turn carried: {"type": "tool_use", "id": "toolu_01ABC...", ...}
# Your next user turn:
{
  "role": "user",
  "content": [
    {
      "type": "tool_result",
      "tool_use_id": "toolu_01ABC...",   # ← REQUIRED, must match
      "content": "<result>"
    }
  ]
}
```

## Rule 6 — Stream response handling

When `stream: true`, the response is **Server-Sent Events**, not JSON.
Do NOT `await response.json()` or `response.text()` — iterate events.

```typescript
// WRONG — hangs or throws
const resp = await client.messages.create({ ..., stream: true });
const data = await resp.json();  // resp is an SSE stream

// RIGHT — use the SDK's stream helper
const stream = await client.messages.stream({ ... });
for await (const chunk of stream) { /* ... */ }
```

## Rule 7 — Model IDs are family-prefix or dated; don't typo

Valid families today: `claude-opus-4-7`, `claude-sonnet-4-6`,
`claude-haiku-4-5-20251001`. The platform rejects unknown IDs.
Prefer family-only IDs unless reproducibility matters; dated IDs
pin to a specific snapshot (e.g., `claude-opus-4-7-20251030`).

**Claude Mythos Preview** (`anthropic/glasswing` — see
[anthropic.com/glasswing](https://anthropic.com/glasswing)) is a
separately-accessed model with adaptive thinking as default. Use its
own model ID when the user requests Glasswing / Mythos access.

## Rule 8 — `tool_choice` enum

`tool_choice` accepts `{type: "auto"}`, `{type: "any"}`,
`{type: "tool", name: "<tool_name>"}`, or `{type: "none"}`. String
forms (`"auto"`, `"any"`) are rejected — must be an object.

---

*Source: distilled from anthropic-sdk-typescript + anthropic-sdk-python
issue trackers + the platform.claude.com docs. Updated by the daily
research agent when new failure modes appear.*
