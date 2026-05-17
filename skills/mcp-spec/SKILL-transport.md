# MCP — Transports

> **Auto-populated by the daily pipeline.** This file is a stub. After
> the first successful `daily.yml` run for the `mcp-spec` skill, it
> will be rewritten from the upstream docs at
> [modelcontextprotocol.io](https://modelcontextprotocol.io).

Covers:

- **stdio** — newline-delimited JSON-RPC on stdin/stdout. Default for local processes.
- **streamable HTTP** — single endpoint, HTTP POST + SSE response for streaming.
- **SSE (legacy)** — separate POST + EventStream endpoints. Now superseded by streamable HTTP.
- Choosing a transport — local vs remote, auth, observability.
- Auth wrapping at the transport layer.

## Status

- Stub created during scaffold. Next daily run populates from upstream.
