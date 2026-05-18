---
name: messages-api
description: Correctness rules for code calling the Anthropic Messages API
appliesTo:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.mjs"
  - "**/*.py"
---

# Messages API — Correctness Rules

Applies when editing code that calls `client.messages.create(...)`,
issues `POST /v1/messages` directly, or constructs `tool_use` /
`tool_result` content blocks.

## Rule 1 — `system` is a top-level field, not a role

The system prompt is passed as `system: "..."` (or `system: [...]` for
multi-part). It is **not** a message with `role: "system"`. Adding a
`{role: "system", ...}` entry to `messages` is rejected by the API.

## Rule 2 — `tool_result` requires matching `tool_use_id`

A `tool_result` content block must carry the exact `tool_use_id` from
the matching `tool_use` block in the previous assistant turn. Mismatched
or missing IDs cause a 400.

## Rule 3 — Streaming `stream: true` returns SSE, not JSON

When `stream: true`, the response is a Server-Sent Events stream of
typed events (`message_start`, `content_block_start`,
`content_block_delta`, `content_block_stop`, `message_delta`,
`message_stop`). Do not `await response.json()` on a streaming
response — iterate events instead.

## Rule 4 — `max_tokens` is required

`max_tokens` is a required field in the request. Omitting it returns a
400. The maximum value depends on the chosen model (see
`SKILL-models.md`).

## Rule 5 — `count_tokens` shares the request schema

The `/v1/messages/count_tokens` endpoint accepts the same shape as
`/v1/messages` (minus `max_tokens` and `stream`). Use it to size a
request before paying for the full call.

## Rule 6 — Cache breakpoints are 1-indexed and limited

`cache_control: { type: "ephemeral" }` may be set on up to **4**
content blocks per request. Adding more is silently ignored at best
and rejected at worst — keep cache breakpoints to the boundaries that
actually pay off (typically system + tools + last large doc).

---

*Auto-updated daily. If a rule conflicts with current API behavior,
file an issue at [xiaolai/autoupdated-anthropic-documentation-knowledge](https://github.com/xiaolai/autoupdated-anthropic-documentation-knowledge).*
