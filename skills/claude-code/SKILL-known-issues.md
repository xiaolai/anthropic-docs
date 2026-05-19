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

<!-- seed: replace on first real research pass -->

*No active known issues recorded yet. The research agent populates this section daily from `anthropics/claude-code` issues labeled `bug`. Entries are auto-pruned when the agent observes an issue close plus a confirmed fix-version release.*

### Example entry (template — the agent overwrites this with real issues)

**KI 0 — Example bug title**

- **Affects:** v2.0.0 – v2.1.143
- **Symptom:** Brief description of what the user observes.
- **Reproduction:** Minimal steps to trigger.
- **Workaround:** What to do until the bug is fixed.
- **Status:** open
- **Source:** [#0](https://github.com/anthropics/claude-code/issues/0)

## Recently resolved

> *Populated by the research agent.* Recent fixes worth flagging
> because users on older versions may still hit them.

---

*Source: `anthropics/claude-code` issue tracker (`label:bug`).*
