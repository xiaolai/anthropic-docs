---
name: claude-connectors-mcpb-manifest
description: Edit-time correctness rules for MCPB (.mcpb) manifest.json files — the metadata Claude Desktop reads to install and run a local MCP server as a Desktop extension. Catches missing required fields, runtime / compatibility / entry_point mistakes, and user_config schema violations.
appliesTo:
  - "**/.mcpb/manifest.json"
  - "**/mcpb.manifest.json"
  - "**/manifest.json"
---

# MCPB Manifest (.mcpb) Rules

## Rule 1 — Required top-level fields

A valid MCPB manifest MUST include: `name`, `version`, `description`,
`runtime` (object), `entry_point`, and at minimum one of `tools` /
`resources` / `prompts` arrays.

```json
{
  "name": "my-mcpb",
  "version": "1.0.0",
  "description": "What this MCPB does, one sentence.",
  "runtime": { "name": "node", "version": ">=18" },
  "entry_point": "dist/server.js",
  "tools": []
}
```

Missing any of these blocks the install in Claude Desktop with a
manifest-validation error.

## Rule 2 — `runtime.name` is currently `node` or `python`

The MCPB runtime spec supports `node` (with bundled Node) and
`python` (requires user to have Python installed). Other values
(`go`, `bun`, `deno`, custom binaries) require packaging the runtime
yourself as a binary entry_point — they are NOT supported under the
`runtime.name` field.

## Rule 3 — `version` must be SemVer

Must parse as a valid SemVer string (`<major>.<minor>.<patch>` with
optional pre-release / build metadata). The directory uses the version
to compute upgrade deltas — non-SemVer versions break update flow.

- ✅ `1.0.0`, `0.1.2`, `2.0.0-beta.1`, `1.0.0+build.42`
- ❌ `v1.0`, `1.0`, `latest`, `2024-01-15`

## Rule 4 — `compatibility` must list real platform IDs

The supported platform IDs are `darwin` (macOS) and `win32` (Windows).
Linux is not currently supported in Claude Desktop. The platform IDs
match Node's `process.platform`.

```json
{
  "compatibility": {
    "platforms": ["darwin", "win32"]
  }
}
```

Listing `linux` is silently ignored; users on Linux can't install
Claude Desktop in the first place.

## Rule 5 — `user_config` types must be supported by the Desktop config UI

The user_config schema renders as a settings UI when the user
installs. Supported field types:

- `string`, `number`, `boolean`
- `secret_string` (renders as password input, encrypted at rest)
- `enum` with `options: [...]`
- `multi_select` with `options: [...]`
- `directory` (file picker, directory-only)
- `file` (file picker)

Custom JSON Schema types (oneOf, anyOf, patternProperties) are NOT
rendered — they'll either crash the installer or display as raw text
input.

## Rule 6 — Tool annotations are mandatory for directory submission

Every tool you declare must carry `annotations: { ... }` describing
its safety profile:

```json
{
  "name": "delete_file",
  "annotations": {
    "title": "Delete file",
    "readOnlyHint": false,
    "destructiveHint": true,
    "idempotentHint": false,
    "openWorldHint": false
  }
}
```

The Connectors Directory review fails MCPBs that omit these. For
internal-only MCPBs you can skip annotations, but they're still
strongly recommended (Claude uses them for permission prompts).

## Rule 7 — `entry_point` is relative to the manifest's directory

Path must be relative, must point at a file that exists in the
bundle. Absolute paths and `..` traversal are rejected at install
time.

## Rule 8 — Pin your dependencies

If your `entry_point` runs `npx <package>`, **pin the version**:
`npx -y @scope/server@0.6.2`. The bare `npx -y @scope/server`
re-resolves to the latest on every launch — a supply-chain
compromise of any future release runs immediately with whatever
capabilities your MCPB requests.

---

*Source: distilled from modelcontextprotocol/mcpb MANIFEST.md +
review-criteria.md + post-publishing.md.*
