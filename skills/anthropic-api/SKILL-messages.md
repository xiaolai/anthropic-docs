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
| `thinking` | Extended thinking config — see below |
| `output_config` | Output configuration — see below |
| `container` | `string` — Container ID to reuse across requests (code execution) |
| `inference_geo` | `string` — Geographic region for inference (default: workspace `default_inference_geo`) |
| `cache_control` | `{ type: "ephemeral", ttl?: "5m"\|"1h" }` — Top-level shorthand; applies cache breakpoint at the last cacheable block |

### `thinking` parameter

Three variants (all optional):

| Variant | Shape | Notes |
|---|---|---|
| `ThinkingConfigEnabled` | `{ type: "enabled", budget_tokens: N, display?: "summarized"\|"omitted" }` | Enables thinking; `budget_tokens` ≥ 1024, counts toward `max_tokens`. |
| `ThinkingConfigDisabled` | `{ type: "disabled" }` | Explicitly disables thinking. |
| `ThinkingConfigAdaptive` | `{ type: "adaptive", display?: "summarized"\|"omitted" }` | Model decides whether and how much to think. |

`display` field:
- `"summarized"` (default) — thinking content is returned normally.
- `"omitted"` — thinking content is redacted; a `signature` is still returned so multi-turn continuity is preserved.

