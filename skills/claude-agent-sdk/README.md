# claude-agent-sdk

> **Looking for structured learning?** The
> [Skilljar courses](https://anthropic.skilljar.com/) include
> "Building Effective Agents" — the foundational course for SDK
> work. Pair it with the hands-on
> [tutorials at claude.com/resources/tutorials](https://claude.com/resources/tutorials).
> This skill is the always-current API reference Claude reads at
> intent-match time; the courses + tutorials build the mental model.

**Last updated**: 2026-07-23

Auto-updated reference skill for the **Claude Agent SDK** — Anthropic's libraries for building autonomous AI agents that wrap the Claude Code CLI runtime. Covers both [TypeScript](https://github.com/anthropics/claude-agent-sdk-typescript) (`@anthropic-ai/claude-agent-sdk` on npm) and [Python](https://github.com/anthropics/claude-agent-sdk-python) (`claude-agent-sdk` on PyPI).

**TypeScript SDK**: v0.3.159 | **Python SDK**: v0.2.87

Part of the [anthropic-docs](../../README.md) plugin.

## Surfaces

| File | Topic |
|---|---|
| [SKILL.md](SKILL.md) | Router — detects language, dispatches to TS or Py reference |
| [SKILL-typescript.md](SKILL-typescript.md) | TypeScript API: `query()`, hooks, subagents, MCP, permissions, sandbox, structured outputs, sessions |
| [SKILL-python.md](SKILL-python.md) | Python API: `query()` + `ClaudeSDKClient`, hooks, subagents, MCP, permissions, lifecycle |
| [rules/claude-agent-sdk-ts.md](rules/claude-agent-sdk-ts.md) | Edit-time auto-correction rules for `*.ts` / `*.tsx` / `*.mts` files |
| [rules/claude-agent-sdk-py.md](rules/claude-agent-sdk-py.md) | Edit-time auto-correction rules for `*.py` files |
| [templates/typescript/](templates/typescript/) | Working TypeScript example apps (14 files) — subagents, MCP, hooks, sessions, etc. |
| [templates/python/](templates/python/) | Working Python example apps (13 files) |

## Source

- **Docs**: [code.claude.com/docs/en/agent-sdk](https://code.claude.com/docs/en/agent-sdk)
- **TypeScript SDK**: [`@anthropic-ai/claude-agent-sdk`](https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk)
- **Python SDK**: [`claude-agent-sdk`](https://pypi.org/project/claude-agent-sdk/)
- **TypeScript repo**: [anthropics/claude-agent-sdk-typescript](https://github.com/anthropics/claude-agent-sdk-typescript)
- **Python repo**: [anthropics/claude-agent-sdk-python](https://github.com/anthropics/claude-agent-sdk-python)
- **Bug-tracker (issue scanning)**: anthropics/claude-agent-sdk-typescript

## Why auto-update

The Claude Agent SDK is pre-1.0 — APIs break frequently, functions get renamed, parameters change. A static skill would teach Claude outdated patterns that produce broken code. The shared pipeline tracks version bumps + scans the issue tracker daily and updates the surface files when the upstream API drifts.

## TypeScript vs Python — at a glance

| | TypeScript | Python |
|---|---|---|
| **Entry point** | `query()` only | `query()` + `ClaudeSDKClient` |
| **Multi-turn** | Not built-in (new session per call) | `ClaudeSDKClient` keeps conversation alive |
| **Hooks** | Available via `query()` options | Require `ClaudeSDKClient` |
| **Custom tools** | Available via `query()` options | Require `ClaudeSDKClient` |
| **Naming** | camelCase (`systemPrompt`, `maxTurns`) | snake_case (`system_prompt`, `max_turns`) |
| **Tool definition** | `tool(name, schema, handler)` function | `@tool(name, desc, schema)` decorator |
| **Options type** | `Options` interface | `ClaudeAgentOptions` dataclass |

For the full per-language reference (every option, every hook event, every message type), see the corresponding `SKILL-<lang>.md` file. The current SDK versions are tracked in `state.json.registry.packages[]` and updated by the pipeline.

## Update model

The shared pipeline at `pipeline/` runs daily (matrix-iterates over all 8 skills; this one is one of them) and rewrites the surface files from the upstream docs + SDK type definitions whenever upstream changes are detected. See the [repo README](../../README.md) for the full pipeline mechanics.

To run it locally for just this skill:

```bash
SKILL_NAME=claude-agent-sdk bash pipeline/agent/monitor.sh           # detect changes
SKILL_NAME=claude-agent-sdk npx tsx pipeline/agent/research-agent.ts # populate surfaces
SKILL_NAME=claude-agent-sdk npm run verify:all                       # gate
```

## Recent activity

| Date | Update | Research | Mending | Report | Total | Notes |
|------|--------|----------|---------|--------|-------|-------|
| 2026-06-01 | success | CC v0.3.158 → v0.3.159 |
| 2026-05-31 | success | research + report (no upstream change) |
| 2026-05-30 | success | CC v0.3.153 → v0.3.159 |
| 2026-05-28 | success | CC v0.3.150 → v0.3.159 |
| 2026-05-26 | — | — | — | — | — | partial; research agent crashed; TS v0.3.150 / PY v0.2.87 unchanged |
| 2026-05-25 | — | — | — | — | — | success; research only; TS v0.3.150 / PY v0.2.87 unchanged |
| 2026-05-24 | — | — | — | — | — | partial; research agent crashed; TS v0.3.150 / PY v0.2.87 unchanged |
