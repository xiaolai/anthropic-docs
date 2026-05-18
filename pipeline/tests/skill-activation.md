# Skill Activation Test Spec

Tests the load-bearing assumption that **Claude reliably activates the
right skill for a given user intent**. Each row is a representative
user prompt + the skill we expect Claude to activate + which surface
file Claude should then read.

## How to run this test

1. Install the plugin in a fresh Claude Code session:
   ```bash
   /plugin install xiaolai/anthropic-docs
   ```
2. For each row below, open a new Claude Code conversation and type
   the prompt verbatim.
3. Observe whether Claude reads the expected `SKILL.md` router and
   dispatches to the expected surface file. Watch the Read tool calls
   in the session transcript.
4. Mark each row PASS / PARTIAL / FAIL and update the score columns.

A skill activation that **never fires** delivers zero value to users.
This is the most important verification we can run.

## Expected pattern

For each prompt, the trace should be:

1. Claude's skill matcher fires the expected skill (visible in the
   conversation as "Using skill: <name>").
2. Claude reads `~/.claude/plugins/.../skills/<name>/SKILL.md` (the
   router).
3. Claude reads the surface file named in the dispatch table for that
   intent.
4. Claude's answer is grounded in the surface content (cite-able).

If step 1 fails, the skill is dead weight — fix the `description`
frontmatter or split/merge the skill.

If step 1 passes but step 3 fails, the router dispatch is too vague
— sharpen the dispatch table.

## Tests per skill

### claude-code (Claude Code CLI itself)

| # | Prompt | Expected skill | Expected surface | Result |
|---|---|---|---|---|
| 1 | "How do I configure a hook that fires after Write?" | claude-code | SKILL-hooks.md | ☐ |
| 2 | "What goes in `.claude/settings.json`?" | claude-code | SKILL-settings.md | ☐ |
| 3 | "How do I add an MCP server to a project?" | claude-code | SKILL-mcp.md | ☐ |
| 4 | "What's the frontmatter schema for a slash command?" | claude-code | SKILL-slash-commands.md | ☐ |
| 5 | "How do I build a Claude Code plugin and publish to a marketplace?" | claude-code | SKILL-plugins.md | ☐ |
| 6 | "What environment variables control Claude Code's behavior?" | claude-code | SKILL-cli.md | ☐ |
| 7 | "Claude Code says 'permission denied' on Write — known issue?" | claude-code | SKILL-known-issues.md | ☐ |

### claude-agent-sdk

| # | Prompt | Expected skill | Expected surface | Result |
|---|---|---|---|---|
| 1 | "How do I use `query()` from @anthropic-ai/claude-agent-sdk in TypeScript?" | claude-agent-sdk | SKILL-typescript.md | ☐ |
| 2 | "Write a Python agent using claude-agent-sdk that uses ClaudeSDKClient." | claude-agent-sdk | SKILL-python.md | ☐ |
| 3 | "How do I register a PreToolUse hook with the Agent SDK?" | claude-agent-sdk | SKILL-typescript.md (or python depending on language hint) | ☐ |
| 4 | "Configure an MCP server in Agent SDK options." | claude-agent-sdk | SKILL-typescript.md | ☐ |
| 5 | "What does `permissionMode: 'plan'` do in the Agent SDK?" | claude-agent-sdk | SKILL-typescript.md | ☐ |

### anthropic-api

| # | Prompt | Expected skill | Expected surface | Result |
|---|---|---|---|---|
| 1 | "What's the request shape for POST /v1/messages?" | anthropic-api | SKILL-messages.md | ☐ |
| 2 | "How do tool_use and tool_result content blocks work?" | anthropic-api | SKILL-messages.md | ☐ |
| 3 | "List my org's API keys via the admin API." | anthropic-api | SKILL-admin.md | ☐ |
| 4 | "What's the latest claude-opus model ID?" | anthropic-api | SKILL-models.md | ☐ |
| 5 | "How do I enable extended thinking via the anthropic-beta header?" | anthropic-api | SKILL-beta.md | ☐ |
| 6 | "Stream activity events from the compliance API." | anthropic-api | SKILL-compliance.md | ☐ |
| 7 | "Migrate from /v1/complete to /v1/messages." | anthropic-api | SKILL-messages.md (legacy section) | ☐ |

### anthropic-platform-features

| # | Prompt | Expected skill | Expected surface | Result |
|---|---|---|---|---|
| 1 | "How do I author an Agent Skill (.skill package)?" | anthropic-platform-features | SKILL-agents-and-tools.md | ☐ |
| 2 | "How do I use the bash tool from the API?" | anthropic-platform-features | SKILL-agents-and-tools.md | ☐ |
| 3 | "Configure prompt caching with cache_control." | anthropic-platform-features | SKILL-build-with-claude.md | ☐ |
| 4 | "Set up Workload Identity Federation with GitHub Actions." | anthropic-platform-features | SKILL-manage-claude.md | ☐ |
| 5 | "Deploy a Managed Agent with cloud-container runtime." | anthropic-platform-features | SKILL-managed-agents.md | ☐ |
| 6 | "Send a batch of messages via the batch API." | anthropic-platform-features | SKILL-build-with-claude.md | ☐ |

### claude-connectors

