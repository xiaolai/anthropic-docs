---
name: anthropic-managed-agents
description: |
  Deep reference for the Managed Agents product — Anthropic-hosted
  long-running agents (Dreams) with their own environments, sessions,
  files, memory, vaults, tools, MCP connectors, multi-agent
  coordination, webhooks, GitHub integration, permission policies,
  and event streaming. Covers onboarding through to production
  deployment with cloud sandboxes.
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
- **Also available on Claude Platform on AWS.** Managed Agents runs on
  AWS-hosted Claude infrastructure with some differences in feature
  availability and session behavior. See
  [`claude-platform-on-aws.md`](https://platform.claude.com/docs/en/build-with-claude/claude-platform-on-aws.md).
- **Endpoint rate limits (org-level):** Create endpoints (agents,
  sessions, environments, etc.) — 300 RPM. Read endpoints (retrieve,
  list, stream, etc.) — 600 RPM. Org-level spend limits and tier-based
  rate limits also apply.
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
  definition; enforced server-side. Default for agent toolset:
  `always_allow`. Default for MCP toolset: `always_ask` (new MCP
  tools don't auto-execute without approval). Policy types:
  `always_allow` and `always_ask` (pauses execution pending
  your confirmation).
- **Cloud sandboxes** are the default Anthropic-managed execution environment
  for code-running agents (Ubuntu 22.04 LTS, x86_64, up to 8 GB RAM, up to
  10 GB disk). Pre-installed with Python 3.12+, Node.js 20+, Go 1.22+,
  Rust 1.77+, and common dev tooling. Network is disabled by default; enable
  in environment config. See
  [`cloud-sandboxes-reference.md`](https://platform.claude.com/docs/en/managed-agents/cloud-sandboxes-reference.md)
  for the full pre-installed package list.
- **Self-hosted sandboxes** keep orchestration on Anthropic's side but
  move tool execution (code, filesystem, network egress) into your own
  infrastructure. An *environment worker* process — run via the `ant`
  CLI or an SDK helper — polls Anthropic's work queue, claims sessions,
  downloads skills, and runs tool calls locally. Not available on Claude
  Platform on AWS. Memory stores are not yet supported with self-hosted
  sandboxes. Combine with MCP Tunnels when you want both code execution
  and MCP tool access to stay inside your network boundary.
  **Platform-specific guides** available for Cloudflare, Daytona, Modal,
  and Vercel — see
  [`self-hosted-sandboxes.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes.md).
- **Beta API surface.** All Managed-Agents endpoints currently live
  under `/v1/...` with the `anthropic-beta` header
  (`managed-agents-2026-04-01`). Pin the beta string to a specific
  version; the shape may evolve.
- **ZDR / HIPAA ineligibility.** Because sessions are stateful
  (persistent filesystem, conversation history stored server-side),
  Managed Agents is **not eligible for Zero Data Retention (ZDR) and
  not covered by a HIPAA Business Associate Agreement (BAA)**.
  Workaround: delete sessions via the sessions API and delete uploaded
  files via the Files API to exercise your data-control rights.
  Full feature-eligibility table:
  [`api-and-data-retention.md`](https://platform.claude.com/docs/en/manage-claude/api-and-data-retention.md).
  Source: [`managed-agents/overview.md`](https://platform.claude.com/docs/en/managed-agents/overview.md).
- **Memory stores persist cross-session.** A memory store
  (`memstore_...` ID) is a workspace-scoped collection of text
  documents mounted as a directory in the agent's container. Create
  via `POST /v1/memory_stores`, seed with
  `POST /v1/memory_stores/{id}/memories`, attach when starting a
  session. Every write creates an immutable version (audit trail).
  Requires the agent toolset to be enabled for read/write operations.
- **Webhooks for async results.** Long-running Dreams notify
  completion via webhook (configure per agent). Don't poll — the
  webhook is cheaper and faster.
- **Session CRUD.** Beyond start/send, sessions support retrieve
  (`GET /v1/sessions/{id}`), list (`GET /v1/sessions?agent_id=...`),
  update (patch `agent.tools` / `agent.mcp_servers` mid-session — full
  replacement semantics, session must be `idle`), archive (`POST
  /v1/sessions/{id}/archive` — preserves history, blocks new events),
  and delete (`DELETE /v1/sessions/{id}` — permanent; does not affect
  files, memory stores, vaults, or agents). A `running` session must
  be interrupted before it can be archived or deleted. Source:
  [`session-operations.md`](https://platform.claude.com/docs/en/managed-agents/session-operations.md).

## Foundation

| Page | Topic |
|---|---|
| [`overview.md`](https://platform.claude.com/docs/en/managed-agents/overview.md) | What Managed Agents is, when to use it |
| [`onboarding.md`](https://platform.claude.com/docs/en/managed-agents/onboarding.md) | First-time setup |
| [`quickstart.md`](https://platform.claude.com/docs/en/managed-agents/quickstart.md) | First-agent walkthrough |
| [`agent-setup.md`](https://platform.claude.com/docs/en/managed-agents/agent-setup.md) | Agent configuration |
| [`define-outcomes.md`](https://platform.claude.com/docs/en/managed-agents/define-outcomes.md) | How to define what success means |
| [`reference.md`](https://platform.claude.com/docs/en/managed-agents/reference.md) | Consolidated reference: event types, self-hosted worker CLI flags, supported MCP server types, rate limits, branding guidelines |

## Agent capabilities

| Capability | Page |
|---|---|
| **Skills** | [`skills.md`](https://platform.claude.com/docs/en/managed-agents/skills.md) |
| **Tools** | [`tools.md`](https://platform.claude.com/docs/en/managed-agents/tools.md) |
| **Files** | [`files.md`](https://platform.claude.com/docs/en/managed-agents/files.md) |
| **Memory stores** | [`memory.md`](https://platform.claude.com/docs/en/managed-agents/memory.md) — Persistent cross-session storage; create via `POST /v1/memory_stores` → `memstore_...` ID; seed with `POST /v1/memory_stores/{id}/memories`; attach to sessions; requires beta header `managed-agents-2026-04-01` |
| **Vaults** | [`vaults.md`](https://platform.claude.com/docs/en/managed-agents/vaults.md) (secret storage) |

### Agent toolset (`agent_toolset_20260401`)

Enable the built-in agent toolset by including `{"type": "agent_toolset_20260401"}` in the
agent's `tools` array. All tools are enabled by default; disable individual tools via the
`configs` array. Source: [`tools.md`](https://platform.claude.com/docs/en/managed-agents/tools.md).

| Tool name | Description |
|---|---|
| `bash` | Execute bash commands in a shell session |
| `read` | Read a file from the local filesystem |
| `write` | Write a file to the local filesystem |
| `edit` | Perform string replacement in a file |
| `glob` | Fast file pattern matching using glob patterns |
| `grep` | Text search using regex patterns |
| `web_fetch` | Fetch content from a URL |
| `web_search` | Search the web for information |

> **Token overflow:** When a tool output exceeds 100K tokens, it is automatically
> written to a file in the sandbox. The model receives a truncated preview with the
> file path and can read the full content from there.

## Environments & runtime

| Page | Topic |
|---|---|
| [`environments.md`](https://platform.claude.com/docs/en/managed-agents/environments.md) | Environment concept (dev / staging / prod) |
| [`cloud-sandboxes-reference.md`](https://platform.claude.com/docs/en/managed-agents/cloud-sandboxes-reference.md) | Pre-installed languages, databases, utilities, and sandbox specs (Ubuntu 22.04, up to 8 GB RAM / 10 GB disk, network off by default) |
| [`self-hosted-sandboxes.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes.md) | Run sessions in your own infrastructure (environment worker pattern) |
| [`self-hosted-sandboxes-security.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security.md) | Shared responsibility model for self-hosted sandbox environments |
| [`sessions.md`](https://platform.claude.com/docs/en/managed-agents/sessions.md) | Session lifecycle — create a session, send events, stream responses |
| [`session-operations.md`](https://platform.claude.com/docs/en/managed-agents/session-operations.md) | Session CRUD: retrieve, list, update (mid-session agent config), archive, delete |
| [`permission-policies.md`](https://platform.claude.com/docs/en/managed-agents/permission-policies.md) | What each agent may do |

## Events quick-reference

Events follow `{domain}.{action}` naming; every event has a `processed_at`
timestamp (null = queued). Source:
[`events-and-streaming.md`](https://platform.claude.com/docs/en/managed-agents/events-and-streaming.md).

| Direction | Type | Notes |
|---|---|---|
| **→ send** | `user.message` | Text turn |
| **→ send** | `user.interrupt` | Stop mid-execution |
| **→ send** | `user.custom_tool_result` | Reply to `agent.custom_tool_use` |
| **→ send** | `user.tool_confirmation` | Approve/deny when permission policy requires |
| **→ send** | `user.define_outcome` | Set a goal for the agent |
| **→ send** | `user.tool_result` | Self-hosted only: provide `agent_toolset` results |
| **← recv** | `agent.message` | Agent text response |
| **← recv** | `agent.thinking` | Agent reasoning (emitted separately) |
| **← recv** | `agent.tool_use / agent.tool_result` | Built-in tool invocation + result |
| **← recv** | `agent.mcp_tool_use / agent.mcp_tool_result` | MCP tool invocation + result |
| **← recv** | `agent.custom_tool_use` | Custom tool call; you reply with `user.custom_tool_result` |
| **← recv** | `agent.thread_context_compacted` | Conversation history was compacted |
| **← recv** | `agent.thread_message_received/sent` | Multi-agent sub-agent coordination |
| **← recv** | `session.status_running` | Agent actively processing |
| **← recv** | `session.status_idle` | Task done; includes `stop_reason` |
| **← recv** | `session.status_rescheduled` | Transient error; retrying |
| **← recv** | `session.status_terminated` | Unrecoverable error |
| **← recv** | `session.updated` | Field(s) changed; applies next turn |
| **← recv** | `session.error` | Error; includes `error.retry_status` |
| **← recv** | `session.thread_created` | Multiagent thread was created |
| **← recv** | `session.thread_status_running` | Multiagent thread started activity |
| **← recv** | `session.thread_status_idle` | Multiagent thread finished its turn; includes `stop_reason` |
| **← recv** | `session.thread_status_terminated` | Multiagent thread was archived or reached terminal error |
| **← recv** | `span.model_request_start/end` | Inference timing; `_end` includes `model_usage` |
| **← recv** | `span.outcome_evaluation_start` | Outcome evaluation started |
| **← recv** | `span.outcome_evaluation_ongoing` | Outcome evaluation heartbeat (in-progress) |
| **← recv** | `span.outcome_evaluation_end` | Outcome evaluation completed |

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

## Branding guidelines

When referencing Claude Managed Agents in a product integration:

| Allowed | Not permitted |
|---|---|
| "Claude Agent" (preferred for dropdown menus) | "Claude Code" or "Claude Code Agent" |
| "Claude" (when within a menu already labeled "Agents") | "Claude Cowork" or "Claude Cowork Agent" |
| "{YourAgentName} Powered by Claude" | Claude Code-branded ASCII art or elements mimicking Claude Code |

Your product should maintain its own branding and not appear to be any other Anthropic product.
Source: [`reference.md`](https://platform.claude.com/docs/en/managed-agents/reference.md).

## Page index

24 source pages under
[`https://platform.claude.com/docs/en/managed-agents/`](https://platform.claude.com/docs/en/managed-agents/).

---

*Source pages: 24 under `platform.claude.com/docs/en/managed-agents/`.*
