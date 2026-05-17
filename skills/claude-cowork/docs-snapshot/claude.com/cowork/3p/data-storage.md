> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# User identity and local data

> How Cowork on 3P identifies users and where it stores conversations, settings, and credentials on disk

Cowork on third-party (3P) has no Anthropic account. There is no sign-in step, no cloud-stored conversation history, and no per-user state on Anthropic infrastructure. Identity and persistence are entirely local to the device.

## Identity

When the app first launches in 3P mode, it generates a random UUID and writes it (base64-encoded) to the `ant-did` file in the application-data directory. This identifier, together with the `deploymentOrganizationUuid` from your managed configuration, is what's attached to telemetry events. It is random per device and per OS-user account, and Anthropic cannot trace it back to a real device or person.

If you need to attribute Cowork activity to named users, configure [OpenTelemetry export](/cowork/3p/configuration#opentelemetry-export) and join the exported events to your identity system on the collector side, or include user identity in the headers your `managedMcpServers` helpers emit.

## Where data lives

Cowork on 3P stores everything under a dedicated directory, separate from standard Claude Desktop, so the two modes can coexist on one machine without interfering.

| Platform | Application data                           | Logs                                   |
| -------- | ------------------------------------------ | -------------------------------------- |
| macOS    | `~/Library/Application Support/Claude-3p/` | `~/Library/Logs/Claude-3p/`            |
| Windows  | `%LOCALAPPDATA%\Claude-3p\`                | (under the application-data directory) |

<Note>
  On Windows, earlier Claude Desktop releases stored this data under `%APPDATA%\Claude-3p\` (the Roaming profile). On first launch after upgrading, the app moves the existing directory to `%LOCALAPPDATA%` automatically; if Roaming is redirected to a network share, conversation history and configuration are copied and large regenerable caches are re-downloaded. Update any external tooling, backup jobs, or endpoint policies that reference the old path. macOS paths are unchanged.
</Note>

Within the application-data directory:

| Path                                                    | Contents                                                                                                                                                                                                                                                                            |
| ------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ant-did`                                               | The random device identifier described above.                                                                                                                                                                                                                                       |
| `configLibrary/`                                        | Locally authored configuration (from the in-app configuration window). `_meta.json` records which saved configuration is applied; each is a `<id>.json` file alongside it. Ignored when a managed profile is present.                                                               |
| `cowork_account_settings.json`                          | User-level preferences set in the app (display name, locale, memory toggle).                                                                                                                                                                                                        |
| `local-agent-mode-sessions/`                            | Cowork conversation history. One `local_<uuid>.json` file plus a working directory per session, scoped by account and organization ID.                                                                                                                                              |
| `local-agent-mode-sessions/.../memory/`                 | Cowork memory: a `CLAUDE.md` instructions file plus a `memory/` subdirectory of Markdown notes Claude writes about the user's preferences, projects, and feedback. See [Memory](#memory).                                                                                           |
| `local-agent-mode-sessions/.../<sessionId>/audit.jsonl` | Append-only log of session events (tool invocations, permission decisions, file operations). Each entry is HMAC-chained to the previous one so edits or deletions are detectable; the companion `.audit-key` file holds the per-session signing key, encrypted via the OS keychain. |
| `claude-code-sessions/`                                 | Code tab conversation history, in the same per-session layout.                                                                                                                                                                                                                      |
| `claude-code/`, `claude-code-vm/`                       | Claude Code binary and VM workspace data for the Code tab.                                                                                                                                                                                                                          |
| `vm_bundles/`                                           | Cached copy of the Cowork sandbox VM bundle.                                                                                                                                                                                                                                        |
| `cowork_plugins/`                                       | User-installed and [org-provisioned](/cowork/3p/extensions#organization-plugins-admin) plugins. Created on first plugin install.                                                                                                                                                    |
| `IndexedDB/`, `Local Storage/`, `Session Storage/`      | Renderer-side UI state (window layout, recent folders, preferences).                                                                                                                                                                                                                |

Files in this directory are written with owner-only permissions so other OS accounts on the same machine cannot read them.

The logs directory contains `main.log` (application and configuration-validation events), `cowork_vm_node.log` (sandbox VM activity), and `claude.ai-web.log` (renderer events).

## Memory

During Cowork sessions, Claude writes short Markdown files recording what it has learned about the user — working preferences, project context, and corrections — and reads them at the start of subsequent sessions. These files live under `local-agent-mode-sessions/.../memory/memory/` and never leave the device.

Users can review and delete individual entries, or pause memory entirely (existing files are kept but not read or updated), under **Settings → Cowork → Memory**. The same page exposes a **Global instructions** editor for the `CLAUDE.md` file that is included in every session.

## Credentials

Inference credentials are handled according to how they're delivered:

* **Managed configuration** (e.g. `inferenceGatewayApiKey`, `inferenceBedrockBearerToken`) — read from the OS preference store / registry at launch and held in memory; never written to the application-data directory.
* **OAuth tokens** (Vertex OAuth, MCP servers with `oauth: true`) — stored in the OS keychain (macOS Keychain / Windows Credential Manager), encrypted at rest by the operating system.
* **Credential-helper output** — held in memory for `inferenceCredentialHelperTtlSec` seconds, then discarded and re-fetched.

## Removing data

To fully reset a device's Cowork on 3P state, delete the application-data directory above. To return to standard Claude Desktop without removing data, choose the Anthropic sign-in option on the sign-in screen; to also remove the locally authored 3P configuration, delete the `configLibrary/` directory.

Conversation history exists only in this directory, so deleting it is unrecoverable.