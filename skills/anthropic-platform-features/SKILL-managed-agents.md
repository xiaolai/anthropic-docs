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
| [`self-hosted-sandboxes.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes.md) | Run agent sessions in your own infrastructure |
| [`self-hosted-sandboxes-security.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security.md) | Shared responsibility model for self-hosted sandboxes |
| [`sessions.md`](https://platform.claude.com/docs/en/managed-agents/sessions.md) | Session lifecycle |
| [`permission-policies.md`](https://platform.claude.com/docs/en/managed-agents/permission-policies.md) | What each agent may do |

### Self-hosted sandboxes

By default, Managed Agents executes tools and code inside
Anthropic-managed cloud containers. **Self-hosted sandboxes** keep the
orchestration on Anthropic's side but move tool execution into
infrastructure you control — the agent's code, filesystem, and network
egress never leave your environment.

Not yet available on Claude Platform on AWS.

#### How it differs from cloud containers

| | Cloud container | Self-hosted sandbox |
|---|---|---|
| Where tools run | Anthropic-managed | Your infrastructure |
| Network reach | Anthropic's egress controls | Your network policy |
| File / GitHub repo mounting | Managed by Anthropic | Managed by you |
| Lifecycle | Managed by Anthropic | Managed by you |

#### Relationship to MCP Tunnels

Self-hosting controls *where the agent's code executes*. MCP Tunnels
controls *how Anthropic reaches MCP servers in your network*. They are
independent and composable: a cloud-container session can reach private
MCP servers through a tunnel; a self-hosted session can use tunneled or
public MCP servers.

#### Environment worker

An **environment worker** is a process you run on your own
infrastructure that receives tool execution requests from Anthropic and
runs them locally. The `self_hosted` environment acts as a work queue:
when a session is assigned, Anthropic enqueues a work item; your worker
claims it, downloads the agent's skills, runs tool calls, and posts
results back.

Worker patterns:

| Pattern | CLI support | SDK support |
|---|---|---|
| **Always-on** — polls continuously | `ant beta:worker poll` | `EnvironmentWorker.run()` |
| **Webhook-triggered** — wakes on `session.status_run_started` | ✗ | `EnvironmentWorker.handle_item()` + `work.poller()` |

**Sandbox filesystem:**
- `/workspace` — default working directory; skills downloaded to `/workspace/skills/<name>/`
- `/mnt/session/outputs` — agent writes final output files here

**Creating a self-hosted environment:**

```bash
curl -sS https://api.anthropic.com/v1/environments \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "anthropic-beta: managed-agents-2026-04-01" \
  -H "content-type: application/json" \
  -d '{"name": "self-hosted", "config": {"type": "self_hosted"}}'
```

The environment key (`ANTHROPIC_ENVIRONMENT_KEY`) — generated in the
Console — authenticates the worker to the work queue. It is scoped to
one environment; do not set `ANTHROPIC_API_KEY` on the worker host
alongside it.

**Worker CLI flags (`ant beta:worker poll`):**

| Flag | Description |
|---|---|
| `--environment-id` | Environment to poll (also `ANTHROPIC_ENVIRONMENT_ID`) |
| `--environment-key` | Authenticates the worker (also `ANTHROPIC_ENVIRONMENT_KEY`) |
| `--workdir` | Root for skills and tool I/O (default `/workspace`) |
| `--on-work` | Script called per session instead of in-process execution |
| `--unrestricted-paths` | Allow tool access outside `--workdir` |
| `--max-idle` | Idle timeout before shutdown (default `60s`) |
| `--log-format` | `text` or `json` (default `text`) |

**SDK helpers:**
- `EnvironmentWorker` — end-to-end polling, setup, and execution
- `work.poller()` — low-level iterator over claimed sessions (use to
  launch per-session containers)
- `tool_runner()` / `AgentToolContext` — execution layer only

**Container isolation pattern:** run `ant beta:worker run` (or the SDK
equivalent) as the container entrypoint. A spawn script launched by
`--on-work` starts a fresh container per session, forwarding
`ANTHROPIC_SESSION_ID`, `ANTHROPIC_ENVIRONMENT_KEY`, `ANTHROPIC_WORK_ID`.

**Monitoring:**
- `work.stats` — returns queue `depth`, `pending`, `oldest_queued_at`,
  `workers_polling`. Use for autoscaling and liveness alerting.
- `work.stop` — gracefully drains a session (`force: true` to interrupt
  immediately). Authenticated with your org API key, not the environment
  key.

**Limitations:**
- Memory stores not yet supported with self-hosted sandboxes.
- Not available on Claude Platform on AWS.

Sources: [`self-hosted-sandboxes.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes.md),
[`self-hosted-sandboxes-security.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security.md).

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
