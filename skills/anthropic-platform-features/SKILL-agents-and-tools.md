---
name: anthropic-agents-and-tools
description: |
  Deep reference for the platform-side agents-and-tools surface —
  Agent Skills format spec (filesystem-based skills with three-level
  progressive disclosure), MCP connector (Anthropic's hosted MCP
  server), remote MCP servers (connecting third-party MCP from the
  API), and the full tool-use catalog (computer use, code execution,
  bash, text editor, memory, advisor, server tools, define-your-own
  tools, parallel/programmatic/strict tool use, fine-grained tool
  streaming, tool combinations).
source: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md
---

# Platform — Agents & Tools

> *Router lives in [`SKILL.md`](SKILL.md). For raw Messages API
> (POST /v1/messages), see [`anthropic-api`](../anthropic-api/SKILL.md).
> For Claude Code's tool use, see [`claude-code`](../claude-code/SKILL.md).*

## Agent Skills

Agent Skills are modular capabilities that extend Claude. Each
skill packages instructions, metadata, and optional resources
(scripts, templates) into a directory; Claude uses them
automatically when relevant.

### Three-level progressive disclosure

| Level | When loaded | Content |
|---|---|---|
| **1: Metadata** | Always, at startup | `name` + `description` from YAML frontmatter |
| **2: Instructions** | When triggered | SKILL.md body — workflows, procedures |
| **3: Resources / code** | On demand | Additional markdown, scripts (run via bash) |

This filesystem-based architecture means installing many skills
costs little context — Claude only sees the frontmatter until a
skill is actually triggered.

### Pre-built skills

Anthropic ships pre-built skills for PowerPoint, Excel, Word, PDF
processing. Available on claude.ai, the API, Claude Platform on
AWS, and Microsoft Foundry.

### Custom skills

Create your own:

- **In Claude Code** — drop a directory under `~/.claude/skills/`.
- **Via the API** — upload through the Skills API.
- **In claude.ai** — add via Settings.
- **On AWS / Foundry** — upload through the Skills API.

### Best practices

Long-form guidance at
[`agent-skills/best-practices.md`](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md)
(41KB — covers naming conventions, description writing,
progressive-disclosure design, when to bundle code vs prose).

### Source pages

| Page | Topic |
|---|---|
| [`agent-skills/overview.md`](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview.md) | What skills are, three-level loading |
| [`agent-skills/quickstart.md`](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/quickstart.md) | First-skill walkthrough |
| [`agent-skills/best-practices.md`](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.md) | Authoring guide |
| [`agent-skills/enterprise.md`](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise.md) | Enterprise distribution patterns |

## MCP integrations

### MCP connector (Anthropic-hosted)

Anthropic's hosted MCP server, accessible from the API. Lets API
consumers use the same MCP-style tool exposure without running their
own server.

Source: [`mcp-connector.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-connector.md).

### Remote MCP servers

Connect to third-party MCP servers (your own or community) from API
calls. Tools surface to the LLM in the same way as Anthropic-built
tools.

Source: [`remote-mcp-servers.md`](https://platform.claude.com/docs/en/agents-and-tools/remote-mcp-servers.md).

For deep MCP protocol details, see [`mcp-spec`](../mcp-spec/SKILL.md).

### MCP tunnels (Research Preview)

Securely connect Claude to MCP servers running in your **private
network** without opening inbound firewall ports or exposing services
to the public internet. Traffic flows over an outbound-only encrypted
connection.

> **Status:** Research Preview — request access at
> <https://claude.com/form/claude-managed-agents>. Provided as-is,
> backed by Cloudflare's network transport. Anthropic may modify or
> discontinue at any time.

#### How it works

A tunnel deployment is two components running inside your network:

| Component | Role |
|---|---|
| **cloudflared** | Outbound-only tunnel agent; initiates connection to the Anthropic-operated tunnel edge |
| **Proxy** | Anthropic's routing component; terminates inner TLS, validates IPs, routes requests to the correct upstream MCP server by hostname |

Each exposed MCP server gets a subdomain under your tunnel domain (e.g.
`docs.<tunnel-domain>`). You attach these to a Managed Agent session in
the Console or pass them to the Messages API via the MCP connector.

#### Security model

Three independent layers protect every request:

| Layer | Protects against |
|---|---|
| Outer mTLS between Anthropic and the transport provider, with IP validation | Unauthorized clients reaching the tunnel |
| Inner TLS from Anthropic's backend to your proxy | Payload inspection by the transport provider (Cloudflare) or any intermediary |
| OAuth on each upstream MCP server | Unauthorized use of MCP tools by authenticated tunnel traffic |

Cloudflare provides the transport and cannot read request/response
payloads because the proxy terminates inner TLS using a certificate only
you hold. Cloudflare does receive connection metadata (egress IP,
tunnel subdomain, timing, byte-volume).

> **Warning:** If an attacker obtains both your tunnel token *and* a
> TLS private key, they can impersonate your proxy. Treat both as
> high-value secrets.

#### Prerequisites

- A Kubernetes cluster, or a VM with Docker Compose.
- A tunnel created in the Claude Console (see
  [`mcp-tunnels/console.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/console.md)).
