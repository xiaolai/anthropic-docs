# autoupdated-anthropic-documentation-knowledge

A self-updating collection of 7 Claude Code skills that mirror the official
Anthropic + MCP documentation surfaces (~624 pages across 4 doc portals)
and present them to Claude at intent-match time. Refreshed every 30 minutes.

## What this gives you

Install once, and Claude Code gains accurate, current reference knowledge
for every Anthropic / MCP surface — without searching, without WebFetching,
without context-bloating the conversation.

**Without this plugin**, asking Claude about MCP transport types or the
Cowork-on-Bedrock setup either: (a) relies on Claude's training cutoff
(stale), (b) requires `WebFetch` of upstream pages mid-conversation (slow,
expensive, parses raw HTML), or (c) requires you to paste in the relevant
doc page yourself.

**With this plugin**, Claude's skill matcher routes intent → skill → surface
in <100ms, loads ~5-10 KB of pre-curated reference content, and answers
grounded in current (≤30 min stale) documentation. Worked examples:

| You ask… | What happens |
|---|---|
| "How do I configure an MCP server with HTTP transport?" | `claude-code` skill fires → router dispatches to `SKILL-mcp.md` → Claude answers with the 5 transport-type fields and a worked `.mcp.json` example |
| "Deploy Cowork on Amazon Bedrock with MDM" | `claude-cowork` skill fires → `SKILL-cowork.md` → Claude lists the provider page + MDM config keys + telemetry toggles |
| "What's the cache_control breakpoint limit?" | `anthropic-platform-features` skill fires → `SKILL-build-with-claude.md` Key Facts section → "Up to 4 breakpoints per request, 5m or 1h TTL" |
| "Show me the tool_use / tool_result round-trip" | `anthropic-api` skill fires → `SKILL-messages.md` → Claude shows the 5-step pattern with the `tool_use_id` matching rule |
| "Define an MCP resource template" | `mcp-spec` skill fires → `SKILL-tools-resources-prompts.md` → Claude shows the URI-template schema + completion handshake |

Plus path-scoped rules that fire when Claude is editing matching files
(`.claude/settings.json`, `.mcp.json`, etc.) — auto-correcting common
mistakes at edit time.

## Install

```bash
/plugin install xiaolai/autoupdated-anthropic-documentation-knowledge
```

(or clone the repo and `/plugin install .` from your local copy)

## Skills

