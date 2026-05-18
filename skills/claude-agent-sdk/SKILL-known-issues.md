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

### KI 42 — Linux: musl binary preferred over glibc in CLI auto-discovery (v0.2.116+)

**Symptom**: `Claude Code native binary not found at ...claude-agent-sdk-linux-x64-musl/claude` on glibc Linux (Ubuntu, Debian, Amazon Linux, etc.) despite a valid glibc installation. May also appear as `write EPIPE` or `SIGTRAP` crashes on container restart.

**Affected versions**: `@anthropic-ai/claude-agent-sdk` v0.2.116+  
**Source**: [#296](https://github.com/anthropics/claude-agent-sdk-typescript/issues/296) — 8 reactions, 8 comments; [#306](https://github.com/anthropics/claude-agent-sdk-typescript/issues/306)

**Root cause** (two-layer bug):
1. **Packaging**: The musl platform package (`claude-agent-sdk-linux-x64-musl`) lacks a `libc` field in `package.json`, so npm/pnpm install it on glibc hosts alongside the glibc variant.
2. **Runtime picker**: The SDK's binary resolver in `sdk.mjs` tries musl first, uses `require.resolve` (which only checks if the directory exists, not if the ELF loader is present), and does not fall back when `spawn()` fails with ENOENT.

**Impact**: Every Linux glibc deploy environment that upgrades from pre-v0.2.116 hits this on first call to `query()`. The error message "native binary not found" is misleading — the file exists but the musl ELF interpreter is absent on glibc.

**Workarounds** (in order of cleanliness):

1. **Explicit path** (simplest, works everywhere):
```typescript
import { createRequire } from 'node:module';
import path from 'node:path';

const require = createRequire(import.meta.url);

function getClaudeCodeExecutable(): string | undefined {
  if (process.platform !== 'linux') return undefined;
  const report = process.report?.getReport() as { header?: { glibcVersionRuntime?: string } } | undefined;
  const isMusl = !report?.header?.glibcVersionRuntime;
  const variant = isMusl ? `linux-${process.arch}-musl` : `linux-${process.arch}`;
  try {
    const pkgJson = require.resolve(`@anthropic-ai/claude-agent-sdk-${variant}/package.json`);
    return path.join(path.dirname(pkgJson), 'claude');
  } catch { return undefined; }
}

query({ prompt, options: { pathToClaudeCodeExecutable: getClaudeCodeExecutable() } });
```

2. **npm `overrides`** — stub out the musl package so the picker falls through to glibc:
```json
"overrides": {
  "@anthropic-ai/claude-agent-sdk": {
    "@anthropic-ai/claude-agent-sdk-linux-x64-musl": "npm:@favware/skip-dependency@^1",
    "@anthropic-ai/claude-agent-sdk-linux-arm64-musl": "npm:@favware/skip-dependency@^1"
  }
}
```

3. **Dockerfile symlink** — point the musl lookup path at the glibc binary:
```dockerfile
RUN mkdir -p /app/node_modules/@anthropic-ai/claude-agent-sdk-linux-x64-musl && \
    ln -sf /app/node_modules/@anthropic-ai/claude-agent-sdk-linux-x64/claude \
           /app/node_modules/@anthropic-ai/claude-agent-sdk-linux-x64-musl/claude
```

4. **Downgrade** to `@anthropic-ai/claude-agent-sdk@0.2.112` (last version before native binaries).

**Status**: Open — upstream fix pending (add `libc` field to platform packages and detect libc at runtime in the picker). See [#305](https://github.com/anthropics/claude-agent-sdk-typescript/issues/305) for a community-contributed fix PR.

---

### KI 43 — `outputFormat` silently returns `success` without `structured_output` for nested schemas

**Symptom**: When `outputFormat` is configured, the `ResultMessage` has `subtype: 'success'` but `structured_output` is `undefined` (key absent). The model produces correct JSON in the `result` text field (wrapped in markdown), but it is not extracted or validated into `structured_output`. The agent never returns `error_max_structured_output_retries`.

**Affected versions**: Confirmed v0.2.81–v0.2.97+  
**Source**: [#277](https://github.com/anthropics/claude-agent-sdk-typescript/issues/277) — 3 reactions, 6 comments

**Trigger**: Occurs with nested schemas (objects with nested objects/arrays/enums). Simple flat schemas (2–3 fields) work correctly.

**Impact**: Consumers cannot distinguish between "structured output succeeded" and "structured output enforcement silently failed" — both return `subtype: 'success'`. The documented contract (`error_max_structured_output_retries` for failures) is not upheld.

**Workaround** — embed the schema in the system prompt and parse `result` manually:
```typescript
const schemaJson = JSON.stringify(z.toJSONSchema(MySchema, { target: 'draft-07' }), null, 2);

for await (const message of query({
  prompt: userPrompt,
  options: {
    systemPrompt: {
      type: 'preset',
      preset: 'claude_code',
      append: `\n\nRespond with ONLY a valid JSON object matching this schema:\n${schemaJson}`
    },
    allowedTools: [],
    maxTurns: 15,
    permissionMode: 'bypassPermissions',
    allowDangerouslySkipPermissions: true,
  }
})) {
  if (message.type === 'result' && message.subtype === 'success' && message.result) {
    try {
      return MySchema.parse(JSON.parse(message.result));
    } catch {
      // Fallback: extract JSON from markdown fences
      const match = message.result.match(/```(?:json)?\s*\n([\s\S]*?)\n```/);
      if (match) return MySchema.parse(JSON.parse(match[1]));
    }
  }
}
```

**Status**: Open — no timeline for fix. The raw Messages API handles nested schemas correctly; this is an SDK-layer issue with how `outputFormat` enforcement works for multi-turn tool-use sessions.

---

*See also: [`rules/claude-agent-sdk-ts.md`](rules/claude-agent-sdk-ts.md)
+ [`rules/claude-agent-sdk-py.md`](rules/claude-agent-sdk-py.md) for
edit-time auto-correction patterns, and
[`SKILL-typescript.md`](SKILL-typescript.md) /
[`SKILL-python.md`](SKILL-python.md) for the canonical API references.*
