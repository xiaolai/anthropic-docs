# anthropic-docs-skills-autoupdated

A self-updating collection of 7 Claude Code skills that mirror the official
Anthropic documentation surfaces and present them at intent-match time. The
pipeline lives once in `pipeline/`; each skill payload lives under
`skills/<name>/` with its own `config.json` declaring upstream sources,
dispatch tables, and schema mappings.

## Skills

| Skill | Source | Surfaces | Status |
|---|---|---|---|
| `claude-code` | [`code.claude.com/docs`](https://code.claude.com/docs) (CLI itself) | 7 | ✅ populated |
| `claude-agent-sdk` | [`code.claude.com/docs/en/agent-sdk`](https://code.claude.com/docs/en/agent-sdk) + npm + PyPI | 2 (TS / Python) | ✅ populated |
| `anthropic-api` | [`platform.claude.com/docs/en/api`](https://platform.claude.com/docs/en/api) | 5 | 🌱 scaffold |
| `anthropic-platform-features` | [`platform.claude.com/docs/en/{agents-and-tools,build-with-claude,manage-claude,managed-agents}`](https://platform.claude.com/docs) | 4 | 🌱 scaffold |
| `claude-connectors` | [`claude.com/docs/en/{connectors,skills,plugins}`](https://claude.com/docs/en/connectors) | 5 | 🌱 scaffold |
| `claude-cowork` | [`claude.com/docs/en/{cowork,office-agents}`](https://claude.com/docs/en/cowork) | 2 | 🌱 scaffold |
| `mcp-spec` | [`modelcontextprotocol.io`](https://modelcontextprotocol.io) + 3 SDK repos | 5 | 🌱 scaffold |

**Legend:** ✅ populated = surface files already carry real content. 🌱 scaffold = `state.json.scaffoldComplete=false`, surfaces are stubs; the daily workflow's first successful run will populate them from upstream and flip the flag.

See [`dev-docs/multi-skill-migration.md`](dev-docs/multi-skill-migration.md) for the full ecosystem plan + per-skill source mappings.

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

The CI workflow at `.github/workflows/daily.yml` matrix-iterates over `skills/*/` every 30 minutes (GitHub free-tier coalesces under load — typical end-to-end latency is sub-hour). Most runs are no-ops because `monitor.sh` exits cheaply when upstream hasn't changed.

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
