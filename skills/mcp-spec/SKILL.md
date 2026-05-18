---
name: mcp-spec
description: |
  Router skill for the Model Context Protocol (MCP) open spec, covering
  the protocol itself (JSON-RPC framing, capabilities, lifecycle), the
  client and server roles, the transport layers (stdio / streamable
  HTTP / SSE), and the core primitives (tools, resources, prompts,
  sampling, roots, completion).

  Use when the user asks about: writing an MCP server (in any language),
  writing an MCP client, the JSON-RPC protocol framing, the
  initialize handshake, capability negotiation, the stdio transport,
  the streamable HTTP transport, the SSE transport, defining a tool /
  resource / prompt, sampling, roots, or completion. Includes the
  TypeScript SDK (`@modelcontextprotocol/sdk`) and Python SDK (`mcp`).

  Skip: Anthropic's hosted MCP connector (use
  anthropic-platform-features), the user-facing Claude Connectors
  directory (use claude-connectors), Claude Code's `.mcp.json` config
  (use claude-code → SKILL-mcp).
user-invocable: true
---

# Model Context Protocol (MCP) — Router

| Field | Value |
|---|---|
| **Source docs** | [modelcontextprotocol.io](https://modelcontextprotocol.io) |
| **Spec repo** | [modelcontextprotocol/modelcontextprotocol](https://github.com/modelcontextprotocol/modelcontextprotocol) |
| **TypeScript SDK** | [`@modelcontextprotocol/sdk`](https://www.npmjs.com/package/@modelcontextprotocol/sdk) v1.29.0 |
| **Python SDK** | [`mcp`](https://pypi.org/project/mcp/) |

> **This skill is auto-updated every 30 min.** A pipeline reads the upstream
> docs and rewrites the per-surface files below. Section structure is
> stable; content drifts to track upstream.

## Dispatch table

| Surface file | Read when the user asks about… |
|---|---|
| [`SKILL-protocol.md`](SKILL-protocol.md) | JSON-RPC framing, the `initialize` handshake, capability negotiation, lifecycle, error codes, versioning |
| [`SKILL-clients.md`](SKILL-clients.md) | implementing an MCP client, calling tools, reading resources, the client-side of sampling |
| [`SKILL-servers.md`](SKILL-servers.md) | implementing an MCP server in TypeScript or Python, server-side capability advertisement, server lifecycle |
| [`SKILL-transport.md`](SKILL-transport.md) | stdio transport, streamable HTTP transport, SSE transport (legacy), choosing a transport |
| [`SKILL-tools-resources-prompts.md`](SKILL-tools-resources-prompts.md) | defining tools (input schema, output schema), defining resources (URI templates, MIME types), defining prompts, sampling, roots, completion |

---

*This skill is auto-updated every 30 minutes by a maintainer-run pipeline. File
issues at [xiaolai/anthropic-docs](https://github.com/xiaolai/anthropic-docs).*
