---
name: claude-code
description: |
  Router skill for Claude Code (the CLI tool itself). Contains intent
  hints and a dispatch table that maps a user's question to the
  surface-specific deep-reference file Claude should Read next.

  Use when the user asks about Claude Code internals: editing
  .claude/settings.json or settings.local.json, authoring or debugging
  hooks (PreToolUse, PostToolUse, Stop, SubagentStop, Notification,
  UserPromptSubmit, PreCompact, SessionStart, SessionEnd, etc.),
  writing slash commands or agents, configuring MCP servers in
  .mcp.json, building plugins or marketplaces, setting ANTHROPIC_* /
  CLAUDE_* env vars, troubleshooting permission modes, understanding
  the ~/.claude/ directory layout, or asking "what does <feature> in
  Claude Code do".

  Skip: questions about the Anthropic Messages API (use anthropic-api),
  the Claude Agent SDK (use claude-agent-sdk), the MCP protocol spec
  (use mcp-spec), or general shell / git / programming topics not
  specific to Claude Code internals.
user-invocable: true
---

# Claude Code Reference — Router

| Field | Value |
|---|---|
| **Claude Code version** | v2.1.147 _(pinned in CI; updated by pipeline)_ |
| **Source docs** | [code.claude.com/docs](https://code.claude.com/docs/en/overview.md) |
| **GitHub** | [anthropics/claude-code](https://github.com/anthropics/claude-code) |
| **npm** | [`@anthropic-ai/claude-code`](https://www.npmjs.com/package/@anthropic-ai/claude-code) |

> **This skill is auto-updated hourly.** A matrix pipeline reads
> the upstream docs and rewrites the per-surface files below. Section
> structure is stable; content drifts to track upstream.

## Dispatch table

Read the surface file(s) matching the user's question. Each surface
file holds its complete reference for that one topic and cross-links
(via markdown links) to siblings when a fact spans surfaces — so you
only need to Read the matching file(s), not all of them.

| Surface file | Read when the user asks about… |
|---|---|
| [`SKILL-settings.md`](SKILL-settings.md) | `settings.json`, `settings.local.json`, project vs user vs local scope, settings keys / defaults / types |
| [`SKILL-hooks.md`](SKILL-hooks.md) | hook events (PreToolUse, PostToolUse, Stop, SubagentStop, Notification, UserPromptSubmit, PreCompact, SessionStart, SessionEnd), hook input/output JSON shapes, matchers, blocking vs non-blocking |
| [`SKILL-slash-commands.md`](SKILL-slash-commands.md) | slash command authoring, frontmatter schema, argument syntax, `$ARGUMENTS`, command discovery paths |
| [`SKILL-mcp.md`](SKILL-mcp.md) | `.mcp.json` schema, MCP transports (stdio / http / sse), server config, MCP tool naming, `mcp__` prefix |
| [`SKILL-plugins.md`](SKILL-plugins.md) | plugin manifest (`.claude-plugin/plugin.json`), marketplaces (`marketplace.json`), plugin install / scope, plugin commands / agents / skills / hooks, CLI hint protocol (`<claude-code-hint />`) for recommending plugins from third-party CLIs |
| [`SKILL-cli.md`](SKILL-cli.md) | CLI flags, subcommands, env vars (ANTHROPIC_* / CLAUDE_*), permission modes (`default` / `acceptEdits` / `plan` / `bypassPermissions`), `~/.claude/` directory layout, IDE integrations, session management (resume, naming, branching, picker, transcript storage), sandbox environments and isolation approaches (sandboxed Bash tool, sandbox runtime, dev containers, VMs) |
| [`SKILL-known-issues.md`](SKILL-known-issues.md) | a user reports a bug, asks about a workaround, mentions an error message, or asks "why does X not work" |

## When unsure which file to read

1. If the user mentions a specific file path (e.g., `.mcp.json`, `settings.json`, `plugin.json`), read the matching surface file.
2. If the user mentions an error message or unexpected behavior, read `SKILL-known-issues.md` first.
3. If the question spans multiple surfaces (e.g., "how do hooks and plugins interact"), read both surface files.
4. If still unclear, prefer reading `SKILL-cli.md` — it's the broadest catch-all surface.

## Auto-correction rules

Path-scoped correction rules live in `rules/`:

| Rule file | Triggers on edits to |
|---|---|
| `rules/settings.md` | `**/.claude/settings.json`, `**/.claude/settings.local.json` |
| `rules/mcp.md` | `**/.mcp.json` |
| `rules/plugins.md` | `**/.claude-plugin/plugin.json`, `**/marketplace.json` |
| `rules/hooks.md` | `**/.claude/hooks/**` |
| `rules/skills-agents-commands.md` | `**/.claude/skills/**/SKILL.md`, `**/.claude/agents/**`, `**/.claude/commands/**` |

---

*This skill is auto-updated hourly by a maintainer-run pipeline. If you
spot a bug in this content, file an issue at
[xiaolai/anthropic-docs](https://github.com/xiaolai/anthropic-docs) —
SKILL.md fixes flow back through the next research run, not via PRs.*