| # | Prompt | Expected skill | Expected surface | Result |
|---|---|---|---|---|
| 1 | "How do I enable the GitHub connector in Claude.ai?" | claude-connectors | SKILL-connectors-overview.md | ☐ |
| 2 | "Build a custom MCP connector with OAuth." | claude-connectors | SKILL-connectors-building.md | ☐ |
| 3 | "Package an MCP server as a .mcpb Desktop extension." | claude-connectors | SKILL-mcp-apps.md | ☐ |
| 4 | "Design guidelines for an MCP App that shows a chart inline." | claude-connectors | SKILL-mcp-apps.md | ☐ |
| 5 | "Install an Agent Skill in Claude Desktop." | claude-connectors | SKILL-claude-skills.md | ☐ |
| 6 | "Find Anthropic's plugin marketplace." | claude-connectors | SKILL-claude-plugins.md | ☐ |

### claude-cowork

| # | Prompt | Expected skill | Expected surface | Result |
|---|---|---|---|---|
| 1 | "Deploy Claude Cowork on Amazon Bedrock for our enterprise." | claude-cowork | SKILL-cowork.md | ☐ |
| 2 | "What's the MDM config schema for Cowork on 3P?" | claude-cowork | SKILL-cowork.md | ☐ |
| 3 | "Compare Claude Enterprise vs Cowork on 3P feature matrix." | claude-cowork | SKILL-cowork.md | ☐ |
| 4 | "How do I install Claude for Excel?" | claude-cowork | SKILL-office-agents.md | ☐ |
| 5 | "What scopes does the Outlook add-in need from Microsoft Graph?" | claude-cowork | SKILL-office-agents.md | ☐ |

### mcp-spec

| # | Prompt | Expected skill | Expected surface | Result |
|---|---|---|---|---|
| 1 | "What's the MCP initialize handshake?" | mcp-spec | SKILL-protocol.md | ☐ |
| 2 | "What's the current MCP protocol version?" | mcp-spec | SKILL-protocol.md | ☐ |
| 3 | "Implement an MCP server in TypeScript that exposes a `search_files` tool." | mcp-spec | SKILL-servers.md | ☐ |
| 4 | "How do I write an MCP client that handles sampling/createMessage?" | mcp-spec | SKILL-clients.md | ☐ |
| 5 | "Should I use stdio or streamable HTTP transport for an internal database server?" | mcp-spec | SKILL-transport.md | ☐ |
| 6 | "Define an MCP resource template for fetching GitHub issues." | mcp-spec | SKILL-tools-resources-prompts.md | ☐ |
| 7 | "Difference between sampling, roots, and elicitation?" | mcp-spec | SKILL-tools-resources-prompts.md | ☐ |

## Negative tests (skill should NOT fire)

These prompts should NOT activate any of the 8 skills — they're out
of scope. If one of our skills fires, the descriptions are too greedy
and need narrowing.

| # | Prompt | Expected | Result |
|---|---|---|---|
| N1 | "Help me debug a Python TypeError." | none | ☐ |
| N2 | "Refactor this React component to use hooks." | none | ☐ |
| N3 | "What's the difference between docker and podman?" | none | ☐ |
| N4 | "Write a SQL query to find duplicate rows." | none | ☐ |
| N5 | "Explain how transformers work conceptually." | none | ☐ |

## Cross-skill triage tests (which of N candidate skills wins?)

These prompts plausibly fit more than one skill. They test the
description-quality and dispatch-clarity boundaries.

| # | Prompt | Expected winner | Why | Result |
|---|---|---|---|---|
| C1 | "How do I configure an MCP server?" | **depends on context** — Claude Code CLI (`.mcp.json`) vs MCP spec vs platform-features mcp-connector — Claude should read multiple and pick. | tests router-level vs cross-skill cross-references | ☐ |
| C2 | "What's the schema for an Agent Skill?" | anthropic-platform-features → SKILL-agents-and-tools.md (authoring spec) NOT claude-connectors (user-facing) | tests our "spec lives there, UX lives here" split | ☐ |
| C3 | "Help me design a plugin." | claude-code → SKILL-plugins.md (CLI authoring) NOT claude-connectors (user-facing) | tests our CLI vs Claude-app split | ☐ |

## What to do with results

- **All-PASS (or 90%+):** intent-matching link in the value chain is
  intact. Move to verifying step 3 (does Claude actually use the
  surface, not just acknowledge it).
- **PARTIAL (60-90%):** some skills are under-activating. Look at
  failed rows — usually the `description` frontmatter is too narrow
  (specific words user didn't use) or too generic (matched by
  another skill first). Sharpen and re-test.
- **FAIL (<60%):** intent matching is broken. Likely causes:
  conflicting skills installed alongside ours; ambiguous descriptions
  across the 8 skills; Claude's skill-matching threshold not tuned
  to our description style. Surface this as a skill-quality issue,
  not a docs issue.

## Automating this (future)

These tests are currently **manual** because Claude Code's skill
activation isn't observable from a script. Two paths to automate:

1. **Headless Claude Code with skill-trace logging:** if a CLI flag
   exposes "which skill matched and which files were read," we can
   parse that and assert. Worth investigating.
2. **Synthetic skill matcher:** use the Agent SDK directly with the
   same skill files mounted, send each test prompt as a `query()`,
   inspect the messages stream for skill-read patterns. More work
   but more deterministic.

For now, manual run after every meaningful skill change.
