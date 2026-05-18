# anthropic-platform-features

Auto-updated reference skill for **Anthropic platform features** above
the raw API: Agent Skills format, MCP connector, tool use, build-with-
claude features (extended thinking, batches, citations, Bedrock,
Vertex, embeddings, fast mode, context editing), manage-claude ops
(WIF, billing, identity), and Managed Agents.

Part of the [autoupdated-anthropic-documentation-knowledge](../../README.md) plugin.

## Surfaces

| File | Topic |
|---|---|
| [SKILL.md](SKILL.md) | Router — dispatch table |
| [SKILL-agents-and-tools.md](SKILL-agents-and-tools.md) | Agent Skills format, MCP connector, tool use (computer / code execution / bash / define-tools) |
| [SKILL-build-with-claude.md](SKILL-build-with-claude.md) | Extended thinking, batches, prompt caching, citations, Bedrock, Vertex, embeddings, fast mode, context editing, vision |
| [SKILL-manage-claude.md](SKILL-manage-claude.md) | WIF, billing, organizations ops, identity & SSO |
| [SKILL-managed-agents.md](SKILL-managed-agents.md) | Managed Agents product |

## Source

- **Docs**: [platform.claude.com/docs](https://platform.claude.com/docs) (excluding `/api/*`, which is the `anthropic-api` skill)

## Update model

```bash
SKILL_NAME=anthropic-platform-features npm run update
```

## Status

After first daily run completes, `state.json.scaffoldComplete` flips
to `true` and the SKILL-*.md stubs are replaced with populated content.
