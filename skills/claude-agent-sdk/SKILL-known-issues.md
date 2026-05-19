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

### KI 1 — Linux: musl binary preferred over glibc in SDK v0.2.116+

**Source**: [#296](https://github.com/anthropics/claude-agent-sdk-typescript/issues/296) | 8 reactions, 8 comments | Status: **Open** (fix PR [#305](https://github.com/anthropics/claude-agent-sdk-typescript/issues/305) in review)

**Symptom**: On Linux with pnpm (which installs all optional deps) or npm in some Docker images, `query()` fails with:
```
Claude Code native binary not found at
  .../claude-agent-sdk-linux-x64-musl/claude.
```
The referenced file **exists** — but is a musl-linked ELF that cannot run on a glibc system, causing the OS loader to return ENOENT for the dynamic linker path.

**Trigger**: Both `@anthropic-ai/claude-agent-sdk-linux-x64-musl` and `@anthropic-ai/claude-agent-sdk-linux-x64` platform packages are installed simultaneously. Since neither declares a `libc` field in `package.json`, pnpm cannot distinguish them and installs both. The SDK's auto-discovery resolves to the musl variant first.

**Affected environments**: Ubuntu, Debian, glibc-based Docker images (e.g., `node:22-slim`, `node:24-bookworm`), Amazon Linux, Alpine-glibc. Confirmed on SDK v0.2.114 through v0.2.119+.

**Workarounds**:

1. **Delete musl packages** (quickest):
   ```bash
   rm -rf node_modules/@anthropic-ai/claude-agent-sdk-linux-x64-musl
   rm -rf node_modules/@anthropic-ai/claude-agent-sdk-linux-arm64-musl
   ```

2. **Override musl packages in package.json** (pnpm):
   ```json
   "pnpm": {
     "overrides": {
       "@anthropic-ai/claude-agent-sdk-linux-x64-musl": "npm:@favware/skip-dependency@^1",
       "@anthropic-ai/claude-agent-sdk-linux-arm64-musl": "npm:@favware/skip-dependency@^1"
     }
   }
   ```

3. **Pin to pre-native version** (downgrade):
   Downgrade to `@anthropic-ai/claude-agent-sdk@0.2.112` (last version before native binary packages were introduced).

4. **Set `pathToClaudeCodeExecutable`** to the glibc binary explicitly:
   ```typescript
   const q = query({
     prompt: 'hello',
     options: {
       pathToClaudeCodeExecutable:
         './node_modules/@anthropic-ai/claude-agent-sdk-linux-x64/claude'
     }
   });
   ```

**Research date**: 2026-05-19

---

*See also: [`rules/claude-agent-sdk-ts.md`](rules/claude-agent-sdk-ts.md)
+ [`rules/claude-agent-sdk-py.md`](rules/claude-agent-sdk-py.md) for
edit-time auto-correction patterns, and
[`SKILL-typescript.md`](SKILL-typescript.md) /
[`SKILL-python.md`](SKILL-python.md) for the canonical API references.*
