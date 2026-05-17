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

## Foundation

| Page | Topic |
|---|---|
| [`overview.md`](docs-snapshot/platform.claude.com/en/build-with-claude/overview.md) | Build-with-Claude landing |
| [`context-windows.md`](docs-snapshot/platform.claude.com/en/build-with-claude/context-windows.md) | Per-model context window sizes |
| [`streaming.md`](docs-snapshot/platform.claude.com/en/build-with-claude/streaming.md) | `stream: true` event types |
| [`structured-outputs.md`](docs-snapshot/platform.claude.com/en/build-with-claude/structured-outputs.md) | JSON Schema validation on output |
| [`handling-stop-reasons.md`](docs-snapshot/platform.claude.com/en/build-with-claude/handling-stop-reasons.md) | `stop_reason` enum, end-of-turn semantics |

## Reasoning controls

| Feature | Page | What it does |
|---|---|---|
| **Extended thinking** | [`extended-thinking.md`](docs-snapshot/platform.claude.com/en/build-with-claude/extended-thinking.md) | `thinking` blocks with budget tokens — model "thinks out loud" before responding |
| **Adaptive thinking** | [`adaptive-thinking.md`](docs-snapshot/platform.claude.com/en/build-with-claude/adaptive-thinking.md) | Model auto-decides when to think hard vs respond immediately |
| **Effort** | [`effort.md`](docs-snapshot/platform.claude.com/en/build-with-claude/effort.md) | Effort-level setting (lower = faster, higher = more thorough) |
| **Fast mode** | [`fast-mode.md`](docs-snapshot/platform.claude.com/en/build-with-claude/fast-mode.md) | Faster response variant available on Opus 4.6 and Opus 4.7 |

## Throughput / cost patterns

| Feature | Page | What it does |
|---|---|---|
| **Prompt caching** | [`prompt-caching.md`](docs-snapshot/platform.claude.com/en/build-with-claude/prompt-caching.md) | `cache_control: ephemeral` breakpoints, 5-min TTL |
| **Batch processing** | [`batch-processing.md`](docs-snapshot/platform.claude.com/en/build-with-claude/batch-processing.md) | Submit many requests at lower price, returns in 24h |
| **Compaction** | [`compaction.md`](docs-snapshot/platform.claude.com/en/build-with-claude/compaction.md) | Auto-summarize older messages when nearing context limit |
| **Context editing** | [`context-editing.md`](docs-snapshot/platform.claude.com/en/build-with-claude/context-editing.md) | Programmatic context-window management |

## Inputs

| Page | Topic |
|---|---|
| [`files.md`](docs-snapshot/platform.claude.com/en/build-with-claude/files.md) | File uploads (Files API) |
| [`pdf-support.md`](docs-snapshot/platform.claude.com/en/build-with-claude/pdf-support.md) | PDF as input (text + vision modes) |
| [`embeddings.md`](docs-snapshot/platform.claude.com/en/build-with-claude/embeddings.md) | Embeddings models |
| [`multilingual-support.md`](docs-snapshot/platform.claude.com/en/build-with-claude/multilingual-support.md) | Supported languages, quality notes |
| [`search-results.md`](docs-snapshot/platform.claude.com/en/build-with-claude/search-results.md) | Web search results as input format |
| [`citations.md`](docs-snapshot/platform.claude.com/en/build-with-claude/citations.md) | Citation block format for grounded responses |
| [`skills-guide.md`](docs-snapshot/platform.claude.com/en/build-with-claude/skills-guide.md) | Using Agent Skills from the API |

## Platform integrations

Claude runs on multiple cloud platforms. Each has its own model
naming, region availability, and auth model:

| Platform | Page |
|---|---|
| **Amazon Bedrock** (current) | [`claude-in-amazon-bedrock.md`](docs-snapshot/platform.claude.com/en/build-with-claude/claude-in-amazon-bedrock.md) |
| **Claude Platform on AWS** | [`claude-platform-on-aws.md`](docs-snapshot/platform.claude.com/en/build-with-claude/claude-platform-on-aws.md) |
| **Amazon Bedrock** (legacy) | [`claude-on-amazon-bedrock-legacy.md`](docs-snapshot/platform.claude.com/en/build-with-claude/claude-on-amazon-bedrock-legacy.md) |
| **Google Vertex AI** | [`claude-on-vertex-ai.md`](docs-snapshot/platform.claude.com/en/build-with-claude/claude-on-vertex-ai.md) |
| **Microsoft Foundry** | [`claude-in-microsoft-foundry.md`](docs-snapshot/platform.claude.com/en/build-with-claude/claude-in-microsoft-foundry.md) |

> **Foundry caveat:** During the Foundry preview, models run on
> Anthropic infrastructure. Bedrock and Vertex are true 3P
> deployments where Anthropic does not see prompts/completions.

---

*Source pages: 29 under `platform.claude.com/docs/en/build-with-claude/`.*
