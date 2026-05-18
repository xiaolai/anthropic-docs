---
name: anthropic-managed-agents
description: |
  Deep reference for the Managed Agents product — Anthropic-hosted
  long-running agents (Dreams) with their own environments, sessions,
  files, memory, vaults, tools, MCP connectors, multi-agent
  coordination, webhooks, GitHub integration, permission policies,
  and event streaming. Covers onboarding through to production
  deployment with cloud containers.
source: https://platform.claude.com/docs/en/managed-agents/overview.md
---

# Platform — Managed Agents

> *Router lives in [`SKILL.md`](SKILL.md). For the Agent SDK
> (build your own agents locally with TS/Python), see
> [`claude-agent-sdk`](../claude-agent-sdk/SKILL.md). Managed Agents
> is the *hosted* alternative — Anthropic runs the agent infrastructure.*

## Key facts (at intent time)

- **Managed Agents vs Agent SDK:** the SDK is a library you embed in
  your app (you run the loop). Managed Agents is a hosted product
  (Anthropic runs the loop, your agent definition lives on Anthropic
  infrastructure). Decision: SDK for tight integration with your
  service; Managed Agents for fire-and-forget jobs and the Dreams
  long-running pattern.
- **Dreams = long-running.** A Dream is an agent execution that can
  run for hours or days, surviving across sessions. Use for research
  syntheses, batch processing, multi-step workflows that don't fit
  in a single conversation.
- **Sessions are persistent conversations.** Unlike Messages API
  (stateless), a Managed Agent session holds state across calls.
  Bill by tokens consumed, not by session duration.
- **Vaults** store secrets your agent needs to access third-party
  services (API keys, OAuth tokens). Encrypted at rest, scoped per
  agent, never exposed to your agent's prompt context.
- **Permission policies** gate what each agent may do (which tools,
  which file paths, which network endpoints). Set on the agent
  definition; enforced server-side. Default-deny.
- **Cloud containers** are the execution sandbox for code-running
  agents. Limited CPU / memory / network egress. Configure per agent
  via the environments resource.
- **Beta API surface.** All Managed-Agents endpoints require
  `anthropic-beta: managed-agents-2026-04-01`. The SDK sets this
  header automatically; curl callers must pass it explicitly.
  Pin the string to a specific version; the shape may evolve.
- **Rate limits**: Create endpoints (agents, sessions, environments)
  are limited to **300 requests/min**; read endpoints (retrieve,
  list, stream) to **600 requests/min** per org.
- **Webhooks for async results.** Long-running Dreams notify
  completion via webhook (configure per agent). Don't poll — the
  webhook is cheaper and faster.

## Agent configuration schema

