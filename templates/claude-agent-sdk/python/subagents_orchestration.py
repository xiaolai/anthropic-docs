"""Subagent orchestration with Claude Agent SDK."""
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition

async def main():
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Glob", "Grep", "Task"],
        agents={
            "reviewer": AgentDefinition(
                description="Code review specialist",
                prompt="Review code for bugs and best practices.",
                tools=["Read", "Glob", "Grep"],
                model="haiku",
            ),
            "writer": AgentDefinition(
                description="Code writing specialist",
                prompt="Write clean, well-documented code.",
                tools=["Read", "Write", "Edit"],
                model="sonnet",
            ),
        },
        permission_mode="bypassPermissions",
    )

    from claude_agent_sdk import ResultMessage

    async for msg in query(prompt="Use the reviewer to check main.py", options=options):
        if isinstance(msg, ResultMessage):
            print(msg.result if msg.result else f"Error: {msg.subtype}")

asyncio.run(main())
