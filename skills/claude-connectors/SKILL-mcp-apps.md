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

Declare which modes your app supports via `appCapabilities.availableDisplayModes`
in the `ui/initialize` response. The host acknowledges which modes it
supports; request a switch at runtime with `ui/request-display-mode`.
Mode values: `"inline"`, `"fullscreen"`, `"pip"`.

Three primary display modes (choose the one that matches your content's scope):

**Inline Card** — compact, embedded directly in conversation.
Constraints:

- Max **500px** height; auto-fit content (no internal scroll).
- Max **2 actions** visible; max **4–5 data points**.
- No multi-view drill-in or horizontal scrolling.
- Mobile tap targets ≥ 44pt.

**Inline Carousel** — side-scrolling item browser embedded in the
conversation. Use for browsing 3–8 comparable items (e.g., search
results, product listings):

- Each card: image + title + metadata (max 3 lines) + optional CTA.
- All cards must have consistent dimensions.

**Full Screen** — immersive interface for dashboards and complex
tools. The app provides its own fullscreen button; a close button
appears in the native header bar when fullscreen is active. The
conversation composer remains available. Avoid floating panels —
use collapsible sidebars or tabs instead.

**PiP (Picture-in-Picture)** — a compact floating overlay. Declare
`"pip"` in `appCapabilities.availableDisplayModes` to opt in.
Use for persistent-status widgets or media controls that should
remain visible while the user continues chatting.

### Visual design standards

- Use **host-provided tokens** (CSS custom properties) for all
  structural colours; use brand colours only for accents.
- Typography: three-level hierarchy (heading / body / caption) with
  two weights maximum.
- Icons: monochromatic, outlined.
- Maintain consistent border radii and spacing for native integration.

### Mobile-specific requirements

MCP Apps render in native **WebViews** (WKWebView on iOS, WebView on
Android — no iframe sandboxing) on Claude Mobile. Current mobile constraints:

- Inline-only display modes (fullscreen not yet available on mobile).
- No camera, microphone, or location access.
- Design responsively from **320px minimum** width (no fixed breakpoints —
  use container queries and `hostContext` CSS variables).
- Honor `hostContext.safeAreaInsets` (`{top, right, bottom, left}` in px)
  to keep content clear of notches and the home indicator.
- Set `_meta.ui.prefersBorder: false` to remove the outer card border.
- Support both light and dark themes automatically.

### Interaction boundaries

| Handle inside the MCP App | Route to Claude chat input |
|---|---|
| Direct manipulation (sliders, toggles, filtering) | Text entry and clarification requests |
| Selection and confirmation | Context-switching requests |
| In-app state transitions | Tasks that need Claude's language capabilities |

### CSS style variables

The host injects CSS custom properties (prefixed `--`) into every MCP App.
Key token categories (all auto-adapt to light/dark):

| Category | Examples |
|---|---|
| Background | `--color-background-primary`, `--color-background-secondary`, `-danger`, `-success`, `-warning` |
| Text | `--color-text-primary`, `--color-text-secondary`, `--color-text-inverse`, `-info`, `-danger` |
| Border | `--color-border-primary`, `--color-border-secondary`, `-info`, `-danger` |
| Ring (focus) | `--color-ring-primary`, `--color-ring-inverse` |
| Typography | `--font-sans`, `--font-mono`, `--font-weight-normal/medium/semibold/bold`, `--font-text-sm-size`, `--font-text-md-size` |
| Radius | `--border-radius-xs` (4px) through `--border-radius-xl` (12px) and `--border-radius-full` (9999px) |
| Border width | `--border-width-regular` (0.5px) |
| Shadow | `--shadow-hairline`, `--shadow-sm`, `--shadow-md`, `--shadow-lg` |

The full color table (light / dark hex values for each token) lives in
[`mcp-apps/design-guidelines.md`](https://claude.com/docs/connectors/building/mcp-apps/design-guidelines.md).

### Transparent theming

Reference: [`mcp-apps/transparent-theming.md`](https://claude.com/docs/connectors/building/mcp-apps/transparent-theming.md).

Three required settings to blend seamlessly into the host UI:

1. **Transparent backgrounds** — set both `<html>` and `<body>` to
   `background: transparent`. Any opaque background hides the chat
   surface behind it.
2. **Color-scheme meta tag** — `<meta name="color-scheme" content="light dark" />`
   prevents browsers from applying opaque backdrops.
3. **Borderless frame** — pass `prefersBorder: false` in your UI
   resource's `_meta.ui` object when calling `registerAppResource()`.

SDK helper functions (preferred over manual DOM manipulation):

| Function | Effect |
|---|---|
| `applyDocumentTheme(theme)` | Sets theme attributes |
| `applyHostStyleVariables(variables)` | Applies CSS custom properties |
| `applyHostFonts(fontCss)` | Injects `@font-face` rules |
| `useHostStyles()` | React hook that calls all three |

The `hostContext` object provides `theme` (`"light"` \| `"dark"`),
`styles.variables` (all `--color-*`, `--font-*`, `--border-*`, etc.
tokens), and `styles.css.fonts` (`@font-face` rules for Anthropic
Sans). Register a `hostcontextchanged` listener before connecting to
catch dark-mode toggles.

**CSP**: add `https://assets.claude.ai` to `resourceDomains` in
`_meta.ui.csp` to load Anthropic Sans fonts.

```css
/* Apply with fallbacks */
color: var(--color-text-primary, light-dark(#141413, #faf9f5));
```

### Instance supersession

Reference: [`mcp-apps/instance-supersession.md`](https://claude.com/docs/connectors/building/mcp-apps/instance-supersession.md).

When a tool is called more than once in a conversation, multiple
iframes mount. Use `BroadcastChannel` to disable older instances:

1. **Server stamps each result** with `{ createdAt, seq }` in
   `structuredContent`. This ordering key is written into the
   transcript, so rehydrated widgets on any device recover the same
   ordering.
2. **Each widget announces its key** on a shared `BroadcastChannel`
   (named for your app) after the `toolresult` event fires.
3. **Widgets compare and self-disable** if a younger sibling exists —
   grey out the UI and short-circuit any calls that mutate Claude's
   context.

Sort by `createdAt` (primary), `seq` (tiebreaker), `instanceId`
(determinism). Never compare server and client timestamps directly.

### External links

How Claude handles `ui/open-link` requests; how directory connectors
can allowlist destinations to skip the confirmation modal.

Reference: [`mcp-apps/external-links.md`](https://claude.com/docs/connectors/building/mcp-apps/external-links.md).

### Cross-platform compatibility (Claude + ChatGPT)

Build MCP Apps that work with both Claude and ChatGPT from a single
codebase. The SDK auto-detects the host and applies the correct
transport — call `App.connect()` without specifying a transport.

The one platform-specific concern is `Resource._meta.ui.domain`.
For Claude, derive the value with a SHA-256 hash of your server URL:

```bash
node -e 'const url = "https://example.com/mcp"; \
  console.log(require("crypto").createHash("sha256") \
    .update(url).digest("hex").slice(0,32) + ".claudemcpcontent.com")'
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
