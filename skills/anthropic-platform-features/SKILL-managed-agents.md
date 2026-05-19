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
| [`cloud-containers.md`](https://platform.claude.com/docs/en/managed-agents/cloud-containers.md) | Container-backed agent runtime (Anthropic-managed) |
| [`self-hosted-sandboxes.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes.md) | Run tool execution in your own infrastructure |
| [`self-hosted-sandboxes-security.md`](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security.md) | Shared responsibility model for self-hosted sandboxes |
| [`sessions.md`](https://platform.claude.com/docs/en/managed-agents/sessions.md) | Session lifecycle |
| [`permission-policies.md`](https://platform.claude.com/docs/en/managed-agents/permission-policies.md) | What each agent may do |

### Self-hosted sandboxes

By default Managed Agents executes tools inside Anthropic-managed cloud
containers. **Self-hosted sandboxes** keep orchestration on Anthropic's
side but move tool execution into **infrastructure you control** — the
agent's code, filesystem, and network egress never leave your environment.

> **Not yet available on Claude Platform on AWS.**

| | Cloud environment | Self-hosted sandbox |
|---|---|---|
| Where tools run | Anthropic-managed containers | Your infrastructure |
| Network reach | Anthropic's egress controls | Your network policy |
| File/repo mounting | Managed by Anthropic | Managed by you |
| Lifecycle | Managed by Anthropic | Managed by you |

Self-hosting is the right choice when the agent must operate on data
that cannot leave your network boundary, reach internal services that
are not publicly routable, or run under your own compliance and audit
controls.

**Combine with MCP Tunnels** when you want both execution *and* tool
access to stay inside your boundary. They are independent: a self-hosted
session can use either tunneled or public MCP servers.

#### Environment worker

An **environment worker** is a process you run on your own
infrastructure. It polls an `env_...` work queue, claims sessions,
downloads agent skills, runs tool calls locally, and posts results back.

Two polling patterns:

- **Always-on** — worker polls continuously.
- **Webhook-triggered** — handler wakes on `session.status_run_started`,
  then drains the queue for that session.

Pre-built workers are available in the `ant` CLI and the Anthropic SDK
(Python, TypeScript, Go). The `ant` CLI supports always-on only; the SDK
supports both patterns.

SDK requirements: `/bin/bash` at that exact path. TypeScript SDK
additionally requires `unzip`, `tar`, and Node.js 22+.

**Sandbox filesystem paths:**

| Path | Purpose |
|---|---|
| `/workspace` | Default working dir; skills downloaded to `/workspace/skills/<name>/` |
| `/mnt/session/outputs` | Agent final output files; mount a host dir here to retrieve them |

**Environment key** (`ANTHROPIC_ENVIRONMENT_KEY` / `sk-ant-oat01-...`):
authorizes polling the work queue and submitting results. Store in a
secrets manager; never bake into images. See the
[security model](https://platform.claude.com/docs/en/managed-agents/self-hosted-sandboxes-security.md)
for full shared-responsibility details.

**`ant` CLI worker flags:**

| Flag | Description |
|---|---|
| `--workdir` | Download dir for skills and tool read/write root. Default `/workspace`. |
| `--on-work` | Script called per claimed session (for container-per-session isolation). |
| `--unrestricted-paths` | Allow tool calls outside `--workdir`. |
| `--max-idle` | Idle shutdown timeout after `end_turn`. Default `60s`. |
| `--log-format` | `text` or `json`. Default `text`. |

**Platform-specific sandbox guides** (community/partner):
[Cloudflare](https://developers.cloudflare.com/sandbox/claude-managed-agents/),
[Daytona](https://www.daytona.io/docs/en/guides/claude/claude-managed-agents),
[Modal](https://github.com/modal-projects/claude-managed-agents-modal-sandbox),
[Vercel](https://vercel.com/kb/guide/run-claude-managed-agent-tools-with-vercel-sandbox).

**Monitoring — `work.stats` fields:** `depth` (queue backlog), `pending`
(in-flight items), `oldest_queued_at`, `workers_polling` (active workers
in last 30 s). Use `work.stop` (with optional `force: true`) to drain a
session gracefully from operations tooling (authenticates with your org
API key, **not** the environment key).

> **Memory not yet supported** with self-hosted sandboxes.

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
