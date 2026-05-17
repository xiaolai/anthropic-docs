> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Web search and web fetch

> How Cowork on 3P reaches the internet, which providers support search, and how to control or disable web access

Cowork includes two built-in tools for reaching the web:

* **Web Search** runs a search-engine query and returns ranked results.
* **Web Fetch** retrieves the contents of a specific URL.

In Cowork on third-party (3P), both are subject to your configuration: search depends on your inference provider, and fetch is gated by the sandbox network allowlist.

## Web Search

Web Search is a **server-side tool** executed by your inference provider, not by the desktop app. Availability depends on which provider you've configured:

| Provider                 | Web Search                                                                |
| ------------------------ | ------------------------------------------------------------------------- |
| Google Cloud's Vertex AI | Available                                                                 |
| Microsoft Foundry        | Available                                                                 |
| Amazon Bedrock           | Not available                                                             |
| Gateway                  | Available if your gateway implements Anthropic's `web_search` server tool |

Because the search runs on the provider's infrastructure, queries and results travel over the same path as model inference and are subject to your provider's data-handling terms. No additional firewall rules are needed beyond the inference endpoint itself.

<Note>
  `coworkEgressAllowedHosts` does **not** apply to Web Search. The allowlist governs client-side egress — Web Fetch and in-sandbox shell network activity — while search executes server-side at your inference provider. URLs returned in search results are, however, automatically permitted for a follow-up Web Fetch even if they aren't in your allowlist. To disable search, add `"WebSearch"` to `disabledBuiltinTools`.
</Note>

If your provider doesn't support search, or you want to use a different search backend, deploy a search MCP server via [`managedMcpServers`](/cowork/3p/configuration#managedmcpservers) and disable the built-in tool (below).

## Web Fetch

Web Fetch runs in the Claude Desktop main process on the user's device. The model supplies only the target URL; it cannot set headers, a request body, or credentials. Every fetch, including redirect targets, is checked against `coworkEgressAllowedHosts` before the request is sent.

By default, the sandbox can reach only your inference provider's endpoint, so Web Fetch will fail for any other host unless you've allowed it. To permit fetches:

| Goal                                   | Set `coworkEgressAllowedHosts` to                   |
| -------------------------------------- | --------------------------------------------------- |
| Allow specific domains                 | `["docs.example.com", "*.your-org.com"]`            |
| Allow all hosts (no sandbox filtering) | `["*"]`                                             |
| Block all fetches                      | `[]` and add `"WebFetch"` to `disabledBuiltinTools` |

Wildcards match one or more leading subdomain labels (`*.example.com` matches `a.example.com` and `a.b.example.com`, but not `example.com`).

<Note>
  `coworkEgressAllowedHosts` controls what the agent's tools can reach. Your perimeter firewall is a separate, outer layer, so a host allowed by this key still won't be reachable if your corporate network blocks it. See [Telemetry and egress](/cowork/3p/telemetry#required-egress-paths) for the distinction.
</Note>

The same allowlist governs other in-sandbox network activity (for example, `curl` or `pip install` from the agent's shell), not just the Web Fetch tool.

## Disabling web tools

To remove web tools entirely, add them to `disabledBuiltinTools`:

```json theme={null}
["WebSearch", "WebFetch"]
```

With both disabled and `coworkEgressAllowedHosts` empty, the agent has no path to the public internet from inside the sandbox. It can still read and write local files, run code against them, and call any MCP servers you've provisioned. See the [Locked down profile](/cowork/3p/configuration#recommended-security-profiles).