Source: [`messages/create.md`](https://platform.claude.com/docs/en/api/messages/create.md) (updated 2026-05-19).

### `output_config` parameter

An optional object that configures the model's output:

| Sub-field | Type | Notes |
|---|---|---|
| `effort` | string | Reasoning effort level: `"low"` / `"medium"` / `"high"` / `"xhigh"` / `"max"`. Controls how much compute the model spends on reasoning. Check `ModelCapabilities.effort` for model support. |
| `format` | object | Structured output format: `{ type: "json_schema", schema: { ... } }`. Forces the model to return JSON matching the schema. |

Source: [`messages/create.md`](https://platform.claude.com/docs/en/api/messages/create.md)

> **Note:** `max_tokens: 0` is valid and pre-warms the prompt cache without generating any output tokens.

### Message count limit

Requests support up to **100,000 messages** in the `messages` array.

### Content blocks

Each message's `content` can be a string (shorthand for one text
block) or an array of typed blocks:

**User-turn input blocks:**

| Block type | Use |
|---|---|
| `text` | Plain text. May include `cache_control` and `citations`. |
| `image` | `{ source: { type: "base64" \| "url", media_type, data \| url } }` |
| `document` | PDF or other document input |
| `search_result` | Passes a search result into context (from tool-search or external lookup). Fields: `content`, `source`, `title`, `type: "search_result"`. Citations within this block use `type: "search_result_location"` — see [citation types](#citation-types). |
| `tool_result` | Result of a previous `tool_use`. **Must reference the matching `tool_use_id`**. |
| `tool_search_tool_result` | Result from a tool_search server tool (`tool_search_tool_bm25` / `tool_search_tool_regex`). Content is `tool_search_tool_search_result` or `tool_search_tool_result_error`. Carries `tool_use_id`. |
| `text_editor_code_execution_tool_result` | Result from a text-editor operation inside code execution. Content is view/create/str_replace result or error. |
| `container_upload` | `ContainerUploadBlockParam` — upload a file to the code-execution container. Fields: `file_id: string`, `type: "container_upload"`, `cache_control: optional`. The file is made available in the container's input directory. |

**Mid-conversation system instructions (`role: "system"` messages):**

A message in the `messages` array may have `role: "system"` if its `content`
consists of `MidConversationSystemBlockParam` blocks (`type: "mid_conv_system"`).
This lets you provide or update system-level instructions at a specific point in
the conversation, rather than only via the top-level `system` parameter.

Schema of a mid-conversation system message:
```json
{
  "role": "system",
  "content": [
    {
      "type": "mid_conv_system",
      "content": [
        { "type": "text", "text": "<updated instruction here>" }
      ]
    }
  ]
}
```

Requires beta header: `mid-conversation-system-2026-04-07` (see [`SKILL-beta.md`](SKILL-beta.md#known-beta-feature-strings)).
Source: [`messages/create.md`](https://platform.claude.com/docs/en/api/messages/create.md) (updated 2026-05-28, SDK v0.100.0).

**Assistant-turn output blocks:**

| Block type | Use |
|---|---|
| `tool_use` | Model invoked a **client** tool. Carries `id`, `name`, `input`, and `caller` (see below). |
| `server_tool_use` | Model invoked a **server** tool. Name: `"web_search"`, `"web_fetch"`, `"code_execution"`, `"bash"`, `"bash_code_execution"`, `"text_editor_code_execution"`, `"tool_search_tool_bm25"`, or `"tool_search_tool_regex"`. Carries a `caller` field. |
| `thinking` | Extended-thinking output (when `thinking` enabled) |
| `redacted_thinking` | Thinking content the API redacted before returning |
| `tool_reference` | Reference to a tool returned by the tool-search server tool. |
| `container_upload` | File uploaded to the code-execution container. `{ file_id, type: "container_upload" }` |
| `web_search_tool_result` | Server-executed web search result. Wraps `WebSearchResultBlock` or error. Carries `tool_use_id` and `caller`. |
| `web_fetch_tool_result` | Server-executed web fetch result. Carries `tool_use_id` and `caller`. |
| `code_execution_tool_result` | Server-executed code execution result (stdout/stderr/return code + output files). Carries `tool_use_id`. |
| `bash_code_execution_tool_result` | Bash result from code execution context. Carries `tool_use_id`. |
| `text_editor_code_execution_tool_result` | Text editor result from code execution context. Carries `tool_use_id`. |
| `tool_search_tool_result` | Tool search result (server-executed). Carries `tool_use_id`. |

#### Citation types

When `citations` are attached to a `text` block or returned in assistant output, the citation is one of these discriminated union variants:

| `type` | Shape | Used for |
|---|---|---|
| `"char_location"` | `CitationCharLocationParam` — `cited_text`, `document_index`, `document_title`, `start_char_index`, `end_char_index` | Citing a character range in a document block |
| `"page_location"` | `CitationPageLocationParam` — `cited_text`, `document_index`, `document_title`, `start_page_number`, `end_page_number` | Citing page numbers in a PDF document block |
| `"content_block_location"` | `CitationContentBlockLocationParam` — `cited_text`, `document_index`, `document_title`, `start_block_index`, `end_block_index` | Citing a range of content blocks in a document |
| `"web_search_result_location"` | `CitationWebSearchResultLocationParam` — `cited_text`, `encrypted_index`, `title` | Citing a web search result (server-executed `web_search`) |
| `"search_result_location"` | `CitationSearchResultLocationParam` — `cited_text`, `search_result_index`, `source`, `title`, `start_block_index`, `end_block_index` | Citing an inline `search_result` content block. `search_result_index` is 0-based among all `search_result` blocks in the request; counted separately from `document_index`. |

> **Response-side `file_id` field (added 2026-05-23):** The response variants of `char_location`, `page_location`, and `content_block_location` citations (`CitationCharLocation`, `CitationPageLocation`, `CitationContentBlockLocation`) include an additional `file_id: string` field identifying the uploaded file used as the document source. The input-side `*Param` variants do not include this field.

Source: [`messages/create.md`](https://platform.claude.com/docs/en/api/messages/create.md) (updated 2026-05-23).

#### `caller` field on `tool_use` and `server_tool_use` blocks

Both `ToolUseBlock` and `ServerToolUseBlock` carry a `caller` discriminated union:

| `caller.type` | Meaning |
|---|---|
| `"direct"` | Invocation directly from the model. |
| `"code_execution_20250825"` | Invoked from within a code-execution server tool. Carries `tool_id`. |
| `"code_execution_20260120"` | Same, newer variant. |

Source: [`messages/create.md`](https://platform.claude.com/docs/en/api/messages/create.md) (updated 2026-05-19).

### Server tools vs. client tools

There are two classes of tools in `tools`:

- **Client tools** — fully defined by the caller via `input_schema`; the model returns a `tool_use` block, and the caller executes and returns `tool_result`.
- **Server tools** — built-in tools executed by Anthropic's infrastructure. Appear as a typed object in `tools` (not a schema definition). The model returns a `server_tool_use` block; the result comes back in the same response without a round-trip.

Known server tool types (specify in `tools` array):

| Tool type string | Name | Description |
|---|---|---|
| `web_search_20250305` / `web_search_20260209` | `"web_search"` | Web search. Supports `allowed_domains`, `blocked_domains`, `user_location`, `max_uses`. |
| `web_fetch_20250910` / `web_fetch_20260209` | `"web_fetch"` | Fetch a URL. Supports `allowed_domains`, `blocked_domains`, `max_content_tokens`, `citations`. |
| `web_fetch_20260309` | `"web_fetch"` | Fetch a URL — adds `use_cache: boolean` param; set to `false` to bypass cached content and force fresh fetch. |
| `code_execution_20250522` | `"code_execution"` | Execute code in a sandbox (earliest variant). |
| `code_execution_20250825` / `code_execution_20260120` | `"code_execution"` | Execute code in a sandbox. `20260120` adds REPL state persistence (daemon mode + gVisor checkpoint). |
| `memory_20250818` | `"memory"` | Memory server tool for persistent key/value storage across sessions. |
| `bash_20250124` | `"bash"` | Bash shell execution (computer use). |
| `text_editor_20250124` / `text_editor_20250429` / `text_editor_20250728` | `"str_replace_editor"` / `"str_replace_based_edit_tool"` | File text editing (computer use). `20250728` adds `max_characters` field. |
| `tool_search_tool_bm25_20251119` / `tool_search_tool_bm25` | `"tool_search_tool_bm25"` | BM25-based tool search (for `tool_reference` content blocks). Undated alias `tool_search_tool_bm25` also accepted. |
| `tool_search_tool_regex_20251119` / `tool_search_tool_regex` | `"tool_search_tool_regex"` | Regex-based tool search (for `tool_reference` content blocks). Undated alias `tool_search_tool_regex` also accepted. |

Server tools also support `defer_loading: true` to exclude from the initial system prompt (loaded on demand) and `strict: true` for schema validation.

Source: [`messages/create.md`](https://platform.claude.com/docs/en/api/messages/create.md) (updated 2026-05-20).

#### Tool definition — additional fields (client tools)

| Field | Type | Notes |
|---|---|---|
| `allowed_callers` | `array` | Which callers can use this tool: `"direct"`, `"code_execution_20250825"`, `"code_execution_20260120"`. Defaults to all. |
| `eager_input_streaming` | `boolean` | When `true`, tool inputs are streamed incrementally before the full JSON is buffered. `false` disables per-tool. `null` (default) follows the beta header setting. |
| `input_examples` | `array` | Optional example inputs (for documentation / prompting). |

Source: [`messages/create.md`](https://platform.claude.com/docs/en/api/messages/create.md) (updated 2026-05-19).

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
    "output_tokens": 100,
    "cache_creation": {
      "ephemeral_5m_input_tokens": 0,
      "ephemeral_1h_input_tokens": 0
    },
    "inference_geo": "us",
    "server_tool_use": {
      "web_search_requests": 0,
      "web_fetch_requests": 0
    },
    "service_tier": "standard"
  }
}
```

#### New top-level response fields (2026-05-19)

| Field | Type | Notes |
|---|---|---|
| `container` | object | Present when code execution was used. `{ id: string, expires_at: string }` — identifier and expiry of the reusable container. |
| `stop_details` | object | Present when `stop_reason == "refusal"`. `{ type: "refusal", category: "cyber"\|"bio", explanation: string }` |

#### `usage` object fields

| Field | Type | Notes |
|---|---|---|
| `input_tokens` | number | Input tokens billed |
| `cache_creation_input_tokens` | number | Tokens written to cache (total across TTLs) |
| `cache_read_input_tokens` | number | Tokens read from cache |
| `output_tokens` | number | Output tokens generated (authoritative billing total) |
| `output_tokens_details` | object | Breakdown of output tokens by category (read-only, observability). `{ thinking_tokens: number }` — number of output tokens spent on internal reasoning (including delimiter tokens), reflecting raw reasoning produced (not possibly-shorter summarized text returned). Added SDK v0.100.0. |
| `cache_creation` | object | Breakdown by TTL: `ephemeral_5m_input_tokens`, `ephemeral_1h_input_tokens` |
| `inference_geo` | string | Geographic region where inference was performed |
| `server_tool_use` | object | Server tool request counts: `web_search_requests`, `web_fetch_requests` |
| `service_tier` | string | Which tier served this request: `"standard"`, `"priority"`, or `"batch"` |

Source: [`messages/create.md`](https://platform.claude.com/docs/en/api/messages/create.md) (updated 2026-05-19).

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
| `content_block_delta` | Incremental content (`text_delta`, `input_json_delta`, `thinking_delta`) — `thinking_delta` frames include `estimated_tokens: number \| null` when the `thinking-token-count-2026-05-13` beta is set (see [`SKILL-beta.md`](SKILL-beta.md)); non-billable running estimate |
| `content_block_stop` | Content block complete |
| `message_delta` | Updates to top-level message (`stop_reason`, `stop_details` (present when `stop_reason == "refusal"`), usage updates) |
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
