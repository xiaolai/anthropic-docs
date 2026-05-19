---
name: claude-code-known-issues
description: |
  Catalog of confirmed Claude Code bugs and their workarounds. Each
  entry: symptom, reproduction, workaround, affected version range,
  GitHub issue link. Read this file when the user reports a bug,
  describes an unexpected behavior, mentions an error message, or
  asks "why does X not work" — especially if the issue might be
  Claude-Code-side rather than a configuration mistake.
source: https://github.com/anthropics/claude-code/issues?q=is%3Aissue+label%3Abug
---

# Claude Code — Known Issues

> *This file is one of seven surface-specific references. The router
> ([`SKILL.md`](SKILL.md)) dispatches you here when a user reports a bug.*

> **Triage hint:** before assuming a known issue applies, check that
> the user's symptom matches the *Reproduction* section closely. Many
> bug reports look superficially similar but have different root
> causes.

## Format

Each entry uses this structure:

```markdown
### KI <issue-number> — <short title>

**Affects:** v<X.Y.Z> – v<X.Y.Z> (or "all versions since v<X.Y.Z>")
**Symptom:** what the user observes.
**Reproduction:** minimal steps to trigger.
**Workaround:** what to do until it's fixed.
**Status:** open / fixed in v<X.Y.Z> / wontfix.
**Source:** [#NNNN](https://github.com/anthropics/claude-code/issues/NNNN)
```

## Active issues

### KI 14956 — Skill `allowed-tools` doesn't auto-approve Bash commands

- **Affects:** All versions (confirmed still present in v2.1.144)
- **Symptom:** A SKILL.md frontmatter declares `allowed-tools: Bash(pattern)` and Claude reports "N tools allowed" when the skill loads, but subsequent Bash calls matching that pattern still prompt for manual permission approval.
- **Reproduction:** 1) Create a skill with `allowed-tools: Bash(path/to/script.sh *)`. 2) Invoke the skill. 3) The first Bash call is auto-approved; the second call (same or different pattern from the same skill) prompts for permission.
- **Workaround:** Add the Bash pattern directly to `~/.claude/settings.json` `permissions.allow` list (e.g. `"Bash(path/to/script.sh *)"`) — this defeats skill-level encapsulation but eliminates the prompts.
- **Status:** open
- **Source:** [#14956](https://github.com/anthropics/claude-code/issues/14956) (33 👍) · also [#60515](https://github.com/anthropics/claude-code/issues/60515)

### KI 11927 — `env` block in settings.json/settings.local.json not used for MCP `${VAR}` substitution

- **Affects:** All versions (confirmed still present in v2.1.144)
- **Symptom:** An MCP server in `.mcp.json` references `"${MY_TOKEN}"` in its `env` block. If `MY_TOKEN` is only set in `settings.local.json` → `env` (not in the shell), the server is silently dropped ("No MCP servers configured") in the REPL. With `--mcp-config`, the server spawns but `${MY_TOKEN}` is passed as the literal empty string, causing downstream auth failures.
- **Reproduction:** Set env var only in `.claude/settings.local.json` `env` block; unset it from shell. Launch `claude` (REPL path drops the server silently) or `claude --mcp-config /path/.mcp.json` (spawns with empty substitution).
- **Workaround:** `export MY_TOKEN=value` in the shell before launching claude, or set it in the terminal session environment. The `env` block in settings.json is applied per-session to Claude's process but is not used as a substitution source for `.mcp.json` variable expansion.
- **Status:** open
- **Source:** [#11927](https://github.com/anthropics/claude-code/issues/11927) (27 👍) · also [#60513](https://github.com/anthropics/claude-code/issues/60513)

### KI 36793 — Project-scope `enabledPlugins` silently ignored when launched from a subdirectory

- **Affects:** All versions (confirmed still present in v2.1.144)
- **Symptom:** A project's `.claude/settings.json` contains `enabledPlugins: { "plugin@owner": true }`. Plugins load correctly when `claude` is launched from the project root, but are silently ignored (status shows as disabled) when launched from any subdirectory.
- **Reproduction:** Add `enabledPlugins` to `.claude/settings.json`; run `claude` from a subdirectory like `src/`. Check `claude plugin list` — the plugin shows disabled despite project-scope config.
- **Workaround:** Always launch `claude` from the project root directory (the one directly containing `.claude/`).
- **Status:** open
- **Source:** [#36793](https://github.com/anthropics/claude-code/issues/36793) · also [#60512](https://github.com/anthropics/claude-code/issues/60512)

### KI 60523 — Session becomes unrecoverable after auto-compaction with `advisor()` calls

- **Affects:** Long sessions in v2.1.x (confirmed v2.1.143+)
- **Symptom:** After auto-compaction fires during a long session that made advisor() calls, every subsequent prompt throws a 400 API error: `unexpected tool_use_id found in advisor_tool_result blocks`. The session cannot recover — `/compact` and `/rewind` don't help once the tree is split.
- **Reproduction:** Run a very long session (800+ JSONL turns) with multiple advisor() calls; let auto-compaction fire mid-session. The next prompt throws 400 on every attempt.
- **Workaround:** Find the broken session at `~/.claude/projects/<slug>/<session-id>.jsonl` and strip the orphaned `advisor_tool_result` blocks whose `parentUuid` points to a missing `server_tool_use`. The issue includes a Python script for this repair: [#60523](https://github.com/anthropics/claude-code/issues/60523).
- **Status:** open (root cause: compaction can place `server_tool_use` and its paired `advisor_tool_result` on different branches of the conversation tree)
- **Source:** [#60523](https://github.com/anthropics/claude-code/issues/60523)

## Recently resolved

> *Populated by the research agent.* Recent fixes worth flagging
> because users on older versions may still hit them.

---

*Source: `anthropics/claude-code` issue tracker (`label:bug`).*
