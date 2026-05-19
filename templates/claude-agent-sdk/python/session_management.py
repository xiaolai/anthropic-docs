"""Session management with Claude Agent SDK."""
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, SystemMessage, ResultMessage

async def main():
    # First query — capture session ID
    session_id = None
    options = ClaudeAgentOptions(
        max_turns=5,
        permission_mode="bypassPermissions",
    )

    async for msg in query(prompt="Read the README.md file", options=options):
        if isinstance(msg, SystemMessage) and msg.subtype == "init":
            session_id = msg.data.get("session_id")
        if isinstance(msg, ResultMessage) and msg.subtype == "success":
            print(f"First query done. Session: {session_id}")

    if not session_id:
        print("No session ID captured")
        return

    # Resume session
    resume_options = ClaudeAgentOptions(
        resume=session_id,
        max_turns=5,
        permission_mode="bypassPermissions",
    )

    async for msg in query(prompt="Now summarize what you read", options=resume_options):
        if isinstance(msg, ResultMessage) and msg.subtype == "success":
            print(f"Resume result: {msg.result[:200] if msg.result else ''}")

    # Fork session
    fork_options = ClaudeAgentOptions(
        resume=session_id,
        fork_session=True,
        max_turns=5,
        permission_mode="bypassPermissions",
    )

    async for msg in query(prompt="Try a different approach", options=fork_options):
        if isinstance(msg, ResultMessage) and msg.subtype == "success":
            print(f"Fork result: {msg.result[:200] if msg.result else ''}")

asyncio.run(main())
