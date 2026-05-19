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
- **Extended thinking is opt-in:** set
  `thinking: { type: "enabled", budget_tokens: N }`. Tokens used in
  thinking blocks are billed at input-token rates and **count against
  `max_tokens`** for the final response.
- **Prompt caching has 4-breakpoint limit per request.** Each
  `cache_control: { type: "ephemeral" }` is one breakpoint. Default TTL
  is `5m`; `1h` is also available. The whole prefix up to the
  breakpoint is cached, so place breakpoints at stable boundaries
  (system prompt → tools → static context → user turn).
- **Cache diagnostics (beta):** When cache hits drop unexpectedly, pass
  `diagnostics: { previous_message_id: <prev_id> }` with beta header
  `cache-diagnosis-2026-04-07`. The response's `diagnostics.cache_miss_reason`
  reports the first divergence point (`model_changed`, `system_changed`,
  `tools_changed`, `messages_changed`, `previous_message_not_found`, or
  `unavailable`). Claude API only — not available on Bedrock or Vertex AI.
  **ZDR eligible (qualified)** — only fingerprints (hashes + token counts) are
  retained, not raw prompt content. See
  [`cache-diagnostics.md`](https://platform.claude.com/docs/en/build-with-claude/cache-diagnostics.md).
- **Batches return within 24h** at 50% discount. Submit via
  `POST /v1/messages/batches`; poll for results. Not for interactive use.
- **Vision input:** images can be base64-inline or URL-referenced.
  Max ~5 MB per image. Document blocks (PDFs) are handled separately
  via `type: "document"`.
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
  `claude-opus-4-6` and `claude-opus-4-7` only. Priced at 6× standard
  Opus rates ($30/MTok input, $150/MTok output). Has its own dedicated
  rate-limit bucket — headers: `anthropic-fast-{input,output}-tokens-{limit,remaining,reset}`.
  Response `usage.speed` field returns `"fast"` or `"standard"`.
  Falling back to standard speed on 429 causes a prompt-cache miss
  (fast and standard don't share cached prefixes). ZDR eligible.
  Join waitlist at [claude.com/fast-mode](https://claude.com/fast-mode).
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
- **Context awareness** — Claude Sonnet 4.6, Sonnet 4.5, and Haiku 4.5
  automatically receive token-budget information injected by the API. At
  conversation start the system sends
  `<budget:token_budget>N</budget:token_budget>` (1M for 1M-window
  models, 200K for others). After each tool call, a
  `<system_warning>Token usage: X/Y; Z remaining</system_warning>` block
  is injected so the model can track remaining capacity. Developers do
  not configure this — it is automatic. The feature helps these models
  persist on long tasks instead of prematurely stopping.
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
| **Extended thinking** | [`extended-thinking.md`](https://platform.claude.com/docs/en/build-with-claude/extended-thinking.md) | `thinking` blocks with budget tokens — model "thinks out loud" before responding |
| **Adaptive thinking** | [`adaptive-thinking.md`](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking.md) | Model auto-decides when to think hard vs respond immediately |
| **Effort** | [`effort.md`](https://platform.claude.com/docs/en/build-with-claude/effort.md) | Effort-level setting (lower = faster, higher = more thorough) |
| **Fast mode** | [`fast-mode.md`](https://platform.claude.com/docs/en/build-with-claude/fast-mode.md) | **Beta (research preview, waitlist).** `speed: "fast"` + header `fast-mode-2026-02-01`; up to 2.5× OTPS on Opus 4.6/4.7 at 6× pricing |

## Throughput / cost patterns

| Feature | Page | What it does |
|---|---|---|
| **Prompt caching** | [`prompt-caching.md`](https://platform.claude.com/docs/en/build-with-claude/prompt-caching.md) | `cache_control: ephemeral` breakpoints, 5-min TTL |
| **Cache diagnostics** | [`cache-diagnostics.md`](https://platform.claude.com/docs/en/build-with-claude/cache-diagnostics.md) | Beta (`cache-diagnosis-2026-04-07`) — identify where a prompt prefix diverged and caused a cache miss; Claude API only |
| **Batch processing** | [`batch-processing.md`](https://platform.claude.com/docs/en/build-with-claude/batch-processing.md) | Submit many requests at lower price, returns in 24h |
| **Compaction** | [`compaction.md`](https://platform.claude.com/docs/en/build-with-claude/compaction.md) | Auto-summarize older messages when nearing context limit. Supported on: `claude-mythos-preview`, Opus 4.7, Opus 4.6, Sonnet 4.6 |
| **Context editing** | [`context-editing.md`](https://platform.claude.com/docs/en/build-with-claude/context-editing.md) | Programmatic context-window management |

## Inputs

| Page | Topic |
|---|---|
| [`files.md`](https://platform.claude.com/docs/en/build-with-claude/files.md) | File uploads (Files API) |
| [`pdf-support.md`](https://platform.claude.com/docs/en/build-with-claude/pdf-support.md) | PDF as input (text + vision modes) |
| [`vision.md`](https://platform.claude.com/docs/en/build-with-claude/vision.md) | Image input (base64 or URL), max ~5 MB per image |
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
| [`task-budgets.md`](https://platform.claude.com/docs/en/build-with-claude/task-budgets.md) | Task budgets (beta) — cap token spend per task |

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

*Source pages: 30 under `platform.claude.com/docs/en/build-with-claude/`.*
