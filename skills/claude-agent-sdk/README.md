# Claude Agent SDK Skill (Auto-Updated)

A self-updating Claude Code skill for building AI agents with the Claude Agent SDK — covering both [TypeScript](https://github.com/anthropics/claude-agent-sdk-typescript) and [Python](https://github.com/anthropics/claude-agent-sdk-python).

**SDK Version**: TypeScript v0.2.77 | Python v0.1.49 | **This skill is auto-updated**: 2026-03-18

## What It Does

- Complete API reference for both TypeScript and Python SDKs: `query()`, hooks, subagents, MCP, permissions, sandbox, structured outputs, sessions
- Auto-correction rules that fire when editing `*agent*.ts` or `*agent*.py` files
- Known issue prevention with links to real GitHub issues
- Keeps itself up to date via a daily automated pipeline

## Why Auto-Update?

The Claude Agent SDK is pre-1.0 (`v0.2.x`) — APIs break frequently, functions get renamed, parameters change. A static skill would teach Claude outdated patterns that produce broken code. The pipeline keeps this skill accurate by tracking version bumps, researching new issues, and updating rules daily. Without it, advice written for `v0.2.30` silently becomes wrong when the SDK moves to `v0.3.0`.

## Installation

Clone into your Claude Code skills directory:

```bash
git clone https://github.com/xiaolai/claude-agent-sdk-skill-autoupdated ~/.claude/skills/claude-agent-sdk-skill-autoupdated
```

Claude Code loads it automatically. To pull the latest updates later:

```bash
cd ~/.claude/skills/claude-agent-sdk-skill-autoupdated && git pull
```

That's it — no API keys, no pipeline setup, no cost. You get a constantly up-to-date SDK skill maintained by the automated pipeline.

Optional: auto-update daily at 09:00 UTC (after the pipeline runs at 08:00):

```bash
(crontab -l 2>/dev/null; echo "0 9 * * * cd ~/.claude/skills/claude-agent-sdk-skill-autoupdated && git pull -q") | crontab -
```

## TypeScript vs Python SDK

Both SDKs wrap the Claude Code CLI and share the same core concepts, but they differ in architecture and feature surface.

### Architecture

| | TypeScript | Python |
|---|---|---|
| **Entry point** | `query()` only | `query()` + `ClaudeSDKClient` |
| **Multi-turn** | Not built-in (new session per call) | `ClaudeSDKClient` keeps conversation alive |
| **Hooks** | Available via `query()` options | Require `ClaudeSDKClient` (not available with standalone `query()`) |
| **Custom tools** | Available via `query()` options | Require `ClaudeSDKClient` |
| **Interrupts** | Not supported | `await client.interrupt()` |
| **Naming** | camelCase (`systemPrompt`, `maxTurns`) | snake_case (`system_prompt`, `max_turns`) |
| **Tool definition** | `tool(name, schema, handler)` function | `@tool(name, desc, schema)` decorator |
| **Options type** | `Options` interface | `ClaudeAgentOptions` dataclass |

### Python-Only Features

- **`ClaudeSDKClient`** — stateful client with `connect()`, `query()`, `receive_response()`, `interrupt()`, `disconnect()` lifecycle
- **`async with` context manager** — automatic connection cleanup
- **Multi-turn conversations** — send multiple queries in the same session without losing context
- **Runtime control** — `set_permission_mode()`, `set_model()`, `rewind_files()` mid-conversation
- **Extended thinking config** — `ThinkingConfig` types (`adaptive`, `enabled`, `disabled`) and `effort` option (`low`/`medium`/`high`/`max`)

### TypeScript-Only Features

- **V2 Session API** (preview) — `unstable_v2_createSession()` for persistent sessions with resume/fork
- **MCP tool annotations** — `annotations` field in tool definitions (v0.2.27+)
- **Plugin support** — `plugins: [{ type: "local", path: "..." }]` option
- **More known issues documented** — 22 tracked issues vs 5 for Python (reflects the older, larger codebase)

### Maturity

| | TypeScript | Python |
|---|---|---|
| **Version** | v0.2.77 | v0.1.49 |
| **GitHub stars** | ~800 | ~4,800 |
| **Open issues** | ~176 | ~570 |
| **Release cadence** | ~daily | ~daily |
| **Stability** | Pre-1.0, frequent changes | Pre-1.0, frequent changes |

Both SDKs are pre-1.0 and under active development. The Python SDK has a larger community but the TypeScript SDK has been around longer. Neither is "more stable" — expect breaking changes in both.

## Structure

```
SKILL.md                          Router (detects language, loads correct reference)
SKILL-typescript.md               TypeScript API reference
SKILL-python.md                   Python API reference
rules/claude-agent-sdk-ts.md      Auto-correction rules for TS files
rules/claude-agent-sdk-py.md      Auto-correction rules for PY files
templates/typescript/              TypeScript code examples
templates/python/                 Python code examples
scripts/check-versions.sh         Manual version check
agent/                            Self-update pipeline (maintainer only, ignore this)
  monitor.sh                      Change detection (npm + PyPI + GitHub, zero API cost)
  update-agent.ts                 Updates skill files when SDK version changes
  research-agent-ts.ts            Audits TS SDK types + researches GitHub issues daily
  research-agent-py.ts            Audits Python SDK types + researches GitHub issues daily
  mending-agent.ts                Fixes verification failures
  report-agent.ts                 Generates daily reports
  verify.sh                       Deterministic post-update verification
  state.json                      Tracked versions, issues, scan state (namespaced by language)
reports/                          Daily pipeline reports
.github/workflows/                CI pipeline (daily cron)
```

## Daily Pipeline

Runs via GitHub Actions at 08:00 UTC, or manually via `workflow_dispatch`.

### Pipeline Overview

The daily run has two paths depending on whether the SDK version changed.

```mermaid
flowchart LR
    M["Monitor<br/>bash · $0"]:::bash --> C{Version<br/>changed?}
    C -- Yes --> U["Update Agent<br/>LLM · ~$1"]:::llm
    U --> R["Research Agent<br/>LLM · ~$3"]:::llm
    C -- No --> R
    R --> V{"Verify<br/>bash · $0"}:::bash
    V -- Pass --> RP["Report Agent<br/>LLM · ~$0.25"]:::llm
    V -- Fail --> ME["Mending Agent<br/>LLM · ~$0.50"]:::llm
    ME --> V
    RP --> CO["Commit + Push"]:::bash

    classDef bash fill:#e8f5e9,stroke:#43a047,color:#1b5e20
    classDef llm fill:#e3f2fd,stroke:#1e88e5,color:#0d47a1
```

### What the Research Agent Does

The research agent is the core of the pipeline. It runs daily and has three phases:

```mermaid
flowchart TB
    NI["npm install<br/><i>fetches latest SDK package</i>"]:::bash --> A

    subgraph A ["Part A — API Surface Audit"]
        direction LR
        A1["Read sdk.d.ts<br/>type definitions"]:::read --> A2["Extract options, methods,<br/>message types, hooks"]
        A2 --> A3["Compare against<br/>SKILL.md"]:::read
        A3 --> A4{"Missing<br/>APIs?"}
        A4 -- Yes --> A5["Add to SKILL.md"]:::write
        A4 -- No --> A6["Skip — already<br/>documented"]
    end

    A --> B

    subgraph B ["Part B — GitHub Issues Research"]
        direction LR
        B1["Fetch recent issues<br/>from SDK repo"]:::read --> B2["Deep-read body<br/>+ all comments"]
        B2 --> B3{"Actionable<br/>workaround?"}
        B3 -- Yes --> B4["Add Known Issue<br/>or auto-correction rule"]:::write
        B3 -- No --> B5["Skip — record<br/>in state.json"]:::write
    end

    B --> D

    subgraph D ["Part C — Final Checks"]
        direction LR
        D1["Verify option tables<br/>match sdk.d.ts"]:::read --> D2["Verify hook event<br/>count matches"]
        D2 --> D3["Verify version strings<br/>consistent across files"]
    end

    classDef bash fill:#e8f5e9,stroke:#43a047,color:#1b5e20
    classDef read fill:#fff3e0,stroke:#f57c00,color:#e65100
    classDef write fill:#e3f2fd,stroke:#1e88e5,color:#0d47a1
```

### What Gets Updated

```mermaid
flowchart LR
    SDK["sdk.d.ts<br/><i>source of truth</i>"]:::source --> |"Part A"| SKILL["SKILL.md<br/><i>API reference</i>"]:::target
    GH["GitHub Issues<br/><i>bug reports</i>"]:::source --> |"Part B"| SKILL
    GH --> |"Part B"| RULES["rules/claude-agent-sdk.md<br/><i>auto-correction rules</i>"]:::target
    SDK --> |"Part A"| RULES
    SKILL --> |"Part C"| STATE["state.json<br/><i>audit + issue tracking</i>"]:::target

    classDef source fill:#f3e5f5,stroke:#8e24aa,color:#4a148c
    classDef target fill:#e8f5e9,stroke:#43a047,color:#1b5e20
```

### Step Details

| Step | What it does | Cost |
|------|-------------|------|
| **Monitor** | Checks npm registry + GitHub for version bumps, issue state changes, new bugs | $0 (bash) |
| **Update Agent** | Reads change report, updates version strings across all skill files | ~$1 (version bump only) |
| **Research Agent** | **Part A** reads `sdk.d.ts`, compares against SKILL.md, adds missing APIs. **Part B** scans GitHub issues, adds Known Issues or rules. **Part C** validates consistency. | ~$3 |
| **Verify** | Deterministic grep/jq checks on version strings and structure | $0 (bash) |
| **Mending Agent** | Reads verification failures, fixes what broke (up to 2 retries) | ~$0.50/attempt |
| **Report Agent** | Generates pipeline summary, updates cost log in README | ~$0.25 |

## Cost Log

| Date | SDK Version | Update | Research | Report | Total | Notes |
|------|-------------|--------|----------|--------|-------|-------|
| 2026-03-18 | — | — | — | $0.20 | **$0.20** | Research only |
| 2026-03-17 | — | $0.43 | — | $0.23 | **$0.65** | SDK v0.2.76→v0.2.77 |
| 2026-03-16 | — | — | — | $0.19 | **$0.19** | Research only |
| 2026-03-15 | — | — | — | $0.20 | **$0.20** | Research only |
| 2026-03-14 | — | $0.29 | — | $0.20 | **$0.49** | SDK v0.2.74→v0.2.76 |
| 2026-03-13 | — | — | — | $0.19 | **$0.19** | Research only |
| 2026-03-12 | — | $0.26 | — | $0.22 | **$0.49** | SDK v0.2.72→v0.2.74 |

_Last 7 days only. Updated automatically by the report agent. See [reports/](reports/) for full history._

## How It Works

The daily pipeline runs via GitHub Actions on this repo. It costs the **maintainer** a few dollars per day in LLM usage. The pipeline commits updated skill files directly to this repo.

**As a user**, you just `git pull` to get the latest. You never run the pipeline yourself and pay nothing. You don't need Node.js, npm, or anything in the `agent/` directory — that's maintainer-only infrastructure.

| Role | What you do | Cost |
|------|------------|------|
| **User** | `git clone` / `git pull` | Free |
| **Maintainer** | Runs the CI pipeline | ~$3–6/day |

## Pipeline Prerequisites (maintainer only)

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed on the runner
- GitHub secret: `CLAUDE_CODE_OAUTH_TOKEN` (subscription) or `ANTHROPIC_API_KEY`
- `gh` CLI authenticated (for issue scanning)

## Links

- [SDK Docs](https://platform.claude.com/docs/en/agent-sdk/overview)
- [TypeScript API Reference](https://platform.claude.com/docs/en/agent-sdk/typescript)
- [Python API Reference](https://platform.claude.com/docs/en/agent-sdk/python)
- [TypeScript GitHub](https://github.com/anthropics/claude-agent-sdk-typescript)
- [Python GitHub](https://github.com/anthropics/claude-agent-sdk-python)
- [Migration Guide](https://platform.claude.com/docs/en/agent-sdk/migration-guide)

---

**Repository**: https://github.com/xiaolai/claude-agent-sdk-skill-autoupdated
**License**: MIT
