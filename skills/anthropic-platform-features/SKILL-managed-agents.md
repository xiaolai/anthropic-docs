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
  via the environments resource.
- **Self-hosted sandboxes** keep tool execution in your own
  infrastructure while Anthropic handles orchestration. Good for data
  that cannot leave your network, internal services not publicly
  routable, or your own compliance controls. Not yet available on
  Claude Platform on AWS. Workers authenticate with an environment
  service key (`ANTHROPIC_ENVIRONMENT_KEY`); use the `ant` CLI or SDK
  `EnvironmentWorker`. Memory stores are not yet supported in
  self-hosted sandboxes.
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
| [`sessions.md`](https://platform.claude.com/docs/en/managed-agents/sessions.md) | Session lifecycle |
| [`permission-policies.md`](https://platform.claude.com/docs/en/managed-agents/permission-policies.md) | What each agent may do |

## Self-hosted sandboxes

Run tool execution in your own infrastructure while Anthropic's
control plane handles orchestration. Sessions are assigned to a
`self_hosted` environment; an **environment worker** you run polls
Anthropic's work queue, claims sessions, downloads skills, executes
tool calls locally, and posts results back.

> **Not yet available** on Claude Platform on AWS.

### Worker architecture

| Pattern | How |
|---|---|
| **Always-on (ant CLI)** | `ant beta:worker poll --workdir /workspace`. Exits cleanly on SIGTERM. |
| **Always-on (SDK)** | `EnvironmentWorker(...).run()` — Python, TypeScript, Go. |
| **Container-per-session** | `ant beta:worker poll --on-work ./spawn.sh` or `work.poller()` in the SDK; spawn a fresh container per claimed session for stronger isolation. |
| **Webhook-triggered (SDK)** | Subscribe to `session.status_run_started`; run `EnvironmentWorker.handle_item()` per event. |

### Filesystem layout

| Path | Purpose |
|---|---|
| `/workspace` | Default `--workdir`; skills downloaded to `/workspace/skills/<name>/` |
| `/mnt/session/outputs` | Agent writes final output files here; mount a host directory to retrieve them |

### Creating a self-hosted environment

```bash
# CLI
ant beta:environments create --name self-hosted --config '{"type": "self_hosted"}'

# cURL
curl https://api.anthropic.com/v1/environments \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "anthropic-beta: managed-agents-2026-04-01" \
  -H "content-type: application/json" \
  -d '{"name": "self-hosted", "config": {"type": "self_hosted"}}'
```

After creating the environment, generate an **environment key**
(`sk-ant-oat01-...`) in the Console and export it as
`ANTHROPIC_ENVIRONMENT_KEY` on the worker host. The environment key
authenticates only that environment's work queue — do not expose it
alongside your org API key on the same host.

### Monitoring

| Endpoint | Purpose |
|---|---|
| `work.stats` | Queue depth, pending items, oldest queued timestamp, workers polling in last 30 s |
| `work.stop` | Gracefully stop a session (or force-stop with `"force": true`) |

Use your **org API key** for these monitoring calls, not the environment key.

### SDK helpers (`anthropic.lib.environments`)

| Helper | When to use |
|---|---|
| `EnvironmentWorker` | Out-of-the-box: handles polling, skill download, tool execution end-to-end |
| `work.poller()` | Custom per-session logic (e.g. launch a container); set `drain=True` to stop when queue is empty |
| `tool_runner()` / `AgentToolContext` + `beta_agent_toolset_20260401()` | Custom tool execution after claiming a session manually |

`EnvironmentWorker` is available in Python, TypeScript, and Go SDKs.
Other SDKs can use the [Environments Work API endpoints](https://platform.claude.com/docs/en/api/beta/environments/work) directly.

### Source pages

| Page | Topic |
|---|---|
| [`self-hosted-sandboxes.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes.md) | Full guide: worker patterns, filesystem, session creation, reference, monitoring |
| [`self-hosted-sandboxes-security.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security.md) | Shared responsibility model — what Anthropic secures vs. what you own |

Third-party platform guides available for Cloudflare, Daytona, Modal, and Vercel.

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
