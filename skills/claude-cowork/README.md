# claude-cowork

Auto-updated reference skill for **Claude Cowork** — Claude for Work
deployed multi-cloud (Amazon Bedrock, Microsoft Foundry, LLM gateways,
enterprise SSO, telemetry, M365 connector, policy controls) and
**Office agents** (Claude in Excel, Slack-style integrations).

Part of the [anthropic-docs](../../README.md) plugin.

**Last updated**: 2026-05-20

## Surfaces

| File | Topic |
|---|---|
| [SKILL.md](SKILL.md) | Router — dispatch table |
| [SKILL-cowork.md](SKILL-cowork.md) | Multi-cloud enterprise deployment (Bedrock, Foundry, gateways, SSO, telemetry, M365, policy) |
| [SKILL-office-agents.md](SKILL-office-agents.md) | Claude in Excel, Slack-style office integrations |

## Source

- **Docs**: [claude.com/docs/en/cowork](https://claude.com/docs/en/cowork), [claude.com/docs/en/office-agents](https://claude.com/docs/en/office-agents)

## Update model

```bash
SKILL_NAME=claude-cowork npm run update
```

## Recent activity

| Date | Update | Research | Mending | Report | Total | Notes |
|------|--------|----------|---------|--------|-------|-------|
| 2026-05-20 | review | research + report (no upstream change) |
| 2026-05-20 (run 9) | — | $1.06 | — | — | **$1.06** | review — check-docs-drift fail; 34 pages audited, 68 turns, 363s; no upstream change |
| 2026-05-20 (run 8) | — | $1.58 | — | — | **$1.58** | review — check-docs-drift fail; 34 pages audited, 85 turns, 550s; no upstream change |
| 2026-05-20 (run 7) | — | $1.20 | — | — | **$1.20** | success — all gates pass; 34 pages audited, 95 turns, 482s; no upstream change |
| 2026-05-20 (run 6) | — | $0.49 | — | — | **$0.49** | review — check-docs-drift fail; 34 pages audited, 40 turns, no upstream change |
| 2026-05-20 (run 5) | — | $0.73 | — | — | **$0.73** | review — check-docs-drift fail; 34 pages audited, 49 turns, no upstream change |
| 2026-05-20 (run 4) | — | $1.23 | — | — | **$1.23** | review — check-docs-drift fail; 34 pages audited, no upstream change; 76 turns 484s |

