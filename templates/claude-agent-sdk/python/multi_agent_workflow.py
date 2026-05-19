"""Multi-agent workflow with custom MCP tools (Python)."""
import asyncio
from typing import Any
from claude_agent_sdk import (
    query, ClaudeAgentOptions, create_sdk_mcp_server, tool,
    AssistantMessage, ResultMessage, TextBlock,
)
from claude_agent_sdk.types import (
    ToolPermissionContext, PermissionResultAllow, PermissionResultDeny,
)


@tool("send_notification", "Send notification to a team", {"message": str, "priority": str})
async def send_notification(args: dict[str, Any]) -> dict[str, Any]:
    priority = args.get("priority", "medium")
    return {"content": [{"type": "text", "text": f"Sent ({priority}): {args['message']}"}]}


@tool("check_health", "Check service health", {"service": str})
async def check_health(args: dict[str, Any]) -> dict[str, Any]:
    return {
        "content": [
            {"type": "text", "text": f'{{"service": "{args["service"]}", "status": "healthy"}}'}
        ]
    }


app_tools = create_sdk_mcp_server(
    name="app-services",
    version="1.0.0",
    tools=[send_notification, check_health],
)


async def can_use_tool(
    tool_name: str, tool_input: dict, context: ToolPermissionContext
) -> PermissionResultAllow | PermissionResultDeny:
    """Block destructive commands."""
    if tool_name == "Bash":
        dangerous = ["rm -rf", "dd if=", "mkfs", "shutdown"]
        if any(p in tool_input.get("command", "") for p in dangerous):
            return PermissionResultDeny(message=f"Blocked: {tool_input['command']}")
    return PermissionResultAllow(updated_input=tool_input)


async def main():
    options = ClaudeAgentOptions(
        system_prompt="You are a DevOps orchestrator. Coordinate agents to complete tasks safely.",
        mcp_servers={"app-services": app_tools},
        agents={
            "deployer": {
                "description": "Handles deployments and rollbacks",
                "prompt": "You deploy applications. Always verify health after deployment.",
                "tools": ["Bash", "Read", "mcp__app-services__check_health", "mcp__app-services__send_notification"],
                "model": "sonnet",
            },
            "security-checker": {
                "description": "Security audits and vulnerability scanning",
                "prompt": "Scan for exposed secrets, outdated deps, and OWASP issues.",
                "tools": ["Read", "Grep", "Bash"],
                "model": "sonnet",
            },
            "monitor": {
                "description": "System monitoring and alerting",
                "prompt": "Check metrics, error rates, and system health.",
                "tools": ["Bash", "Read", "mcp__app-services__check_health"],
                "model": "haiku",
            },
        },
        allowed_tools=[
            "Task", "Read", "Bash", "Grep",
            "mcp__app-services__send_notification",
            "mcp__app-services__check_health",
        ],
        can_use_tool=can_use_tool,
        permission_mode="bypassPermissions",
    )

    async for msg in query(
        prompt="Deploy v2.5.0 with security check and health monitoring",
        options=options,
    ):
        if isinstance(msg, AssistantMessage):
            for block in msg.content:
                if isinstance(block, TextBlock):
                    print(block.text)
        elif isinstance(msg, ResultMessage):
            if msg.subtype == "success":
                print(f"\nDone: {msg.result}")
                print(f"Cost: ${msg.total_cost_usd or 0:.4f}")
            else:
                print(f"Error: {msg.subtype}")


asyncio.run(main())
