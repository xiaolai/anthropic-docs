> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Troubleshooting MCP Apps

> Debug and resolve common issues with MCP Apps in Claude Desktop

## Using developer tools

Claude Desktop's Developer Tools can help you debug MCP Apps. To use them:

1. Open **Help > Troubleshooting** and click **Enable Developer Mode**. A new **Developer** menu appears in the menu bar.
2. Open Developer Tools by pressing `Cmd+Option+I` (Mac) or `Ctrl+Shift+I` (Windows)
3. Inspect the tool call element and look for an iframe nested inside another iframe. Your app will be loaded as the content of the inner iframe.

<Tip>From the **Developer** menu, select **Reload MCP Configuration** after editing your `claude_desktop_config.json` to apply changes without restarting.</Tip>

## Problem: Tool call appears but the app is invisible

This is the most common issue when developing MCP Apps. Check these two causes:

### Missing `app.connect()` call

Your app must call [`app.connect()`](https://modelcontextprotocol.github.io/ext-apps/api/classes/app.App.html#connect) (Vanilla JS) or [`useApp()`](https://modelcontextprotocol.github.io/ext-apps/api/functions/_modelcontextprotocol_ext-apps_react.useApp.html) (React) to establish communication with Claude Desktop.

<CodeGroup>
  ```javascript Vanilla JS theme={null}
  import { App } from "@modelcontextprotocol/ext-apps";

  const app = new App({ name: "My App", version: "1.0.0" });

  // Register handlers before connecting
  app.ontoolresult = (result) => {
    // Handle tool results
  };

  await app.connect();
  ```

  ```javascript React theme={null}
  import { useApp } from "@modelcontextprotocol/ext-apps/react";

  function MyComponent() {
    // The useApp hook handles connection automatically
    const { app } = useApp({
      appInfo: { name: "My App", version: "1.0.0" },
      capabilities: {},
      onAppCreated: (app) => {
        app.ontoolresult = (result) => {
          // Handle tool results
        };
      }
    });
  }
  ```
</CodeGroup>

<Warning>Event handlers like `app.ontoolinput` and `app.ontoolresult` won't be invoked until the app is connected.</Warning>

### Iframe has zero height

Your app needs a non-zero height to be visible. A zero height can occur if:

* Your app's container has no content yet
* You called `sendSizeChanged({ width, height: 0 })`

Check that your root element has explicit dimensions or content that gives it height.

## Problem: App doesn't render when tool results are large

When a tool result exceeds approximately 150,000 characters and Claude's code execution sandbox is active, the result is written to the sandbox filesystem instead of being passed inline to the conversation. Your app receives a pointer to the stored file rather than the structured content it needs, so it never hydrates.

<Note>This \~150,000-character threshold is specific to Claude.ai and Claude Desktop. Claude Code uses a separate 25,000-token default limit configurable via `MAX_MCP_OUTPUT_TOKENS`.</Note>

To avoid this, keep initial tool result payloads lean:

* **Paginate large results.** Return a summary or the first page of data, and let the user request more through follow-up interactions.
* **Fetch details on demand.** Use app-initiated tool calls to load additional data from within your widget as the user explores, rather than returning everything upfront.
* **Defer heavy content.** If your data includes large blobs—full document text, base64-encoded images, extensive logs—return identifiers or previews in the initial result and provide a separate tool to retrieve the full content when needed.