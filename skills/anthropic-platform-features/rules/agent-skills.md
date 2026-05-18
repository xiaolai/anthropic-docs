---
name: anthropic-platform-agent-skills
description: Edit-time rules for authoring Agent Skills (.skill packages) per the spec at platform.claude.com/docs/en/agents-and-tools/agent-skills/. Catches name / description mistakes that prevent skill activation, plus filesystem-layout violations.
appliesTo:
  - "**/SKILL.md"
  - "**/.skill/**"
---

# Agent Skills (.skill package) Rules

## Rule 1 — `name` and `description` are required

Every SKILL.md frontmatter MUST have both. Without them, the platform
refuses to register the skill.

```yaml
---
name: pdf-processing
description: Extract text and tables from PDFs, fill forms, merge documents. Use when working with PDFs or when the user mentions PDF files or document extraction.
---
```

## Rule 2 — `name` must be lowercase kebab-case

The platform normalizes skill names — uppercase, underscores, or spaces
produce activation failures. Use `lowercase-with-hyphens`.

- ✅ `pdf-processing`, `claude-cowork`, `mcp-spec`
- ❌ `PDF_Processing`, `pdfProcessing`, `PDF Processing`

## Rule 3 — `description` is the activation trigger; write it for intent matching

The description is what the platform's skill matcher reads to decide
whether to activate the skill. Write it so:
- It explicitly enumerates the user-prompts that should activate it
  ("Use when the user asks about X, Y, Z")
- It explicitly enumerates what should NOT match ("Skip: questions
  about A")
- It uses domain-specific terminology the user is likely to use

Skill descriptions over 1024 characters get truncated. Keep under 1000.

## Rule 4 — Filesystem layout

A `.skill` package directory contains:

```
my-skill/
  SKILL.md              ← required, frontmatter + body
  README.md             ← optional, human-facing
  scripts/              ← optional, executable helpers Claude runs via bash
  references/           ← optional, additional .md files for progressive load
```

The platform reads SKILL.md at startup (Level 1 metadata only). The
body of SKILL.md loads when triggered (Level 2). Other files load on
demand (Level 3) — Claude reads them via the Read tool when relevant.

## Rule 5 — Don't dump all reference content into SKILL.md

The platform's three-level progressive disclosure depends on splitting
content. A 5000-line SKILL.md defeats the purpose — Claude pays the
context cost once SKILL.md is loaded, even for trivial uses.

Pattern: keep SKILL.md to ~200-500 lines of conceptual + workflow
content. Move per-feature reference details into `references/X.md`
files and have SKILL.md link them.

## Rule 6 — Scripts should be self-contained and language-agnostic where possible

Scripts under `scripts/` run via bash in Claude's VM environment. Prefer:
- POSIX shell or Python (always available)
- No interactive prompts (Claude can't respond)
- Self-documenting `--help` output
- Exit 0 on success, non-zero on failure (Claude reads exit codes)

---

*Source: platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices.*
