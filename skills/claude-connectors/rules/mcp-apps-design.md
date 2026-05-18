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

## Rule 1 — Inline cards max 500px height

Inline cards embedded directly in conversation should fit content
under 500px tall. Beyond that, prefer the expanded-view display mode.
Cards that try to scroll internally compete with the conversation
scroll and produce a bad UX.

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
- **Full screen mode** for any UI that needs popups

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

## Rule 8 — Test on mobile viewports

Claude Mobile renders MCP Apps too. A card that's only laid out for
desktop widths breaks on mobile. Test at 360px width minimum.

---

*Source: claude.com/docs/connectors/building/mcp-apps/design-guidelines.md.*
