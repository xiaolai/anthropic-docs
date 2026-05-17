"""In-process MCP server with Claude Agent SDK."""
import asyncio
from typing import Any
from claude_agent_sdk import query, tool, create_sdk_mcp_server, ClaudeAgentOptions

@tool("search_docs", "Search documentation", {
    "query": {"type": "string", "description": "Search query"},
    "limit": {"type": "integer", "description": "Max results", "default": 5}
})
async def search_docs(args: dict[str, Any]) -> dict[str, Any]:
    q = args.get("query", "")
    limit = args.get("limit", 5)
    results = [f"Result {i}: {q} match" for i in range(1, min(limit + 1, 4))]
    return {"content": [{"type": "text", "text": "\n".join(results)}]}

@tool("get_doc", "Get a specific document", {
    "doc_id": {"type": "string", "description": "Document ID"}
})
async def get_doc(args: dict[str, Any]) -> dict[str, Any]:
    doc_id = args.get("doc_id", "")
    return {"content": [{"type": "text", "text": f"Document {doc_id}: Lorem ipsum..."}]}

async def main():
    server = create_sdk_mcp_server(
        name="docs",
        version="1.0.0",
        tools=[search_docs, get_doc],
    )

    options = ClaudeAgentOptions(
        mcp_servers={"docs": server},
        system_prompt="You help users search documentation.",
        permission_mode="bypassPermissions",
    )

    async for msg in query(prompt="Search for authentication docs", options=options):
        from claude_agent_sdk import ResultMessage
        if isinstance(msg, ResultMessage) and msg.subtype == "success":
            print(msg.result)

asyncio.run(main())
