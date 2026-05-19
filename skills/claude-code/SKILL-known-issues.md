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

*No active known issues recorded. The `anthropics/claude-code` repository uses GitHub primarily for pull requests and does not use issue labels (including `bug` labels). No bug-labeled issues were found as of the 2026-05-19 research run. This section will be populated if/when labeled bug issues appear.*

## Recently resolved

> *Populated by the research agent.* Recent fixes worth flagging
> because users on older versions may still hit them.

---

*Source: `anthropics/claude-code` issue tracker (`label:bug`).*
