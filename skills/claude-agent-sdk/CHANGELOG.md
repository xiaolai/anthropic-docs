# Changelog

## 2026-03-18

- Research only, no version change (TS v0.2.77, Python v0.1.49 unchanged)
- TS: added KI #40 (file checkpointing no-op in SDK mode), KI #41 (subagents hardcoded to deny `bypassPermissions`)
- PY: added KI #23 (thinking=disabled breaks compatible providers), KI #24 (MCP tool calls fail after ~70s), KI #25 (output_format+resume broken), KI #26 (v0.1.49 incomplete PyPI wheels — Linux/Windows blocked), KI #27 (can_use_tool never fires — critical security no-op); new auto-correction rule for can_use_tool
- Typecheck false-positive (recurring script artifact, non-blocking)
- [Full report](reports/2026-03-18.md)

## 2026-03-17

- SDK TS v0.2.76 → v0.2.77; Python v0.1.48 → v0.1.49 (both bumped)
- TS v0.2.77: new `SDKAPIRetryMessage` (23rd type), `applyFlagSettings()`, `AccountInfo.apiProvider`, richer `CanUseTool` fields (`title`, `displayName`, `description`), new `'compact'` InstructionsLoaded load_reason
- Research: tracked 2 new TS issues (#230, #231, pending KI assignment); PY no new findings
- [Full report](reports/2026-03-17.md)

## 2026-03-16

- Research only, no version change (TS v0.2.76, Python v0.1.48 unchanged)
- TS: added `tagSession()` docs to SKILL-typescript.md (was exported but undocumented); updated BaseHookInput to include `agent_id?` / `agent_type?`; GitHub API unavailable, no new issues scanned
- PY: consistency audit passed (no changes); GH_TOKEN unavailable for issue scan
- Typecheck false-positive (recurring script artifact, non-blocking)
- [Full report](reports/2026-03-16.md)

## 2026-03-15

- Research only, no version change (TS v0.2.76, Python v0.1.48 unchanged)
- TS: added KI #37 (fast mode requires Bun binary, unavailable in Node.js), KI #38 (MCP zombie processes after session ends); updated KI #35 (sdk-tools export fixed in v0.2.76)
- PY: no new findings — version unchanged, GH_TOKEN unavailable for issue scan
- Typecheck false-positive (recurring script artifact, non-blocking)
- [Full report](reports/2026-03-15.md)

## 2026-03-14

- SDK TS v0.2.74 → v0.2.76; Python v0.1.48 unchanged
- Added `getSessionInfo()`, `forkSession()` APIs; `listSessions()` pagination (`offset`); `SDKSessionInfo` gains `tag`, `createdAt` fields; hook count 21 → 22
- Research agents found no new issues (all issues already current through TS #229, PY #672)
- [Full report](reports/2026-03-14.md)

## 2026-03-13

- Research only, no version change (TS v0.2.74, Python v0.1.48)
- PY: documented 3 hook output types (`PreToolUseHookSpecificOutput`, `PostToolUseHookSpecificOutput`, `UserPromptSubmitHookSpecificOutput`)
- TS: full API audit confirmed consistent; last-verified date updated
- Typecheck false-positive (recurring script artifact, non-blocking)
- [Full report](reports/2026-03-13.md)

## 2026-03-12

- SDK TS v0.2.72 → v0.2.74; Python v0.1.48 unchanged; verify passed (18/18, 1 mending run)
- TS: documented `renameSession()`, `agentProgressSummaries` option, `supportsAutoMode` model field
- PY: added KI #22 (early async generator exit poisons event loop); revised KI #2 (`allowed_tools` vs `tools` semantics); updated KI #14, #16, #17, #20
- Typecheck false-positive (recurring script artifact, non-blocking)
- [Full report](reports/2026-03-12.md)

## 2026-03-11

- Research only, no version change (TS v0.2.72, Python v0.1.48)
- TS: added KI #36 (settings.json env overrides options.env); changelog entries for v0.2.71 and v0.2.72
- PY: added KI #20 (multi-user session confusion) and KI #21 (include_partial_messages breaks Bedrock/Vertex); updated KI #14, #16, #17, #19
- Typecheck false-positive (recurring script artifact, non-blocking)
- [Full report](reports/2026-03-11.md)

## 2026-03-10

- SDK TS v0.2.71 → v0.2.72; Python v0.1.48 unchanged; verify passed (18/18, no mending)
- Python: added KI #18 (global settings override) and KI #19 (dict as options raises AttributeError); updated KI #16 and #17
- Typecheck false-positive (recurring script artifact, non-blocking)
- [Full report](reports/2026-03-10.md)

## 2026-03-09

- Research only, no version change (TS v0.2.71, Python v0.1.48)
- TS: added `prompt` field to `task_started` message subtype docs; PY: full API surface verified, no changes
- Typecheck step false-positive (script artifact, non-blocking); same issue as 2026-03-08
- [Full report](reports/2026-03-09.md)

## 2026-03-08

- Research only, no version change (TS v0.2.71, Python v0.1.48)
- Python: added subagent attribution docs, McpSdkServerConfigStatus/McpClaudeAIProxyServerConfig types, and TypedDict dot-notation rule (issue #623)
- Typecheck step false-positive (script artifact, non-blocking)
- [Full report](reports/2026-03-08.md)

## 2026-03-06

- SDK TS v0.2.69 → v0.2.70, Python v0.1.46 → v0.1.47; verify passed (28/28 checks, no mending)
- No new known issues added; typecheck step had a false-positive script error (not a template bug)
- [Full report](reports/2026-03-06.md)

## 2026-02-18

- SDK TS v0.2.44 → v0.2.45; verify passed after 2 mending runs (attempt 3 of 3)
- API docs updated: 2 new message types (task_started, RateLimitEvent), hook types fully typed, tool_progress field renamed elapsed_ms→elapsed_time_seconds
- Python: transport param added to query(), rewind_files() param renamed, output_format type corrected
- [Full report](reports/2026-02-18.md)

## 2026-02-17

- SDK v0.2.42 → v0.2.44 (TypeScript) and v0.1.36 → v0.1.37 (Python), verify passed after 1 mending run
- TypeScript: `canUseTool` API expanded with `toolUseID`, `agentID`, `blockedPath`, `decisionReason` fields
- Python: Known Issue #9 fix version corrected to v0.1.37; hook events count updated (6→10)
- [Full report](reports/2026-02-17.md)

## 2026-02-16

- Research only, no version change (TypeScript v0.2.42, Python v0.1.36)
- Python SDK: Added 5 new known issues (#10–#14), updated #3 with v0.1.35 fix
- Key additions: CLAUDECODE=1 env inheritance, search_result blocks dropped, FastAPI hanging, session fork failure, SDK MCP string prompts crash
- [Full report](reports/2026-02-16.md)

## 2026-02-15

- Research only, no version change (TypeScript v0.2.42, Python v0.1.36)
- Added 1 TypeScript rule for tool() API (requires ZodRawShape, not ZodObject)
- State maintenance: synced GitHub release tags
- [Full report](reports/2026-02-15.md)

## 2026-02-14

- Research only, no version change (TypeScript v0.2.42, Python v0.1.36)
- Python SDK: Added 9 known issues (#1–#9), applied 5 template fixes
- Key additions: Query.close() hang fix, FastAPI compatibility issue, allowed_tools=[] pitfall
- [Full report](reports/2026-02-14.md)

## 2026-02-13

- SDK v0.2.39 → v0.2.41 (verification failed on stale version in historical report)
- Added Known Issue #20 (Zod structured output requires draft-07 target)
- [Full report](reports/2026-02-13.md)

## 2026-02-12

- Research only, no version change
- Added 2 known issues (#18: v2 sessions don't support plugins, #19: subagent tool restrictions not enforced)
- [Full report](reports/2026-02-12.md)

## 2026-02-11

- Research only, no version change
- Added 6 known issues (#12–#17); evaluated 13 issues total
- [Full report](reports/2026-02-11.md)

## 2026-02-09

- Research only, no version change (SDK remains at v0.2.37)
- Added 6 known issues, 1 usage rule; evaluated 13 issues total
- [Full report](reports/2026-02-09.md)
