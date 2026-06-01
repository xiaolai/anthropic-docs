---
name: claude-agent-sdk
description: |
  Router skill for the Claude Agent SDK — Anthropic's libraries for
  building autonomous AI agents that wrap the Claude Code CLI runtime.
  Ships in TypeScript (`@anthropic-ai/claude-agent-sdk` on npm) and
  Python (`claude-agent-sdk` on PyPI). Covers `query()` / `ClaudeSDKClient`,
  hooks (PreToolUse / PostToolUse / Stop / etc.), subagents, MCP
  servers (stdio / HTTP / SSE / SDK in-process), permission modes,
  the sandbox (Docker / Kubernetes), structured outputs (JSON Schema
  validation), session capture / resume / fork, and session storage
  adapters (`SessionStore`, `InMemorySessionStore`, S3/Redis/Postgres).

  Use when the user asks about: importing `@anthropic-ai/claude-agent-sdk`
  in TypeScript or `from claude_agent_sdk import ...` in Python, writing
  an agent that uses `query()` or `ClaudeSDKClient`, registering hooks
  via the SDK (`hooks: { PreToolUse: [...] }` / `hooks={"PreToolUse": [...]}`),
  defining MCP servers in SDK options, configuring `permissionMode` /
  `permission_mode`, building subagents with `AgentDefinition`, enabling
  structured outputs, running agents in a Docker/K8s sandbox, capturing
  and resuming sessions, mirroring session transcripts to external storage
  (S3, Redis, Postgres) via `SessionStore`, or troubleshooting SDK-specific
  errors (the
  SDK wraps Claude Code, so its errors differ from raw Messages API
  errors).

  Skip: questions about the Claude Code CLI itself such as `.claude/
  settings.json` or `.mcp.json` files (use claude-code), the Anthropic
  Messages API directly without the SDK (use anthropic-api), the MCP
  protocol spec itself (use mcp-spec), or Anthropic's hosted Managed
  Agents product (use anthropic-platform-features).
user-invocable: true
---

# Claude Agent SDK Reference

| | TypeScript | Python |
|---|---|---|
| **Version** | v0.3.159 | v0.2.87 |
| **Package** | `@anthropic-ai/claude-agent-sdk` | `claude-agent-sdk` (PyPI) |
| **Docs** | [TypeScript SDK](https://platform.claude.com/docs/en/agent-sdk/typescript) | [Python SDK](https://platform.claude.com/docs/en/agent-sdk/python) |
| **Repo** | [claude-agent-sdk-typescript](https://github.com/anthropics/claude-agent-sdk-typescript) | [claude-agent-sdk-python](https://github.com/anthropics/claude-agent-sdk-python) |
| **Full reference** | [SKILL-typescript.md](SKILL-typescript.md) | [SKILL-python.md](SKILL-python.md) |

## When you detect the user's language

- Working with `.ts` files, TypeScript imports, or `npm`/`node` → read `SKILL-typescript.md`
- Working with `.py` files, Python imports, or `pip`/`python` → read `SKILL-python.md`
- Ambiguous or multi-language → read both surface files

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
- **Sessions**: Capture, resume, fork, and mirror transcripts to external storage (`SessionStore`)

For API details, code examples, options tables, and known issues,
read the language-specific reference file.
