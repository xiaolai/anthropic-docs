"""Hooks with Claude Agent SDK (Python).

Hooks work with both ClaudeSDKClient and query() via ClaudeAgentOptions.hooks.
This example uses ClaudeSDKClient for its multi-turn conversation support.
"""
import asyncio
from typing import Any
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions, HookMatcher, HookContext


async def audit_logger(
    input_data: dict[str, Any], tool_use_id: str | None, context: HookContext
) -> dict[str, Any]:
    """Log every tool call."""
    print(f"[audit] {input_data.get('tool_name')} called (id: {tool_use_id})")
    return {}


async def protect_sensitive_files(
    input_data: dict[str, Any], tool_use_id: str | None, context: HookContext
) -> dict[str, Any]:
    """Block writes to protected paths by redirecting."""
    file_path = input_data.get("tool_input", {}).get("file_path", "")
    protected = [".env", "credentials", "secrets", "id_rsa"]

    if any(p in file_path for p in protected):
        return {
            "hookSpecificOutput": {
                "hookEventName": input_data["hook_event_name"],
                "permissionDecision": "deny",
                "permissionDecisionReason": f"Write to {file_path} blocked",
            }
        }
    return {}


async def bash_guardrails(
    input_data: dict[str, Any], tool_use_id: str | None, context: HookContext
) -> dict[str, Any]:
    """Add safety context before Bash execution."""
    return {
        "hookSpecificOutput": {
            "hookEventName": input_data["hook_event_name"],
            "additionalContext": "IMPORTANT: Do not modify files outside the project directory.",
        }
    }


async def result_logger(
    input_data: dict[str, Any], tool_use_id: str | None, context: HookContext
) -> dict[str, Any]:
    """Log tool results."""
    tool_name = input_data.get("tool_name", "unknown")
    print(f"[post] {tool_name} completed (id: {tool_use_id})")
    return {}


async def on_stop(
    input_data: dict[str, Any], tool_use_id: str | None, context: HookContext
) -> dict[str, Any]:
    """Cleanup on agent stop."""
    print("[stop] Agent finished, running cleanup...")
    return {}


async def main():
    options = ClaudeAgentOptions(
        hooks={
            "PreToolUse": [
                HookMatcher(matcher="Write|Edit", hooks=[protect_sensitive_files]),
                HookMatcher(matcher="Bash", hooks=[bash_guardrails]),
                HookMatcher(hooks=[audit_logger]),  # no matcher = all tools
            ],
            "PostToolUse": [
                HookMatcher(hooks=[result_logger]),
            ],
            "Stop": [
                HookMatcher(hooks=[on_stop]),  # matchers ignored for lifecycle hooks
            ],
        },
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("Refactor the auth module to use bcrypt")
        async for message in client.receive_response():
            from claude_agent_sdk import ResultMessage
            if isinstance(message, ResultMessage):
                if message.subtype == "success":
                    print(f"\nDone: {message.result}")
                    print(f"Cost: ${message.total_cost_usd or 0:.4f}")
                else:
                    print(f"Error: {message.subtype}")


asyncio.run(main())
