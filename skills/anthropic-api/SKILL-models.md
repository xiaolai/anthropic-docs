---
name: anthropic-api-models
description: |
  Deep reference for the Anthropic models catalog — list /
  retrieve endpoints, model IDs (claude-opus-4-7,
  claude-sonnet-4-6, claude-haiku-4-5-20251001 and earlier
  variants), per-model context window sizes, and the
  /v1/models endpoints for runtime model discovery.
source: https://platform.claude.com/docs/en/api/models/list.md
---

# Anthropic Models Catalog

> *Router lives in [`SKILL.md`](SKILL.md). For context-window
> details, see [`anthropic-platform-features → SKILL-build-with-claude.md`](../anthropic-platform-features/SKILL-build-with-claude.md).*

## Endpoints

| Endpoint | Source |
|---|---|
| `GET /v1/models` — list models | [`models/list.md`](https://platform.claude.com/docs/en/api/models/list.md) |
| `GET /v1/models/{model_id}` — retrieve model | [`models/retrieve.md`](https://platform.claude.com/docs/en/api/models/retrieve.md) |
| Models API section index | [`models.md`](https://platform.claude.com/docs/en/api/models.md) |

Use these at runtime to discover what's available rather than
hardcoding model IDs.

## Current model family (Claude 4.X)

Per the upstream API (`messages/create.md`, updated 2026-05-19):

| ID | Description |
|---|---|
| `claude-opus-4-7` | Frontier intelligence for long-running agents and coding (latest Opus) |
| `claude-mythos-preview` | New class of intelligence, strongest in coding and cybersecurity (preview) |
| `claude-opus-4-6` | Frontier intelligence for long-running agents and coding |
| `claude-sonnet-4-6` | Best combination of speed and intelligence (latest Sonnet) |
| `claude-haiku-4-5` | Fastest model with near-frontier intelligence (family alias) |
| `claude-haiku-4-5-20251001` | Same as above, pinned snapshot |
| `claude-opus-4-5` / `claude-opus-4-5-20251101` | Premium model combining maximum intelligence with practical performance |
| `claude-sonnet-4-5` / `claude-sonnet-4-5-20250929` | High-performance model for agents and coding |
| `claude-opus-4-1` / `claude-opus-4-1-20250805` | Exceptional model for specialized complex tasks |
| `claude-opus-4-0` / `claude-opus-4-20250514` | Powerful model for complex tasks |
| `claude-sonnet-4-0` / `claude-sonnet-4-20250514` | High-performance model with extended thinking |
| `claude-3-haiku-20240307` | Fast and cost-effective (Claude 3 generation) |

> **Naming conventions:** family ID (e.g., `claude-opus-4-7`) is a stable alias
> tracking the latest snapshot; dated ID (e.g., `claude-haiku-4-5-20251001`) pins
> to a specific snapshot for reproducibility. Use family IDs for most apps.

When building new applications, default to the latest and most
capable model unless cost / latency dictates otherwise.

## Model ID conventions

- **Family ID** (e.g., `claude-opus-4-7`) — stable alias that
  points at the latest version of that family. Recommended for
  most apps so you get improvements automatically.
- **Dated ID** (e.g., `claude-haiku-4-5-20251001`) — pinned to a
  specific snapshot. Recommended when reproducibility matters
  (benchmarks, regression-sensitive workflows).

## `ModelCapabilities` schema

The `GET /v1/models` list response and `GET /v1/models/{id}` retrieve
response include a `capabilities` field with the following structure
(all fields are `CapabilitySupport` objects with `supported: boolean`
unless noted):

| Field | Notes |
|---|---|
| `batch` | Whether the model supports the Batch API. |
| `citations` | Whether the model supports citation generation. |
| `code_execution` | Whether the model supports code-execution server tools. |
| `context_management` | Object with strategies: `clear_thinking_20251015`, `clear_tool_uses_20250919`, `compact_20260112`, plus top-level `supported`. |
| `effort` | Object with levels: `low`, `medium`, `high`, `xhigh`, `max` (each `CapabilitySupport`) plus `supported`. |
| `image_input` | Whether the model accepts image content blocks. |
| `pdf_input` | Whether the model accepts PDF content blocks. |
| `structured_outputs` | Whether the model supports `output_config.format.json_schema`. |
| `thinking` | Object with `supported` and `types` (`adaptive`, `enabled`). |

Source: [`models/list.md`](https://platform.claude.com/docs/en/api/models/list.md)

## Context windows

Per-model context window sizes change over time. Always consult
[`models/retrieve.md`](https://platform.claude.com/docs/en/api/models/retrieve.md)
output at runtime rather than hardcoding the limit. The response also
includes `max_input_tokens` and `max_tokens` (max output) fields.
Conceptual overview: [`anthropic-platform-features → SKILL-build-with-claude.md`](../anthropic-platform-features/SKILL-build-with-claude.md)
under "Context windows".

## Deprecation and retirement

Anthropic publishes deprecation dates in the per-model retrieve
response. Use those dates to plan migrations. After the retirement
date, requests targeting that ID return an error.

## Source pages

- `models/list.md` — list available models
- `models/retrieve.md` — model details (context, deprecation, etc.)

---

*Source pages: 2 under `platform.claude.com/docs/en/api/models/`.*
