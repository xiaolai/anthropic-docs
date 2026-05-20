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
- **Cloud containers** are the default execution sandbox for code-running
  agents. Limited CPU / memory / network egress. Configure per agent
  via the environments resource. See also **self-hosted sandboxes** if
  your data cannot leave your own infrastructure.
- **Self-hosted sandboxes** keep orchestration on Anthropic's side but
  move tool execution into infrastructure you control — your network
  policy, filesystem, and egress rules apply. Not yet available on
  Claude Platform on AWS. Use with MCP tunnels when you need both
  execution and tool access to stay inside your boundary.
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
| [`cloud-containers.md`](https://platform.claude.com/docs/en/managed-agents/cloud-containers.md) | Container-backed agent runtime (Anthropic-managed) |
| [`self-hosted-sandboxes.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes.md) | Run agent tool execution in your own infrastructure via an environment worker |
| [`self-hosted-sandboxes-security.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security.md) | Shared responsibility model for self-hosted sandbox environments |
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

## Self-hosted sandboxes

By default Managed Agents executes tools in Anthropic-managed cloud
containers. Self-hosted sandboxes move tool execution to infrastructure
you control while Anthropic's orchestration layer remains on Anthropic's
side.

**When to use:** agent needs to operate on data that cannot leave your
network, reach internal services not publicly routable, or run under
your own compliance / audit controls.

**Not yet available** on Claude Platform on AWS.

### Environment worker

An environment worker is a process you run on your own infrastructure
that claims sessions from the environment's work queue, downloads the
agent's skills, runs tool calls locally, and posts results back.

Two worker architectures:

| Architecture | How |
|---|---|
| **Always-on** | Worker polls continuously. Supported by `ant beta:worker poll` CLI and `EnvironmentWorker` SDK helper. |
| **Webhook-triggered** | Handler wakes on `session.status_run_started` event, then claims and executes the session. Supported by SDK only. |

Setup steps (all architectures):
1. Create a `self_hosted` environment via Console or API (`POST /v1/environments` with `config.type: "self_hosted"` + beta header `managed-agents-2026-04-01`).
2. Generate an environment key in the Console. Export `ANTHROPIC_ENVIRONMENT_KEY` and `ANTHROPIC_ENVIRONMENT_ID`.
3. Run the worker pointing at `--workdir /workspace` (skills are downloaded to `/workspace/skills/<name>/`). Final output files go to `/mnt/session/outputs`.

### Sandbox filesystem

| Path | Purpose |
|---|---|
| `/workspace` | Default working directory; skills download to `/workspace/skills/<name>/` |
| `/mnt/session/outputs` | Agent's final output files (mount a host directory here to retrieve) |

### Monitoring the worker fleet

`work.stats` (authenticated with your API key, not the environment key)
returns `depth` (queued items), `pending` (in-flight), `oldest_queued_at`,
and `workers_polling` (liveness, last 30 seconds).

Use `work.stop` to gracefully drain a session. Pass `force: true` to
interrupt immediately.

> **Security note:** Call monitoring endpoints from outside the worker
> host. `ANTHROPIC_API_KEY` on the worker host exposes an org-scoped
> credential to agent tool calls. Workers authenticate with the narrower
> `ANTHROPIC_ENVIRONMENT_KEY` instead.

### Self-hosted sandbox security (shared responsibility)

Your organization owns:
- Container image quality and runtime hardening (non-root, read-only root fs, drop capabilities)
- Network egress controls (restrict to only required endpoints)
- Environment service key storage and rotation (treat like a database password)
- Isolating untrusted workloads (one workspace/environment per trust boundary)
- Tool-execution blast radius (least privilege on process user, restrict mounts)
- Log retention and session content (outside Anthropic's data lifecycle once delivered)

Anthropic handles: session and work queue integrity, multi-tenant isolation, agent-context minimization.

See [`self-hosted-sandboxes-security.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security.md).

## Dreams (long-running)

| Page | Topic |
|---|---|
| [`dreams.md`](https://platform.claude.com/docs/en/managed-agents/dreams.md) | "Dreams" — long-running agent jobs that execute over hours/days |

## Page index

22 source pages under
[`https://platform.claude.com/docs/en/managed-agents/`](https://platform.claude.com/docs/en/managed-agents/).

---

*Source pages: 22 under `platform.claude.com/docs/en/managed-agents/`.*
