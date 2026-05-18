---
name: claude-agent-sdk-py
description: Edit-time correctness rules for code using the claude-agent-sdk Python package. Catches the mistakes most commonly logged in the upstream issue tracker — wrong client lifecycle, camelCase / snake_case confusion, allowed_tools vs tools confusion, thinking config, can_use_tool non-firing, TypedDict access, generator break-out. Pairs with SKILL-python.md (the deep reference).
appliesTo:
  - "**/*.py"
---

# Claude Agent SDK Rules — Python

> *Edit-time corrections. For the full type definitions, options
> dataclass, message-type catalog, and worked examples, see
> [`SKILL-python.md`](../SKILL-python.md). This file lists only the
> patterns Claude should rewrite on sight.*

## Package

- Package: `claude-agent-sdk` (PyPI, NOT `anthropic-sdk-python`).
- Latest version is tracked in `state.json.registry.packages[]`; the
  daily research agent updates SKILL-python.md when it changes.

## Common Mistakes

### Use `async with` for `ClaudeSDKClient`

```python
# WRONG — manual lifecycle, won't clean up subprocess on errors
client = ClaudeSDKClient(options)
result = await client.query("...")

# CORRECT — async context manager (also: ensures graceful disconnect)
async with ClaudeSDKClient(options) as client:
    result = await client.query("...")
```

