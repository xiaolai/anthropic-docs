> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Connectors overview

> Connect Claude to external tools, data, and UI through MCP

Connectors extend Claude's capabilities by connecting it to external tools and data sources. They are powered by the [Model Context Protocol (MCP)](/connectors/building/mcp), an open standard created by Anthropic that provides a unified way for AI applications to interact with the outside world.

## How connectors work

Connectors can do two things:

* **Provide tools and information** — Give Claude access to external data and the ability to take actions (search files, read emails, create issues, etc.)
* **Surface UI components** — Render interactive visual elements directly in the conversation through [MCP Apps](/connectors/building/mcp-apps/getting-started)

<Note>
  **Building for Claude?** Most partners ship both a remote MCP server and a plugin that wraps it with skills. See [what to build](/connectors/building/what-to-build) for the decision guide.
</Note>

## Types of connectors

### Prebuilt integrations

Anthropic provides first-party integrations with popular services like Google Drive, Gmail, Google Calendar, GitHub, Slack, and Microsoft 365. These are ready to use with no setup beyond authentication. See [Getting started](/connectors/getting-started) for setup instructions.

### Remote MCP servers

[Remote MCP servers](/connectors/custom/remote-mcp) communicate with Claude over the internet, giving it access to cloud-hosted tools and data. You can connect to existing remote MCP servers or build your own for any tool or service.

### MCP Apps

[MCP Apps](/connectors/building/mcp-apps/getting-started) allow MCP servers to display interactive UI elements in conversational MCP clients. Rather than only returning text, an MCP App can render charts, maps, forms, and other visual components directly in the chat. See the [design guidelines](/connectors/building/mcp-apps/design-guidelines) and [cross-platform compatibility](/connectors/building/mcp-apps/cross-compatibility) docs for building MCP Apps.

### MCP Bundles

[MCP Bundles (MCPB)](/connectors/custom/desktop-extensions) package MCP servers with their dependencies for distribution as desktop extensions. MCPB handles cross-platform compatibility, dependency management, code signing, and centralized version updates — making it suitable for enterprise deployment of local MCP servers to Claude Desktop.

### Self-serve local MCP

Local MCP servers distributed through third-party package registries like npm or PyPI cannot be listed directly in the Connectors Directory. To distribute a local server, package it as an [MCPB](/connectors/building/mcpb) for the Desktop Extensions gallery, or bundle it in a [plugin](/plugins/overview) using `.mcp.json` and submit it to the [plugin directory](/plugins/submit).

## Ways to connect

### Connectors directory

The [Connectors Directory](/connectors/directory) is an open catalog of verified and reviewed MCP servers from third-party developers. These integrations are vetted by Anthropic and available across all Claude products.

### Third-party connectors

You can build and connect your own MCP servers for proprietary tools or workflows. See [Third-party Connectors](/connectors/custom/remote-mcp) for remote MCP and [Desktop Extensions](/connectors/custom/desktop-extensions) for local integrations.

## Related concepts

### Plugins

[Plugins](/plugins/overview) combine MCP connectors, [Skills](/skills/overview), slash commands, and sub-agents into shareable capability packages. They are available in Claude Code and Cowork. You can also [submit your plugin](/plugins/submit) to the plugin directory.

## Platform availability

Prebuilt integrations and directory connectors work across all Claude products:

* **Claude.ai** — Full remote MCP support & MCP Apps
* **Claude Desktop** — Full MCP support and local desktop extensions
* **Claude Mobile** — Remote MCP access
* **Claude Code** — Remote MCP access and plugins
* **Claude Cowork** — Full MCP and plugin support

## Next steps

<Columns cols={2}>
  <Card title="Getting started" icon="rocket" href="/connectors/getting-started">
    Set up your first connector.
  </Card>

  <Card title="Connectors directory" icon="grid-2" href="/connectors/directory">
    Browse verified integrations.
  </Card>

  <Card title="Build a connector" icon="code" href="/connectors/building/index">
    Create your own MCP server.
  </Card>

  <Card title="MCP Apps" icon="window" href="/connectors/building/mcp-apps/getting-started">
    Build UI components for Claude.
  </Card>
</Columns>