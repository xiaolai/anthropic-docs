---
name: claude-connectors-mcp-apps-design
description: Edit-time rules for MCP App UI code that renders inside Claude Desktop. Catches patterns that break out of the conversational flow — long-form content, deep navigation, dropdowns that clip, chat-input duplication — per the claude.com design guidelines.
appliesTo:
  - "**/mcp-apps/**/*.tsx"
  - "**/mcp-apps/**/*.jsx"
  - "**/mcp-apps/**/*.html"
  - "**/mcp-apps/**/*.css"
---

# MCP Apps Design Rules

## Rule 1 — Inline cards max 500px height, 2 actions, 4-5 data points

Inline cards embedded directly in conversation should fit content
under 500px tall. Beyond that, prefer the full-screen display mode.
Cards that try to scroll internally compete with the conversation
scroll and produce a bad UX. Also: max 2 actions (at the bottom of
the card); max 4-5 data points per card.

```tsx
// WRONG — explicit large height
<div style={{ height: '800px', overflow: 'auto' }}>...</div>

// RIGHT — auto-fit content, cap at the display mode's natural max
<div style={{ maxHeight: '500px', overflow: 'visible' }}>...</div>
```

## Rule 2 — No nested scrolling

Inline cards should auto-fit content height. Internal scroll containers
get clipped by the host's container boundaries — content disappears
without a scrollbar the user can grab.

If you need pagination / virtualization, use the full-screen mode, not
an inline card.

## Rule 3 — No dropdowns, context menus, popovers

These get clipped by container boundaries OR create z-index conflicts
with the host's own UI chrome. Either way: invisible to the user.

Prefer:
- **Segmented buttons** for 2-5 mutually exclusive options
- **Toggles** for boolean state
- **Inline options** rendered visibly in the card
- **Expanded view** for any UI that needs popups

## Rule 4 — Don't render chat input or message lists

Claude already has these. Replicating them inside an MCP App breaks
the convention that the App extends the conversation, not replaces
it.

## Rule 5 — Use transparent backgrounds + Claude style variables

Set `background: transparent` on your root and inherit Claude's CSS
custom properties (theme variables) so your widget visually melts
into the host UI in both light and dark modes.

```css
:root {
  background: transparent;
  color: var(--claude-text-color);
  font-family: var(--claude-font-family);
}
```

## Rule 6 — Implement instance supersession

If your tool can be called multiple times per conversation, ensure
only the **newest** widget instance is active. Use the MCP App SDK's
supersession API rather than letting old widget instances pile up
and consume DOM / memory.

## Rule 7 — Handle `ui/open-link` correctly

For external links, use the MCP App SDK's `openLink()` (which honors
the user's confirmation modal and the directory's allowlist).

```tsx
// WRONG — bypasses Claude's link confirmation
<a href="https://external.com">Open</a>

// RIGHT — uses the host's link handler
<button onClick={() => mcpApp.openLink('https://external.com')}>Open</button>
```

## Rule 8 — Test on mobile viewports, honor safe-area insets

Claude Mobile renders MCP Apps in a native WebView (WKWebView on iOS,
WebView on Android) — NOT a sandboxed iframe. Design for 320pt minimum
width. Read `hostContext.safeAreaInsets` (`{top, right, bottom, left}`
in pixels) and respect notch / home-indicator clearances.

Touch targets must be at least **44 × 44pt** (Apple HIG / Material
guidelines). Space interactive elements to avoid mis-taps.

## Rule 9 — Declare CSP origins via `_meta.ui.csp`, not inline script

All external origins are blocked by default. Declare them per
`ui://` resource in `_meta.ui.csp`:

- `connectDomains` — `fetch` / XHR origins  
- `resourceDomains` — scripts, styles, fonts (also added to `script-src`, `style-src`)  
- `baseUriDomains` — `<base href>` origins  
- `frameDomains` — third-party iframes (currently restricted pending security review)

Never add `allow-same-origin` to a sandboxed iframe or inline scripts
that reach external origins without a proper CSP declaration.

## Rule 10 — Use `ui/request-display-mode` to switch display modes

Available enum values: `inline`, `fullscreen`, `pip`.
Declare your supported modes via `appCapabilities.availableDisplayModes`
in `ui/initialize`. The host replies with what it supports; only
then request a switch. Do not hard-code layout assumptions for a mode
the host hasn't confirmed.

---

*Source: claude.com/docs/connectors/building/mcp-apps/design-guidelines.md
and transparent-theming.md.*
