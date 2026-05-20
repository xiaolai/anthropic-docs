---
name: claude-mcp-apps
description: |
  Deep reference for MCP Apps for Claude Desktop + Claude.ai —
  packaging via MCPB (.mcpb desktop extensions) and the visual +
  interaction design guidelines for the in-conversation app surface.
  Covers display modes (inline card, expanded view, sidebar),
  transparent theming, instance supersession, external link
  handling, cross-platform compatibility (Claude + ChatGPT), and
  the MCPB CLI / manifest schema.
source: https://claude.com/docs/connectors/building/mcp-apps/design-guidelines.md
---

# MCP Apps — Packaging (MCPB) + Design

> *Router lives in [`SKILL.md`](SKILL.md). For connector OAuth /
> submission workflow, see [`SKILL-connectors-building.md`](SKILL-connectors-building.md).
> This surface intentionally bundles MCPB packaging and MCP Apps
> design — both Desktop-specific and consulted together.*

## Part 1: MCPB (.mcpb) packaging for Claude Desktop

### What an MCPB is

An `.mcpb` file is a zip archive containing a local MCP server and
a `manifest.json`. It enables single-click installation in Claude
Desktop, similar to a browser extension.

Characteristics:

- Runs locally on the user's machine.
- Communicates via **stdio** transport.
- Bundles all dependencies.
- Works offline.
- No OAuth required.

