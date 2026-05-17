---
paths: "**/*agent*.py"
description: Auto-corrections for Claude Agent SDK (Python) v0.1.49
---

# Claude Agent SDK Rules (Python)

## Package
- Package: `claude-agent-sdk` (PyPI, NOT `anthropic-sdk-python`)
- Latest: v0.1.49

## Common Mistakes

### Use async with for ClaudeSDKClient
```python
# WRONG — client won't be properly cleaned up
client = ClaudeSDKClient(options)
result = await client.query("...")

# CORRECT — use async context manager
async with ClaudeSDKClient(options) as client:
    result = await client.query("...")
```

### Use snake_case for options
```python
# WRONG — camelCase from TypeScript
options = ClaudeAgentOptions(
    permissionMode="bypassPermissions",
    maxTurns=10,
    systemPrompt="...",
    allowedTools=["Read"]
)

# CORRECT — Python snake_case
options = ClaudeAgentOptions(
    permission_mode="bypassPermissions",
    max_turns=10,
    system_prompt="...",
    allowed_tools=["Read"]
)
```

### Use @tool decorator for tool definitions
```python
# WRONG — bare function, wrong signature
def get_weather(city: str) -> dict:
    return {"content": [{"type": "text", "text": f"Weather in {city}: sunny"}]}

# CORRECT — use @tool decorator; handler receives a dict of args
@tool("get_weather", "Get weather for a city", {"city": str})
async def get_weather(args: dict) -> dict:
    return {"content": [{"type": "text", "text": f"Weather in {args['city']}: sunny"}]}
```

### Import from claude_agent_sdk, not anthropic
```python
# WRONG
from anthropic import ClaudeSDKClient
from anthropic.sdk import query

# CORRECT
from claude_agent_sdk import ClaudeSDKClient, query, tool, create_sdk_mcp_server
```

### Use can_use_tool callback with correct signature (NOTE: callback never fires — see below)
```python
# WRONG — missing updated_input
async def can_use_tool(tool_name, tool_input, options):
    return {"behavior": "allow"}

# CORRECT signature (but callback is non-functional — use PreToolUse hooks instead)
async def can_use_tool(tool_name, tool_input, options):
    return {"behavior": "allow", "updated_input": tool_input}
```
**Important**: Despite the correct signature, `can_use_tool` callbacks are never invoked by the CLI. See rule below: "Don't rely on `can_use_tool` for permission enforcement".

### Don't use ANTHROPIC_LOG=debug with SDK
```python
# WRONG — corrupts JSON protocol between SDK and CLI
env={"ANTHROPIC_LOG": "debug"}

# CORRECT — use SDK's stderr callback for debug output
import logging
logger = logging.getLogger("claude-sdk")
options = ClaudeAgentOptions(
    stderr=lambda data: logger.debug(f"CLI stderr: {data}")
)
```

### Use `tools=` to restrict tool availability, not `allowed_tools=`
```python
# WRONG — allowed_tools is a permission allowlist, NOT a tool restriction
options = ClaudeAgentOptions(allowed_tools=[])        # Does nothing (falsy, omitted)
options = ClaudeAgentOptions(allowed_tools=["Read"])  # Pre-approves "Read" permission

# CORRECT — use tools= to control which tools are available
options = ClaudeAgentOptions(tools=[])               # Disables all tools
options = ClaudeAgentOptions(tools=["Read", "Grep"]) # Only these tools enabled
options = ClaudeAgentOptions(tools=None)             # Default toolset (omits --tools flag)
```
**Why**: `allowed_tools` maps to `--allowedTools` (permission pre-approval), not `--tools` (tool availability). An empty `allowed_tools=[]` is also falsy, so it's silently omitted. To disable or restrict tools, always use the `tools` parameter. Issues [#523](https://github.com/anthropics/claude-agent-sdk-python/issues/523), [#634](https://github.com/anthropics/claude-agent-sdk-python/issues/634).

