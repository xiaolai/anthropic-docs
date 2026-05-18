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

| Tool | Page | Use case |
|---|---|---|
| **Computer use** | [`tool-use/computer-use-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool.md) | Screen interaction, click/type/screenshot |
| **Code execution** | [`tool-use/code-execution-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/code-execution-tool.md) | Sandboxed Python/shell in a VM |
| **Bash** | [`tool-use/bash-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/bash-tool.md) | Shell command execution |
| **Text editor** | [`tool-use/text-editor-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/text-editor-tool.md) | File edit operations |
| **Memory** | [`tool-use/memory-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool.md) | Persistent memory |
| **Advisor** | [`tool-use/advisor-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool.md) | Self-reflection / planning tool |
| **Server tools** | [`tool-use/server-tools.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/server-tools.md) | Server-side tool exposure pattern |
| **Web fetch** | [`tool-use/web-fetch-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-fetch-tool.md) | Fetch content from URLs |
| **Web search** | [`tool-use/web-search-tool.md`](https://platform.claude.com/docs/en/agents-and-tools/tool-use/web-search-tool.md) | Search the web for current information |

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

*Source pages: 31 under `platform.claude.com/docs/en/agents-and-tools/`
(agent-skills/* + mcp-connector + remote-mcp-servers + tool-use/*).*
