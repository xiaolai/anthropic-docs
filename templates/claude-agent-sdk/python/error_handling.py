"""Error handling patterns with Claude Agent SDK."""
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, SystemMessage, ResultMessage

async def main():
    options = ClaudeAgentOptions(
        max_turns=5,
        max_budget_usd=1.00,
        permission_mode="bypassPermissions",
    )

    session_id = None
    async for msg in query(prompt="Analyze this codebase", options=options):
        if isinstance(msg, SystemMessage):
            if msg.subtype == "init":
                session_id = msg.data.get("session_id")
                print(f"Session: {session_id}")
        elif isinstance(msg, ResultMessage):
            match msg.subtype:
                case "success":
                    print(f"Done: {msg.result[:200] if msg.result else ''}")
                    print(f"Cost: ${msg.total_cost_usd or 0:.4f}")
                case "error_max_turns":
                    print("Hit max turns limit")
                case "error_max_budget_usd":
                    print("Hit budget limit")
                case "error_during_execution":
                    print(f"Execution error occurred")

asyncio.run(main())
