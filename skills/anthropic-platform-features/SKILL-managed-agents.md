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
  definition; enforced server-side. Default-deny.
- **Cloud containers** are the execution sandbox for code-running
  agents. Limited CPU / memory / network egress. Configure per agent
  via the environments resource.
- **Beta API surface.** All Managed-Agents endpoints currently live
  under `/v1/...` with the `anthropic-beta` header
  (`managed-agents-2026-04-01`). Pin the beta string to a specific
  version; the shape may evolve.
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
| **Memory stores** | [`memory.md`](https://platform.claude.com/docs/en/managed-agents/memory.md) | Persistent cross-session storage; create via `POST /v1/memory_stores` → `memstore_...` ID; seed with `POST /v1/memory_stores/{id}/memories`; attach to sessions; requires beta header `managed-agents-2026-04-01` |
| **Vaults** | [`vaults.md`](https://platform.claude.com/docs/en/managed-agents/vaults.md) (secret storage) |

## Environments & runtime

| Page | Topic |
|---|---|
| [`environments.md`](https://platform.claude.com/docs/en/managed-agents/environments.md) | Environment concept (dev / staging / prod) |
| [`cloud-containers.md`](https://platform.claude.com/docs/en/managed-agents/cloud-containers.md) | Container-backed agent runtime |
| [`self-hosted-sandboxes.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes.md) | Run tool execution in your own infrastructure |
| [`sessions.md`](https://platform.claude.com/docs/en/managed-agents/sessions.md) | Session lifecycle |
| [`permission-policies.md`](https://platform.claude.com/docs/en/managed-agents/permission-policies.md) | What each agent may do |

### Self-hosted sandboxes

Self-hosted sandboxes move tool execution out of Anthropic-managed cloud
containers and into infrastructure you control, while keeping
orchestration on Anthropic's side. Use them when the agent must operate
on data that cannot leave your network boundary, reach internal services
that are not publicly routable, or run under your own compliance and
audit controls.

Not yet available on Claude Platform on AWS.

| | Cloud environment | Self-hosted sandbox |
|---|---|---|
| Where tools run | Anthropic-managed containers | Your infrastructure |
| Network reach | Anthropic's egress controls | Your network policy |
| File / GitHub repo mounting | Managed by Anthropic | Managed by you |
| Lifecycle | Managed by Anthropic | Managed by you |

> **Memory is not yet supported with self-hosted sandboxes.**

**Relationship to MCP tunnels:** self-hosting controls *where the
agent's code executes*; [MCP Tunnels](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/overview.md)
controls *how Anthropic reaches MCP servers in your network*. They are
independent and can be combined: a self-hosted session can still use
tunneled or public MCP servers.

#### Environment worker

An **environment worker** is a process you run on your own
infrastructure. It polls the `self_hosted` environment's work queue,
claims session work items, downloads the agent's skills, runs tool
calls locally, and posts results back to Anthropic.

Two worker patterns:

| Pattern | How |
|---|---|
| **Always-on** | Worker polls continuously — `ant beta:worker poll` or `EnvironmentWorker.run()` |
| **Webhook-triggered** | Wakes on `session.status_run_started`, handles one session, exits |

Platform-specific guides are available for Cloudflare, Daytona, Modal,
and Vercel (linked from the source page). For full control, implement
against the [Environments Work endpoints](https://platform.claude.com/docs/en/api/beta/environments/work) directly.

#### Worker environment variables

| Variable | Purpose |
|---|---|
| `ANTHROPIC_ENVIRONMENT_KEY` | Authenticates the worker with its environment (`sk-ant-oat01-...`) |
| `ANTHROPIC_ENVIRONMENT_ID` | Environment to poll for work (`env_...`) |
| `ANTHROPIC_SESSION_ID` | Passed to spawn scripts for container-per-session patterns |
| `ANTHROPIC_WORK_ID` | Work item ID, used with `work.stop` from operations tooling |
| `ANTHROPIC_WEBHOOK_SIGNING_KEY` | Webhook signature verification (webhook-triggered pattern only) |

#### Sandbox filesystem

| Path | Purpose |
|---|---|
| `/workspace` | Default working directory; skills downloaded to `/workspace/skills/<name>/` |
| `/mnt/session/outputs` | Agent writes final output files here; mount a host directory to retrieve them |

Required system dependencies in the container image: `/bin/bash`.
TypeScript SDK additionally requires `unzip`, `tar`, and Node.js 22+.

#### SDK helpers (Python / TypeScript / Go)

| Helper | Purpose |
|---|---|
| `EnvironmentWorker` | Out-of-the-box: polls, downloads skills, executes tools, posts results |
| `work.poller()` | Low-level: yields each claimed work item; use when launching per-session containers |
| `tool_runner()` | Runs tool calls for a single already-claimed session |

#### Queue monitoring

`work.stats` returns `depth` (items waiting), `pending` (items claimed
and in-flight), `oldest_queued_at`, and `workers_polling` (liveness
signal: workers that polled in the last 30 s). Authenticate monitoring
calls with your org API key, not the environment key.

`work.stop` gracefully drains the session a worker is handling; pass
`force: true` to interrupt immediately.

#### Security responsibilities

You own:
- Container image quality and runtime hardening (non-root user, minimal capabilities, read-only root FS)
- Network egress controls — without restrictions a compromised tool execution can reach arbitrary external hosts
- `ANTHROPIC_ENVIRONMENT_KEY` storage and rotation (treat like a database password; rotate immediately if compromised)
- Isolating untrusted workloads — provision a separate environment per trust boundary
- Log retention and session content — data outside Anthropic's lifecycle controls once delivered to your worker

Anthropic cannot instantly revoke a leaked key, verify your container build, or sandbox tools inside your container.

Source pages:
[`self-hosted-sandboxes.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes.md) ·
[`self-hosted-sandboxes-security.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security.md)

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

22 source pages under
[`https://platform.claude.com/docs/en/managed-agents/`](https://platform.claude.com/docs/en/managed-agents/).

---

*Source pages: 22 under `platform.claude.com/docs/en/managed-agents/`.*
