"""Multi-turn conversation with ClaudeSDKClient.

ClaudeSDKClient maintains a stateful session across multiple exchanges,
supporting interrupts, hooks, and custom tools — unlike query() which
creates a new session each time.
"""
import asyncio
from claude_agent_sdk import (
    ClaudeSDKClient, ClaudeAgentOptions,
    ResultMessage, AssistantMessage, TextBlock,
)


async def multi_turn():
    """Multiple queries in the same conversation context."""
    options = ClaudeAgentOptions(
        permission_mode="bypassPermissions",
        max_turns=10,
    )

    async with ClaudeSDKClient(options=options) as client:
        # First exchange
        await client.query("Read the README.md and summarize the project")
        async for msg in client.receive_response():
            if isinstance(msg, ResultMessage) and msg.subtype == "success":
                print(f"Summary: {(msg.result or '')[:200]}")

        # Follow-up in same context — agent remembers the first exchange
        await client.query("Now list the main dependencies from package.json")
        async for msg in client.receive_response():
            if isinstance(msg, ResultMessage) and msg.subtype == "success":
                print(f"Deps: {(msg.result or '')[:200]}")

        # Third exchange — still in context
        await client.query("Are there any version conflicts between them?")
        async for msg in client.receive_response():
            if isinstance(msg, ResultMessage) and msg.subtype == "success":
                print(f"Analysis: {(msg.result or '')[:200]}")


async def with_interrupt():
    """Interrupt a long-running query and start a new one."""
    options = ClaudeAgentOptions(
        permission_mode="bypassPermissions",
        max_turns=50,
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("Analyze every file in the project for code smells")

        turn_count = 0
        interrupted = False
        async for msg in client.receive_response():
            if isinstance(msg, AssistantMessage):
                turn_count += 1
                print(f"Turn {turn_count}...")
                # Interrupt after 5 turns if taking too long
                if turn_count >= 5 and not interrupted:
                    print("Interrupting — taking too long")
                    await client.interrupt()
                    interrupted = True

        # Continue with a more focused query in the same session
        await client.query("Just check the auth/ directory instead")
        async for msg in client.receive_response():
            if isinstance(msg, ResultMessage) and msg.subtype == "success":
                print(f"Result: {(msg.result or '')[:300]}")


asyncio.run(multi_turn())
