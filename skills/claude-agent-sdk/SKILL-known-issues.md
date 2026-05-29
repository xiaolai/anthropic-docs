---
name: claude-agent-sdk-known-issues
description: |
  Catalog of user-impacting bugs the daily research agent has confirmed
  in the Claude Agent SDK (TypeScript or Python). Entries link to the
  upstream GitHub issue, document the symptom + reproduction + a
  workaround if one exists.

  Use when a user reports an SDK error they didn't expect, mentions
  "doesn't work" / "broken" / "regression" / "hangs" with the SDK, or
  asks "is X a known issue?"

  Skip: questions about correct SDK usage (use SKILL-typescript or
  SKILL-python), edit-time correction patterns (use rules/*.md), feature
  requests.
source: https://github.com/anthropics/claude-agent-sdk-typescript/issues
---

# Claude Agent SDK — Known Issues

> Daily issue-tracker scans of
> [`anthropics/claude-agent-sdk-typescript`](https://github.com/anthropics/claude-agent-sdk-typescript)
> (the bug-tracker repo for this skill — see `config.json.upstream.bugTrackerRepo`)
> land confirmed user-impacting bugs here as `### KI N — <title>`
> entries. Python-SDK-specific issues are also surfaced here when they
> appear in the Python repo, prefixed with `(PY)`.

## How entries land here

The research agent's Part B reads new bug-labeled issues in the
upstream repo. For each:

- **`added_known_issue`** → a new `### KI N — <title>` section here.
- **`added_rule`** → if auto-correctable at edit time, becomes a rule
  in [`rules/claude-agent-sdk-ts.md`](rules/claude-agent-sdk-ts.md) or
  [`rules/claude-agent-sdk-py.md`](rules/claude-agent-sdk-py.md)
  instead.
- **`skipped`** → recorded in `state.json.researchedIssues` with a
  reason.

## Entries

### KI 1 — Empty thinking blocks emitted on AWS Bedrock (v0.3.152+ regression)

**Source:** [anthropics/claude-agent-sdk-typescript #337](https://github.com/anthropics/claude-agent-sdk-typescript/issues/337) · opened 2026-05-28 · open

**Symptom:** On AWS Bedrock endpoints (`us.anthropic.claude-opus-4-7[1m]`,
`us.anthropic.claude-opus-4-8[1m]`) with
`thinking: { type: "adaptive", display: "summarized" }`, SDK v0.3.152+
emits completed assistant `thinking` blocks whose `thinking` field is `""`.
The raw stream contains only a `signature_delta` — no `thinking_delta` events —
so the finished assistant message has `{ type: "thinking", thinking: "", signature: "..." }`.
This is a regression from v0.3.150, which produced non-empty summarized thinking text
for the same prompt, model, and options. The issue does **not** reproduce on the
direct Anthropic provider (same SDK versions, same prompts).

**Reproduction:**

```ts
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const msg of query({
  prompt: 'Use the Bash tool once to run `echo hi`, then reply DONE.',
  options: {
    model: "us.anthropic.claude-opus-4-7[1m]",  // Bedrock cross-region endpoint
    thinking: { type: "adaptive", display: "summarized" },
    includePartialMessages: true,
    allowedTools: ["Bash"],
    permissionMode: "bypassPermissions",
    allowDangerouslySkipPermissions: true,
  },
})) {
  if (msg.type === "assistant") {
    for (const block of msg.message.content) {
      if (block.type === "thinking" && !block.thinking.trim()) {
        console.log("EMPTY THINKING BLOCK (regression):", block.signature?.slice(0, 20));
      }
    }
  }
}
```

**Workaround (either):**

1. Switch to the direct Anthropic provider instead of AWS Bedrock — does not
   reproduce with any tested SDK version (0.3.150–0.3.156) on direct Anthropic.
2. Filter empty thinking blocks client-side before rendering/persisting:
   ```ts
   const visibleBlocks = msg.message.content.filter(
     b => !(b.type === "thinking" && !b.thinking.trim())
   );
   ```

**Status:** Open — regression introduced between v0.3.150 and v0.3.152.

---

### KI 2 — Interrupted assistant message indistinguishable from normal completion at emit time

**Source:** [anthropics/claude-agent-sdk-typescript #338](https://github.com/anthropics/claude-agent-sdk-typescript/issues/338) · opened 2026-05-29 · open

**Symptom:** When `session.interrupt()` aborts an in-flight model stream, the SDK
emits a truncated `SDKAssistantMessage` (with partial content and
`stop_reason: null`) *before* the `result` message that signals the abort.
Because `stop_reason` is `null` even on **normal** completed assistant messages,
consumers cannot distinguish a truncated partial from a completed message at the
moment they receive it. The only reliable discriminator —
`result.terminal_reason === "aborted_streaming"` — arrives after the partial has
already been pushed downstream.

**Reproduction:**

```ts
const session = query({
  prompt: asyncIterable,
  options: { model: "claude-opus-4-7", permissionMode: "bypassPermissions",
             allowDangerouslySkipPermissions: true },
});

setTimeout(() => session.interrupt(), 4000);

for await (const msg of session) {
  if (msg.type === "assistant") {
    // stop_reason is null here for BOTH interrupted and normal cases
    console.log("stop_reason:", msg.message.stop_reason);  // → null
  }
  if (msg.type === "result") {
    console.log("terminal_reason:", msg.terminal_reason);  // → "aborted_streaming"
  }
}
```

**Workaround:** Buffer assistant messages and defer rendering/processing until the
`result` message arrives, then check `result.terminal_reason`:

```ts
const assistantMsgs: SDKAssistantMessage[] = [];

for await (const msg of session) {
  if (msg.type === "assistant") {
    assistantMsgs.push(msg);
    continue;
  }
  if (msg.type === "result") {
    const truncated = msg.terminal_reason === "aborted_streaming";
    if (truncated && assistantMsgs.length > 0) {
      // Last assistant message was cut off — mark or discard it
      markAsPartial(assistantMsgs[assistantMsgs.length - 1]);
    }
    renderAll(assistantMsgs);
  }
}
```

**Status:** Open — `stop_reason` is `null` for both interrupted and normal-completion
assistant messages; no field on the assistant message itself distinguishes the two.

---

*See also: [`rules/claude-agent-sdk-ts.md`](rules/claude-agent-sdk-ts.md)
+ [`rules/claude-agent-sdk-py.md`](rules/claude-agent-sdk-py.md) for
edit-time auto-correction patterns, and
[`SKILL-typescript.md`](SKILL-typescript.md) /
[`SKILL-python.md`](SKILL-python.md) for the canonical API references.*
