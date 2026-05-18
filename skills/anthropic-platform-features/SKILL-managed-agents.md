---
name: anthropic-managed-agents
description: |
  Deep reference for the Managed Agents product — Anthropic-hosted
  agents with their own environments, sessions, files, memory stores,
  vaults, tools, MCP connectors, multi-agent coordination, webhooks,
  GitHub integration, permission policies, and event streaming. Also
  covers Dreams (async memory consolidation jobs). Onboarding through
  production deployment with cloud containers.
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
  service; Managed Agents for fire-and-forget jobs and async workflows.
- **Dreams = memory consolidation (Research Preview).** A Dream is an
  asynchronous job that reads an existing memory store plus up to 100
  past session transcripts and produces a NEW reorganized memory store
  (deduped, contradictions resolved, stale entries replaced). The input
  store is never modified. Poll `/v1/dreams/{id}` for status; Dreams
  do not trigger webhooks. Requires BOTH beta headers:
  `managed-agents-2026-04-01` AND `dreaming-2026-04-21`.
  Supported models: `claude-opus-4-7`, `claude-sonnet-4-6`.
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
- **Beta API surface.** All Managed-Agents endpoints currently live
  under `/v1/...` with the `anthropic-beta` header. Pin the beta
  string to a specific version; the shape may evolve.
- **Webhooks for session state changes.** Webhooks notify you of major
  session transitions (`session.status_run_started`, `session.status_idled`,
  `session.status_rescheduled`, `session.status_terminated`) and vault
  events. Also fires for multiagent thread events and outcome evaluations.
  Configure via Console (Manage → Webhooks). Webhook payloads carry only the
  event type + id — fetch the full object separately to avoid stale data on
  retry. Verify signatures via `X-Webhook-Signature` header.

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

## Dreams (memory consolidation)

| Page | Topic |
|---|---|
| [`dreams.md`](https://platform.claude.com/docs/en/managed-agents/dreams.md) | Dreams (Research Preview) — async jobs that consolidate agent memory stores by processing past session transcripts |

## Page index

20 source pages under
[`https://platform.claude.com/docs/en/managed-agents/`](https://platform.claude.com/docs/en/managed-agents/).

---

*Source pages: 20 under `platform.claude.com/docs/en/managed-agents/`.*
