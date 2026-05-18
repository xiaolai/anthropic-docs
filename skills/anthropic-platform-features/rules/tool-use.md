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

## Rule 3 — `cache_control` placement: automatic (top-level) or explicit (per-block)

There are **two valid ways** to place `cache_control`:

**Automatic (recommended for multi-turn):** place `cache_control` at the **top level of the request body**. The API automatically applies the breakpoint to the last cacheable block and advances it each turn. No per-block annotation needed.

```json
{
  "model": "claude-opus-4-7",
  "max_tokens": 1024,
  "cache_control": { "type": "ephemeral" },
  "system": "...",
  "messages": [...]
}
```

**Explicit breakpoints:** place `cache_control` directly on individual content blocks (up to **4 breakpoints per request**). Never place it on the message object (the `{role, content}` wrapper) — that is always wrong. Convert `system` from a string to an array-of-blocks first if you need to annotate it.

**WRONG (on message wrapper):**
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

## Rule 4 — Extended thinking: model-specific API

The `thinking` parameter behaves differently per model:

- **Claude Opus 4.7:** use `thinking: {type: "adaptive"}`. Manual `thinking: {type: "enabled", budget_tokens: N}` returns **400**. Do NOT pass `budget_tokens` to Opus 4.7.
- **Claude Opus 4.6 / Sonnet 4.6:** adaptive is recommended (`thinking: {type: "adaptive"}`); `budget_tokens` still works but is **deprecated**.
- **Older models (Opus 4.5, Sonnet 4.5, etc.):** must use `thinking: {type: "enabled", budget_tokens: N}`.

When using `budget_tokens`, `N` must be > 0 and **less than `max_tokens`** (thinking tokens are billed at input rates but consume the output budget).

**WRONG (budget_tokens on Opus 4.7):**
```python
# Returns 400 on claude-opus-4-7
thinking={"type": "enabled", "budget_tokens": 4000}
```

**RIGHT (Opus 4.7):**
```python
thinking={"type": "adaptive"}   # or omit thinking entirely; pair with effort
```

**RIGHT (older models):**
```python
thinking={"type": "enabled", "budget_tokens": 8000}  # budget_tokens < max_tokens
```

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

## Rule 8 — `tool_choice` enum

`tool_choice` accepts `{type: "auto"}`, `{type: "any"}`,
`{type: "tool", name: "<tool_name>"}`, or `{type: "none"}`. String
forms (`"auto"`, `"any"`) are rejected — must be an object.

---

*Source: distilled from anthropic-sdk-typescript + anthropic-sdk-python
issue trackers + the platform.claude.com docs. Updated by the daily
research agent when new failure modes appear.*
