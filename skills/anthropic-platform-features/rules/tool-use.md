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

## Rule 3 — `cache_control` placement: two valid modes

There are two valid placements for `cache_control: { type: "ephemeral" }`:

**Mode A — Automatic caching (top-level request body):**
Place `cache_control` at the top level of the request body. The system automatically
applies it to the last cacheable block and advances it as the conversation grows.
Best for multi-turn conversations — no block-level edits needed.

```json
{
  "model": "claude-opus-4-7",
  "max_tokens": 1024,
  "cache_control": { "type": "ephemeral" },
  "messages": [...]
}
```

**Mode B — Explicit breakpoints (on content blocks):**
Place `cache_control` directly on individual content blocks. Up to **4 breakpoints
per request**. Placing one on the system role's string form is wrong — convert
`system` to the array form first.

```json
{
  "role": "user",
  "content": [
    { "type": "text", "text": "<long context>",
      "cache_control": { "type": "ephemeral" } }
  ]
}
```

**WRONG (cache_control on the message object, not on a content block):**
```json
{ "role": "user", "cache_control": { "type": "ephemeral" }, "content": "..." }
```

Source: [`prompt-caching.md`](https://platform.claude.com/docs/en/build-with-claude/prompt-caching.md).

## Rule 4 — Extended thinking needs `budget_tokens` and counts against `max_tokens`

`thinking: { type: "enabled", budget_tokens: N }`. `N` must be > 0 and
**less than `max_tokens`** (thinking tokens are billed at input rates
but consume the same output budget as the final response).

**WRONG (no budget):**
```python
thinking={"type": "enabled"}     # 400 missing_required_field
```

**WRONG (budget > max_tokens):**
```python
max_tokens=1000
thinking={"type": "enabled", "budget_tokens": 4000}  # rejected
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
`claude-haiku-4-5-20251001`, `claude-mythos-preview`. The platform
rejects unknown IDs. Prefer family-only IDs unless reproducibility
matters; dated IDs pin to a specific snapshot (e.g.,
`claude-opus-4-7-20251030`). Note: `claude-mythos-preview` rejects
forced tool_choice (`"any"` / `"tool"`) — use `"auto"` or `"none"`.

## Rule 8 — `tool_choice` enum

`tool_choice` accepts `{type: "auto"}`, `{type: "any"}`,
`{type: "tool", name: "<tool_name>"}`, or `{type: "none"}`. String
forms (`"auto"`, `"any"`) are rejected — must be an object.

## Rule 9 — Extended thinking restricts `tool_choice`

When `thinking: { type: "enabled", ... }` is set, only
`tool_choice: {"type": "auto"}` (default) and
`tool_choice: {"type": "none"}` are supported. Using `"any"` or
`"tool"` with extended thinking returns an error.

```python
# WRONG — rejected when thinking is enabled
tool_choice={"type": "any"}                          # error
tool_choice={"type": "tool", "name": "my_tool"}      # error

# RIGHT — with extended thinking
tool_choice={"type": "auto"}   # default, always safe
tool_choice={"type": "none"}   # also valid
```

---

*Source: distilled from anthropic-sdk-typescript + anthropic-sdk-python
issue trackers + the platform.claude.com docs. Updated by the daily
research agent when new failure modes appear.*