Reference: [`building/mcpb.md`](https://claude.com/docs/connectors/building/mcpb.md).

> **Note:** MCPB is the **secondary** distribution path for the
> Connectors Directory — remote MCP servers are recommended for
> directory listing. Use MCPB for local/internal deployments,
> firewall-restricted environments, and offline use cases.

### MCPB vs remote: which to build

Build MCPB when you need:

- Access to systems behind a firewall (internal databases, JIRA,
  Confluence, private wikis).
- Direct filesystem access (code editing, Git operations).
- Integration with locally installed tools (Docker, IDEs).
- Zero-trust compliance inside corporate network boundaries.
- Privacy-sensitive operations that should not leave the user's
  machine.
- Hardware integration or desktop app control.
- One-click install with bundled Node.js, no dependencies to manage.
- Organization-level admin controls (custom uploads, allowlists).

Build a remote connector when you need:

- Cloud services + public APIs with centralized infrastructure.
- OAuth flows with server-side token management.
- Distribution across web, mobile, and desktop.
- Centralized updates pushed to all users.
- Public-facing integrations used by multiple organizations.

### Quickstart

```bash
# 1. Install the MCPB CLI
npm install -g @anthropic-ai/mcpb

# 2. Build a stdio MCP server using @modelcontextprotocol/sdk
#    (see mcp-spec → SKILL-servers.md)

# 3. Generate the manifest
mcpb init

# 4. Bundle
mcpb pack

# 5. Install in Claude Desktop — double-click the .mcpb file.
```

### Language choice

**Node.js is strongly recommended.** Node ships with Claude Desktop
on macOS and Windows — users need no separate runtime. Best
compatibility, best MCP SDK support. Other languages work but
require the user to install the runtime themselves.

### Platform support

Claude Desktop runs on macOS (`darwin`) and Windows (`win32`).
Specify supported platforms in the `compatibility` section of
`manifest.json`. Test on both even if you primarily develop on one.

### manifest.json

Required metadata: what the MCPB does, how to run it, which tools
it provides, what configuration it needs. Full schema:
[MCPB Manifest Spec](https://github.com/modelcontextprotocol/mcpb/blob/main/MANIFEST.md).

Key fields (see [MCPB Manifest Spec](https://github.com/modelcontextprotocol/mcpb/blob/main/MANIFEST.md) for full schema):

- `manifest_version` — spec version (currently `"0.3"`); required.
- `name`, `version`, `description` — discoverability.
- `author` — required object; must include `name` string.
- `server` — required object containing:
  - `type` — `"node"` or `"python"` (or `"binary"` for other runtimes).
  - `entry_point` — relative path to your MCP server's entrypoint.
  - `mcp_config` — launch config: `command`, `args`, optional `env`.
- `compatibility` — supported OS list; valid platforms: `darwin`, `win32`.
- `tools` — declared tool list with annotations.
- `icons` — icon paths, optionally per theme (light/dark) and size.
- `user_config` — generates a settings UI in Claude Desktop.

### Installation paths (user-facing)

1. **Double-click** the `.mcpb` file.
2. **Drag and drop** into the Claude Desktop window.
3. **Settings → Extensions → Advanced settings → Install Extension…**

All three open an installation UI for review + permission grant.

### Submission to the Connectors Directory

If your MCPB has broader value, submit to the directory:
[`building/submission.md`](https://claude.com/docs/connectors/building/submission.md).
Requires mandatory tool annotations, privacy policy, working
examples per tool, test credentials, and review per
[`review-criteria.md`](https://claude.com/docs/connectors/building/review-criteria.md).

---

## Part 2: MCP Apps design guidelines

> Source: [`building/mcp-apps/design-guidelines.md`](https://claude.com/docs/connectors/building/mcp-apps/design-guidelines.md).

### Core principles

MCP Apps are interactive interfaces inside Claude's conversation —
**natural extensions of the conversation**, not separate apps that
happen to appear alongside.

- **Conversational** — fit naturally into dialogue.
- **Contextual** — use conversation history to inform display.
- **Integrated** — inherit styling and conventions from the host.
- **Adaptive** — variable sizing, mobile viewports, accessibility.

> See Anthropic's [Figma UI kit](https://www.figma.com/community/file/1597641111449594397/mcp-apps-for-claude)
> for components.

### Good vs bad candidates

**Good MCP Apps:**

- Data analysis, document review, project coordination.
- Communication artifacts — message search results, threads, profiles.
- Tasks with clear start/end — booking, ordering, scheduling.
- Information users can act on immediately.

**Avoid:**

- Long-form / static content better viewed externally (>500px height).
- Complex multi-step workflows beyond the display-mode scope.
- Deep navigation (no drill-ins, breadcrumbs, multi-views).
- Nested scrolling (inline cards should auto-fit content height).
- Menus and popovers — dropdowns/context menus/popovers get clipped
  by container boundaries or create z-index conflicts. Prefer visible
  controls (segmented buttons, toggles, inline options).
- Chat inputs or conversational UI — don't replicate Claude's features.

### Display modes

Three display modes; declare support via `appCapabilities.availableDisplayModes`
in `ui/initialize` and request a switch with `ui/request-display-mode`.
Supported mode values: `inline`, `fullscreen`, `pip`.

- **Inline card** — compact, embedded directly in conversation. Good
  for summaries, confirmations, quick actions. Max height 500px; max
  2 actions; max 4-5 data points; no nested scroll.
- **Inline carousel** — side-by-side items (3–8) for browsing options
  (product listings, venue options, media galleries). Each card: image +
  title + metadata (≤3 lines) + optional CTA. Consistent card dimensions
  required.
- **Full screen** — immersive interfaces for data visualizations, detailed
  analysis, or document editing. Conversation composer stays visible.
  Apps provide their own fullscreen button; a close button appears in
  the native header. No floating panels — use collapsible sidebars, tabs,
  or pagination instead.

Source: [`mcp-apps/design-guidelines.md`](https://claude.com/docs/connectors/building/mcp-apps/design-guidelines.md).

### Transparent theming

Make your widget background transparent and style with Claude's
CSS custom properties — blends seamlessly into the host UI across themes.
The host passes `hostContext` (via `App.connect()`) with fields:
`theme` (`"light"`|`"dark"`), `styles.variables` (CSS custom properties),
and `styles.css.fonts` (`@font-face` rules from `https://assets.claude.ai`).

SDK helpers (all from `@modelcontextprotocol/ext-apps`):
- `applyDocumentTheme(theme)` — sets `<html data-theme>` + root `color-scheme`
- `applyHostStyleVariables(variables)` — writes tokens to `:root`
- `applyHostFonts(fontCss)` — injects `@font-face` rules
- React: `useApp(options)`, `useHostStyles(app, hostContext)`

To suppress the host border card: set `prefersBorder: false` in your
resource's `_meta.ui`. To allow host font loading: add
`csp: { resourceDomains: ["https://assets.claude.ai"] }` in `_meta.ui`.

**Content security policy:** All external origins are blocked by default.
Declare allowed origins per `ui://` resource via `_meta.ui.csp`:

```json
{
  "_meta": {
    "ui": {
      "csp": {
        "connectDomains": ["https://api.example.com"],
        "resourceDomains": ["https://cdn.example.com"],
        "baseUriDomains": []
      }
    }
  }
}
```

`frameDomains` (embedding third-party iframes) is currently restricted
pending security review.

Listen for `hostcontextchanged` on the `App` instance to re-apply on
theme switch.

Reference: [`mcp-apps/transparent-theming.md`](https://claude.com/docs/connectors/building/mcp-apps/transparent-theming.md).
Full CSS token table: [`mcp-apps/design-guidelines.md#style-variables`](https://claude.com/docs/connectors/building/mcp-apps/design-guidelines.md).

### Instance supersession

When a tool is called more than once in a conversation, keep only
the newest copy of the widget active. Prevents stale widgets from
piling up.

**Pattern:** Use `BroadcastChannel` across widget iframes (same origin
`*.claudemcpcontent.com`). The server stamps each tool result with an
election key (`{createdAt, seq}`) in `structuredContent` (the typed
JSON payload of an MCP tool result). Each widget reads its key from the
SDK's `toolresult` event, announces on the channel, and marks itself
superseded if a sibling has a newer key. Guard all calls to
`updateModelContext()` and `sendMessage()` with `if (!superseded)`.

Key SDK types involved: `structuredContent`, `App.toolresult` event,
`hostContext.toolInfo.id` (stable tool-use ID on Claude.ai web),
`_meta.ui.domain` (channel scope — see cross-compatibility section).

Reference: [`mcp-apps/instance-supersession.md`](https://claude.com/docs/connectors/building/mcp-apps/instance-supersession.md).

### External links

`ui/open-link` requests show a confirmation modal by default. Directory
connectors can declare **Allowed link URIs** at submission time to skip
the modal for trusted destinations.

Allowlist entry shapes:

| Shape | Example | Matches |
|---|---|---|
| HTTPS origin | `https://docs.example.com` | Exact hostname only (no implicit subdomain match) |
| Custom URI scheme | `example-app` or `example-app:` | Any URL with that scheme (e.g., deep links) |

Rejected scheme values: `http`, `https`, `file`, `data`, `javascript`,
`blob`, `mailto`, `tel`, `sms`, `intent`, `android-app`, browser-extension
schemes, Windows shell schemes (`search-ms`, `shell`), etc.

The modal is also shown when `ui/open-link` fires without a real user
gesture (programmatic, on a timer, or after the activation window expires).

Custom/local connectors always show the modal regardless of allowlist.

Reference: [`mcp-apps/external-links.md`](https://claude.com/docs/connectors/building/mcp-apps/external-links.md).

### Cross-platform compatibility (Claude + ChatGPT)

Build MCP Apps that work with both Claude and ChatGPT using a
single codebase. The SDK auto-detects the host via `App.connect()` —
no explicit transport parameter needed.

**`_meta.ui.domain` for Claude:** Compute as a SHA-256 hash of your
server URL, truncated to 32 hex chars + `.claudemcpcontent.com`:
```bash
node -e 'const u="https://example.com/mcp"; console.log(require("crypto").createHash("sha256").update(u).digest("hex").slice(0,32)+".claudemcpcontent.com")'
```
This domain is used for `BroadcastChannel` scope in instance supersession.

Reference: [`mcp-apps/cross-compatibility.md`](https://claude.com/docs/connectors/building/mcp-apps/cross-compatibility.md).

### Mobile guidelines

Claude Mobile renders MCP Apps in a native WebView (WKWebView on iOS,
WebView on Android) — not a sandboxed iframe. Mobile-specific constraints:

- Inline display only (fullscreen mode **coming soon** on mobile — apps render
  inline only for now).
- No camera, microphone, or location access.
- Connectors must be added via web or desktop before they appear on mobile.

**Layout hints from host:** `hostContext.safeAreaInsets` — `{top, right,
bottom, left}` in pixels. Honor these to avoid notches, home indicators,
and the composer overlay.

Apps fill the container width — design responsively from 320px up using
container queries and host CSS variables. Inline max height is 500px.

Tap targets minimum 44×44pt (Apple HIG / Material guidelines). Test at
360px viewport width minimum. Dark mode is required — use the host's style
tokens; never hardcode colors.

Show skeleton screens (not spinners) while inline content loads.

### Getting started

[`mcp-apps/getting-started.md`](https://claude.com/docs/connectors/building/mcp-apps/getting-started.md)
walks through testing MCP Apps in Claude. Official example servers (all
from `@modelcontextprotocol/ext-apps` repo): Customer Segmentation, Map,
QR Code, ShaderToy, Sheet Music, [and more](https://github.com/modelcontextprotocol/ext-apps/tree/main/examples).
Install via `npx -y @modelcontextprotocol/<name>-server --stdio`.

**MCP Apps skills for AI coding agents:** Works with Claude Code, Cursor, Gemini CLI,
and any agent that supports the [Agent Skills](https://agentskills.io) standard.
Install in Claude Code with:
```
/plugin marketplace add modelcontextprotocol/ext-apps
/plugin install mcp-apps@modelcontextprotocol-ext-apps
```
Then ask the agent: "Create an MCP App" or "Add a UI to my MCP tool".

**Migrating from OpenAI Apps SDK:** See the [migration reference](https://modelcontextprotocol.github.io/ext-apps/api/documents/Migrate_OpenAI_App.html)
or ask an agent: "Migrate from OpenAI Apps SDK" / "Convert my OpenAI App to an MCP App".

### Troubleshooting

[`mcp-apps/troubleshooting.md`](https://claude.com/docs/connectors/building/mcp-apps/troubleshooting.md)
covers common rendering, theming, and link-handling issues.

## Page index

8 MCP-Apps + 1 MCPB source page under
[`https://claude.com/docs/connectors/building/`](https://claude.com/docs/connectors/building/):

| Page | Topic |
|---|---|
| `mcpb.md` | Build a Desktop extension with MCPB |
| `mcp-apps/getting-started.md` | Test MCP Apps in Claude |
| `mcp-apps/design-guidelines.md` | Visual + interaction design |
| `mcp-apps/transparent-theming.md` | Theme integration |
| `mcp-apps/instance-supersession.md` | Keep only the newest widget |
| `mcp-apps/external-links.md` | ui/open-link handling, allowlists |
| `mcp-apps/cross-compatibility.md` | Claude + ChatGPT in one codebase |
| `mcp-apps/troubleshooting.md` | Debugging rendering issues |

---

*Source pages: 9 under `claude.com/docs/connectors/building/` (MCPB
+ mcp-apps/* subtree).*
