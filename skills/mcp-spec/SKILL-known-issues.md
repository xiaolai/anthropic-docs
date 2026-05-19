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

### KI 1 — `outputSchema` type restriction interop: TypeScript/C# require `type:"object"`, Python/prose do not

**Symptom:** Tools using the Python `mcp` SDK can define an `outputSchema` with a
root type other than `object` (e.g. `type: "array"` for list operations). When
such a tool connects to a client using the TypeScript or C# SDK, the client
rejects the schema with a validation error because those SDKs enforce
`type: "object"` at the root.

**Reproduction:** Define a tool in Python with
```python
output_schema = {"type": "array", "items": {"type": "string"}}
```
and connect via a TypeScript-SDK-based client → schema validation fails.

**Root cause:** The JSON Schema definition in `schema/draft/schema.json` sets
`"const": "object"` on the `outputSchema.type` field, but the prose
specification does not require `type: "object"`. This prose/schema
disagreement caused the Python and C# SDKs to implement contradictory
behaviours.

**Workaround:** Until the spec is resolved, always wrap results in an object
schema to ensure cross-SDK compatibility:
```json
{
  "outputSchema": {
    "type": "object",
    "properties": {
      "results": { "type": "array", "items": { "type": "string" } }
    }
  }
}
```

**Status:** Open — being tracked for spec clarification via an SEP
(sponsored by @olaservo). Monitor
[issue #1906](https://github.com/modelcontextprotocol/modelcontextprotocol/issues/1906)
for resolution.

**Affects:** All servers using `outputSchema` with non-object root types;
cross-SDK interoperability (Python ↔ TypeScript/C# clients).

---

*See also: [`rules/mcp-server-impl.md`](rules/mcp-server-impl.md) for
edit-time auto-correction patterns when implementing MCP servers, and
[`SKILL-protocol.md`](SKILL-protocol.md) /
[`SKILL-clients.md`](SKILL-clients.md) /
[`SKILL-servers.md`](SKILL-servers.md) for the canonical references.*