Fields for `POST /v1/agents` (source:
[`agent-setup.md`](https://platform.claude.com/docs/en/managed-agents/agent-setup.md)):

| Field | Required | Description |
|---|---|---|
| `name` | ✓ | Human-readable agent name |
| `model` | ✓ | Model ID string OR `{"id":"...", "speed":"fast"}` for fast mode |
| `system` | | System prompt (behavior/persona) |
| `tools` | | Array of tool specs; use `{"type":"agent_toolset_20260401"}` for the default toolset |
| `mcp_servers` | | MCP server configurations |
| `skills` | | Agent Skill package references |
| `multiagent` | | Coordinator declaration for sub-agent delegation |
| `description` | | Human description of the agent's purpose |
| `metadata` | | Arbitrary key-value pairs |

Response adds: `id`, `type`, `version`, `created_at`, `updated_at`, `archived_at`.
Agents are versioned; updating creates a new version; pass `version` to pin.

## Built-in toolset (`agent_toolset_20260401`)

Source: [`tools.md`](https://platform.claude.com/docs/en/managed-agents/tools.md)

| Tool name | What it does |
|---|---|
| `bash` | Execute shell commands |
| `read` | Read a file from the container filesystem |
| `write` | Write a file to the container filesystem |
| `edit` | String-replacement edit of a file |
| `glob` | File pattern matching |
| `grep` | Regex text search |
| `web_fetch` | Fetch content from a URL |
| `web_search` | Search the web |

Disable individual tools with `configs: [{"name": "web_fetch", "enabled": false}]` inside the toolset spec.

## Session event types

Source: [`events-and-streaming.md`](https://platform.claude.com/docs/en/managed-agents/events-and-streaming.md).
Event type strings follow `{domain}.{action}`.

**User events** (you → agent): `user.message`, `user.interrupt`,
`user.custom_tool_result`, `user.tool_confirmation`, `user.define_outcome`

**Agent events** (agent → you): `agent.message`, `agent.thinking`,
`agent.tool_use`, `agent.tool_result`, `agent.mcp_tool_use`,
`agent.mcp_tool_result`, `agent.custom_tool_use`,
`agent.thread_context_compacted`, `agent.thread_message_received`,
`agent.thread_message_sent`

**Session events**: `session.status_running`, `session.status_idle`
(includes `stop_reason`), `session.status_rescheduled`,
`session.status_terminated`, `session.error`

**Span events**: `span.model_request_start`, `span.model_request_end`
(includes `model_usage` with token counts), `span.outcome_evaluation_start`,
`span.outcome_evaluation_ongoing`, `span.outcome_evaluation_end`

Every event carries a `processed_at` timestamp (null if queued).

## Foundation

| Page | Topic |
|---|---|
| [`overview.md`](https://platform.claude.com/docs/en/managed-agents/overview.md) | What Managed Agents is, when to use it |
| [`onboarding.md`](https://platform.claude.com/docs/en/managed-agents/onboarding.md) | First-time setup |
| [`quickstart.md`](https://platform.claude.com/docs/en/managed-agents/quickstart.md) | First-agent walkthrough |
| [`agent-setup.md`](https://platform.claude.com/docs/en/managed-agents/agent-setup.md) | Agent configuration |
| [`define-outcomes.md`](https://platform.claude.com/docs/en/managed-agents/define-outcomes.md) | How to define what success means |

## Agent capabilities

| Capability | Page |
|---|---|
| **Skills** | [`skills.md`](https://platform.claude.com/docs/en/managed-agents/skills.md) |
| **Tools** | [`tools.md`](https://platform.claude.com/docs/en/managed-agents/tools.md) |
| **Files** | [`files.md`](https://platform.claude.com/docs/en/managed-agents/files.md) |
| **Memory** | [`memory.md`](https://platform.claude.com/docs/en/managed-agents/memory.md) |
| **Vaults** | [`vaults.md`](https://platform.claude.com/docs/en/managed-agents/vaults.md) (secret storage) |

## Environments & runtime

| Page | Topic |
|---|---|
| [`environments.md`](https://platform.claude.com/docs/en/managed-agents/environments.md) | Environment concept (dev / staging / prod) |
| [`cloud-containers.md`](https://platform.claude.com/docs/en/managed-agents/cloud-containers.md) | Container-backed agent runtime |
| [`sessions.md`](https://platform.claude.com/docs/en/managed-agents/sessions.md) | Session lifecycle |
| [`permission-policies.md`](https://platform.claude.com/docs/en/managed-agents/permission-policies.md) | What each agent may do |

## Integrations

| Page | Topic |
|---|---|
| [`github.md`](https://platform.claude.com/docs/en/managed-agents/github.md) | GitHub integration (PR review, issue triage, code edits) |
| [`mcp-connector.md`](https://platform.claude.com/docs/en/managed-agents/mcp-connector.md) | Connect MCP servers to a managed agent |
| [`webhooks.md`](https://platform.claude.com/docs/en/managed-agents/webhooks.md) | Webhook triggers |
| [`events-and-streaming.md`](https://platform.claude.com/docs/en/managed-agents/events-and-streaming.md) | Event streaming during execution |

## Multi-agent

| Page | Topic |
|---|---|
| [`multi-agent.md`](https://platform.claude.com/docs/en/managed-agents/multi-agent.md) | Coordination between multiple managed agents |

## Dreams (long-running)

| Page | Topic |
|---|---|
| [`dreams.md`](https://platform.claude.com/docs/en/managed-agents/dreams.md) | "Dreams" — long-running agent jobs that execute over hours/days |

## Page index

20 source pages under
[`https://platform.claude.com/docs/en/managed-agents/`](https://platform.claude.com/docs/en/managed-agents/).

---

*Source pages: 20 under `platform.claude.com/docs/en/managed-agents/`.*
