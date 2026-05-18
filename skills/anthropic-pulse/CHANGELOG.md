# anthropic-pulse — Changelog

All notable changes to this skill. The pipeline appends an entry per detected upstream change.

## [0.1.0] — 2026-05-18

### Added

- Initial scaffold + initial population from anthropic.com/news and anthropic.com/research (15 news items + 13 research items extracted via WebFetch).
- `SKILL-news.md` + `SKILL-research.md` digest surfaces.
- `config.json` declares the two HTML index URLs + `pipelineOverrides` directing the workflow to use `pipeline/scripts/fetch-anthropic-pulse.sh` instead of the default refresh + agent steps.
- `state.json` with `scaffoldComplete: true` (initial population is complete).
- This is the **8th skill** in the plugin and the **first deterministic-render skill** (zero LLM cost per pipeline run).
