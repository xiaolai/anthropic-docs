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

Key fields:

- `name`, `version`, `description` — discoverability.
- `runtime` — Node version requirements (default: bundled runtime).
- `compatibility` — supported OS list.
- `entry` — path to your MCP server's entrypoint.
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
CSS custom properties. Key steps:

1. Set `html, body { background: transparent; }` — any opaque background
   hides the chat surface.
2. Add `<meta name="color-scheme" content="light dark" />` in your document
   `<head>` so the browser drops its opaque canvas backdrop.
3. Set `prefersBorder: false` in your UI resource's `_meta.ui` object so
   the host doesn't wrap your widget in a bordered card.

The SDK delivers a [`hostContext`](https://modelcontextprotocol.github.io/ext-apps/api/interfaces/app.McpUiHostContext.html)
object with theming data during `connect()`:

| Field | Contents |
|---|---|
| `theme` | `"light"` or `"dark"` |
| `styles.variables` | CSS custom properties: `--color-background-*`, `--color-text-*`, `--color-border-*`, `--color-ring-*`, `--font-*`, `--border-radius-*`, `--border-width-*` |
| `styles.css.fonts` | `@font-face` rules for Anthropic Sans (served from `https://assets.claude.ai`) |

Read the initial context via `App.getHostContext()` after `connect()`
resolves; subscribe to subsequent changes (e.g., user toggles dark mode)
via the `hostcontextchanged` event. Register the listener **before**
calling `connect()`.

To load Anthropic Sans, include `csp: { resourceDomains: ["https://assets.claude.ai"] }`
in your `_meta.ui` object.

Register the resource with `registerAppResource` / `RESOURCE_MIME_TYPE`
from `@modelcontextprotocol/ext-apps/server`.

Reference: [`mcp-apps/transparent-theming.md`](https://claude.com/docs/connectors/building/mcp-apps/transparent-theming.md).
Full CSS token table: [`mcp-apps/design-guidelines.md#style-variables`](https://claude.com/docs/connectors/building/mcp-apps/design-guidelines.md).

### Instance supersession

When a tool is called more than once in a conversation, keep only
the newest copy of the widget active. Prevents stale widgets from
piling up.

All widget iframes from a single connector share the same sandbox origin
(`*.claudemcpcontent.com` with `allow-same-origin`), so a `BroadcastChannel`
opened in one instance reaches every sibling in the same conversation.

**Pattern:**

1. **Server** stamps each tool result with an election key (`{createdAt, seq}`)
   in `structuredContent` (the typed JSON payload slot of an MCP tool result).
   Use `registerAppTool` from `@modelcontextprotocol/ext-apps/server`.
2. **Widget** reads its key from the `toolresult` event (delivered by the SDK
   after `connect()` resolves), then broadcasts the key on a `BroadcastChannel`.
3. Any widget that sees a younger sibling marks itself superseded (greyed out,
   buttons disabled).

Use server-minted keys (`structuredContent` values) rather than
client-side `Date.now()` — on stored-conversation reopen, widgets mount
as they scroll into view, so client timestamps don't reflect tool-call
order.

Reference: [`mcp-apps/instance-supersession.md`](https://claude.com/docs/connectors/building/mcp-apps/instance-supersession.md).

### External links

`ui/open-link` requests show an "Open external link" confirmation modal
by default. Directory connectors can declare trusted destinations that
open without the modal via the **Allowed link URIs** field in directory
submission.

**Allowlist entry shapes:**

| Shape | Example | Matches |
|---|---|---|
| HTTPS origin | `https://docs.example.com` | Exact hostname only; subdomains must be listed separately; port not compared |
| Custom URI scheme | `example-app` or `example-app:` | Any URL with that scheme (e.g., deep links) |

Rejected shapes: bare hostnames (`example.com`), `http://` origins,
malformed values, and reserved schemes (`http`, `https`, `file`, `data`,
`javascript`, `blob`, `mailto`, `tel`, `sms`, `intent`, `android-app`, etc.).

Bypassed links also require a real user gesture (button click) in the
widget. Programmatic or timer-triggered `ui/open-link` calls always show
the modal.

Custom connectors and locally configured servers always show the modal
(no allowlist support). Design your UI so it works with the modal present.

Reference: [`mcp-apps/external-links.md`](https://claude.com/docs/connectors/building/mcp-apps/external-links.md).

### Cross-platform compatibility (Claude + ChatGPT)

Build MCP Apps that work with both Claude and ChatGPT using a
single codebase. Worth the constraints if your audience spans both.

Reference: [`mcp-apps/cross-compatibility.md`](https://claude.com/docs/connectors/building/mcp-apps/cross-compatibility.md).

### Getting started

[`mcp-apps/getting-started.md`](https://claude.com/docs/connectors/building/mcp-apps/getting-started.md)
walks through testing MCP Apps in Claude.

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
