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

### KI 42 — Linux: musl binary preferred over glibc — "native binary not found" on pnpm/glibc hosts

**Source**: [`anthropics/claude-agent-sdk-typescript#296`](https://github.com/anthropics/claude-agent-sdk-typescript/issues/296) (8 reactions, 8 comments) — **Open**

**SDK version introduced**: v0.2.116

**Symptom**: On Linux with pnpm (which installs all optional platform packages including the musl variant), `query()` fails immediately:
```
Claude Code native binary not found at .../claude-agent-sdk-linux-x64-musl/claude.
```
The file referenced actually exists and is readable. Running it directly produces `cannot execute: required file not found` because the musl dynamic loader (`/lib/ld-musl-*`) is absent on glibc systems (Ubuntu, Debian, RHEL, etc.).

**Reproduction**:
- Use pnpm on a glibc Linux host
- Both `@anthropic-ai/claude-agent-sdk-linux-x64-musl` and `@anthropic-ai/claude-agent-sdk-linux-x64` get installed
- Call `query()` with any options

**Root cause**: `sdk.mjs` iterates Linux binary candidates in order `musl → glibc`. When pnpm installs both, `require.resolve()` succeeds for musl first and the SDK returns that path without checking if it actually executes on the current libc.

**Workaround**: Set `pathToClaudeCodeExecutable` explicitly to the glibc variant:
```typescript
import { execFileSync } from 'child_process';
// Use system-installed claude binary:
const claudePath = execFileSync('which', ['claude'], { encoding: 'utf8' }).trim();
const q = query({ prompt, options: { pathToClaudeCodeExecutable: claudePath } });
```
Or use npm/yarn instead of pnpm (they only install the platform-matching optional dep).

**Status**: Open; proposed fix in [#305](https://github.com/anthropics/claude-agent-sdk-typescript/issues/305) (community fix, pending maintainer integration). See also [`SKILL-typescript.md` § Known Issues #42](SKILL-typescript.md#42-linux--musl-binary-preferred-over-glibc-causing-native-binary-not-found-with-pnpm).

---

*See also: [`rules/claude-agent-sdk-ts.md`](rules/claude-agent-sdk-ts.md)
+ [`rules/claude-agent-sdk-py.md`](rules/claude-agent-sdk-py.md) for
edit-time auto-correction patterns, and
[`SKILL-typescript.md`](SKILL-typescript.md) /
[`SKILL-python.md`](SKILL-python.md) for the canonical API references.*
