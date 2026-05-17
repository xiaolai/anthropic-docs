# anthropic-docs-skills-autoupdated

**Status: mid-migration to multi-skill architecture (2026-05-17).** Per-skill content + history lives under `skills/<name>/`. This README describes the repo as a whole.

A self-updating collection of Claude Code skills that mirror the official
Anthropic documentation surfaces and surface them at intent-match time. The
pipeline lives once in `pipeline/`; each skill payload lives under
`skills/<name>/` with its own `config.json` declaring upstream sources,
dispatch tables, and schema mappings.

## Skills currently shipping

| Skill | Source | Status |
|---|---|---|
| `claude-code` | `code.claude.com/*` (ex agent-sdk) | ✅ shipping — see [`skills/claude-code/README.md`](skills/claude-code/README.md) and [`skills/claude-code/CHANGELOG.md`](skills/claude-code/CHANGELOG.md) for the full history |
| `claude-agent-sdk` | `code.claude.com/agent-sdk/*` + npm + PyPI | 🚧 planned (migration from `claude-agent-sdk-skill-autoupdated`) |
| `anthropic-api` | `platform.claude.com/api/*` | 🚧 planned |
| `anthropic-platform-features` | `platform.claude.com/{agents-and-tools,build-with-claude,manage-claude,managed-agents}/*` | 🚧 planned |
| `claude-connectors` | `claude.com/docs/{connectors,skills,plugins}/*` | 🚧 planned |
| `claude-cowork` | `claude.com/docs/{cowork,office-agents}/*` | 🚧 planned |
| `mcp-spec` | `modelcontextprotocol.io/*` | 🚧 planned |

See [`dev-docs/multi-skill-migration.md`](dev-docs/multi-skill-migration.md) for the migration plan.

## Architecture

```
anthropic-docs-skills-autoupdated/
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
│       └── daily.yml          ← matrix-runs the pipeline across all skills
├── pipeline.config.json       ← (TBD) matrix-controlling top-level config
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

The daily workflow matrix-iterates over `skills/*/` automatically.

## For maintainers

Each skill's `config.json` is the source of truth for its upstream sources, dispatch table (which doc page → which SKILL surface), and schema mappings (which surface validates against which JSONSchema).

Adding a new skill:
1. `mkdir skills/<name>` + write `config.json`, `SKILL.md` router, surface stubs
2. Add `<name>` to the workflow matrix in `.github/workflows/daily.yml`
3. Run `SKILL_NAME=<name> bash pipeline/scripts/refresh-docs-snapshot.sh` to bootstrap
4. Local smoke: `SKILL_NAME=<name> bash pipeline/agent/verify.sh`

See `skills/claude-code/` as the reference example.

## License

MIT — see [LICENSE](LICENSE).
