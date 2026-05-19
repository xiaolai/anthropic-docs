---
name: claude-office-agents
description: |
  Deep reference for Claude for M365 — the Claude-powered add-ins
  that run inside Microsoft 365 apps (Excel, PowerPoint, Word,
  Outlook). Covers per-app capabilities, work-across-apps shared
  state, connectors and skills integration, dictation, third-party
  platform deployment (Bedrock / Vertex / Foundry / gateway),
  enterprise admin setup (OpenTelemetry audit, usage analytics,
  spend tracking), and the one-time Microsoft Graph consent required
  for Outlook.
source: https://claude.com/docs/office-agents/
---

# Claude for M365 (Office Agents)

> *Router lives in [`SKILL.md`](SKILL.md). This file is the deep
> reference for everything under `claude.com/docs/office-agents/*`.*

## What it is

Claude for M365 is a set of Claude-powered add-ins inside Microsoft
365 apps. Chat with Claude about the file or email you have open;
ask it to read or edit content; move work between Excel, PowerPoint,
Word, and Outlook without leaving the app.

## Per-app surfaces

| App        | Capabilities                                                                         | Source page |
|------------|--------------------------------------------------------------------------------------|-------------|
| **Excel**      | Read/write cells, formulas, formatting, pivot tables, charts                     | [`excel.md`](https://claude.com/docs/office-agents/excel.md) |
| **PowerPoint** | Read, edit, generate slides using existing templates                             | [`powerpoint.md`](https://claude.com/docs/office-agents/powerpoint.md) |
| **Word**       | Draft, redline, review documents with tracked changes and comment-driven editing | [`word.md`](https://claude.com/docs/office-agents/word.md) |
| **Outlook**    | Inbox triage, voice-matched reply drafts, thread summaries, meeting-time finding | [`outlook.md`](https://claude.com/docs/office-agents/outlook.md) |

## Work-across-apps shared state

Claude for Excel, PowerPoint, Word, and Outlook share conversation
state. Actions in one app are informed by what happened in others —
e.g., findings from an Outlook inbox triage can be referenced when
drafting a PowerPoint summary, without re-uploading or repeating
context.

> **3P platform limitation.** Work-across-apps is **not** supported
> when connecting through Amazon Bedrock, Google Cloud Vertex AI, Azure
> AI Foundry, or an LLM gateway. It requires direct Claude account sign-in.

Enable per add-in under **Settings → "Let Claude work across files"**.
Pro and Max plans have this on by default; Team and Enterprise default
to off (admin-controllable at **Organization settings → Office agents**).
Any Skills you've enabled apply across all apps during cross-app tasks.

See [`work-across-apps.md`](https://claude.com/docs/office-agents/work-across-apps.md).

## Outlook setup: Microsoft Graph consent

Outlook requires a **one-time Microsoft Graph admin consent** before
deployment. The consent flow grants the M365 add-in the Graph scopes
it needs to triage inbox, summarize threads, and access calendar for
meeting-time finding.

See [`outlook.md` § Grant Microsoft Graph consent](https://claude.com/docs/office-agents/outlook.md).

## Connectors and Skills integration

The M365 add-ins extend the same Connectors and Skills models used
across Claude products:

- **Connectors** — pull external context (e.g., a CRM, a wiki, a
  ticket system) into the M365 conversation.
- **Skills** — package reusable task recipes (e.g., "quarterly
  pipeline review") that any user can invoke inside Excel /
  PowerPoint / Word / Outlook.

See [`connectors-and-skills.md`](https://claude.com/docs/office-agents/connectors-and-skills.md).

## Dictation

Speak prompts instead of typing them. The dictation surface is
available across all four M365 apps.

See [`dictation.md`](https://claude.com/docs/office-agents/dictation.md).

## FSI plugins

Pre-built plugins for financial-services workflows (modeling,
disclosures, compliance reviews) ship as a dedicated plugin bundle.

See [`fsi-plugins.md`](https://claude.com/docs/office-agents/fsi-plugins.md).

## Third-party platform deployment

Claude for M365 can connect through Amazon Bedrock, Google Cloud
Vertex AI, Azure AI Foundry, or an LLM gateway — the same providers
supported by [Cowork on 3P](SKILL-cowork.md). This decouples M365
deployment from Anthropic's API for organizations with the same
residency / regulatory drivers.

See [`third-party-platforms.md`](https://claude.com/docs/office-agents/third-party-platforms.md).

## Enterprise readiness

Security architecture diagrams, OpenTelemetry audit setup, usage
analytics, and spend-tracking conventions live in
[`enterprise-readiness.md`](https://claude.com/docs/office-agents/enterprise-readiness.md).

Highlights:

- Security architecture diagrams per app (first-party and third-party
  deployment modes).
- OpenTelemetry export for per-action audit trail (prompt, tool calls,
  token counts). **Custom collector endpoints receive unfiltered spans
  including prompt and document content** — only spans sent to
  Anthropic's own collector are attribute-filtered.
- Usage analytics (Analytics API) and spend tracking (CSV exports) apply
  to **first-party (direct Claude account) deployments only**. Third-party
  platform deployments (Bedrock / Vertex / Foundry / gateway) track usage
  through your cloud provider's billing console and gateway logs.

## Page index

All 10 source pages mirrored under
[`https://claude.com/docs/office-agents/`](https://claude.com/docs/office-agents/):

| Page | Topic |
|---|---|
| `excel.md` | Claude for Excel |
| `powerpoint.md` | Claude for PowerPoint |
| `word.md` | Claude for Word |
| `outlook.md` | Claude for Outlook (incl. Graph consent) |
| `work-across-apps.md` | Shared conversation state across apps |
| `connectors-and-skills.md` | Connectors + Skills in M365 context |
| `dictation.md` | Voice input |
| `fsi-plugins.md` | Financial-services plugin bundle |
| `third-party-platforms.md` | Bedrock / Vertex / Foundry / gateway |
| `enterprise-readiness.md` | Security, audit, analytics, spend |

---

*Source pages: 10 under `claude.com/docs/office-agents/`.*
