> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Gateway single sign-on with your identity provider

> Let each user sign in to your LLM gateway with their own work account instead of a shared API key

Instead of distributing a shared gateway API key, you can have each user sign in with their own work account. The first time a user opens Cowork, the app opens their browser to your organization's normal sign-in page (Microsoft Entra ID, Okta, or any OpenID Connect provider). After they sign in, the app sends a per-user token to your gateway on every request, and your gateway checks that token to confirm who the user is.

This gives you per-user attribution in your gateway logs, lets your identity provider enforce MFA and conditional access, and means there is no long-lived credential to distribute or rotate.

<Note>
  Requires Claude Desktop **1.5.0** or later.
</Note>

## Before you start

You need three things in place:

* An LLM gateway that can validate JSON Web Tokens (LiteLLM, Kong, Envoy, and Azure API Management all support this)
* Admin access to your identity provider to register a new application
* A way to push managed configuration to user devices (your existing MDM)

The walkthrough below uses Microsoft Entra ID. An Okta variant follows at the end.

## Set up single sign-on

<Steps>
  <Step title="Register an application in Entra ID">
    In the [Microsoft Entra admin center](https://entra.microsoft.com), go to **Identity → Applications → App registrations** and select **New registration**. Give it a name such as `Claude Cowork gateway`, choose **Accounts in this organizational directory only**, and select **Register**.

    On the overview page, copy the **Application (client) ID** and **Directory (tenant) ID**. You will use both in the next two steps.

    Open the **Authentication** blade, select **Add a platform**, and choose **Mobile and desktop applications**. Under **Custom redirect URIs**, add exactly:

    ```text theme={null}
    http://127.0.0.1/callback
    ```

    A few details that matter here: use `127.0.0.1` (not `localhost`), include the `/callback` path, and add it under the **Mobile and desktop applications** platform specifically. That platform is the only one Entra allows to use any local port, which the app needs because it picks a free port at sign-in time. You do not need a client secret or any additional API permissions.
  </Step>

  <Step title="Configure your gateway to validate the token">
    Tell your gateway to accept the bearer token only if it was issued by your tenant **for this application**. In LiteLLM that looks like:

    ```yaml theme={null}
    general_settings:
      litellm_jwtauth:
        public_key_url: https://login.microsoftonline.com/YOUR_TENANT_ID/discovery/v2.0/keys
        audience: YOUR_CLIENT_ID
        user_id_jwt_field: oid
    ```

    Replace `YOUR_TENANT_ID` and `YOUR_CLIENT_ID` with the values from step 1.

    <Warning>
      The `audience` line is required. Without it, your gateway accepts tokens issued to any application in your tenant, not just this one.
    </Warning>

    For Kong, Envoy, or Azure API Management, configure the equivalent JWT validation policy with the same JWKS URL and audience.
  </Step>

  <Step title="Configure in the app">
    Open the in-app configuration window (**Developer → Configure third-party inference**). In the **Connection** section, set **Inference provider** to **Gateway**, then fill in the **Gateway credentials** card. Selecting `sso` for **Gateway auth scheme** hides the API-key field and reveals **Gateway SSO IdP (OIDC)**:

    | Field                                  | Value                                                   |
    | -------------------------------------- | ------------------------------------------------------- |
    | Gateway base URL                       | `https://llm-gateway.example.corp`                      |
    | Gateway auth scheme                    | `sso`                                                   |
    | Gateway SSO IdP (OIDC) → Client ID     | `YOUR_CLIENT_ID`                                        |
    | Gateway SSO IdP (OIDC) → Issuer URL    | `https://login.microsoftonline.com/YOUR_TENANT_ID/v2.0` |
    | Gateway SSO IdP (OIDC) → Scopes        | *leave empty for the default*                           |
    | Gateway SSO IdP (OIDC) → Redirect port | *leave empty*                                           |

    Then click **Export** to produce a `.mobileconfig` (macOS) or `.reg` (Windows) file for your MDM. See [Installation and setup](/cowork/3p/installation) for the export and deployment workflow.

    When a user next opens Cowork, they see a **Sign in to your organization** button. Clicking it opens their browser to your Entra sign-in page; once they approve, they return to the app and can start working. The app keeps them signed in and refreshes the token in the background, so they will not see the browser again unless their session is revoked or expires under your tenant's policy.
  </Step>
</Steps>

## Using Okta instead

In the Okta Admin Console, create a **Native** application with the **Authorization Code** and **Refresh Token** grant types. Okta requires the redirect URI to match exactly, including the port, so pick a fixed port (for example `53180`), register `http://127.0.0.1:53180/callback`, and set that same port in **Gateway SSO IdP (OIDC)**:

| Field         | Value                         |
| ------------- | ----------------------------- |
| Client ID     | `YOUR_CLIENT_ID`              |
| Issuer URL    | `https://YOUR_ORG.okta.com`   |
| Scopes        | *leave empty for the default* |
| Redirect port | `53180`                       |

<Note>
  Use the **issuer** value, not the **Metadata URI**. Okta's admin console shows the metadata URI (ending in `/.well-known/openid-configuration`) prominently — that is the discovery document the app fetches *from* the issuer, not the issuer itself. If you are unsure, open the metadata URI in a browser and copy the `"issuer"` field from the JSON response. For a custom Okta authorization server the issuer is `https://YOUR_ORG.okta.com/oauth2/AUTH_SERVER_ID`.
</Note>

Point your gateway's JWT validation at `https://YOUR_ORG.okta.com/oauth2/v1/keys` with `audience` set to the Okta client ID.

## Configuration keys

This feature is enabled by setting `inferenceGatewayAuthScheme` to `sso` **and** supplying `inferenceGatewayOidc`. Both are required — `sso` alone selects a different mode where the gateway itself acts as the authorization server.

| Setting                | MDM key                      | Required            | Description                                                                                                                                       |
| ---------------------- | ---------------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| Gateway auth scheme    | `inferenceGatewayAuthScheme` | Yes — must be `sso` | Selects sign-in instead of an API key.                                                                                                            |
| Gateway SSO IdP (OIDC) | `inferenceGatewayOidc`       | Yes                 | A **single JSON object** describing the identity provider (fields below). The resulting ID token is sent to the gateway as the bearer credential. |

The `inferenceGatewayOidc` value is one JSON object with these fields:

| Field          | Required | Description                                                                                                                                                               |
| -------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `clientId`     | Yes      | Application (client) ID registered with the identity provider.                                                                                                            |
| `issuer`       | Yes      | OIDC issuer URL — the base URL only, **without** `/.well-known/openid-configuration`. The app appends that path itself to discover the authorization and token endpoints. |
| `scopes`       | No       | Space-separated OIDC scopes. Defaults to `openid profile email offline_access`.                                                                                           |
| `redirectPort` | No       | Fixed local port for the loopback redirect. Leave unset to let the app choose an ephemeral port (Entra). Set when the provider requires an exact port match (Okta).       |

<Warning>
  `inferenceGatewayOidc` is **one MDM key whose value is a JSON string** — not separate keys like `inferenceGatewayOidc.clientId`. See [how object-typed keys are encoded](/cowork/3p/configuration#value-types). The in-app **Export** produces the correct format automatically.
</Warning>

In a macOS `.mobileconfig` payload (Okta example):

```xml theme={null}
<key>inferenceGatewayAuthScheme</key>
<string>sso</string>
<key>inferenceGatewayOidc</key>
<string>{"issuer":"https://YOUR_ORG.okta.com","clientId":"YOUR_CLIENT_ID","redirectPort":53180}</string>
```

The remaining gateway keys (`inferenceGatewayBaseUrl`, `inferenceModels`) are documented on the [Gateway](/cowork/3p/gateway#configuration-keys) page.

## Troubleshooting

**`gateway SSO: server does not advertise device_authorization_endpoint`** — The app could not read your `inferenceGatewayOidc` value, so it fell back to treating the gateway itself as the sign-in server. Almost always this means the value is not a valid JSON string (for example, separate dotted keys, or a plist `<dict>` instead of a `<string>`). Re-export from the in-app configuration window, or copy the `.mobileconfig` snippet above.

**`OIDC discovery failed (HTTP 404)` or `(HTTP 405)`** — The `issuer` value is not the issuer base URL. Most often the metadata URI (ending in `/.well-known/openid-configuration`) was pasted instead, which doubles the path. Remove that suffix so `issuer` is just `https://YOUR_ORG.okta.com` (or the equivalent for your provider).

**`one of inferenceGatewayApiKey, inferenceCredentialHelper, … or inferenceGatewayAuthScheme: 'sso' must be set`** — `inferenceGatewayAuthScheme` is missing or set to something other than `sso`.

**Browser shows "Connected" but the app reports the sign-in failed, or `Token exchange failed (HTTP 401)`** — The browser step succeeded, but the identity provider rejected the follow-up token request. This usually means the IdP application is registered as a confidential (Web) client, which expects a client secret. Claude is a public PKCE client and doesn't send one. Register a public/native client instead: **Native Application** in Okta, or the **Mobile and desktop applications** platform in Entra ID. Application type generally can't be changed after creation, so you may need to create a new one.

<Note>
  Google Workspace can be used as the identity provider, but Google does not issue a fresh ID token on background refresh, so users are prompted to sign in again roughly once an hour. Entra ID and Okta are not affected.
</Note>