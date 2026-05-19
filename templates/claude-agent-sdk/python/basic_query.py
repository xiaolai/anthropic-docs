"""Basic Claude Agent SDK query example."""
import asyncio
from claude_agent_sdk import (
    query, ClaudeAgentOptions,
    AssistantMessage, ResultMessage, TextBlock,
)

async def main():
    options = ClaudeAgentOptions(
        system_prompt="You are a helpful assistant.",
        max_turns=5,
        permission_mode="bypassPermissions",
    )

    async for message in query(prompt="What is 2 + 2?", options=options):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if isinstance(block, TextBlock):
                    print(block.text)
        elif isinstance(message, ResultMessage):
            if message.subtype == "success":
                print(f"Result: {message.result}")
                print(f"Cost: ${message.total_cost_usd or 0:.4f}")
            else:
                print(f"Error: {message.subtype}")

asyncio.run(main())