### Use thinking config instead of max_thinking_tokens for Opus 4.6+
```python
# WRONG — deprecated, doesn't work with Opus 4.6
options = ClaudeAgentOptions(
    model="claude-opus-4-6",
    max_thinking_tokens=10000
)

# CORRECT — use thinking config with adaptive mode
options = ClaudeAgentOptions(
    model="claude-opus-4-6",
    thinking={"type": "adaptive"},
    effort="high"
)
```
**Why**: Opus 4.6 deprecated `budget_tokens` in favor of adaptive thinking. The `max_thinking_tokens` option maps to the old parameter. Issue [#553](https://github.com/anthropics/claude-agent-sdk-python/issues/553).

### Add explicit prompt for StructuredOutput to avoid wrapper issues
```python
# WRONG — agent may wrap output in {"output": {...}}, breaking validation
options = ClaudeAgentOptions(
    system_prompt="Analyze the data"
)

# CORRECT — add explicit instruction when using StructuredOutput tool
options = ClaudeAgentOptions(
    system_prompt="Analyze the data. **CRITICAL**: When using StructuredOutput tool, provide the JSON object directly - do NOT wrap in {\"output\": {...}}"
)

# BETTER — use output_format instead of relying on StructuredOutput tool
options = ClaudeAgentOptions(
    output_format={"type": "json_schema", "schema": your_schema}
)
```
**Why**: Agent non-deterministically wraps JSON in `{"output": {...}}`, breaking root-level schema validation. Issue [#571](https://github.com/anthropics/claude-agent-sdk-python/issues/571).

### Wrap client.disconnect() in timeout to prevent hangs
```python
# WRONG — can hang indefinitely with 100% CPU
async with ClaudeSDKClient(options) as client:
    await client.query("...")
    # exit might hang forever

# CORRECT — add timeout wrapper
import asyncio

async with asyncio.timeout(10):
    async with ClaudeSDKClient(options) as client:
        await client.query("...")
        # or manually disconnect with timeout

# ALTERNATIVE — set environment variable for graceful shutdown
import os
os.environ["CLAUDE_CODE_STREAM_CLOSE_TIMEOUT"] = "10000"  # milliseconds
```
**Why**: `Query.close()` has no timeout on task group cleanup. If subprocess is killed or tasks don't respond to cancellation, `anyio._deliver_cancellation()` spins at 100% CPU forever. Issue [#378](https://github.com/anthropics/claude-agent-sdk-python/issues/378).

### Use dict-key access on TypedDict types, not attribute access

```python
# WRONG — attribute access fails at runtime; TypedDicts are plain dicts
config = ThinkingConfigEnabled(type="enabled", budget_tokens=20000)
config.budget_tokens  # AttributeError: 'dict' object has no attribute 'budget_tokens'

output = SyncHookJSONOutput(continue_=True)
output.continue_  # AttributeError at runtime

# CORRECT — use dict key access
config = ThinkingConfigEnabled(type="enabled", budget_tokens=20000)
config["budget_tokens"]  # ✅

output = SyncHookJSONOutput(continue_=True)
output["continue_"]  # ✅
```
**Why**: `TypedDict` classes (e.g., `ThinkingConfig*`, `SyncHookJSONOutput`, `AsyncHookJSONOutput`, `HookSpecificOutput` variants, `McpStdioServerConfig`, `McpSSEServerConfig`, `McpHttpServerConfig`, `SandboxSettings`) are plain `dict` at runtime. Attribute access like `.budget_tokens` raises `AttributeError`. Only `@dataclass` types (e.g., `AgentDefinition`, `HookMatcher`, `TextBlock`, `ResultMessage`) support dot-notation. Issue [#623](https://github.com/anthropics/claude-agent-sdk-python/issues/623).

### Don't rely on `can_use_tool` for permission enforcement — it never fires
```python
# WRONG — can_use_tool callback is never invoked by the CLI (SDK v0.1.48+)
async def my_permission_handler(tool_name, tool_input, context):
    if tool_name == "Write":
        return PermissionResultDeny(message="Blocked")
    return PermissionResultAllow()

options = ClaudeAgentOptions(can_use_tool=my_permission_handler)  # Silent no-op

# CORRECT — use PreToolUse hooks for permission enforcement
async def permission_hook(input_data, tool_use_id, context):
    if input_data.get("tool_name") == "Write":
        return {"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "Blocked"}}
    return {}

options = ClaudeAgentOptions(
    hooks={"PreToolUse": [HookMatcher(hooks=[permission_hook])]}
)
```
**Why**: The CLI does not emit `can_use_tool` control protocol messages even when `--permission-prompt-tool stdio` is active. All `can_use_tool` callbacks are silently bypassed. Issue [#469](https://github.com/anthropics/claude-agent-sdk-python/issues/469).

### Don't break out of query() generator early — can poison event loop
```python
# WRONG — breaking early can raise RuntimeError and cancel all subsequent awaits
async for msg in query(prompt="...", options=options):
    if isinstance(msg, ResultMessage):
        break  # RuntimeError: cancel scope in different task

# CORRECT — let the generator exhaust naturally (it ends at ResultMessage automatically)
async for msg in query(prompt="...", options=options):
    process(msg)  # Generator stops naturally after ResultMessage

# ALSO CORRECT — collect all messages first
messages = [msg async for msg in query(prompt="...", options=options)]
```
**Why**: The query task group enters a cancel scope in one async context and exits in another during generator cleanup. AnyIO forbids this, raising `RuntimeError` which in production can cascade to `CancelledError` on all subsequent `await` calls in that event loop. Issue [#454](https://github.com/anthropics/claude-agent-sdk-python/issues/454).
