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
- **Extended thinking — model-specific behavior:**
  - **Claude Opus 4.7:** manual `thinking: {type: "enabled", budget_tokens: N}` is **not supported** (returns 400). Use `thinking: {type: "adaptive"}` with the `effort` parameter instead.
  - **Claude Opus 4.6 / Sonnet 4.6:** adaptive thinking is recommended; manual `budget_tokens` is deprecated but still functional.
  - **Older models (Opus 4.5, Sonnet 4.5, etc.):** adaptive thinking is not supported — must use `thinking: {type: "enabled", budget_tokens: N}`.
  - Thinking tokens are billed at input-token rates and count against `max_tokens`.
- **Prompt caching — two modes:**
  - **Automatic** (recommended for multi-turn): add `cache_control: {type: "ephemeral"}` at the **top level** of the request body; the API auto-applies the breakpoint to the last cacheable block and advances it each turn.
  - **Explicit breakpoints:** place `cache_control` directly on individual content blocks. Up to 4 breakpoints per request. Place at stable boundaries (system → tools → static context → user turn).
  - Default TTL is 5 min; 1-hour TTL also available.
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
- **Context windows** differ per model and may change over time.
  Use `GET /v1/models/{id}` at runtime instead of hardcoding the
  limit. See [`anthropic-api → SKILL-models.md`](../anthropic-api/SKILL-models.md).

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
| **Extended thinking** | [`extended-thinking.md`](https://platform.claude.com/docs/en/build-with-claude/extended-thinking.md) | Manual `thinking: {type: "enabled", budget_tokens: N}` — supported on Opus 4.6, Sonnet 4.6, and older models only |
| **Adaptive thinking** | [`adaptive-thinking.md`](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking.md) | `thinking: {type: "adaptive"}` — recommended for Opus 4.7, Opus 4.6, Sonnet 4.6; only mode on Opus 4.7 |
| **Effort** | [`effort.md`](https://platform.claude.com/docs/en/build-with-claude/effort.md) | Levels: `low` / `medium` / `high` (default) / `xhigh` (Opus 4.7 only) / `max`; placed in `output_config.effort` |
| **Fast mode** | [`fast-mode.md`](https://platform.claude.com/docs/en/build-with-claude/fast-mode.md) | `speed: "fast"` + beta header `fast-mode-2026-02-01`; up to 2.5x output tokens/s on Opus 4.6 & 4.7 |

## Throughput / cost patterns

| Feature | Page | What it does |
|---|---|---|
| **Prompt caching** | [`prompt-caching.md`](https://platform.claude.com/docs/en/build-with-claude/prompt-caching.md) | `cache_control: ephemeral` breakpoints, 5-min TTL |
| **Batch processing** | [`batch-processing.md`](https://platform.claude.com/docs/en/build-with-claude/batch-processing.md) | Submit many requests at lower price, returns in 24h |
| **Compaction** | [`compaction.md`](https://platform.claude.com/docs/en/build-with-claude/compaction.md) | Auto-summarize older messages when nearing context limit |
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

*Source pages: 29 under `platform.claude.com/docs/en/build-with-claude/`.*
