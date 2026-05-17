"""Custom permission control with Claude Agent SDK."""
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions
from claude_agent_sdk.types import (
    ToolPermissionContext, PermissionResultAllow, PermissionResultDeny,
)

async def can_use_tool(
    tool_name: str, tool_input: dict, context: ToolPermissionContext
) -> PermissionResultAllow | PermissionResultDeny:
    read_only = ["Read", "Grep", "Glob"]
    if tool_name in read_only:
        return PermissionResultAllow(updated_input=tool_input)
    if tool_name == "Bash" and any(
        cmd in tool_input.get("command", "")
        for cmd in ["rm -rf", "dd if=", "mkfs"]
    ):
        return PermissionResultDeny(message="Destructive command blocked")
    return PermissionResultAllow(updated_input=tool_input)

async def main():
    from claude_agent_sdk import ResultMessage

    options = ClaudeAgentOptions(
        can_use_tool=can_use_tool,
        permission_mode="default",
        max_turns=10,
    )

    async for msg in query(prompt="List files in the current directory", options=options):
        if isinstance(msg, ResultMessage) and msg.subtype == "success":
            print(msg.result)

asyncio.run(main())
