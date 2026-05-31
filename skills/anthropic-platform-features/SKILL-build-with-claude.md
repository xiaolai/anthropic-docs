---
name: anthropic-build-with-claude
description: |
  Deep reference for the build-with-claude surface — model selection
  (context windows, models page), reasoning (extended thinking,
  adaptive thinking, effort, fast mode), throughput patterns
  (streaming, batch processing, prompt caching, compaction, context
  editing), inputs (files, PDF support, multilingual, embeddings,
  search results, citations), platform integrations (Bedrock,
  Vertex, Foundry, Claude Platform on AWS), and output handling
  (structured outputs, handle-stop-reasons).
source: https://platform.claude.com/docs/en/build-with-claude/overview.md
---

# Platform — Build with Claude

> *Router lives in [`SKILL.md`](SKILL.md). For raw API request/
> response shape, see [`anthropic-api → SKILL-messages.md`](../anthropic-api/SKILL-messages.md).*

## Key facts (at intent time)

- **Three sampling controls:** `temperature` (randomness, 0.0–1.0),
  `top_p` (nucleus sampling), `top_k` (vocabulary cutoff). Use
  `temperature` alone for most cases; combine only when you understand
  the interaction.
- **Extended thinking — model-specific rules:**
  - **Claude Opus 4.8 (`claude-opus-4-8`) and Claude Opus 4.7:** manual
    `thinking: {type: "enabled", budget_tokens: N}` is **not supported**
    — returns a `400` error. Use `thinking: {type: "adaptive"}` instead.
    `display` defaults to `"omitted"` on both models.
  - **Claude Opus 4.6 / Sonnet 4.6:** `budget_tokens` is **deprecated**
    (still functional, will be removed in a future release). Switch to
    `thinking: {type: "adaptive"}` with the `effort` parameter.
    `display` defaults to `"summarized"` on these models.
  - **Claude Mythos Preview:** adaptive thinking is the default;
    `thinking: {type: "disabled"}` is not supported; `display` defaults
    to `"omitted"` — pass `display: "summarized"` to receive summaries.
  - **`display` field values:** `"summarized"` (default on Opus 4.6,
    Sonnet 4.6, earlier Claude 4 models) returns summarized thinking
    text; `"omitted"` (default on Opus 4.8, Opus 4.7, Mythos Preview)
    returns empty `thinking` field but includes encrypted `signature`
    for multi-turn continuity — faster time-to-first-token when streaming.
  - **Older models (Sonnet 4.5, Opus 4.5, etc.):** use manual
    `thinking: {type: "enabled", budget_tokens: N}` — adaptive thinking
    is not available.
  - Thinking tokens are billed at input-token rates and **count against
    `max_tokens`** for the final response.
  Source: [`extended-thinking.md`](https://platform.claude.com/docs/en/build-with-claude/extended-thinking.md),
  [`adaptive-thinking.md`](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking.md).
- **Prompt caching: two modes.** (1) **Automatic caching** — add
  `cache_control: {"type": "ephemeral"}` at the request body top level;
  the system automatically applies the breakpoint to the last cacheable
  block and advances it each turn. TTL option: `{"type": "ephemeral",
  "ttl": "1h"}` at top level. (2) **Explicit breakpoints** — place
  `cache_control` on individual content blocks for fine-grained control
  (up to 4 breakpoints per request). Automatic caching uses one of the 4
  slots if combined with explicit breakpoints. Default TTL is `5m`; `1h`
  is available at 2× base input price.
  Source: [`prompt-caching.md`](https://platform.claude.com/docs/en/build-with-claude/prompt-caching.md).
- **Cache diagnostics (beta):** Diagnose cache misses by passing
  `diagnostics: { previous_message_id: <prev_id> }` with beta header
  `cache-diagnosis-2026-04-07`. On the **first turn** (no prior response to
  compare), pass `previous_message_id: null` to opt in. The response's
  `diagnostics.cache_miss_reason` reports the first divergence point
  (`model_changed`, `system_changed`, `tools_changed`, `messages_changed`,
  `previous_message_not_found`, or `unavailable`). Claude API only — not
  available on Bedrock or Vertex AI. **ZDR eligible (qualified)** — only
  fingerprints (hashes + token counts) are retained, not raw prompt content.
  - **Response format:** `diagnostics: null` means either first turn
    (`previous_message_id` was `null`) or a comparison ran and found no
    divergence. `diagnostics: {"cache_miss_reason": null}` means the
    comparison was still running when the response was serialized (treat as
    inconclusive, check the next turn).
  - **`cache_missed_input_tokens`** — the four `*_changed` reason types each
    carry this integer field: an estimate (byte-based, pre-tokenization) of how
    many input tokens fell after the divergence point. Treat as a magnitude
    indicator, not an exact billing number.
  - **`unavailable` triggers:** `model`, `system`, and `tools` match but one of
    `tool_choice`, `thinking`, `context_management`, `output_config`,
    `output_format`, or the set of active `anthropic-beta` headers differs; also
    triggered when the divergence is beyond the comparison horizon on very long
    conversations.
  - **Streaming:** In streaming responses, the `diagnostics` object appears on
    the `message_start` SSE event; it is also available on the final accumulated
    message returned by SDK streaming helpers.
  - **Reading diagnostics + usage together:** `diagnostics` answers "did my
    request change?" while `usage.cache_read_input_tokens` answers "did the
    cache hit?". The matrix below applies when a real `previous_message_id`
    was passed; skip it when `cache_miss_reason` is `null` (comparison still
    pending) or `type` is `previous_message_not_found`/`unavailable`.

    | `cache_miss_reason` | Cache read tokens | Interpretation |
    |---|---|---|
    | `null` | high | Working correctly — prefix stable, cache hit |
    | `null` | low or zero | Match found but cache entry expired; use 1h TTL |
    | `*_changed` type | low or zero | Your request changed; fix the indicated cause |
    | `*_changed` type | high | Late-prompt change with earlier breakpoint still hitting; low-impact |

  See
  [`cache-diagnostics.md`](https://platform.claude.com/docs/en/build-with-claude/cache-diagnostics.md).
- **Batches return within 24h** at 50% discount. Submit via
  `POST /v1/messages/batches`; poll for results. Not for interactive use.
- **Vision input:** images can be base64-inline or URL-referenced.
  Max ~5 MB per image. Document blocks (PDFs) are handled separately
  via `type: "document"`. Claude Opus 4.7 supports **high-resolution
  images** (2576px max long edge, ~4784 tokens/image vs ~1568 on other
  models) — no beta header needed, automatic.
  **Per-request image/PDF limit:** a single request may include up to
  **600 images or PDF pages** (100 for 200k-context models such as
  Sonnet 4.5 and Haiku 4.5). You may hit request-size limits before
  hitting the token limit when sending many images or large documents.
  Source: [`vision.md`](https://platform.claude.com/docs/en/build-with-claude/vision.md),
  [`context-windows.md`](https://platform.claude.com/docs/en/build-with-claude/context-windows.md).
- **Context awareness** (Claude Sonnet 4.6, Sonnet 4.5, Haiku 4.5): The
  API automatically injects a token-budget XML tag at conversation start
  (`<budget:token_budget>1000000</budget:token_budget>`) and updates
  remaining capacity after each tool call
  (`<system_warning>Token usage: N/M; R remaining</system_warning>`).
  Helps these models track context capacity during long agentic workflows.
  Source: [`context-windows.md`](https://platform.claude.com/docs/en/build-with-claude/context-windows.md).
- **Bedrock vs Vertex vs Foundry:** Bedrock + Vertex are true 3P
  (Anthropic doesn't see prompts). Foundry is currently a billing
  integration — models still run on Anthropic infra. See
  [`anthropic-platform-features → SKILL-build-with-claude.md`](SKILL-build-with-claude.md)
  cross-reference to [`claude-cowork → SKILL-cowork.md`](../claude-cowork/SKILL-cowork.md)
  for the data-residency implications.
- **Streaming requires SSE handling.** When `stream: true`, do NOT
  `await response.json()`. Iterate Server-Sent Events. See
  [`anthropic-api → rules/messages-api.md`](../anthropic-api/rules/messages-api.md)
  rule 3 for the failure mode.
- **Fast mode is beta (research preview) with a waitlist.** Use
  `speed: "fast"` in the request body **plus** beta header
  `anthropic-beta: fast-mode-2026-02-01`. Supported on
  `claude-opus-4-6` and `claude-opus-4-7` only. Provides up to 2.5×
  higher output tokens per second at premium pricing. ZDR eligible.
  Join waitlist at [claude.com/fast-mode](https://claude.com/fast-mode).
- **Mid-conversation system messages** (`{"role": "system"}` in the
  `messages` array): inject system instructions mid-session without
  editing the top-level `system` field, preserving the cached prefix.
  Placement rules: must immediately follow a `user` turn (or an
  `assistant` turn ending in server tool use); must precede an
  `assistant` turn or end the array. Consecutive system messages are
  not allowed. Available on **Claude API and Claude Platform on AWS
  only** — not on Bedrock, Vertex AI, or Foundry. Available on
  `claude-opus-4-8` only. No beta header required. ZDR eligible.
  Source: [`mid-conversation-system-messages.md`](https://platform.claude.com/docs/en/build-with-claude/mid-conversation-system-messages.md).
- **Context windows** differ per model. Current sizes: **1M tokens** for
  Claude Mythos Preview (`claude-mythos-preview`), Opus 4.7, Opus 4.6, and
  Sonnet 4.6; **200K tokens** for Sonnet 4.5 and older models. Use
  `GET /v1/models/{id}` at runtime to avoid hardcoding.
  See [`anthropic-api → SKILL-models.md`](../anthropic-api/SKILL-models.md).
- **`stop_reason: "model_context_window_exceeded"`** — on Claude 4.5
  and newer models, if `input_tokens + max_tokens` exceeds the context
  window, the API accepts the request and returns this stop reason when
  generation reaches the limit (instead of a validation error). On
  older models the API returns a validation error by default; opt in to
  the new behavior with beta header
  `model-context-window-exceeded-2025-08-26`.
  Source: [`context-windows.md`](https://platform.claude.com/docs/en/build-with-claude/context-windows.md).

## Platform foundation (top-level intro pages)

| Page | Topic |
|---|---|
| [`intro.md`](https://platform.claude.com/docs/en/intro.md) | Platform overview |
| [`get-started.md`](https://platform.claude.com/docs/en/get-started.md) | First-API-call walkthrough |

## Foundation (build-with-claude)

| Page | Topic |
|---|---|
| [`overview.md`](https://platform.claude.com/docs/en/build-with-claude/overview.md) | Build-with-Claude landing |
| [`context-windows.md`](https://platform.claude.com/docs/en/build-with-claude/context-windows.md) | Per-model context window sizes |
| [`streaming.md`](https://platform.claude.com/docs/en/build-with-claude/streaming.md) | `stream: true` event types |
| [`structured-outputs.md`](https://platform.claude.com/docs/en/build-with-claude/structured-outputs.md) | JSON Schema validation on output |
| [`handling-stop-reasons.md`](https://platform.claude.com/docs/en/build-with-claude/handling-stop-reasons.md) | `stop_reason` enum, end-of-turn semantics |

## Test & Evaluate (guardrails)

| Page | Topic |
|---|---|
| [`test-and-evaluate/strengthen-guardrails/handle-streaming-refusals.md`](https://platform.claude.com/docs/en/test-and-evaluate/strengthen-guardrails/handle-streaming-refusals.md) | Handling `stop_reason: refusal` mid-stream |

## Reasoning controls

| Feature | Page | What it does |
|---|---|---|
| **Extended thinking** | [`extended-thinking.md`](https://platform.claude.com/docs/en/build-with-claude/extended-thinking.md) | Manual `thinking: {type: "enabled", budget_tokens: N}` — supported on Opus 4.6/Sonnet 4.6 (deprecated) and older models. **NOT supported on Opus 4.8 or Opus 4.7** (400 error). **Interleaved thinking** (Claude 4 models only): enables Claude to think between tool calls. See [`extended-thinking.md#interleaved-thinking`](https://platform.claude.com/docs/en/build-with-claude/extended-thinking#interleaved-thinking) for syntax |
| **Adaptive thinking** | [`adaptive-thinking.md`](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking.md) | `thinking: {type: "adaptive"}` — model auto-decides thinking depth. **Only thinking mode on Opus 4.8 and Opus 4.7** (must be explicitly enabled). Default on Claude Mythos Preview (auto-applies when `thinking` is unset). Recommended for Opus 4.6/Sonnet 4.6. No beta header required |
| **Effort** | [`effort.md`](https://platform.claude.com/docs/en/build-with-claude/effort.md) | Controls token spend depth. Levels: `low`, `medium`, `high` (default), `max`, `xhigh` (Opus 4.7 only). No beta header required. Supported on Claude Mythos Preview, Opus 4.7, Opus 4.6, Sonnet 4.6, Opus 4.5. **Schema:** `effort` is nested under `output_config` in the request body: `{"output_config": {"effort": "medium"}}`. `max` is available on Claude Mythos Preview, Opus 4.7, Opus 4.6, and Sonnet 4.6 only (not Opus 4.5) |
| **Fast mode** | [`fast-mode.md`](https://platform.claude.com/docs/en/build-with-claude/fast-mode.md) | **Beta (research preview, waitlist).** `speed: "fast"` + header `fast-mode-2026-02-01`; up to 2.5× OTPS on Opus 4.6/4.7 at 6× pricing |

## Throughput / cost patterns

| Feature | Page | What it does |
|---|---|---|
| **Prompt caching** | [`prompt-caching.md`](https://platform.claude.com/docs/en/build-with-claude/prompt-caching.md) | Automatic (top-level `cache_control`) or explicit per-block breakpoints; 5-min or 1h TTL |
| **Cache diagnostics** | [`cache-diagnostics.md`](https://platform.claude.com/docs/en/build-with-claude/cache-diagnostics.md) | Beta (`cache-diagnosis-2026-04-07`) — identify where a prompt prefix diverged and caused a cache miss; Claude API only |
| **Batch processing** | [`batch-processing.md`](https://platform.claude.com/docs/en/build-with-claude/batch-processing.md) | Submit many requests at lower price, returns in 24h |
| **Compaction** | [`compaction.md`](https://platform.claude.com/docs/en/build-with-claude/compaction.md) | Auto-summarize older messages when nearing context limit. Supported on: `claude-mythos-preview`, Opus 4.7, Opus 4.6, Sonnet 4.6 |
| **Context editing** | [`context-editing.md`](https://platform.claude.com/docs/en/build-with-claude/context-editing.md) | Programmatic context-window management |

## Inputs

| Page | Topic |
|---|---|
| [`files.md`](https://platform.claude.com/docs/en/build-with-claude/files.md) | File uploads (Files API) |
| [`pdf-support.md`](https://platform.claude.com/docs/en/build-with-claude/pdf-support.md) | PDF as input (text + vision modes) |
| [`vision.md`](https://platform.claude.com/docs/en/build-with-claude/vision.md) | Image input (base64 or URL), max ~5 MB; Opus 4.7 high-res (2576px, ~4784 tok/img); max 600 images or PDF pages per request (100 on 200k-context models) |
| [`embeddings.md`](https://platform.claude.com/docs/en/build-with-claude/embeddings.md) | Embeddings models |
| [`multilingual-support.md`](https://platform.claude.com/docs/en/build-with-claude/multilingual-support.md) | Supported languages, quality notes |
| [`search-results.md`](https://platform.claude.com/docs/en/build-with-claude/search-results.md) | Web search results as input format |
| [`citations.md`](https://platform.claude.com/docs/en/build-with-claude/citations.md) | Citation block format for grounded responses |
| [`skills-guide.md`](https://platform.claude.com/docs/en/build-with-claude/skills-guide.md) | Using Agent Skills from the API |

## Output / request utilities

| Page | Topic |
|---|---|
| [`working-with-messages.md`](https://platform.claude.com/docs/en/build-with-claude/working-with-messages.md) | Messages API format — constructing requests, content blocks |
| [`token-counting.md`](https://platform.claude.com/docs/en/build-with-claude/token-counting.md) | Count tokens in a request without running inference |
| [`task-budgets.md`](https://platform.claude.com/docs/en/build-with-claude/task-budgets.md) | Task budgets (beta, `task-budgets-2026-03-13`) — advisory token cap for full agentic loop. **Schema:** nested under `output_config`: `{"output_config": {"effort": "high", "task_budget": {"type": "tokens", "total": 64000}}}`. Supported on Opus 4.7 only |

## Conversation management

| Feature | Page | What it does |
|---|---|---|
| **Mid-conversation system messages** | [`mid-conversation-system-messages.md`](https://platform.claude.com/docs/en/build-with-claude/mid-conversation-system-messages.md) | Append `{"role":"system"}` to `messages` mid-session; preserves cached prefix. Claude API + Claude Platform on AWS only (`claude-opus-4-8`). No beta header. ZDR eligible |
| **Orchestration mode example** | [`mid-conversation-effort-example.md`](https://platform.claude.com/docs/en/build-with-claude/mid-conversation-effort-example.md) | Worked example: toggle a session-level mode that auto-fans tasks to parallel subagents using mid-conversation system messages + `effort: "xhigh"` + multi-agent Workflow tool |

## Platform integrations

Claude runs on multiple cloud platforms. Each has its own model
naming, region availability, and auth model:

| Platform | Page |
|---|---|
| **Amazon Bedrock** (current) | [`claude-in-amazon-bedrock.md`](https://platform.claude.com/docs/en/build-with-claude/claude-in-amazon-bedrock.md) |
| **Claude Platform on AWS** | [`claude-platform-on-aws.md`](https://platform.claude.com/docs/en/build-with-claude/claude-platform-on-aws.md) |
| **Amazon Bedrock** (legacy) | [`claude-on-amazon-bedrock-legacy.md`](https://platform.claude.com/docs/en/build-with-claude/claude-on-amazon-bedrock-legacy.md) |
| **Google Vertex AI** | [`claude-on-vertex-ai.md`](https://platform.claude.com/docs/en/build-with-claude/claude-on-vertex-ai.md) |
| **Microsoft Foundry** | [`claude-in-microsoft-foundry.md`](https://platform.claude.com/docs/en/build-with-claude/claude-in-microsoft-foundry.md) |

> **Foundry caveat:** During the Foundry preview, models run on
> Anthropic infrastructure. Bedrock and Vertex are true 3P
> deployments where Anthropic does not see prompts/completions.

---

*Source pages: 32 under `platform.claude.com/docs/en/build-with-claude/`.*
