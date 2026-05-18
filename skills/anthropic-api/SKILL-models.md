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

## Available models

Per the API as of 2026-05-18 (`GET /v1/models`), from most to least recent:

| ID | Tier | Notes |
|---|---|---|
| `claude-opus-4-7` | Opus | Most capable; fast mode available (`fast-mode-2026-02-01`) |
| `claude-mythos-preview` | — | Preview model (may change or be retired) |
| `claude-opus-4-6` | Opus | Previous Opus generation |
| `claude-sonnet-4-6` | Sonnet | Balanced cost/capability |
| `claude-haiku-4-5` | Haiku | Latest Haiku alias |
| `claude-haiku-4-5-20251001` | Haiku | Dated Haiku snapshot |
| `claude-opus-4-5` | Opus | Older Opus generation |
| `claude-opus-4-5-20251101` | Opus | Dated snapshot |
| `claude-sonnet-4-5` | Sonnet | Older Sonnet generation |
| `claude-sonnet-4-5-20250929` | Sonnet | Dated snapshot |
| `claude-opus-4-1` | Opus | Older Opus generation |
| `claude-opus-4-1-20250805` | Opus | Dated snapshot |
| `claude-opus-4-0` | Opus | Older Opus generation |
| `claude-opus-4-20250514` | Opus | Dated snapshot |
| `claude-sonnet-4-0` | Sonnet | Older Sonnet generation |
| `claude-sonnet-4-20250514` | Sonnet | Dated snapshot |
| `claude-3-haiku-20240307` | Haiku (Claude 3) | Legacy; lowest cost |

**Preview models** (e.g., `claude-mythos-preview`) may change shape or be retired without a deprecation window. Pin to dated IDs for stability.

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
