# anthropic-pulse

Auto-updated digest of recent **Anthropic news** + **Anthropic research** — fresh daily, surfaced at intent-match time.

Part of the [anthropic-docs](../../README.md) plugin.

## What this skill is (and isn't)

The other 7 skills in this plugin mirror **reference documentation** (Claude Code internals, API request shapes, MCP protocol). This skill is different: it mirrors **time-sensitive narrative content** — model launches, partnership announcements, research papers — so Claude can answer "what's new?" / "did X just launch?" without making the user (or Claude) WebFetch the index page.

The two surfaces are **digests only** — title + date + 1-2 sentence summary + link to the full post or paper. Claude WebFetches the linked URL on demand when a user wants depth on a specific item.

## Surfaces

| File | Topic |
|---|---|
| [SKILL.md](SKILL.md) | Router — dispatch between news and research |
| [SKILL-news.md](SKILL-news.md) | Last ~15-20 anthropic.com/news posts |
| [SKILL-research.md](SKILL-research.md) | Last ~15-20 anthropic.com/research papers/posts |

## Source

- **News**: [anthropic.com/news](https://www.anthropic.com/news)
- **Research**: [anthropic.com/research](https://www.anthropic.com/research)

## Update model

This skill is **deterministically rendered** from upstream HTML — no LLM agents involved. The pipeline runs daily (via the shared matrix workflow at `.github/workflows/pipeline.yml`):

1. `pipeline/scripts/fetch-anthropic-pulse.sh` fetches both index pages, extracts the ~15-20 most recent items per feed via HTML parsing, writes JSON to local cache.
2. The same script renders `SKILL-news.md` + `SKILL-research.md` from the JSON using a Markdown template.
3. The workflow commits the deltas.

Zero LLM cost per pipeline run. Because there's no agent in the loop, there's also no prompt-injection surface — the output is mechanical.

To re-fetch manually:

```bash
SKILL_NAME=anthropic-pulse bash pipeline/scripts/fetch-anthropic-pulse.sh
```

## Why a separate skill

Why not just have Claude WebFetch the news / research index every time someone asks "what's new?":

- **Cached digest = fast.** Per-query WebFetch costs a network round-trip + HTML parse + token spend. The cached digest is ~5 KB of pre-extracted markdown — instant.
- **Freshness budget = the daily cron, not per-query.** All users of the plugin share one refresh, paid in CI minutes, not in their conversations.
- **Activation isolation.** The other 7 skills are reference-shaped; this one is news-shaped. Mixing them would dilute intent matching.

## What this skill DOESN'T include

- **Historical archive.** Only the latest ~20 items per feed.
- **Full post / paper text.** Digest carries title + URL + summary. For depth, Claude WebFetches the URL.
- **Marketing pages.** Skips landing pages, careers, jobs.
- **Skilljar courses + tutorials.** Interactive content doesn't fit the digest model. See the root README's "Learning resources" section for those.
- **Economic Futures pages.** Too narrow for a dedicated skill — covered by the research feed when relevant.
