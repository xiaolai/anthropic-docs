# MCP server version pinning

`templates/.mcp.json` ships with **pinned** package versions on every `npx`
invocation. This is deliberate — the unpinned `npx -y <pkg>` pattern that
appears in many MCP tutorials is a supply-chain risk:

| Pattern | What happens at startup |
|---|---|
| `npx -y @scope/server` | npm resolves to the **latest** version every time. A compromise of any future release runs immediately with whatever permissions the MCP server requests. |
| `npx -y @scope/server@^0.6` | npm resolves to the latest **0.6.x**. A compromise within that minor range still runs. |
| `npx -y @scope/server@0.6.2` *(recommended)* | npm resolves to the **exact** version. A compromise affects you only when you deliberately bump. |

## How to update the templates

1. Verify the latest stable version on npmjs.com (or the project's GitHub
   release tags). Read the changelog and look specifically for:
   - **New required capabilities** (filesystem write, network egress,
     credentials access) — these require user re-consent, not silent
     auto-update.
   - **Removed or renamed transports / protocol versions** — a server
     that drops `stdio` support breaks every `.mcp.json` that pins it.
   - **Auth-flow changes** — environment-variable renames or new token
     scopes that change which secrets the server reads.
   - **Major version bumps** — never cross a major boundary without
     reading the migration notes; minor and patch can be batched.
2. Update the version pin in `templates/.mcp.json`.
3. Test locally by pointing your own `.mcp.json` at the same pinned
   version and running the MCP client end-to-end before committing.
4. Add a CHANGELOG entry naming the old + new versions and the reason
   for the bump (security fix, capability you need, deprecation).

## What the example versions in this repo mean

The versions checked in here are **illustrative** — they exist in npm at the
time the template was written but may be stale by the time you read this.
Treat them as "this is the pinning idiom", not "these are the right versions
for your project today". Bump before deploying.

## Why this matters for an MCP server specifically

MCP servers run as subprocesses with the privileges of your shell. A
compromised filesystem server can read every file the user can read; a
compromised GitHub server has the user's GitHub token. The blast radius of
"latest" is larger here than for most npm packages because MCP servers
deliberately ask for sensitive capabilities.
