---
name: claude-agent-sdk
description: |
  Build autonomous AI agents with Claude Agent SDK.
  TypeScript v0.2.77 | Python v0.1.49.
  Covers: query(), hooks, subagents, MCP, permissions, sandbox,
  structured outputs, and sessions.

  Use when: building AI agents, configuring MCP servers, setting up
  permissions/hooks, using structured outputs, troubleshooting SDK errors,
  or working with subagents.
user-invocable: true
---

# Claude Agent SDK Reference

| | TypeScript | Python |
|---|---|---|
| **Version** | v0.2.77 | v0.1.49 |
| **Package** | `@anthropic-ai/claude-agent-sdk` | `claude-agent-sdk` (PyPI) |
| **Docs** | [TypeScript SDK](https://platform.claude.com/docs/en/agent-sdk/typescript) | [Python SDK](https://platform.claude.com/docs/en/agent-sdk/python) |
| **Repo** | [claude-agent-sdk-typescript](https://github.com/anthropics/claude-agent-sdk-typescript) | [claude-agent-sdk-python](https://github.com/anthropics/claude-agent-sdk-python) |
| **Full reference** | [SKILL-typescript.md](SKILL-typescript.md) | [SKILL-python.md](SKILL-python.md) |

## When you detect the user's language

- Working with `.ts` files, TypeScript imports, or `npm`/`node` → read `SKILL-typescript.md`
- Working with `.py` files, Python imports, or `pip`/`python` → read `SKILL-python.md`
- Ambiguous or multi-language → read both as needed

## Cross-Language Naming Map

| Concept | TypeScript | Python |
|---------|-----------|--------|
| One-shot query | `query(options)` | `query(options)` |
| Stateful client | N/A (query manages state) | `ClaudeSDKClient` |
| Options type | `Options` interface | `ClaudeAgentOptions` dataclass |
| Tool definition | `tool(name, schema, handler)` | `@tool(name, desc, schema)` decorator |
| MCP server factory | `createSdkMcpServer()` | `create_sdk_mcp_server()` |
| Permission callback | `canUseTool` | `can_use_tool` |
| Permission mode | `permissionMode: "..."` | `permission_mode="..."` |
| Hook registration | `hooks: { PreToolUse: [...] }` | `hooks={"PreToolUse": [...]}` |
| System prompt | `systemPrompt` | `system_prompt` |
| Max turns | `maxTurns` | `max_turns` |
| Allowed tools | `allowedTools` | `allowed_tools` |
| MCP servers | `mcpServers` | `mcp_servers` |
| Subagent def | `AgentDefinition` | `AgentDefinition` dataclass |

## Shared Concepts (both languages)

Both SDKs wrap the Claude Code CLI and share these concepts:
- **Hooks**: Pre/PostToolUse, Stop, SubagentStop, Notification, etc.
- **Permissions**: default, acceptEdits, plan, bypassPermissions, etc.
- **MCP Servers**: stdio, HTTP, SSE, SDK (in-process) configurations
- **Subagents**: Delegate tasks to child agents with scoped tools/permissions
- **Structured Outputs**: JSON Schema validation on agent output
- **Sandbox**: Container-based isolation (Docker/Kubernetes)
- **Sessions**: Capture, resume, and fork conversation state

For API details, code examples, options tables, and known issues,
read the language-specific reference file.
