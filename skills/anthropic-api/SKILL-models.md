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
| `GET /v1/models` — list models | [`models/list.md`](docs-snapshot/platform.claude.com/en/api/models/list.md) |
| `GET /v1/models/{model_id}` — retrieve model | [`models/retrieve.md`](docs-snapshot/platform.claude.com/en/api/models/retrieve.md) |

Use these at runtime to discover what's available rather than
hardcoding model IDs.

## Current model family (Claude 4.X)

Per the latest snapshot:

| Tier | ID | Notes |
|---|---|---|
| **Opus** | `claude-opus-4-7` | Most capable; fast mode available |
| **Sonnet** | `claude-sonnet-4-6` | Balanced cost/capability |
| **Haiku** | `claude-haiku-4-5-20251001` | Cheapest, fastest; the `-20251001` suffix is the snapshot date |

When building new applications, default to the latest and most
capable model unless cost / latency dictates otherwise.

## Model ID conventions

- **Family ID** (e.g., `claude-opus-4-7`) — stable alias that
  points at the latest version of that family. Recommended for
  most apps so you get improvements automatically.
- **Dated ID** (e.g., `claude-haiku-4-5-20251001`) — pinned to a
  specific snapshot. Recommended when reproducibility matters
  (benchmarks, regression-sensitive workflows).

## Context windows

Per-model context window sizes change over time. Always consult
[`models/retrieve.md`](docs-snapshot/platform.claude.com/en/api/models/retrieve.md)
output at runtime rather than hardcoding the limit. Conceptual
overview: [`anthropic-platform-features → SKILL-build-with-claude.md`](../anthropic-platform-features/SKILL-build-with-claude.md)
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
