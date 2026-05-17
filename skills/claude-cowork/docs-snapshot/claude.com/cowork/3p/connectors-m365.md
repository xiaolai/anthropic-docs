> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Connect to Microsoft 365

> Give Claude access to your organization's Outlook, OneDrive, SharePoint, and Teams data through a connector you register in your own Microsoft Entra tenant.

When Cowork is deployed on third-party inference, Claude can read your organization's Microsoft 365 data—Outlook mail and calendar, OneDrive, SharePoint, and Teams—through Anthropic's Microsoft 365 connector service. The desktop app authenticates with an app registration you create in your own Microsoft Entra tenant, and the connector service performs the Microsoft Graph calls on the signed-in user's behalf.

Anthropic's connector service receives the desktop's delegated access token on each request and exchanges it on-behalf-of the user for a short-lived Graph token. Neither token is persisted server-side beyond the request, and Anthropic never holds your tenant's client secrets or the user's refresh token (the refresh token stays encrypted on the user's device).

Setup takes about fifteen minutes and requires a Global Administrator or Cloud Application Administrator in your Entra tenant.

## How the connection works

Three applications participate in the sign-in chain. Understanding which one each ID refers to makes the setup steps below easier to follow.

| Application             | Owner                           | Purpose                                                                      |
| ----------------------- | ------------------------------- | ---------------------------------------------------------------------------- |
| Desktop client app      | You (registered in your tenant) | What Claude Desktop signs in as. Public client, PKCE, no secret.             |
| Anthropic connector app | Anthropic (multi-tenant)        | Receives the desktop's token and calls Microsoft Graph on the user's behalf. |
| Microsoft Graph         | Microsoft                       | The Microsoft 365 data APIs.                                                 |

Claude Desktop signs in through your desktop client app, receives a token scoped to the Anthropic connector app, and sends that token to Anthropic's connector service. The connector service exchanges it for a Graph token using the on-behalf-of flow and makes Graph calls as the signed-in user.

## Set up the connector

The four steps below cover tenant consent, app registration, allowlisting, and desktop configuration.

<Steps>
  <Step title="Consent the Anthropic connector app into your tenant">
    A tenant administrator must consent to Anthropic's multi-tenant connector app once for the organization. This creates a service principal in your tenant; no secret is exchanged.

    Open the following URL after replacing `YOUR_TENANT_ID` with the Directory (tenant) ID shown in **Entra admin center → Overview**.

    ```text theme={null}
    https://login.microsoftonline.com/YOUR_TENANT_ID/adminconsent?client_id=07c030f6-5743-41b7-ba00-0a6e85f37c17
    ```

    The consent screen lists the delegated Microsoft Graph permissions the connector requests. All are read-only:

    | Scope                                     | Purpose                                                     |
    | ----------------------------------------- | ----------------------------------------------------------- |
    | `User.Read`                               | Read the signed-in user's profile                           |
    | `Mail.Read`, `Mail.Read.Shared`           | Read mail in the user's and shared mailboxes                |
    | `Calendars.Read`, `Calendars.Read.Shared` | Read events in the user's and shared calendars              |
    | `Files.Read.All`                          | Read files the user can access in OneDrive and SharePoint   |
    | `Sites.Read.All`                          | Read SharePoint site content the user can access            |
    | `Chat.Read`, `ChatMessage.Read`           | Read Teams chat messages the user can access                |
    | `offline_access`                          | Allow the desktop to refresh its token without re-prompting |

    Review the permissions and select **Accept**.

    <Note>
      FedRAMP and GovCloud deployments use a different connector app ID and a
      different connector service hostname. Contact your Anthropic representative
      for the app ID to use in this URL and in the scope string in step 4, and for
      the connector URL to use in step 4.
    </Note>
  </Step>

  <Step title="Register a desktop client app in your tenant">
    Create the public client that Claude Desktop will sign in as.

    1. In **Entra admin center → App registrations → New registration**, set **Name** to `Claude Desktop` (or your preferred name), set **Supported account types** to *Accounts in this organizational directory only*, and add a **Redirect URI** of platform *Mobile and desktop applications* with the value `http://127.0.0.1/callback`.
    2. Select **Register**, then note the **Application (client) ID** and **Directory (tenant) ID** shown on the overview page.
    3. Under **API permissions → Add a permission → APIs my organization uses**, search for `Anthropic` (or paste the connector app ID from step 1), select **Delegated permissions → access\_as\_user**, then **Add permissions**.
    4. Select **Grant admin consent for \{your organization}**.

    No client secret is needed; this is a public client that uses PKCE.
  </Step>

  <Step title="Send Anthropic your IDs">
    Anthropic maintains an allowlist of tenant and client IDs that may call the connector service. Email your Anthropic representative, or open a support ticket, with your Directory (tenant) ID and the Application (client) ID from step 2. Allowlisting is typically completed within two to three business days, as it requires a connector service deployment.

    Until the allowlist is updated, sign-in will succeed but the connector returns *Client application is not authorized for this resource*.
  </Step>

  <Step title="Configure Claude Desktop">
    In the Claude Desktop setup window, open **Connectors**, select **Add → Microsoft 365**, and enter the values below.

    | Field     | Value                                                                      |
    | --------- | -------------------------------------------------------------------------- |
    | Client ID | The Application (client) ID from step 2                                    |
    | Tenant ID | Your Directory (tenant) ID                                                 |
    | Scope     | `api://07c030f6-5743-41b7-ba00-0a6e85f37c17/access_as_user offline_access` |

    Select **Save**, then deploy the configuration through your device-management tool as usual.

    If you manage configuration through JSON or a plist directly instead of the setup window, add the following entry to [`managedMcpServers`](/cowork/3p/configuration#managedmcpservers).

    ```json theme={null}
    {
      "name": "m365",
      "url": "https://microsoft365.mcp.claude.com/mcp",
      "transport": "http",
      "oauth": {
        "clientId": "APPLICATION_CLIENT_ID_FROM_STEP_2",
        "tenantId": "DIRECTORY_TENANT_ID",
        "scope": "api://07c030f6-5743-41b7-ba00-0a6e85f37c17/access_as_user offline_access"
      }
    }
    ```
  </Step>
</Steps>

## Sign in as a user

After the configuration is deployed, each user opens **Settings → Connectors** in Claude Desktop and selects **Connect** next to Microsoft 365. Their browser opens to your tenant's sign-in page; once they consent, the connector is ready to use in conversations.

## Allow the required network hosts

In addition to the [base egress hosts](/cowork/3p/telemetry#required-egress-paths), Claude Desktop needs outbound HTTPS access to the hosts below. The connector service itself calls `graph.microsoft.com` from Anthropic's infrastructure, so user devices do not need egress to Graph.

| Host                          | Purpose                                                       |
| ----------------------------- | ------------------------------------------------------------- |
| `login.microsoftonline.com`   | Microsoft Entra sign-in                                       |
| `microsoft365.mcp.claude.com` | The connector service (substitute your deployment's hostname) |

## Troubleshoot sign-in errors

The errors below are the ones most commonly seen during setup. Each maps to a specific step that was missed or misconfigured.

| Error                                                    | Cause                                                                                                                               | Fix                               |
| -------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| `AADSTS50011` redirect mismatch                          | Redirect URI is not exactly `http://127.0.0.1/callback`, or was registered under *Web* instead of *Mobile and desktop applications* | Re-check step 2.1                 |
| `AADSTS50194` multi-tenant required                      | Tenant ID is missing from the configuration                                                                                         | Add Tenant ID in step 4           |
| `AADSTS65001` admin consent required                     | Step 1 was not completed, or step 2.4 was skipped                                                                                   | Complete admin consent            |
| `Client application is not authorized for this resource` | Anthropic allowlist not yet updated                                                                                                 | Wait for confirmation from step 3 |
| `AADSTS9000411` duplicate prompt parameter               | Older Claude Desktop build                                                                                                          | Upgrade to the current release    |