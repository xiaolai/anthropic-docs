---
name: anthropic-pulse
description: |
  Router skill for Anthropic's news + research feeds — auto-refreshed
  daily from anthropic.com/news and anthropic.com/research.

  Use when the user asks about TIME-SENSITIVE Anthropic content: model
  launches ("did Claude X just release?"), product announcements,
  partnership news, region launches, new research papers, recent
  policy positions, or "what's new from Anthropic?" / "what did
  Anthropic just announce?" / "any recent research on X?"

  Skip: deep technical reference (use the other 7 skills — claude-code,
  anthropic-api, etc.); historical news older than ~30 items (link out
  to anthropic.com instead); detailed paper content (the digest carries
  title + summary + URL — Claude WebFetches the paper for depth on
  demand).
user-invocable: true
---

# Anthropic Pulse — Router

| Field | Value |
|---|---|
| **News index** | [anthropic.com/news](https://www.anthropic.com/news) |
| **Research index** | [anthropic.com/research](https://www.anthropic.com/research) |
| **Refresh cadence** | daily (matrix workflow) |
| **Content model** | digest only — title + date + URL + 1-2 sentence summary. Click through for full content. |

> **This skill is auto-updated daily.** The pipeline scrapes
> the two index pages, extracts the most recent ~20 items each, and
> rewrites the surface files below. Unlike the other 7 skills, this
> one has no docs-snapshot (the upstream is HTML, not markdown), no
> LLM agents (deterministic render), and no token cost per run.

## Dispatch table

| Surface file | Read when the user asks about… |
|---|---|
| [`SKILL-news.md`](SKILL-news.md) | Recent product launches, partnerships, region openings, model releases, policy updates, business announcements, "did X just launch?", "what did Anthropic announce recently?" |
| [`SKILL-research.md`](SKILL-research.md) | Recent research papers, alignment research, evaluations, benchmarks, "what's Anthropic's research on X?", interpretability work, the Anthropic Institute / Anthropic Economic Index |

## When unsure which file to read

1. Word "research" / "paper" / "benchmark" / "evaluation" / "alignment" / "interpretability" → `SKILL-research.md`
2. Words "announce" / "launch" / "release" / "partnership" / "available" / a model name → `SKILL-news.md`
3. Generic "what's new" → read both

## What this skill ISN'T

- **Not a deep reference.** Each digest entry is just title + date + URL + summary. For the body of a news post or a paper, WebFetch the linked URL — that's the design.
- **Not historical archive.** Only the latest ~20 items per feed. Older items live at anthropic.com; the freshness budget is "what changed recently."
- **Not Anthropic-internal docs.** This is the public-facing news + research feed. For product docs use the other 7 skills.

---

*Auto-updated daily from anthropic.com/news and
anthropic.com/research. File issues at
[xiaolai/anthropic-docs](https://github.com/xiaolai/anthropic-docs).*