- Authentication to the Tunnels API — either:
  - **Programmatic (recommended):** Workload Identity Federation
    (`org:manage_tunnels` scope) for short-lived tokens.
  - **Manual:** static tunnel token + server certificate from a CA you
    register in the Console.
- One or more MCP servers reachable within your private network.
- Outbound connectivity:

| Component | Destination | Port / protocol |
|---|---|---|
| Setup | `api.anthropic.com` | 443 TCP |
| cloudflared | Tunnel edge (`198.41.192.0/19`, `2606:4700:a0::/44`) | 7844 TCP+UDP |
| Proxy | Your upstream MCP servers | As configured |

#### Deployment options

| Method | Use when |
|---|---|
| [`mcp-tunnels/quickstart.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/quickstart.md) | Local testing with Docker Compose |
| [`mcp-tunnels/deploy-compose.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/deploy-compose.md) | Single host / VM with Docker Compose |
| [`mcp-tunnels/deploy-helm.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/deploy-helm.md) | Kubernetes via Anthropic Helm chart |

Use **programmatic access (WIF)** when you have an OIDC identity
provider; **manual credentials** when you don't.

#### Using tunneled servers

Once the tunnel is active (active CA certificate, stack connected),
the routed MCP servers are available from Managed Agents and the
Messages API. Tunneled servers are **not** available as connectors in
claude.ai.

**Managed Agents (Console):** In Managed Agents > Sessions, create a
session, click **+ MCP Server**, and select the tunnel from the
dropdown. Supply the subdomain and path for the target MCP server.

**Messages API:** Pass the routed URL in `mcp_servers[]` the same as
any other remote MCP server. Use `anthropic-beta: mcp-client-2025-11-20`.
The host is `<subdomain>.<tunnel-domain>`.

#### Sub-pages

| Page | Topic |
|---|---|
| [`mcp-tunnels/overview.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/overview.md) | Architecture, security model, prerequisites, usage |
| [`mcp-tunnels/console.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/console.md) | Creating a tunnel and managing CA certificates in the Console |
| [`mcp-tunnels/quickstart.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/quickstart.md) | Shortest path to a working tunnel (Docker Compose + sample server) |
| [`mcp-tunnels/deploy-compose.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/deploy-compose.md) | Production Docker Compose deployment |
| [`mcp-tunnels/deploy-helm.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/deploy-helm.md) | Kubernetes Helm chart deployment |
| [`mcp-tunnels/security.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/security.md) | Hardening, credential rotation, breach response |
| [`mcp-tunnels/troubleshooting.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/troubleshooting.md) | Diagnosing connectivity, TLS, and routing issues |
| [`mcp-tunnels/reference.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-tunnels/reference.md) | Proxy config fields, Tunnels API, certificate requirements, setup CLI |

## Tool use catalog

The full tool-use surface lives under
[`tool-use/`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/).

### Canonical tool-definition shape

This is the validated reference shape for a tool entry passed to
`POST /v1/messages` in the `tools: []` array. The schema at
[`pipeline/schema/anthropic-tool.schema.json`](../../pipeline/schema/anthropic-tool.schema.json)
enforces it via `validate-examples.sh`:

```json
{
  "name": "search_files",
  "description": "Search files in the user's project matching a query string. Returns an array of paths with snippets.",
  "input_schema": {
    "type": "object",
    "properties": {
      "query": { "type": "string" },
      "max_results": { "type": "integer", "minimum": 1, "maximum": 100 }
    },
    "required": ["query"]
  }
}
```

Common mistakes (see [`rules/tool-use.md`](rules/tool-use.md)):
- `input_schema` missing `type: "object"` at the top level → 400
- `required` array omitted → all params silently optional
- `name` too long (max 64 chars) or with disallowed chars → 400

### Optional tool definition properties

Every tool in the `tools` array accepts these optional properties (they
compose — you can combine any of them on the same tool). Source:
[`tool-use/tool-reference.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-reference.md).

