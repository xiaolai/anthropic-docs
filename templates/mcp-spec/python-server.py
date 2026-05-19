"""Minimal MCP server in Python using the `mcp` package.

Exposes one tool (`echo`) and one resource (`hello://world`).
See rules/mcp-server-impl.md for correctness rules.

Run as a stdio MCP server:
    python python-server.py
"""

import sys
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import (
    Tool,
    TextContent,
    Resource,
    ResourceContents,
)

SERVER_NAME = "example-mcp-server"
SERVER_VERSION = "1.0.0"
PROTOCOL_VERSION = "2025-11-25"  # Rule 4: pin the protocol version.

# Rule 1: only declare capabilities we actually handle.
server = Server(SERVER_NAME)


# ─── Tools ─────────────────────────────────────────────────────────────────


@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="echo",
            description="Echo the input message back to the caller.",
            inputSchema={
                "type": "object",
                "properties": {
                    "message": {"type": "string", "description": "Text to echo"},
                },
                "required": ["message"],
            },
            # Rule 3: explicit annotations help clients render permission prompts.
            annotations={
                "title": "Echo",
                "readOnlyHint": True,
                "destructiveHint": False,
                "idempotentHint": True,
                "openWorldHint": False,
            },
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name == "echo":
        message = arguments.get("message", "")
        return [TextContent(type="text", text=f"echo: {message}")]
    # Rule 7: unknown-tool is a protocol-level error — raise.
    raise ValueError(f"Unknown tool: {name}")


# ─── Resources ─────────────────────────────────────────────────────────────


@server.list_resources()
async def list_resources() -> list[Resource]:
    return [
        Resource(
            uri="hello://world",  # Rule 6: absolute URI with a real scheme.
            name="Hello, World",
            description="A greeting resource.",
            mimeType="text/plain",
        ),
    ]


@server.read_resource()
async def read_resource(uri: str) -> str:
    if uri == "hello://world":
        return "Hello, World!"
    raise ValueError(f"Unknown resource: {uri}")


# ─── Boot ─────────────────────────────────────────────────────────────────


async def main() -> None:
    # Rule 5: stderr for logs (stdio servers reserve stdout for JSON-RPC).
    print(
        f"Starting {SERVER_NAME} v{SERVER_VERSION} (MCP {PROTOCOL_VERSION})",
        file=sys.stderr,
    )
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
