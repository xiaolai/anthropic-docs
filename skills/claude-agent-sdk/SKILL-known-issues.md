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

### KI 1 — Linux: musl binary incorrectly preferred over glibc (SDK v0.2.114+)

**Symptom**: On Linux, `query()` fails immediately with `"Claude Code native binary not found at ..."` or `EPIPE`/`ENOENT`/`SIGTRAP` errors, even though the Claude Code binary physically exists in `node_modules`.

**Affected versions**: `@anthropic-ai/claude-agent-sdk` v0.2.114 and later (when native binary packages were first introduced).

**Cause**: The CLI auto-discovery logic in `sdk.mjs` probes the musl-linked ELF variant before the glibc variant on Linux. On glibc-based systems (Debian, Ubuntu, Amazon Linux 2, most containers), the musl binary is present (pnpm installs all optional deps for the current CPU architecture; some npm setups also end up with it) but cannot execute because the musl dynamic linker is missing. The error message says "binary not found" even though the file exists, making the root cause obscure.

**Reproduction**:
- pnpm (any version): installs both `@anthropic-ai/claude-agent-sdk-linux-x64` and `@anthropic-ai/claude-agent-sdk-linux-x64-musl` (no `libc` field to distinguish them)
- npm on some glibc images: musl package still resolved/probed first despite it being uninstallable

**Workarounds** (choose one):

1. **Remove the musl package** (simplest for Docker builds):
   ```sh
   rm -rf node_modules/@anthropic-ai/claude-agent-sdk-linux-x64-musl
   ```

2. **npm overrides** — tell npm to replace musl packages with a no-op:
   ```json
   "overrides": {
     "@anthropic-ai/claude-agent-sdk": {
       "@anthropic-ai/claude-agent-sdk-linux-x64-musl": "npm:@favware/skip-dependency@^1",
       "@anthropic-ai/claude-agent-sdk-linux-arm64-musl": "npm:@favware/skip-dependency@^1"
     }
   }
   ```

3. **Pin explicit path** — bypass auto-discovery entirely:
   ```typescript
   import { execFileSync } from 'child_process';
   const claudePath = execFileSync('which', ['claude'], { encoding: 'utf8' }).trim();
   for await (const msg of query({ prompt: "...", options: { pathToClaudeCodeExecutable: claudePath } })) { ... }
   ```

4. **Downgrade** to v0.2.112 (last version before native binary packages).

**Status**: Fix open (PR [#305](https://github.com/anthropics/claude-agent-sdk-typescript/issues/305)) — not yet released. Track issue [#296](https://github.com/anthropics/claude-agent-sdk-typescript/issues/296).

---

*See also: [`rules/claude-agent-sdk-ts.md`](rules/claude-agent-sdk-ts.md)
+ [`rules/claude-agent-sdk-py.md`](rules/claude-agent-sdk-py.md) for
edit-time auto-correction patterns, and
[`SKILL-typescript.md`](SKILL-typescript.md) /
[`SKILL-python.md`](SKILL-python.md) for the canonical API references.*
