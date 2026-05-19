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
| [`sessions.md`](https://platform.claude.com/docs/en/managed-agents/sessions.md) | Session lifecycle |
| [`permission-policies.md`](https://platform.claude.com/docs/en/managed-agents/permission-policies.md) | What each agent may do |

## Self-Hosted Sandboxes

By default, Managed Agents executes tools and code inside
Anthropic-managed cloud containers. **Self-hosted sandboxes** keep
orchestration on Anthropic's side but move tool execution into
infrastructure you control — the agent's code, filesystem, and network
egress never leave your environment.

> **Not yet available** on Claude Platform on AWS.

### When to use self-hosted vs. cloud containers

| | Cloud environment | Self-hosted sandbox |
|---|---|---|
| Where tools run | Anthropic-managed containers | Your infrastructure |
| Network reach | Anthropic's egress controls | Your network policy |
| File / GitHub repo mounting | Managed by Anthropic | Managed by you |
| Lifecycle | Managed by Anthropic | Managed by you |

Self-hosting is a good fit when the agent needs to operate on data
that cannot leave your network boundary, reach internal services that
are not publicly routable, or run under your own compliance and audit
controls.

### Relationship to MCP tunnels

Self-hosted sandboxes control *where the agent's code executes*.
[MCP tunnels](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/overview.md)
control *how Anthropic reaches MCP servers in your network*. They are
independent and can be combined.

### Environment worker

An **environment worker** is a process you run on your infrastructure
that receives tool execution requests from Anthropic and runs them
locally. It polls a work queue, claims sessions, downloads agent
skills, executes tool calls, and posts results back.

Create a self-hosted environment via the Console (**Workspace >
Environments > New > Self-hosted**) or with
`POST /v1/environments` using `"config": {"type": "self_hosted"}` and
the beta header `managed-agents-2026-04-01`.

#### Sandbox filesystem

| Path | Purpose |
|---|---|
| `/workspace` | Default working directory; skills are downloaded to `/workspace/skills/<name>/` |
| `/mnt/session/outputs` | Agent writes final output files here; mount a host directory to retrieve them |

#### Worker patterns

| Pattern | Tool | When to use |
|---|---|---|
| **Always-on** | `ant beta:worker poll` (CLI) or `EnvironmentWorker.run()` (SDK) | Continuous polling; single host or shared fleet |
| **Container per session** | `ant beta:worker poll --on-work ./spawn.sh` | Stronger isolation — fresh filesystem and network controls per session |
| **Webhook-triggered** | `EnvironmentWorker.handle_item()` (SDK) triggered by `session.status_run_started` | On-demand; no idle workers |

SDK language coverage for `EnvironmentWorker`: Python, TypeScript,
Go. For C#, Java, PHP, Ruby, use the `ant` CLI or the
[Environments Work endpoints](https://platform.claude.com/docs/en/api/beta/environments/work)
directly.

#### Required dependencies (SDK workers)

- `/bin/bash` at that exact path.
- TypeScript SDK additionally requires `unzip`, `tar`, Node.js 22+.

#### Environment keys

The environment service key (`ANTHROPIC_ENVIRONMENT_KEY`, prefix
`sk-ant-oat01-`) authenticates the worker with the work queue. Store
in a secrets manager — not in environment files or container images.
Rotate immediately on suspected exposure.

**Operations tooling** (queue depth, session stop) uses your
organization API key, not the environment key. Do not expose
`ANTHROPIC_API_KEY` on the worker host.

#### Monitoring

`work.stats` returns queue state:

| Field | Meaning |
|---|---|
| `depth` | Items waiting to be claimed |
| `pending` | Items a worker has claimed and is executing |
| `oldest_queued_at` | Timestamp of oldest queued item (null if empty) |
| `workers_polling` | Workers that have polled in the last 30 s |

#### Security responsibilities (self-hosted)

Anthropic secures the control plane (session integrity, multi-tenant
isolation). You own:

- Container image quality and runtime hardening (drop unnecessary
  Linux capabilities, run as non-root, read-only root filesystem).
- Network egress controls (restrict outbound to only required endpoints).
- Environment service key storage and rotation.
- Isolating untrusted workloads (separate workspace/environment per
  trust boundary).
- Tool-execution blast radius (least privilege for the process user).
- Log retention and session content (data outside Anthropic's
  lifecycle controls once delivered to your worker).

### Source pages

| Page | Topic |
|---|---|
| [`self-hosted-sandboxes.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes.md) | Architecture, worker setup, monitoring, operations reference |
| [`self-hosted-sandboxes-security.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security.md) | Shared responsibility model, hardening checklist |

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
