# MCP — Protocol (framing, lifecycle, capabilities)

> **Auto-populated by the daily pipeline.** This file is a stub. After
> the first successful `daily.yml` run for the `mcp-spec` skill, it
> will be rewritten from the upstream docs at
> [modelcontextprotocol.io](https://modelcontextprotocol.io).

Covers:

- JSON-RPC 2.0 framing.
- The `initialize` handshake — `protocolVersion`, `capabilities`, `clientInfo` / `serverInfo`.
- Capability negotiation — what each side advertises and how the other reacts.
- Lifecycle — initialize → operate → shutdown.
- Error codes — JSON-RPC standard + MCP-specific.
- Protocol versioning — current version, backward compatibility rules.

## Status

- Stub created during scaffold. Next daily run populates from upstream.
