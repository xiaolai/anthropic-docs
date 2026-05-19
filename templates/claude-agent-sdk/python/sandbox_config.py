"""Sandbox configuration with Claude Agent SDK."""
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage
from claude_agent_sdk.types import (
    ToolPermissionContext, PermissionResultAllow, PermissionResultDeny,
)


async def basic_sandbox():
    """Basic sandbox — auto-approve bash, allow local network."""
    options = ClaudeAgentOptions(
        permission_mode="bypassPermissions",
        sandbox={
            "enabled": True,
            "autoAllowBashIfSandboxed": True,
            "network": {"allowLocalBinding": True},
        },
    )

    async for msg in query(prompt="Build the project and run tests", options=options):
        if isinstance(msg, ResultMessage):
            if msg.subtype == "success":
                print(msg.result)
            else:
                print(f"Error: {msg.subtype}")


async def production_sandbox():
    """Production sandbox — restricted network, canUseTool for escape hatch."""

    async def can_use_tool(
        tool_name: str, tool_input: dict, context: ToolPermissionContext
    ) -> PermissionResultAllow | PermissionResultDeny:
        # Approve or deny unsandboxed command requests
        if tool_name == "Bash" and tool_input.get("dangerouslyDisableSandbox"):
            safe_commands = ["npm publish", "docker push"]
            if any(tool_input.get("command", "").startswith(cmd) for cmd in safe_commands):
                return PermissionResultAllow(updated_input=tool_input)
            return PermissionResultDeny(
                message=f"Unsandboxed blocked: {tool_input.get('command')}"
            )
        return PermissionResultAllow(updated_input=tool_input)

    options = ClaudeAgentOptions(
        can_use_tool=can_use_tool,
        sandbox={
            "enabled": True,
            "autoAllowBashIfSandboxed": True,
            # Static allowlist: always bypass sandbox
            "excludedCommands": ["git", "docker", "kubectl"],
            # Model can request unsandboxed execution — falls back to can_use_tool
            "allowUnsandboxedCommands": True,
            "network": {
                "allowLocalBinding": True,
                "allowUnixSockets": ["/var/run/docker.sock"],
            },
        },
    )

    async for msg in query(prompt="Deploy and verify health checks", options=options):
        if isinstance(msg, ResultMessage) and msg.subtype == "success":
            print(msg.result)


asyncio.run(basic_sandbox())
