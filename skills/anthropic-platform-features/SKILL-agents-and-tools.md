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
[`agent-skills/best-practices.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/agent-skills/best-practices.md)
(41KB — covers naming conventions, description writing,
progressive-disclosure design, when to bundle code vs prose).

### Source pages

| Page | Topic |
|---|---|
| [`agent-skills/overview.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/agent-skills/overview.md) | What skills are, three-level loading |
| [`agent-skills/quickstart.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/agent-skills/quickstart.md) | First-skill walkthrough |
| [`agent-skills/best-practices.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/agent-skills/best-practices.md) | Authoring guide |
| [`agent-skills/enterprise.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/agent-skills/enterprise.md) | Enterprise distribution patterns |

## MCP integrations

### MCP connector (Anthropic-hosted)

Anthropic's hosted MCP server, accessible from the API. Lets API
consumers use the same MCP-style tool exposure without running their
own server.

Source: [`mcp-connector.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/mcp-connector.md).

### Remote MCP servers

Connect to third-party MCP servers (your own or community) from API
calls. Tools surface to the LLM in the same way as Anthropic-built
tools.

Source: [`remote-mcp-servers.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/remote-mcp-servers.md).

For deep MCP protocol details, see [`mcp-spec`](../mcp-spec/SKILL.md).

## Tool use catalog

The full tool-use surface lives under
[`tool-use/`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/).

### Conceptual foundation

| Page | Topic |
|---|---|
| [`tool-use/overview.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/overview.md) | Tool use overview |
| [`tool-use/how-tool-use-works.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/how-tool-use-works.md) | Request/response lifecycle |
| [`tool-use/handle-tool-calls.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/handle-tool-calls.md) | Round-tripping tool_use / tool_result |
| [`tool-use/define-tools.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/define-tools.md) | input_schema, tool_choice, descriptions |
| [`tool-use/tool-reference.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/tool-reference.md) | Tool-block reference |

### Anthropic-built tools

| Tool | Page | Use case |
|---|---|---|
| **Computer use** | [`tool-use/computer-use-tool.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/computer-use-tool.md) | Screen interaction, click/type/screenshot |
| **Code execution** | [`tool-use/code-execution-tool.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/code-execution-tool.md) | Sandboxed Python/shell in a VM |
| **Bash** | [`tool-use/bash-tool.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/bash-tool.md) | Shell command execution |
| **Text editor** | [`tool-use/text-editor-tool.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/text-editor-tool.md) | File edit operations |
| **Memory** | [`tool-use/memory-tool.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/memory-tool.md) | Persistent memory |
| **Advisor** | [`tool-use/advisor-tool.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/advisor-tool.md) | Self-reflection / planning tool |
| **Server tools** | [`tool-use/server-tools.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/server-tools.md) | Server-side tool exposure pattern |

### Advanced patterns

| Topic | Page |
|---|---|
| **Parallel tool use** | [`tool-use/parallel-tool-use.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/parallel-tool-use.md) |
| **Programmatic tool calling** | [`tool-use/programmatic-tool-calling.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/programmatic-tool-calling.md) |
| **Strict tool use** | [`tool-use/strict-tool-use.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/strict-tool-use.md) |
| **Fine-grained tool streaming** | [`tool-use/fine-grained-tool-streaming.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/fine-grained-tool-streaming.md) |
| **Tool combinations** | [`tool-use/tool-combinations.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/tool-combinations.md) |
| **Tool search** | [`tool-use/tool-search-tool.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/tool-search-tool.md) |
| **Tool runner** | [`tool-use/tool-runner.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/tool-runner.md) |
| **Manage tool context** | [`tool-use/manage-tool-context.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/manage-tool-context.md) |
| **Build a tool-using agent** | [`tool-use/build-a-tool-using-agent.md`](docs-snapshot/platform.claude.com/en/agents-and-tools/tool-use/build-a-tool-using-agent.md) |

---

*Source pages: 31 under `platform.claude.com/docs/en/agents-and-tools/`
(agent-skills/* + mcp-connector + remote-mcp-servers + tool-use/*).*
