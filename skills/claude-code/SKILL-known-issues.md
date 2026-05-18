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

### KI 60237 — Sub-agent `tools:` array loses first and last entries at spawn time

- **Affects:** All versions (plugin sub-agents)
- **Symptom:** Plugin sub-agents declared with a `tools:` frontmatter array lose the first and last entries at spawn. An agent with `tools: [Read, Write, Bash]` gets only `{Write}` at runtime; calls to Read/Bash return "tool exists but is not enabled in this context". A 2-tool agent gets 0 usable tools.
- **Workaround:** Pad the array with throwaway built-in tools at position 0 and last: `tools: [Glob, Read, Write, Bash, Grep]` so the real tools occupy middle positions.
- **Status:** open
- **Source:** [#60237](https://github.com/anthropics/claude-code/issues/60237)

### KI 60292 — User-scope plugins show "not cached at (not recorded)" — `/plugins` TUI cannot refresh

- **Affects:** All versions
- **Symptom:** User-scope plugins (~/.claude/settings.json) show "not cached at (not recorded)" in `/plugins` Errors tab. Running `/plugins` refresh does nothing. `claude plugin uninstall` fails with "not installed in project scope". When CWD is `$HOME`, even `--scope user` fails (config paths collide).
- **Workaround:** From a directory that is **not** `$HOME`, run: `claude plugin uninstall <plugin>@<marketplace> --scope user` then reinstall with `--scope user`.
- **Status:** open
- **Source:** [#60292](https://github.com/anthropics/claude-code/issues/60292)

### KI 60274 — Agent View rebinds mouse wheel — scroll wheel cycles input history after entering agent detail

- **Affects:** All versions with Agent View
- **Symptom:** After entering an Agent View agent detail conversation, the mouse scroll wheel cycles through previous inputs (like Up/Down arrows) instead of scrolling. The rebinding persists after exiting Agent View. Affects Windows (VS Code terminal, Windows Terminal) and macOS (Ghostty, Warp).
- **Workaround:** Use keyboard arrow keys or Page Up/Down to scroll. Restart `claude` to restore mouse wheel behavior.
- **Status:** open
- **Source:** [#60274](https://github.com/anthropics/claude-code/issues/60274)

### KI 60240 — Settings migration silently deletes `model` field from `~/.claude/settings.json`

- **Affects:** Versions containing the `unpinOpus47LaunchEffort` migration
- **Symptom:** After upgrading, the `model` field is silently deleted from `~/.claude/settings.json` on next launch with no UI notification. Users who pinned a specific model are switched to the default without warning.
- **Workaround:** Manually re-add `"model": "<desired-model>"` to `~/.claude/settings.json` after the migration runs. The `unpinOpus47LaunchEffort: true` flag in `~/.claude.json` prevents it from running again.
- **Status:** open
- **Source:** [#60240](https://github.com/anthropics/claude-code/issues/60240)

### KI 60224 — stdio MCP server tools silently dropped when `initialize` exceeds probe timeout

- **Affects:** All versions
- **Symptom:** A stdio MCP server that takes longer than Claude Code's probe timeout to complete `initialize` (e.g. >10s cold-start) has all its tools silently dropped. `ToolSearch` returns "No matching deferred tools found" for all `mcp__<server>__*` tools for the entire session. Server may incorrectly report as Connected in `claude mcp list`.
- **Workaround:** Pre-warm the MCP server process externally before starting Claude Code so `initialize` completes within the timeout. Or keep a long-running process warm between sessions.
- **Status:** open
- **Source:** [#60224](https://github.com/anthropics/claude-code/issues/60224)

### KI 60194 — Permission prompt disappears after Ctrl+O toggle during concurrent tool calls

- **Affects:** All versions (Linux; Ghostty/zsh confirmed)
- **Symptom:** During a Bash tool permission prompt, pressing Ctrl+O (expand output), then having a second tool call arrive, then pressing Ctrl+O again causes the permission prompt to disappear permanently. Claude waits indefinitely for approval that cannot be granted.
- **Workaround:** Press Esc to cancel the stuck tool call, then ask Claude to retry. Avoid pressing Ctrl+O while a permission prompt is active.
- **Status:** open
- **Source:** [#60194](https://github.com/anthropics/claude-code/issues/60194)

### KI 60212 — `/agents` TUI freezes after navigating back from agent detail view (Windows)

- **Affects:** All versions (Windows 11, all shells: PowerShell 7, Git Bash, cmd.exe)
- **Symptom:** Running `claude agents` or `/agents`, navigating into an agent detail view, then pressing left-arrow or Esc to go back freezes the entire TUI. No further keystrokes are processed. Ctrl+C is unreliable; closing the terminal window is usually required.
- **Workaround:** Avoid navigating into agent detail views on Windows. If frozen, close the terminal window and relaunch.
- **Status:** open
- **Source:** [#60212](https://github.com/anthropics/claude-code/issues/60212)

### KI 60263 — Status bar `used_percentage` contains Unix timestamp instead of 0–100 value after `/clear`

- **Affects:** All versions
- **Symptom:** After running `/clear`, the statusLine JSON has `rate_limits.five_hour.used_percentage` set to the `resets_at` Unix timestamp (e.g. `1779124800`) instead of a percentage. Custom status bar scripts display absurd values like "5h ████ (1779124800%)".
- **Workaround:** In custom `statusLine` scripts, clamp `used_percentage` values outside [0, 100] and hide/skip that display block when out of range.
- **Status:** open
- **Source:** [#60263](https://github.com/anthropics/claude-code/issues/60263)

### KI 60269 — `claude plugins list --json` produces invalid JSON (ANSI codes leaked)

- **Affects:** All versions
- **Symptom:** `claude plugins list --json` (or `claude plugin list --json`) outputs raw ANSI escape sequences and terminal control characters mixed into the JSON output. The result cannot be parsed by `jq` or any standard JSON parser.
- **Workaround:** Strip ANSI codes before parsing: `claude plugins list --json | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | jq ...`. Alternatively, read `~/.claude/settings.json` directly for `enabledPlugins`.
- **Status:** open
- **Source:** [#60269](https://github.com/anthropics/claude-code/issues/60269)

### KI 60290 — MCP OAuth `complete_authentication` fails since v2.1.143 (Atlassian, Slack, others)

- **Affects:** v2.1.143+
- **Symptom:** After calling `mcp__<provider>__authenticate` and completing browser OAuth consent, calling `complete_authentication` with the callback URL fails with "No OAuth flow is in progress. Call authenticate first". State parameter may show corruption (`++` characters injected). Affects Atlassian and Slack MCP providers; likely others.
- **Workaround:** Downgrade to Claude Code v2.1.142.
- **Status:** open (regression since v2.1.143)
- **Source:** [#60290](https://github.com/anthropics/claude-code/issues/60290)

### KI 60289 — PowerShell `allow` rule with trailing `*` wildcard doesn't suppress permission prompts

- **Affects:** All versions (Windows, PowerShell tool enabled)
- **Symptom:** `PowerShell(dotnet.exe build *)` in `permissions.allow` does not prevent permission prompts for `dotnet.exe build --help` or other matching commands. Exact-match rules work; wildcard prefix matching is broken for native executables with positional subcommands.
- **Workaround:** Add exact-match rules for each specific command variant, or use "approve and don't ask again" for each specific invocation.
- **Status:** open
- **Source:** [#60289](https://github.com/anthropics/claude-code/issues/60289)

### KI 60252 — `--strict-mcp-config` still fetches MCP registry and connects user-configured servers

- **Affects:** All versions
- **Symptom:** `claude --strict-mcp-config --mcp-config '{"mcpServers":{}}' -p ...` still fetches `https://api.anthropic.com/v1/mcp_servers` (197-URL registry) and attempts connections to user-configured servers from `~/.claude/settings.json`, adding ~1.2s+ latency per invocation.
- **Workaround:** Run with a sandboxed `HOME` directory containing only `.claude/.credentials.json` (no `settings.json`) to eliminate user-MCP connection attempts. The registry fetch cannot be suppressed with current flags.
- **Status:** open
- **Source:** [#60252](https://github.com/anthropics/claude-code/issues/60252)

### KI 60277 — "Accept and auto mode" shows false "Permission mode couldn't be changed" warning

- **Affects:** All versions (macOS Claude Desktop confirmed)
- **Symptom:** Clicking "Accept and auto mode" (Cmd+Return) in Plan mode always shows a yellow warning "Permission mode couldn't be changed. You can try again." The mode does switch to Auto and execution proceeds normally — the warning is a false positive.
- **Workaround:** Ignore the warning; auto mode does activate correctly. Alternatively, use plain "Accept" then manually switch to Auto mode.
- **Status:** open (cosmetic/confusing, not functional)
- **Source:** [#60277](https://github.com/anthropics/claude-code/issues/60277)

### KI 60191 — `claude` hangs on startup on Fedora 42 x86_64 (glibc 2.43)

- **Affects:** All versions (Fedora 42 x86_64 with glibc 2.43)
- **Symptom:** Running `claude` hangs indefinitely with no output, no logs, no network connections. `claude --version` and `claude --help` work normally. strace shows futex timeout loops, no I/O.
- **Workaround:** No confirmed workaround. Setting `ANTHROPIC_API_KEY` env var may help if the hang is in the auth-config TUI path. Related platform-specific open issues: #58680, #58035, #56220.
- **Status:** open
- **Source:** [#60191](https://github.com/anthropics/claude-code/issues/60191)

## Recently resolved

> *Populated by the research agent.* Recent fixes worth flagging
> because users on older versions may still hit them.

---

*Source: `anthropics/claude-code` issue tracker (`label:bug`).*