| Property | Purpose | Available on |
|---|---|---|
| `cache_control` | Prompt-cache breakpoint at this tool definition | All tools |
| `strict` | Grammar-constrained sampling — guarantees inputs match `input_schema` | All tools except `mcp_toolset` |
| `defer_loading` | Exclude from initial system prompt; expand inline when tool search returns a `tool_reference` for it. Preserves prompt cache across tool additions. | All tools (MCP: see connector config) |
| `allowed_callers` | Restrict callers: `"direct"` (default, model calls directly) or `"code_execution_20260120"` (callable only from code sandbox). Response's `tool_use` block gains a `caller` field. | All tools except `mcp_toolset` |
| `input_examples` | Array of example input objects (must validate against `input_schema`) to help Claude call the tool correctly | User-defined + Anthropic-schema client tools; **not** server tools |
| `eager_input_streaming` | Fine-grained per-input streaming (`true`) vs. standard buffered streaming (`false`) | User-defined tools only |

### tool_choice compatibility notes

- **Extended thinking + forced tool_choice:** `tool_choice: {"type": "any"}` and
  `tool_choice: {"type": "tool", "name": "..."}` are **not supported** when extended
  thinking is enabled. Only `"auto"` (default) and `"none"` are compatible. Using
  an incompatible combination returns an error.
- **Claude Mythos Preview:** forced tool use (`"any"` or `"tool"`) returns a 400.
  Use `"auto"` or `"none"` and rely on prompting to steer tool selection.

Source: [`tool-use/define-tools.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools.md).

### Conceptual foundation

| Page | Topic |
|---|---|
| [`tool-use/overview.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/overview.md) | Tool use overview |
| [`tool-use/how-tool-use-works.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/how-tool-use-works.md) | Request/response lifecycle |
| [`tool-use/handle-tool-calls.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/handle-tool-calls.md) | Round-tripping tool_use / tool_result |
| [`tool-use/define-tools.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/define-tools.md) | input_schema, tool_choice, descriptions |
| [`tool-use/tool-reference.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-reference.md) | Tool-block reference |

### Anthropic-built tools