See [`SKILL-python.md` § ClaudeSDKClient lifecycle](../SKILL-python.md#claudesdkclient).

### Options are `snake_case`, not `camelCase`

The Python `ClaudeAgentOptions` dataclass uses Python-native
`snake_case`. Don't copy-paste TypeScript options names.

```python
# WRONG — camelCase silently dropped (dataclass ignores unknown kwargs in some versions)
options = ClaudeAgentOptions(permissionMode="bypassPermissions", maxTurns=10)

# CORRECT
options = ClaudeAgentOptions(permission_mode="bypassPermissions", max_turns=10)
```

### Import from `claude_agent_sdk`, not `anthropic`

```python
# WRONG — confuses the SDK with the older anthropic-sdk-python package
from anthropic import ClaudeSDKClient
from anthropic.sdk import query

# CORRECT
from claude_agent_sdk import ClaudeSDKClient, query, tool, create_sdk_mcp_server
```

### Use the `@tool` decorator with `(args: dict)` signature

```python
# WRONG — bare function, won't register
def get_weather(city: str) -> dict:
    return {"content": [{"type": "text", "text": f"Weather in {city}"}]}

# CORRECT — @tool decorator; handler receives a dict
@tool("get_weather", "Get weather for a city", {"city": str})
async def get_weather(args: dict) -> dict:
    return {"content": [{"type": "text", "text": f"Weather in {args['city']}"}]}
```

See [`SKILL-python.md` § @tool()](../SKILL-python.md#tool).

### `tools=` restricts availability; `allowed_tools=` pre-approves permissions

These two parameters look similar but mean different things. Empty
`allowed_tools=[]` is also falsy and silently omitted.

```python
# WRONG — does NOT disable tools (it's a permission pre-approval)
options = ClaudeAgentOptions(allowed_tools=[])

# CORRECT for "disable all tools"
options = ClaudeAgentOptions(tools=[])

# CORRECT for "only Read and Grep enabled"
options = ClaudeAgentOptions(tools=["Read", "Grep"])

# Pre-approve Read without prompting (still need tools= to enable it)
options = ClaudeAgentOptions(tools=["Read"], allowed_tools=["Read"])
```

Issues [#523](https://github.com/anthropics/claude-agent-sdk-python/issues/523),
[#634](https://github.com/anthropics/claude-agent-sdk-python/issues/634).

### Use `thinking={"type": "adaptive"}` not `max_thinking_tokens`

`max_thinking_tokens` is deprecated for Opus 4.6+. Use the `thinking`
config dict + `effort` instead.

```python
# WRONG — deprecated, no-op on Opus 4.6+
options = ClaudeAgentOptions(model="claude-opus-4-6", max_thinking_tokens=10000)

# CORRECT
options = ClaudeAgentOptions(
    model="claude-opus-4-6",
    thinking={"type": "adaptive"},
    effort="high"
)
```

Issue [#553](https://github.com/anthropics/claude-agent-sdk-python/issues/553).

### `can_use_tool` is silently never invoked — use `PreToolUse` hooks instead

The `can_use_tool` callback shipped in v0.1.48+ never fires in
practice because the CLI doesn't emit the underlying control protocol
messages. All `can_use_tool` registrations are silent no-ops.

```python
# WRONG — silent no-op, permission enforcement bypassed
options = ClaudeAgentOptions(can_use_tool=my_permission_handler)

# CORRECT — use PreToolUse hooks
async def permission_hook(input_data, tool_use_id, context):
    if input_data.get("tool_name") == "Write":
        return {"hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": "Blocked"
        }}
    return {}

options = ClaudeAgentOptions(
    hooks={"PreToolUse": [HookMatcher(hooks=[permission_hook])]}
)
```

Issue [#469](https://github.com/anthropics/claude-agent-sdk-python/issues/469).

### Use dict-key access on `TypedDict` types, not attribute access

```python
# WRONG — TypedDicts are plain dicts at runtime
config = ThinkingConfigEnabled(type="enabled", budget_tokens=20000)
config.budget_tokens   # AttributeError

# CORRECT
config["budget_tokens"]
```

`TypedDict`-based types in the SDK include `ThinkingConfig*`,
`SyncHookJSONOutput`, `AsyncHookJSONOutput`, `HookSpecificOutput`
variants, `Mcp*ServerConfig`, `SandboxSettings`. `@dataclass`-based
types (`AgentDefinition`, `HookMatcher`, `TextBlock`, `ResultMessage`,
…) DO support attribute access. Issue [#623](https://github.com/anthropics/claude-agent-sdk-python/issues/623).

### Don't break out of `query()` generator early — can poison the event loop

```python
# WRONG — breaking before exhaustion can cascade CancelledError to all
# subsequent awaits in the event loop
async for msg in query(prompt="...", options=options):
    if isinstance(msg, ResultMessage):
        break

# CORRECT — let the generator exhaust (it stops at ResultMessage anyway)
async for msg in query(prompt="...", options=options):
    process(msg)

# ALSO CORRECT — collect first, process after
messages = [msg async for msg in query(prompt="...", options=options)]
```

Issue [#454](https://github.com/anthropics/claude-agent-sdk-python/issues/454).

### Wrap `client.disconnect()` in a timeout

`Query.close()` has no timeout on task-group cleanup; under certain
subprocess-death conditions it spins at 100% CPU forever.

```python
import asyncio

async with asyncio.timeout(10):
    async with ClaudeSDKClient(options) as client:
        await client.query("...")

# Or set the env var globally
import os
os.environ["CLAUDE_CODE_STREAM_CLOSE_TIMEOUT"] = "10000"  # ms
```

Issue [#378](https://github.com/anthropics/claude-agent-sdk-python/issues/378).

### Don't use `ANTHROPIC_LOG=debug` with the SDK

```python
# WRONG — corrupts the JSON protocol between SDK and CLI subprocess
env={"ANTHROPIC_LOG": "debug"}

# CORRECT — use the SDK's stderr callback
options = ClaudeAgentOptions(
    stderr=lambda data: logger.debug(f"CLI stderr: {data}")
)
```

### `StructuredOutput` tool: prefer `output_format` to avoid wrapper bug

The `StructuredOutput` tool non-deterministically wraps the JSON
in `{"output": {...}}`, breaking root-level schema validation.

```python
# WORKAROUND — explicit instruction
options = ClaudeAgentOptions(
    system_prompt="... CRITICAL: When using StructuredOutput tool, provide the JSON object directly — do NOT wrap in {\"output\": {...}}"
)

# BETTER — use output_format instead (no wrapper bug)
options = ClaudeAgentOptions(
    output_format={"type": "json_schema", "schema": your_schema}
)
```

Issue [#571](https://github.com/anthropics/claude-agent-sdk-python/issues/571).

---

*This file lists edit-time correctable patterns. Background, full
types, and complete examples live in
[`SKILL-python.md`](../SKILL-python.md). When that surface and this
file disagree, the surface is canonical and this file is stale — file
an issue at
[xiaolai/autoupdated-anthropic-documentation-knowledge](https://github.com/xiaolai/autoupdated-anthropic-documentation-knowledge).*