| Skill | Covers | Surfaces | Upstream pages |
|---|---|---|---|
| `claude-code` | [`code.claude.com/docs`](https://code.claude.com/docs) — Claude Code CLI itself | 7 | 103 |
| `claude-agent-sdk` | [`code.claude.com/docs/en/agent-sdk`](https://code.claude.com/docs/en/agent-sdk) + npm + PyPI — TS / Python SDK | 2 | 29 |
| `anthropic-api` | [`platform.claude.com/docs/en/api`](https://platform.claude.com/docs/en/api) — Messages API + admin / compliance / beta / models | 5 + 1 rule | 199 |
| `anthropic-platform-features` | [`platform.claude.com/docs`](https://platform.claude.com/docs) — agents-and-tools / build-with-claude / manage-claude / managed-agents | 4 | 108 |
| `claude-connectors` | [`claude.com/docs/{connectors,skills,plugins}`](https://claude.com/docs/connectors) — connectors directory + custom + MCPB + MCP Apps design | 5 | 34 |
| `claude-cowork` | [`claude.com/docs/{cowork,office-agents}`](https://claude.com/docs/cowork) — Cowork on 3P + Office agents | 2 | 35 |
| `mcp-spec` | [`modelcontextprotocol.io`](https://modelcontextprotocol.io) + 3 SDK repos — MCP open spec | 5 | 116 |
| `anthropic-pulse` | [`anthropic.com/news`](https://www.anthropic.com/news) + [`anthropic.com/research`](https://www.anthropic.com/research) — fresh digest of recent posts | 2 | rolling (~30 latest) |

**Total: 8 skills, 32 surface files + 14 rule files + 42 templates covering 624+ pages of upstream docs and rolling news/research digests.**

See [`dev-docs/multi-skill-migration.md`](dev-docs/multi-skill-migration.md) for the full ecosystem plan + per-skill source mappings.

## Learning resources (not packaged as skills)

Some Anthropic content is better as a link than as a skill. Three sources we do NOT package — but you should know they exist:

| Resource | Best for | Why not a skill |
|---|---|---|
| [anthropic.skilljar.com](https://anthropic.skilljar.com/) | Structured courses (Claude Code, Agent SDK, prompt engineering) | Interactive course material — videos, quizzes — doesn't fit the "Claude reads markdown at intent-match time" model. Take them in the Skilljar UI. |
| [claude.com/resources/tutorials](https://claude.com/resources/tutorials) | Curated hands-on tutorials with full walkthroughs | Users searching for tutorials typically prefer the tutorial UI directly; replicating in a skill adds little over the URL itself. |
| [anthropic.com/economic-futures](https://www.anthropic.com/economic-futures) | The Anthropic Economic Futures initiative (policy, research agenda) | Niche audience; relevant items surface via [`anthropic-pulse`](skills/anthropic-pulse/) when published. |

When relevant, the per-skill READMEs link to the appropriate Skilljar courses (Claude Code → "Claude Code Fundamentals", Agent SDK → "Building Agents with Claude") and tutorial collections.

## What you DON'T get (transparency)

This repo distributes the **synthesized SKILL surfaces** (our authorial work) plus per-page MANIFEST.json hashes for drift detection. We do NOT ship the verbatim upstream documentation content — that lives at the upstream URLs the surfaces link to, and our CI re-fetches it ephemerally during each pipeline run. Two reasons: (1) avoid redistributing Anthropic-copyrighted content; (2) keep the public repo footprint small (~50 KB instead of ~20 MB). When Claude needs the deep page for a question, it can `WebFetch` the linked upstream URL directly.

## Architecture

```
autoupdated-anthropic-documentation-knowledge/
├── pipeline/                  ← shared infrastructure
│   ├── agent/                 ← TS agents + sanitiser + monitor.sh + verify.sh
│   ├── scripts/               ← verification scripts
│   └── schema/                ← JSONSchemas
├── skills/
│   └── <skill-name>/          ← one directory per skill payload
│       ├── config.json        ← upstream URLs + dispatch + schema mappings
│       ├── SKILL.md           ← router
│       ├── SKILL-*.md         ← deep references
│       ├── rules/             ← path-scoped auto-correction rules
│       ├── templates/         ← executable example configs
│       ├── docs-snapshot/     ← committed upstream snapshot
│       ├── state.json         ← per-skill pipeline state
│       ├── README.md          ← per-skill story
│       └── CHANGELOG.md       ← per-skill history
├── .github/
│   └── workflows/
│       └── pipeline.yml       ← matrix-runs the pipeline across all skills every 30 min
├── package.json + lockfile    ← devDeps for shared scripts
├── LICENSE
└── README.md (this file) + CHANGELOG.md
```

## Per-skill invocation

Each script + agent reads `SKILL_NAME` from the environment:

```bash
# Verify a single skill
SKILL_NAME=claude-code bash pipeline/agent/verify.sh

# Run a single-skill pipeline locally
SKILL_NAME=claude-code bash pipeline/agent/monitor.sh
SKILL_NAME=claude-code npx tsx pipeline/agent/research-agent.ts
```

The CI workflow at `.github/workflows/pipeline.yml` matrix-iterates over `skills/*/` every 30 minutes (GitHub free-tier coalesces under load — typical end-to-end latency is sub-hour). Most runs are no-ops because `monitor.sh` exits cheaply when upstream hasn't changed.

## Local development — first-clone bootstrap

The `docs-snapshot/` page trees are **gitignored** (`skills/*/docs-snapshot/*/` in `.gitignore`); only each skill's `MANIFEST.json` (hashes + URLs + counts) is committed. Rationale: avoid redistributing upstream-copyrighted documentation, and keep the public repo small (~20 MB → ~50 KB).

On a fresh clone, bootstrap the snapshots you want to work with:

```bash
npm ci                          # one-time: root devDeps (ajv)
npm --prefix pipeline/agent ci  # one-time: agent deps

# Bootstrap one skill's snapshot (~30s-2min per skill, depending on page count)
SKILL_NAME=claude-code bash pipeline/scripts/refresh-docs-snapshot.sh

# Or all 7 skills at once:
for SKILL in $(ls skills); do
  SKILL_NAME=$SKILL bash pipeline/scripts/refresh-docs-snapshot.sh
done
```

After bootstrap, `SKILL_NAME=<name> npm run verify:all` works locally with the populated check enforceable via `FORCE_POPULATED_CHECK=1`.

## For maintainers

Each skill's `config.json` is the source of truth for its upstream sources, dispatch table (which doc page → which SKILL surface), and schema mappings (which surface validates against which JSONSchema).

Adding a new skill:
1. `mkdir skills/<name>` + write `config.json`, `SKILL.md` router, surface stubs
2. The workflow auto-discovers `skills/*/` (no matrix-list edit needed)
3. Run `SKILL_NAME=<name> bash pipeline/scripts/refresh-docs-snapshot.sh` to bootstrap the snapshot locally — the resulting `MANIFEST.json` gets committed; the page files stay gitignored
4. Local smoke: `SKILL_NAME=<name> npm run verify:all`

See `skills/claude-code/` as the reference example.

## License

MIT — see [LICENSE](LICENSE).