| Tool | `type` string(s) | Kind | Status | Page |
|---|---|---|---|---|
| **Web search** | `web_search_20260209`, `web_search_20250305` | Server | GA | [`web-search-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-search-tool.md) |
| **Web fetch** | `web_fetch_20260209`, `web_fetch_20250910` | Server | GA | [`web-fetch-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-fetch-tool.md) |
| **Code execution** | `code_execution_20260120`, `code_execution_20250825` | Server | GA | [`code-execution-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/code-execution-tool.md) |
| **Advisor** | `advisor_20260301` | Server | Beta: `advisor-tool-2026-03-01` | [`advisor-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool.md) |
| **Tool search** | `tool_search_tool_regex_20251119`, `tool_search_tool_bm25_20251119` | Server | GA | [`tool-search-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool.md) |
| **MCP connector** | `mcp_toolset` | Server | Beta: `mcp-client-2025-11-20` | [`mcp-connector.md`](https://platform.claude.com/docs/en/agents-and-tools/mcp-connector.md) |
| **Memory** | `memory_20250818` | Client | GA | [`memory-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool.md) |
| **Bash** | `bash_20250124` | Client | GA | [`bash-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/bash-tool.md) |
| **Text editor** | `text_editor_20250728` (Claude 4), `text_editor_20250124` (earlier) | Client | GA | [`text-editor-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/text-editor-tool.md) |
| **Computer use** | `computer_20251124`, `computer_20250124` | Client | `computer-use-2025-11-24` for `computer_20251124` (Opus 4.7/4.6, Sonnet 4.6, Opus 4.5); `computer-use-2025-01-24` for `computer_20250124` (Sonnet 4.5, Haiku 4.5, Opus 4.1, and deprecated models) | [`computer-use-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool.md) |

> **Computer use beta headers:** two versions, two headers. Use `anthropic-beta: computer-use-2025-11-24` with `computer_20251124` on current models; use `computer-use-2025-01-24` with `computer_20250124` on older/deprecated models. Source: [`computer-use-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool.md).

> **Computer use — `enable_zoom` (`computer_20251124` only):** Pass `"enable_zoom": true` in the tool definition to enable the **zoom** action, which lets Claude inspect a screen region at full resolution. Syntax: `{"action": "zoom", "region": [x1, y1, x2, y2]}`. Default is `false`. Source: [`computer-use-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool.md).

**Server** tools execute on Anthropic's infrastructure; **Client** tools define the schema but your app handles execution. Source: [`tool-use/tool-reference.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-reference.md).

> **Tool versioning:** `_YYYYMMDD` suffix identifies a tool version. Older versions remain available; pick the newer one for new capabilities (e.g. `code_execution_20260120` adds programmatic tool calling vs `code_execution_20250825`). `text_editor_20250728` is for Claude 4 models; `text_editor_20250124` for earlier models. Tool search types are variants, not versions — neither supersedes the other. Tool search also accepts undated aliases `tool_search_tool_regex` and `tool_search_tool_bm25` which resolve to the latest dated version.

### Server tool response mechanics

When a server tool executes, the response includes a `server_tool_use` block (prefix `srvtoolu_`), distinct from client `tool_use` blocks (prefix `toolu_`). The API runs the tool internally and includes the result in the same assistant turn — **you do not respond with `tool_result`** for server tools.

For long-running server tool operations the API may return `stop_reason: "pause_turn"`. Resume by appending the paused assistant content as the next assistant turn and calling the API again with the same tools. Source: [`tool-use/server-tools.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/server-tools.md).

### Advanced patterns

| Topic | Page |
|---|---|
| **Parallel tool use** | [`tool-use/parallel-tool-use.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/parallel-tool-use.md) |
| **Programmatic tool calling** | [`tool-use/programmatic-tool-calling.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling.md) |
| **Strict tool use** | [`tool-use/strict-tool-use.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/strict-tool-use.md) |
| **Fine-grained tool streaming** | [`tool-use/fine-grained-tool-streaming.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/fine-grained-tool-streaming.md) |
| **Tool combinations** | [`tool-use/tool-combinations.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-combinations.md) |
| **Tool search** | [`tool-use/tool-search-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool.md) |
| **Tool runner** | [`tool-use/tool-runner.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-runner.md) |
| **Manage tool context** | [`tool-use/manage-tool-context.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/manage-tool-context.md) |
| **Tool use with prompt caching** | [`tool-use/tool-use-with-prompt-caching.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-use-with-prompt-caching.md) |
| **Troubleshooting tool use** | [`tool-use/troubleshooting-tool-use.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/troubleshooting-tool-use.md) |
| **Build a tool-using agent** | [`tool-use/build-a-tool-using-agent.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/build-a-tool-using-agent.md) |

---

*Source pages: 39 under `platform.claude.com/docs/en/agents-and-tools/`
(agent-skills/* + mcp-connector + remote-mcp-servers + mcp-tunnels/* + tool-use/*).*
