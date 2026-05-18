---
name: anthropic-api-messages
description: |
  Deep reference for the Anthropic Messages API — POST /v1/messages
  request and response shape, content blocks (text, image,
  tool_use, tool_result, thinking, document, citations), streaming
  events, system prompts, count_tokens, message batches, and the
  cache_control breakpoint pattern.
source: https://platform.claude.com/docs/en/api/messages/create.md
---

# Anthropic Messages API

> *Router lives in [`SKILL.md`](SKILL.md). For correctness rules
> when calling the API, see [`rules/messages-api.md`](rules/messages-api.md).*

## `POST /v1/messages`

Send a structured list of messages with text and/or image content;
the model generates the next message in the conversation. Works for
single queries or stateless multi-turn conversations.

### Required parameters

| Parameter | Type | Notes |
|---|---|---|
| `model` | string | Model ID (e.g., `claude-opus-4-7`, `claude-sonnet-4-6`, `claude-haiku-4-5-20251001`) |
| `max_tokens` | integer | Maximum tokens to generate. Required. Per-model maximum — see [`models/list.md`](docs-snapshot/platform.claude.com/en/api/models/list.md) |
| `messages` | array | Alternating `user` / `assistant` turns |

### Common optional parameters

| Parameter | Notes |
|---|---|
| `system` | Top-level system prompt (string OR array of content blocks). **NOT** a message with `role: "system"` — see rules. |
| `temperature` | 0.0–1.0 |
| `top_p`, `top_k` | Sampling controls |
| `stop_sequences` | Array of strings; model stops when any is generated |
| `stream` | `true` for SSE response stream |
| `tools` | Array of tool definitions (see tool use) |
| `tool_choice` | `auto` / `any` / `tool` / `none` |
| `metadata` | `{ user_id: "..." }` for abuse signaling |
| `service_tier` | `auto` / `standard_only` |
| `thinking` | `{ type: "enabled", budget_tokens: N }` for extended thinking |

### Content blocks

Each message's `content` can be a string (shorthand for one text
block) or an array of typed blocks:

| Block type | Use |
|---|---|
| `text` | Plain text. May include `cache_control` and `citations`. |
| `image` | `{ source: { type: "base64" \| "url", media_type, data \| url } }` |
| `document` | PDF or other document input |
| `tool_use` | Assistant turn: model invoked a tool. Carries `id`, `name`, `input`. |
| `tool_result` | User turn: result of a previous tool_use. **Must reference the matching `tool_use_id`**. |
| `thinking` | Extended-thinking output (when `thinking` enabled) |
| `redacted_thinking` | Thinking content the API redacted before returning |

### Prompt caching: `cache_control`

Mark a content block with `cache_control: { type: "ephemeral" }` to
create a 5-minute cache breakpoint. The platform reuses the cached
prefix on subsequent requests with an identical prefix up to that
block, charging cache-read rates instead of full input rates.

```json
{
  "type": "text",
  "text": "<long system prompt>",
  "cache_control": { "type": "ephemeral", "ttl": "5m" }
}
```

Limits:

- Up to **4 cache breakpoints** per request.
- TTL is `5m` (default) or `1h`.

See [`build-with-claude/prompt-caching.md`](../anthropic-platform-features/SKILL-build-with-claude.md)
in the platform-features skill for caching strategy.

### Response shape

```json
{
  "id": "msg_...",
  "type": "message",
  "role": "assistant",
  "model": "claude-opus-4-7",
  "content": [
    { "type": "text", "text": "..." }
  ],
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 25,
    "cache_creation_input_tokens": 0,
    "cache_read_input_tokens": 0,
    "output_tokens": 100
  }
}
```

### Stop reasons

| `stop_reason` | Meaning |
|---|---|
| `end_turn` | Model completed naturally |
| `max_tokens` | Hit the `max_tokens` limit |
| `stop_sequence` | Hit one of the configured `stop_sequences` |
| `tool_use` | Model wants to invoke a tool — round-trip required |
| `pause_turn` | Server tool wants to pause |
| `refusal` | Model refused (safety) |

See [`handling-stop-reasons.md`](../anthropic-platform-features/SKILL-build-with-claude.md)
for handling each.

## Streaming

When `stream: true`, the response is an SSE stream of typed events:

| Event | Payload |
|---|---|
| `message_start` | Initial message metadata (id, role, usage so far) |
| `content_block_start` | New content block beginning |
| `content_block_delta` | Incremental content (`text_delta`, `input_json_delta`, `thinking_delta`) |
| `content_block_stop` | Content block complete |
| `message_delta` | Updates to top-level message (`stop_reason`, usage updates) |
| `message_stop` | Stream complete |
| `ping` | Keep-alive |
| `error` | Error event |

Do **NOT** `await response.json()` on a streaming response — iterate
events. See [`rules/messages-api.md`](rules/messages-api.md) rule 3.

For streaming details: [`build-with-claude/streaming.md`](../anthropic-platform-features/SKILL-build-with-claude.md).

## `POST /v1/messages/count_tokens`

Same shape as `/v1/messages` (minus `max_tokens` and `stream`).
Returns the token count of the request without spending tokens to
generate a response. Use to size requests before committing.

Source: [`messages/count_tokens.md`](docs-snapshot/platform.claude.com/en/api/messages/count_tokens.md).

## Message batches

Submit many requests at lower price (returns within 24h):

| Endpoint | Purpose |
|---|---|
| `POST /v1/messages/batches` | Create a batch |
| `GET /v1/messages/batches/{id}` | Retrieve batch status |
| `GET /v1/messages/batches/{id}/results` | Stream results (newline-delimited JSON) |
| `GET /v1/messages/batches` | List batches |
| `POST /v1/messages/batches/{id}/cancel` | Cancel |
| `DELETE /v1/messages/batches/{id}` | Delete |

See [`messages/batches/`](docs-snapshot/platform.claude.com/en/api/messages/batches/).

## Tool use round-trip

```
1. Request:  messages = [user message describing task] + tools = [tool defs]
2. Response: content includes tool_use block with id/name/input
3. Run the tool yourself.
4. Request:  messages = [original user, assistant tool_use, user tool_result with matching tool_use_id]
5. Response: model's final response (or another tool_use to loop).
```

See [`anthropic-platform-features → SKILL-agents-and-tools.md`](../anthropic-platform-features/SKILL-agents-and-tools.md)
for tool definitions and patterns.

## Source pages

- [`messages.md`](docs-snapshot/platform.claude.com/en/api/messages.md) — Messages API section index
- [`messages/create.md`](docs-snapshot/platform.claude.com/en/api/messages/create.md) — POST /v1/messages
- [`messages/count_tokens.md`](docs-snapshot/platform.claude.com/en/api/messages/count_tokens.md) — token counting
- [`messages/batches.md`](docs-snapshot/platform.claude.com/en/api/messages/batches.md) + [`messages/batches/`](docs-snapshot/platform.claude.com/en/api/messages/batches/) — batch processing

## Legacy: Text Completions API

The legacy `/v1/complete` endpoint (predecessor to Messages) is still
documented at:

- [`completions.md`](docs-snapshot/platform.claude.com/en/api/completions.md) — section index
- [`completions/create.md`](docs-snapshot/platform.claude.com/en/api/completions/create.md) — `POST /v1/complete`

**Do not use for new applications.** Text Completions does not support
tool use, vision, or structured outputs. Migrate to Messages.

---

*Source pages: 9 under `platform.claude.com/docs/en/api/messages*` (Messages family) + 2 legacy completions.*
