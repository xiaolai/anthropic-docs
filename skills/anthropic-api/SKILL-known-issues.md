---
name: anthropic-api-known-issues
description: |
  Catalog of user-impacting bugs the daily research agent has confirmed
  in the Anthropic API or its TypeScript / Python SDKs. Entries link to
  the upstream GitHub issue, document the symptom + reproduction + a
  workaround if one exists.

  Use when a user reports an error they didn't expect, mentions
  "doesn't work" / "broken" / "regression", or asks "is X a known
  issue?"

  Skip: questions about correct API usage (use SKILL-messages),
  questions about admin / compliance (use SKILL-admin /
  SKILL-compliance), feature requests.
source: https://github.com/anthropics/anthropic-sdk-typescript/issues
---

# Anthropic API & SDK — Known Issues

> Daily issue-tracker scans of
> [`anthropics/anthropic-sdk-typescript`](https://github.com/anthropics/anthropic-sdk-typescript)
> (the bug-tracker repo for this skill — see `config.json.upstream.bugTrackerRepo`)
> land confirmed user-impacting bugs here as `### KI N — <title>` entries.

## How entries land here

The research agent's Part B reads new bug-labeled issues in the upstream
repo. For each:

- **`added_known_issue`** → a new `### KI N — <title>` section is added
  here with symptom / reproduction / workaround / link.
- **`added_rule`** → if the bug is auto-correctable at edit time, the
  fix becomes a new rule in [`rules/messages-api.md`](rules/messages-api.md)
  instead of an entry here.
- **`skipped`** → recorded in `state.json.researchedIssues` with a
  reason; not added here (typically feature requests, environment-
  specific, or already documented).

## Entries

### KI 1031 — claude-opus-4-7 (Bedrock) prepends `<<<SENTINEL\n` (or `<![CDATA[`) to tool input_json string values

**Status:** Open as of 2026-05-18 · [anthropics/anthropic-sdk-typescript#1031](https://github.com/anthropics/anthropic-sdk-typescript/issues/1031)

**Symptom:** With `global.anthropic.claude-opus-4-7` on AWS Bedrock (cross-region inference, streaming tool use), every string value inside a specific tool's `input_json` was prefixed with literal bytes `<<<SENTINEL\n`, then otherwise-correct content. A separate corroborating report shows similar corruption with `<![CDATA[` prefixes (no closing `]]>`). The artifact persists across multiple separate inference calls in the same conversation thread.

**Trigger:** Narrow conditions — flat `Record<string, string>` tool shape with long, newline-rich string values (e.g., file-path → file-content maps); Bedrock cross-region inference endpoint; `claude-opus-4-7` model; observed in a ~5-hour window 2026-05-06 to 2026-05-08 UTC.

**Workaround:** Validate all `tool_use.input` string values before use; strip or reject any that start with `<<<SENTINEL` or `<![CDATA[`. If contamination is detected, start a new conversation thread (the regression appeared to persist via conditioning).

**Label:** `api` (model-level regression, not an SDK bug)

---

### KI 1038 — Vertex AI: document `url` source type rejected with misleading error

**Status:** Open as of 2026-05-18 · [anthropics/anthropic-sdk-typescript#1038](https://github.com/anthropics/anthropic-sdk-typescript/issues/1038)

**Symptom:** When using `@anthropic-ai/vertex-sdk` (v0.16.0) to send a `document` content block with `source.type: "url"`, the Vertex AI endpoint rejects the request with: `messages.0.content.0.image.source.base64.data: URL sources are not supported`. The error path (`image.source.base64.data`) is wrong — the block is a `document`, not an `image`.

**Trigger:** Vertex AI endpoint only; `document` content block with `source.type: "url"`. Direct API / AWS Bedrock unaffected.

**Workaround:** Pass the document as base64 instead of a URL — encode the file bytes and use `source.type: "base64"` with `source.data` and `source.media_type`. See [Anthropic PDF support docs](https://platform.claude.com/docs/en/build-with-claude/pdf-support#option-2-base64-encoded-pdf-document).

---

*See also: [`rules/messages-api.md`](rules/messages-api.md) for
auto-correction rules that fire at edit time, and
[`SKILL-messages.md`](SKILL-messages.md) for the canonical API
reference.*
