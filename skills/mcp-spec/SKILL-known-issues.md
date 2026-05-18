---
name: mcp-spec-known-issues
description: |
  Catalog of user-impacting bugs the daily research agent has confirmed
  in the MCP open spec or its TypeScript / Python SDKs. Entries link to
  the upstream GitHub issue, document the symptom + reproduction + a
  workaround if one exists.

  Use when a user reports an MCP protocol-level error, mentions an
  unexpected behavior in @modelcontextprotocol/sdk or the Python mcp
  package, or asks "is X a known issue in MCP?"

  Skip: questions about correct MCP usage (use SKILL-protocol /
  SKILL-clients / SKILL-servers), implementation patterns (use
  rules/mcp-server-impl.md), feature requests.
source: https://github.com/modelcontextprotocol/modelcontextprotocol/issues
---

# MCP — Known Issues

> Daily issue-tracker scans of
> [`modelcontextprotocol/modelcontextprotocol`](https://github.com/modelcontextprotocol/modelcontextprotocol)
> (the bug-tracker repo for this skill — see `config.json.upstream.bugTrackerRepo`)
> land confirmed user-impacting bugs here as `### KI N — <title>`
> entries. SDK-specific bugs (TypeScript-sdk or Python-sdk repos) are
> also surfaced here when they affect spec conformance.

## How entries land here

The research agent's Part B reads new bug-labeled issues in the
upstream repos. For each:

- **`added_known_issue`** → a new `### KI N — <title>` section here.
- **`added_rule`** → if auto-correctable at edit time, becomes a rule
  in [`rules/mcp-server-impl.md`](rules/mcp-server-impl.md) instead.
- **`skipped`** → recorded in `state.json.researchedIssues` with a
  reason.

## Entries

### KI 1 — Resource-not-found error code inconsistent across SDKs

**Symptom:** An MCP client trying to detect "resource not found" errors
receives different JSON-RPC error codes depending on which SDK the server
is built on.

**Reproduction:** Call `resources/read` with a non-existent URI against
servers built with different SDKs:

| SDK | Error code for resource-not-found |
|---|---|
| TypeScript (`@modelcontextprotocol/sdk`) | `-32602` (InvalidParams) |
| Python (`mcp`) | `0` (generic) |
| C# / Rust / Java / Go / PHP official SDKs | `-32002` (custom RESOURCE_NOT_FOUND) |
| Kotlin SDK | `-32603` (InternalError) |
| Ruby / Swift SDKs | Left to the server implementer |

The current spec's error-handling section recommends `-32002`, but the
TypeScript and Python SDKs diverge from this recommendation.

**Workaround:** Clients needing to detect resource-not-found should:
1. Treat `-32602`, `-32002`, `-32603`, and `0` as *potentially*
   resource-not-found, using the error `message` field to confirm.
2. When building a TypeScript SDK server, `-32602` is returned
   automatically by the SDK's built-in `resources/read` handler.
3. When building a Python SDK server, throw a custom `McpError` with
   `-32002` or `-32602` explicitly if you need clients to detect the case.

**Status:** [SEP-2164](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md)
(Draft, Standards Track, created 2026-01-28) proposes standardizing all
official SDKs to `-32602`. No merge date set yet.

**Link:** [SEP-2164: Standardize Resource Not Found Error Code](https://modelcontextprotocol.io/seps/2164-resource-not-found-error.md)

---

*See also: [`rules/mcp-server-impl.md`](rules/mcp-server-impl.md) for
edit-time auto-correction patterns when implementing MCP servers, and
[`SKILL-protocol.md`](SKILL-protocol.md) /
[`SKILL-clients.md`](SKILL-clients.md) /
[`SKILL-servers.md`](SKILL-servers.md) for the canonical references.*
