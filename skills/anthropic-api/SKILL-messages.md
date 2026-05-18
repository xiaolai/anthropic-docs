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
| `max_tokens` | integer | Maximum tokens to generate. Required. Per-model maximum — see [`models/list.md`](https://platform.claude.com/docs/en/api/models/list.md) |
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
| `thinking` | `ThinkingConfigEnabled \| ThinkingConfigAdaptive \| ThinkingConfigDisabled` — see below |
| `output_config` | Output configuration — see below |

### `thinking` parameter

| Type | Fields | Notes |
|---|---|---|
| `ThinkingConfigEnabled` | `type: "enabled"`, `budget_tokens: number`, `display?: "summarized" \| "omitted"` | Explicit extended thinking. `budget_tokens` ≥1024, < `max_tokens`. `display: "omitted"` redacts thinking but returns a signature for multi-turn continuity; defaults to `"summarized"`. |
| `ThinkingConfigAdaptive` | `type: "adaptive"`, `display?: "summarized" \| "omitted"` | Model decides whether to think. Same `display` semantics as above. |
| `ThinkingConfigDisabled` | `type: "disabled"` | Explicitly disable thinking. |

### `output_config` parameter

An optional object that configures the model's output:

| Sub-field | Type | Notes |
|---|---|---|
| `effort` | string | Reasoning effort level: `"low"` / `"medium"` / `"high"` / `"xhigh"` / `"max"`. Controls how much compute the model spends on reasoning. Check `ModelCapabilities.effort` for model support. |
| `format` | object | Structured output format: `{ type: "json_schema", schema: { ... } }`. Forces the model to return JSON matching the schema. |

Source: [`messages/create.md`](https://platform.claude.com/docs/en/api/messages/create.md) — *last audited 2026-05-18*

> **Note:** `max_tokens: 0` is valid and pre-warms the prompt cache without generating any output tokens.

### Message count limit

Requests support up to **100,000 messages** in the `messages` array.

### Content blocks

Each message's `content` can be a string (shorthand for one text
block) or an array of typed blocks:

| Block type | Use |
|---|---|
| `text` | Plain text. May include `cache_control` and `citations`. Citation types: `char_location`, `page_location`, `content_block_location`, `web_search_result_location`, `search_result_location` (from tool-search results). |
| `image` | `{ source: { type: "base64" \| "url", media_type, data \| url } }` |
| `document` | PDF or other document input |
| `tool_use` | Assistant turn: model invoked a **client** tool. Carries `id`, `name`, `input`. |
| `tool_result` | User turn: result of a previous `tool_use`. **Must reference the matching `tool_use_id`**. |
| `server_tool_use` | Assistant turn: model invoked a **server** tool (e.g. web_search, web_fetch, code_execution). Different return path — see server tools below. |
| `tool_reference` | A reference to a deferred tool loaded via the tool-search mechanism (see `defer_loading` below). |
| `thinking` | Extended-thinking output (when `thinking` enabled) |
| `redacted_thinking` | Thinking content the API redacted before returning |

### Server tools vs. client tools

There are two classes of tools in `tools`:

- **Client tools** — fully defined by the caller via `input_schema`; the model returns a `tool_use` block, and the caller executes and returns `tool_result`. Additional fields: `eager_input_streaming` (stream tool inputs incrementally), `input_examples` (few-shot examples for the model), `type: "custom"` (explicit).
- **Server tools** — built-in tools executed by Anthropic's infrastructure. Appear as a typed object in `tools` (not a schema definition). The model returns a `server_tool_use` block; the result comes back in the same response without a round-trip.

Known server tool types (specify in `tools` array):

| Tool type string | Tool name | Notes |
|---|---|---|
| `web_search_20250305` / `web_search_20260209` | `web_search` | Web search. Supports `allowed_domains`, `blocked_domains`, `user_location`, `max_uses`. |
| `web_fetch_20250910` / `web_fetch_20260209` | `web_fetch` | Fetch a URL. Supports `allowed_domains`, `blocked_domains`, `max_content_tokens`, `citations`, `allowed_callers`. |
| `web_fetch_20260309` | `web_fetch` | Newest variant — adds `use_cache: boolean` to bypass server-side caching. |
| `code_execution_20250522` / `code_execution_20250825` / `code_execution_20260120` | `code_execution` | Execute code. `20260120` adds REPL state persistence (daemon+gVisor checkpoint). |
| `bash_20250124` | `bash` | Execute bash commands in a sandbox. |
| `memory_20250818` | `memory` | Persistent memory store access. |
| `text_editor_20250124` / `text_editor_20250429` / `text_editor_20250728` | `str_replace_editor` / `str_replace_based_edit_tool` | Text editing. `20250728` adds `max_characters` limit. |
| `tool_search_tool_bm25_20251119` | `tool_search_tool_bm25` | BM25 full-text tool search — loads deferred tools on demand. |
| `tool_search_tool_regex_20251119` | `tool_search_tool_regex` | Regex tool search — loads deferred tools on demand. |

Common fields on all server tools: `allowed_callers` (restrict which other tools may call this one: `"direct"`, `"code_execution_20250825"`, `"code_execution_20260120"`), `defer_loading: true` (exclude from initial system prompt; loaded on demand via tool-search), `strict: true` (validate inputs), `cache_control`, `max_uses`.

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

Source: [`messages/count_tokens.md`](https://platform.claude.com/docs/en/api/messages/count_tokens.md).

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

See [`messages/batches/`](https://platform.claude.com/docs/en/api/messages/batches/).

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

- [`messages.md`](https://platform.claude.com/docs/en/api/messages.md) — Messages API section index
- [`messages/create.md`](https://platform.claude.com/docs/en/api/messages/create.md) — POST /v1/messages
- [`messages/count_tokens.md`](https://platform.claude.com/docs/en/api/messages/count_tokens.md) — token counting
- [`messages/batches.md`](https://platform.claude.com/docs/en/api/messages/batches.md) + [`messages/batches/`](https://platform.claude.com/docs/en/api/messages/batches/) — batch processing

## Legacy: Text Completions API

The legacy `/v1/complete` endpoint (predecessor to Messages) is still
documented at:

- [`completions.md`](https://platform.claude.com/docs/en/api/completions.md) — section index
- [`completions/create.md`](https://platform.claude.com/docs/en/api/completions/create.md) — `POST /v1/complete`

**Do not use for new applications.** Text Completions does not support
tool use, vision, or structured outputs. Migrate to Messages.

---

*Source pages: 9 under `platform.claude.com/docs/en/api/messages*` (Messages family) + 2 legacy completions.*
