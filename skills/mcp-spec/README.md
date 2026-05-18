# mcp-spec

Auto-updated reference skill for the **Model Context Protocol (MCP)**
open spec — the protocol itself (JSON-RPC framing, lifecycle,
capabilities), the client and server roles, the transport layers
(stdio / streamable HTTP / SSE), and the core primitives (tools,
resources, prompts, sampling, roots, completion).

Part of the [anthropic-docs](../../README.md) plugin.

**Last updated**: 2026-05-18

## Surfaces

| File | Topic |
|---|---|
| [SKILL.md](SKILL.md) | Router — dispatch table |
| [SKILL-protocol.md](SKILL-protocol.md) | JSON-RPC framing, initialize, capabilities, lifecycle, errors, versioning |
| [SKILL-clients.md](SKILL-clients.md) | Implementing MCP clients, calling tools, reading resources, sampling client side |
| [SKILL-servers.md](SKILL-servers.md) | Implementing MCP servers (TS + Python), advertising capabilities, lifecycle |
| [SKILL-transport.md](SKILL-transport.md) | stdio, streamable HTTP, SSE legacy, choosing a transport |
| [SKILL-tools-resources-prompts.md](SKILL-tools-resources-prompts.md) | Tools, resources, prompts, sampling, roots, completion |

## Source

- **Docs**: [modelcontextprotocol.io](https://modelcontextprotocol.io)
- **Spec repo**: [modelcontextprotocol/modelcontextprotocol](https://github.com/modelcontextprotocol/modelcontextprotocol)
- **TypeScript SDK**: [`@modelcontextprotocol/sdk`](https://www.npmjs.com/package/@modelcontextprotocol/sdk)
- **Python SDK**: [`mcp`](https://pypi.org/project/mcp/)

## Recent activity

| Date | Update | Research | Mending | Report | Total | Notes |
|------|--------|----------|---------|--------|-------|-------|
| 2026-05-18 | $0.52 | $0.65 | $0 | — | **$1.18** | success; docs index +2 pages (118 total); sdk npm 1.29.0 / pypi 1.27.1 |

## Update model

```bash
SKILL_NAME=mcp-spec npm run update
```

