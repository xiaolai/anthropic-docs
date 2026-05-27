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

### KI 61735 — ScheduleWakeup wakeups lost on session process death

- **Affects:** All versions (in-memory design)
- **Symptom:** `/loop` sessions and any code using `ScheduleWakeup` silently stop scheduling further turns when the Claude Code session process dies (crash, OOM, cluster recycle, terminal hang). The session does not resume or notify; it goes permanently silent.
- **Reproduction:** Start a long `/loop` session. While wakeups are pending, kill the Claude Code process (e.g. SIGKILL, OOM event, `pkill claude`). Observe that the loop never resumes.
- **Workaround:** For tasks that must survive process death, use `/schedule` (Routines) which runs on Anthropic-managed cloud infrastructure and persists independently of the local session process. Alternatively, implement an external watchdog: a systemd user timer or cron job that checks the session's transcript mtime and alerts or restarts if it goes stale. Reference implementation: [honzastim/claude-code-stuck-session-workaround](https://github.com/honzastim/claude-code-stuck-session-workaround).
- **Status:** Open — no persistent wakeup queue yet; cloud Routines are the supported alternative.
- **Source:** [#61735](https://github.com/anthropics/claude-code/issues/61735)

### KI 61734 — Sonnet 4.6 context window meter shows 200K instead of 1M

- **Affects:** v2.1.152 (possibly earlier); behaviour may vary by plan
- **Symptom:** The status bar context-window meter displays 200K tokens for `claude-sonnet-4-6`. Multiple users report this was 1M in previous versions. Sessions may be actively limited to 200K, not just mis-displayed.
- **Reproduction:** Start Claude Code with `claude-sonnet-4-6` on a Pro or Max plan and observe the context meter.
- **Workaround:** Switch to `claude-opus-4-7` which shows and uses the 1M context window on eligible plans. For API/Team plans, using `--model claude-sonnet-4-6` via CLI may restore 1M. Plan-specific context limits: Max plan caps Sonnet at 200K but gives Opus 4.7 the 1M window; API/Team plans allow 1M on Sonnet 4.6. Check `claude.ai/settings` → Plan for your tier's limits.
- **Status:** Open; maintainers aware (v2.1.152 regression suspected, not confirmed).
- **Source:** [#61734](https://github.com/anthropics/claude-code/issues/61734)

## Recently resolved

*None tracked yet. The research agent will surface user-impacting bugs that were fixed in a recent CLI release, so users on older versions know what's worth upgrading for.*

---

*Source: `anthropics/claude-code` issue tracker (`label:bug`).*
