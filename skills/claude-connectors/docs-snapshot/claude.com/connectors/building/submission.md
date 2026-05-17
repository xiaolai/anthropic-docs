> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Submitting to the Connectors Directory

> Submit your MCP connector to the Connectors Directory

The [Connectors Directory](/connectors/directory) aims to be a collection of high-quality, vetted, and reviewed MCP servers that are helpful and harmless to users. Anyone is welcome to build MCP servers, but only servers meeting the review standards outlined on this page will be included in the directory.

## What you can submit

Developers can submit:

* **Remote MCP servers** — internet-hosted servers that provide tools and data to Claude
* **Desktop extensions** — local MCP servers packaged as [MCP Bundles (MCPB)](https://github.com/modelcontextprotocol/mcpb) for Claude Desktop
* **[MCP Apps](/connectors/building/mcp-apps/getting-started)** — MCP servers that surface interactive UI elements. These have the additional requirement of including screenshots for submission and listing in the directory.

## Directory terms & conditions

All servers in the directory must comply with:

* [Anthropic Software Directory Terms](https://support.claude.com/en/articles/13145338-anthropic-software-directory-terms)
* [Anthropic Software Directory Policy](https://support.claude.com/en/articles/13145358-anthropic-software-directory-policy)

By submitting a connector, you also agree to:

* Maintain your connector's security and functionality
* Respond to security issues promptly
* Provide accurate descriptions and documentation

## Submission requirements

All MCP connectors submitted to the directory must meet:

1. **Security**: Meet Anthropic's security standards
2. **Tool annotations**: All tools must include a `title` and the applicable `readOnlyHint` or `destructiveHint`
3. **Authentication**: Use OAuth 2.0 for authenticated services
4. **Privacy Policy**: Local connectors must include privacy policies
5. **Documentation**: Provide clear setup and usage instructions

If your connector opens external links, also provide your [allowed link URIs](#allowed-link-uris) so users aren't prompted to confirm each one.

## Privacy policy requirements

Local connectors must include:

1. "Privacy Policy" section in README.md
2. `privacy_policies` array in manifest.json (manifest\_version 0.2+)
3. HTTPS URLs to privacy policies

The privacy policy must cover:

* Data collection practices
* Usage and storage
* Third-party sharing
* Data retention
* Contact information

<Warning>
  Missing or incomplete privacy policies result in immediate rejection.
</Warning>

## Allowed link URIs

If your connector uses the `ui/open-link` capability to open URLs in the user's browser or native apps, provide the list of link targets your server will request. Claude uses this list to suppress the "Open external link" confirmation prompt for destinations you've declared. Links to any other destination still work—users are simply asked to confirm before the link opens.

Provide each entry in one of two forms:

* **HTTPS origin** — `https://example.com`. Only the scheme and hostname are matched; paths, ports, and query strings are ignored. Subdomains are not implied—list each one (`https://app.example.com`, `https://docs.example.com`).
* **Custom URI scheme** — `myapp:` for deep links into a native app you own (for example, `spotify:` or `notion:`). Only the scheme is matched.

Every origin and scheme you list **must be owned by you** (the submitting organization). You may not list third-party domains or URI schemes registered to apps you don't publish. Entries you don't own will be removed during review.

<Note>
  This field is optional. If omitted, your connector functions normally, but users are shown a confirmation prompt each time it opens a link.
</Note>

## Asset specifications

### Carousel screenshots (MCP Apps)

* **Format:** PNG
* **Width:** at least 1000px
* **Count:** 3–5 images
* **Crop:** to the app response only—**do not include the prompt** in the image
* **Aspect ratio:** any
* **Paired prompts:** provide the prompt text separately for each screenshot
* **Mobile:** no separate mobile assets are required—one batch covers all surfaces
* **Video/GIF:** not accepted

A carousel template is available in the [Anthropic MCP Apps Figma community file](https://www.figma.com/community/file/1597641111449594397/mcp-apps-for-claude).

### Detail card description

You write the detail card description in the submission form. It is not editable by Anthropic. The disclaimer text shown on connector cards is general and not customizable per partner.

## Review process

Review times vary with queue volume. The submission form is always open.

If you can't access the form because of a corporate firewall or tenant restriction, email `mcp-review@anthropic.com`—the form is also moving to a native Claude.ai surface.

A self-serve status dashboard is rolling out in Claude.ai. Until then, you may not receive proactive notification on every status change; email `mcp-review@anthropic.com` for escalations.

Run the [pre-submission checklist](/connectors/building/review-criteria) and, for plugins, `claude plugin validate` before you submit.

## Submit your connector

Ready to submit? Use the appropriate form based on your connector type:

* Desktop extensions (MCPB): [Desktop extension submission form](https://clau.de/desktop-extention-submission)
* Remote MCPs (including MCP Apps): [MCP directory submission form](https://clau.de/mcp-directory-submission)

Skills are not a standalone submission type—bundle them in a [plugin](/plugins/submit).

### What you'll need for submission

Have the following information ready when filling out the submission form:

* **Server basics** — server name, URL, tagline, description, use cases
* **Connection details** — auth type, transport protocol, read/write capabilities, connection requirements
* **Allowed link URIs** *(optional)* — HTTPS origins (e.g., `https://app.example.com`) and custom URI schemes (e.g., `myapp:`) your connector opens via `ui/open-link`; declaring these lets users skip the "Open external link" confirmation prompt. See [Opening external links](/connectors/building/mcp-apps/external-links) for matching rules and restrictions.
* **Data & compliance** — data handling practices, third-party connections, health data access, category
* **Tools, resources & prompts** — list of all tools (with human-readable names), resources, and prompts in your server, plus confirmation of tool annotations
* **Documentation & support** — links to docs, privacy policy, support channel
* **Test account** — credentials with step-by-step setup instructions for a reviewer unfamiliar with your service
* **Launch readiness** — GA date, confirmation of which surfaces you've tested in (Claude.ai, Desktop, etc.)
* **Branding** — server logo (URL or SVG upload), favicon verification, promotional screenshots for MCP Apps (see [asset specifications](#asset-specifications) above)
* **Documentation link** — must be public by your publish date (a blog post or help-center article is sufficient); you can share privately with Anthropic during review
* **Policy & requirements checklists** — confirming compliance with directory policy, technical requirements (OAuth, HTTPS, `Origin`-header validation, annotations), documentation, and testing standards
* **Optional: Skills & Plugins** — if submitting a related Agent Skill alongside the server. To submit a standalone plugin, see [Submitting your plugin](/plugins/submit).