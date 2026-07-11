# anthropic-api

Auto-updated reference skill for the **Anthropic Messages API** and
adjacent surfaces (admin, compliance, beta, models).

**Last updated**: 2026-07-11

Part of the [anthropic-docs](../../README.md) plugin.

## Surfaces

| File | Topic |
|---|---|
| [SKILL.md](SKILL.md) | Router — dispatch table to the surface files below |
| [SKILL-messages.md](SKILL-messages.md) | `POST /v1/messages`, tool use, streaming, count_tokens, batches |
| [SKILL-admin.md](SKILL-admin.md) | Admin API — orgs, workspaces, keys, invites, usage, cost |
| [SKILL-compliance.md](SKILL-compliance.md) | Data residency, audit logs, retention |
| [SKILL-beta.md](SKILL-beta.md) | Features behind `anthropic-beta` header |
| [SKILL-models.md](SKILL-models.md) | Model IDs, context windows, deprecation dates |
| [rules/messages-api.md](rules/messages-api.md) | Correctness rules for API-calling code |

## Source

- **Docs**: [platform.claude.com/docs/en/api](https://platform.claude.com/docs/en/api)
- **TypeScript SDK**: [`@anthropic-ai/sdk`](https://www.npmjs.com/package/@anthropic-ai/sdk)
- **Python SDK**: [`anthropic`](https://pypi.org/project/anthropic/)

## Update model

The shared pipeline at `pipeline/` runs daily and rewrites this skill's
surface files from the upstream docs. See the [repo README](../../README.md)
for how the pipeline works.

To run it locally for just this skill:

```bash
SKILL_NAME=anthropic-api npm run update
```

## Recent activity

| Date | Update | Research | Mending | Report | Total | Notes |
|------|--------|----------|---------|--------|-------|-------|
| 2026-06-02 | success | research + report (no upstream change) |
| 2026-06-01 | — | — | — | — | — | success; research + report (no upstream change) |
| 2026-05-31 | — | — | — | — | — | success; research + report (no upstream change) |
| 2026-05-30 | — | — | — | — | — | success; research + report (no upstream change) |
| 2026-05-29 | — | — | — | — | — | success; research + report (no upstream change) |
| 2026-05-28 | — | — | — | — | — | success; research + report (no upstream change) |
| 2026-05-27 | — | ~$0.89 | — | — | **~$0.89** | success; @anthropic-ai/sdk 0.98.0→0.99.0; stop_details fix |

