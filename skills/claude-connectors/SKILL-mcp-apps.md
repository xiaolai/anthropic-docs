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
CSS custom properties — blends seamlessly into the host UI across themes.

Three settings for transparency:
1. `html, body { background: transparent; }` — no opaque body background.
2. `<meta name="color-scheme" content="light dark" />` in `<head>` — prevents the
   browser's opaque canvas backdrop in dark mode.
3. Set `prefersBorder: false` in `_meta.ui` of your `registerAppResource()` call
   to suppress the host's bordered card wrapper.

The `hostContext` object delivered by the SDK after `connect()` contains:

| Field | Contents |
|---|---|
| `theme` | `"light"` or `"dark"` |
| `styles.variables` | CSS custom properties: `--color-background-*`, `--color-text-*`, `--color-border-*`, `--color-ring-*`, `--font-*`, `--border-radius-*`, `--border-width-*` |
| `styles.css.fonts` | `@font-face` rules for Anthropic Sans from `https://assets.claude.ai` |

Listen for `hostcontextchanged` events to track runtime theme switches. To allow
host fonts, add `csp: { resourceDomains: ["https://assets.claude.ai"] }` to `_meta.ui`.

Reference: [`mcp-apps/transparent-theming.md`](https://claude.com/docs/connectors/building/mcp-apps/transparent-theming.md).
Full CSS token table: [`mcp-apps/design-guidelines.md#style-variables`](https://claude.com/docs/connectors/building/mcp-apps/design-guidelines.md).

### Instance supersession

When a tool is called more than once in a conversation, keep only
the newest copy of the widget active. Prevents stale widgets from
piling up.

**Implementation pattern** (using `BroadcastChannel`):

All widget iframes from one connector share the same sandbox origin on
`*.claudemcpcontent.com` (`allow-same-origin` is set), so a `BroadcastChannel`
in one instance reaches all sibling instances.

Three-step pattern:
1. **Server** stamps each tool result with an election key `{createdAt, seq}` in
   `structuredContent` (typed JSON in MCP tool result). This is stored in the
   conversation transcript so every device/remount sees the same key.
2. **Widget** reads its key from the SDK's `toolresult` event and broadcasts on a
   shared `BroadcastChannel`.
3. Any widget that sees a younger sibling marks itself superseded (disables buttons,
   stops updating model context).

> Use server wall-clock time + a monotonic counter, not `Date.now()` client-side —
> widgets may mount out of order when a stored conversation is reopened.

Reference: [`mcp-apps/instance-supersession.md`](https://claude.com/docs/connectors/building/mcp-apps/instance-supersession.md).

### External links

Claude shows a confirmation modal for every `ui/open-link` request. Directory
connectors can allowlist destinations that skip the modal; custom/local connectors
always show it.

**Allowlist entry shapes** (provide in the "Allowed link URIs" field when submitting):

| Shape | Example | Matches |
|---|---|---|
| HTTPS origin | `https://docs.example.com` | Exact hostname only; subdomains don't match implicitly; port ignored |
| Custom URI scheme | `example-app` or `example-app:` | Any URL with that scheme (e.g. deep links) |

Bare hostnames (`example.com`), `http://` origins, and malformed values are ignored.
Generic/reserved schemes (`http`, `https`, `file`, `javascript`, `mailto`, etc.) are rejected.

**User-activation requirement:** the modal bypass only works when `ui/open-link`
follows a real user gesture (button click). Programmatic or timer-fired requests
always show the modal.

Reference: [`mcp-apps/external-links.md`](https://claude.com/docs/connectors/building/mcp-apps/external-links.md).

### Cross-platform compatibility (Claude + ChatGPT)

Build MCP Apps that work with both Claude and ChatGPT using a
single codebase. Worth the constraints if your audience spans both.

Key API surface:
- Use `registerAppTool()` and `registerAppResource()` — they auto-generate
  platform-specific metadata; write once, works on both hosts.
- Call `App.connect()` without an explicit transport — the SDK detects Claude vs ChatGPT
  and picks the right transport automatically.
- `Resource._meta.ui.domain` format is host-determined. For Claude, compute via SHA-256 of
  your server URL (lower-case hex, first 32 chars + `.claudemcpcontent.com`):

```shell
node -e 'const u="https://example.com/mcp"; console.log(require("crypto").createHash("sha256").update(u).digest("hex").slice(0,32)+".claudemcpcontent.com")'
```

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
