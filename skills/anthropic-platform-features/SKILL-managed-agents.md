---
name: anthropic-managed-agents
description: |
  Deep reference for the Managed Agents product — Anthropic-hosted
  long-running agents (Dreams) with their own environments, sessions,
  files, memory, vaults, tools, MCP connectors, multi-agent
  coordination, webhooks, GitHub integration, permission policies,
  and event streaming. Covers onboarding through to production
  deployment with cloud containers or self-hosted sandboxes (run tool
  execution on your own infrastructure).
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
- **Self-hosted sandboxes** move tool execution into infrastructure you
  control while Anthropic's orchestration remains on the control plane.
  Use when the agent must operate on data that cannot leave your network
  boundary or needs to reach internal services. Not yet available on
  Claude Platform on AWS. See the [Self-hosted sandboxes](#self-hosted-sandboxes) section below.
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

## Self-hosted sandboxes

By default Managed Agents executes tools inside Anthropic-managed cloud
containers. Self-hosted sandboxes keep orchestration on Anthropic's side but
move tool execution into infrastructure you control — the agent's code,
filesystem, and network egress never leave your environment.

Source pages: [`self-hosted-sandboxes.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes.md) and [`self-hosted-sandboxes-security.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security.md).

### Cloud vs self-hosted comparison

| | Cloud environment | Self-hosted sandbox |
|---|---|---|
| Where tools run | Anthropic-managed containers | Your infrastructure |
| Network reach | Anthropic's egress controls | Your network policy |
| File / GitHub repo mounting | Managed by Anthropic | Managed by you |
| Lifecycle | Managed by Anthropic | Managed by you |
| Memory stores | Supported | Not yet supported |
| Claude Platform on AWS | Supported | Not yet available |

Self-hosting is a good fit when the agent needs to operate on data that cannot
leave your network boundary, reach internal services not publicly routable, or
run under your organization's own compliance and audit controls.

### When to combine with MCP tunnels

Self-hosted sandboxes control *where the agent's code executes*. MCP tunnels
control *how Anthropic reaches MCP servers in your network*. They are
independent — a cloud-container session can still reach private MCP servers
through a tunnel, and a self-hosted session can use either tunneled or public
MCP servers.

### Environment worker concept

Create a `self_hosted` environment via the API or Console (**Workspace >
Environments > New > Self-hosted**):

```bash
curl https://api.anthropic.com/v1/environments \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "anthropic-beta: managed-agents-2026-04-01" \
  -H "content-type: application/json" \
  -d '{"name": "self-hosted", "config": {"type": "self_hosted"}}'
```

Generate an **environment key** (`sk-ant-oat01-…`) in the Console — this is
scoped only to that environment's work queue, separate from your API key.

An **environment worker** is a process you run that:
1. Polls the environment's work queue for sessions
2. Spawns an execution context for each session
3. Downloads the agent's skills
4. Runs tool calls locally
5. Posts results back to Anthropic's control plane

Two worker patterns:

| Pattern | Mechanism |
|---|---|
| **Always-on** | Worker polls continuously, claims sessions as they arrive |
| **Webhook-triggered** | Handler wakes on `session.status_run_started`, then polls and claims |

### Worker implementations

| Implementation | Languages supported |
|---|---|
| **`ant` CLI** (`ant beta:worker poll`) | Always-on only; all platforms |
| **SDK `EnvironmentWorker`** | Python, TypeScript, Go (always-on + webhook); C#, Java, PHP, Ruby: use CLI |

SDK requirements: `/bin/bash` at that exact path. TypeScript SDK additionally requires `unzip`, `tar`, and Node.js 22+.

**Container-per-session isolation** (stronger): build an image with `ant` and
use `ant beta:worker poll --on-work ./spawn.sh` so each session gets a fresh
filesystem, resource limits, and network controls.

### Sandbox filesystem

| Path | Purpose |
|---|---|
| `/workspace` | Default working directory; skills download to `/workspace/skills/<name>/` |
| `/mnt/session/outputs` | Agent writes final output files here; mount a host directory to retrieve them |

### CLI reference flags

| Flag | Description | Default |
|---|---|---|
| `--environment-id` | Environment to poll (also `ANTHROPIC_ENVIRONMENT_ID`) | Required |
| `--environment-key` | Worker auth key (also `ANTHROPIC_ENVIRONMENT_KEY`) | Required |
| `--workdir` | Directory for tool reads/writes and skill downloads | `/workspace` |
| `--on-work` | Script called once per claimed work item (for container-per-session) | In-process |
| `--unrestricted-paths` | Allow tool calls outside `--workdir` | false |
| `--max-idle` | Wait time after `end_turn` idle before shutdown | `60s` |
| `--log-format` | `text` or `json` | `text` |

### Monitoring

| Operation | How |
|---|---|
| **Queue depth** | `GET /v1/environments/{id}/work/stats` → `depth`, `pending`, `oldest_queued_at`, `workers_polling` |
| **Stop session** | `POST /v1/environments/{id}/work/{work_id}/stop` (pass `force: true` to interrupt immediately) |

> Monitor calls use your org API key, not the environment key. Do not set
> `ANTHROPIC_API_KEY` on the worker host — it would expose an org-scoped
> credential to agent tool calls.

### Security model (self-hosted)

Anthropic secures the control plane (session/queue integrity, multi-tenant
isolation). When you self-host, you own:

- **Container image quality and runtime hardening** (Anthropic does not inspect your image)
- **Network egress controls** (restrict outbound to only required endpoints)
- **Environment key storage and rotation** (store in a secrets manager; rotate immediately if exposed)
- **Isolating untrusted workloads** (provision separate environment per trust boundary)
- **Tool-execution blast radius** (apply least privilege to process user)
- **Log retention and session content** (session content delivered to your worker is outside Anthropic's data lifecycle)

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
