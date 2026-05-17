> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Deploy Cowork on 3P with Google Cloud's Vertex AI

> Set up Google Cloud, choose an authentication path for your organization, and configure Cowork on 3P to use Claude models on Vertex AI

This page walks an IT administrator through a complete Vertex AI deployment: enabling Claude in your Google Cloud project, choosing the authentication path that fits your organization, preparing devices, and pushing the managed configuration. If you only need the list of configuration keys, skip to [Configure the app](#configure-the-app).

## Choose an authentication approach

Vertex AI authenticates with Google Cloud Application Default Credentials, which can be supplied several ways. The right one depends on whether your users have Google identities and whether you need per-user attribution in Cloud Audit Logs.

| Scenario                                               | Use                                                                         | Per-device prerequisite     | Per-user Cloud Audit Logs identity | Notes                                                                                                  |
| ------------------------------------------------------ | --------------------------------------------------------------------------- | --------------------------- | ---------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Proof of concept, single team                          | [Service-account key](#credentials-file) (`inferenceVertexCredentialsFile`) | The key file on each device | No (shared service account)        | A long-lived secret distributed to every device. Simplest to start; not recommended for broad rollout. |
| Users have Google Workspace or Cloud Identity accounts | [In-app Google sign-in](#in-app-google-sign-in) (`inferenceVertexOAuth*`)   | None                        | Yes                                | Users sign in with their Google account inside the app. See the session-control warning below.         |
| You already operate an LLM proxy                       | [Gateway provider](/cowork/3p/gateway) instead of Vertex                    | None                        | At your gateway                    | The proxy holds the Google Cloud credentials; the app authenticates only to the proxy.                 |

<Warning>
  If your Google Workspace or Cloud Identity organization enforces a **Google Cloud session length** of a few hours or less (Admin console → Security → Google Cloud session control), the in-app Google sign-in stores a refresh token that is subject to that policy, and users will be prompted to sign in again each time it expires. For short session policies, either mark your OAuth client as a [trusted app exempt from reauthentication](https://support.google.com/a/answer/9368756), or use a service-account key or the gateway provider instead.
</Warning>

`inferenceCredentialHelper` is not invoked when `inferenceProvider` is `vertex`, because Vertex authentication is file-based rather than token-based. Use one of the options above.

## Set up Google Cloud

These steps are performed once per Google Cloud project, regardless of which authentication approach you chose. You need a project with Owner or Editor access.

<Steps>
  <Step title="Enable the Vertex AI API">
    In the [Google Cloud console](https://console.cloud.google.com/apis/library/aiplatform.googleapis.com), enable the **Vertex AI API** for your project.
  </Step>

  <Step title="Enable Claude models in Model Garden">
    In the Vertex AI [Model Garden](https://console.cloud.google.com/vertex-ai/model-garden), locate the Claude models you intend to deploy and click **Enable** on each. Model availability varies by region; enable them in the region you will set as `inferenceVertexRegion`.
  </Step>

  <Step title="Grant users access to Vertex AI">
    Each authenticated principal needs permission to call the model. On the project's **IAM** page, grant the **Vertex AI User** role (`roles/aiplatform.user`) to:

    * the service account, if using a service-account key file
    * the Google group containing your users, if using in-app Google sign-in

    If your organization uses a narrower custom role, it must include at minimum `aiplatform.endpoints.predict`.
  </Step>

  <Step title="Create an OAuth client (in-app Google sign-in only)">
    If you chose in-app Google sign-in, create a Desktop-app OAuth client in your project. See [Sign in with Google for Vertex AI](/cowork/3p/vertex-google-sign-in) for the full procedure, including consent-screen setup.
  </Step>

  <Step title="Federate to your IdP (optional)">
    If your users authenticate with Microsoft Entra ID, Okta, or another SAML identity provider and do not already have Google accounts, provision a free Cloud Identity tenant and configure SAML single sign-on to your IdP. Users then sign in through the in-app Google sign-in approach with a Google identity that is backed by your IdP. No Google Workspace licenses are required. See [Set up SSO with a third-party IdP](https://support.google.com/cloudidentity/answer/12032922) in the Cloud Identity documentation.
  </Step>
</Steps>

## Prepare devices

What each end-user device needs depends on the authentication approach you chose.

### Credentials file

Create a service account in your project, grant it the **Vertex AI User** role, and download its JSON key. Distribute the key file to a fixed path on each device through your device-management tooling and set `inferenceVertexCredentialsFile` to that path.

`inferenceVertexCredentialsFile` accepts any Application Default Credentials JSON format, so if your environment already produces an `authorized_user` file (from `gcloud auth application-default login`) or an `external_account` Workforce Identity Federation configuration, you can point at that file instead. For `external_account` files, the `credential_source` must be of type `file` or `url` (`executable` sources are not supported), and separate tooling on the device must obtain the IdP token and write it to the configured location; Cowork does not perform that step.

### In-app Google sign-in

No per-device preparation is required. Distribute the OAuth client ID and secret in the managed configuration; the app shows a **Sign in with Google** page on first launch and stores the user's refresh token encrypted with the operating system's secure storage. See [Sign in with Google for Vertex AI](/cowork/3p/vertex-google-sign-in) for the full flow.

## Configure the app

With Google Cloud set up and devices prepared, open the in-app configuration window (**Developer → Configure third-party inference**) on an evaluation device. In the **Connection** section, set **Inference provider** to **Vertex** and fill in the **Vertex credentials** card with the values for whichever authentication approach you chose:

| Field                      | Service-account key    | In-app Google sign-in                          |
| -------------------------- | ---------------------- | ---------------------------------------------- |
| GCP project ID             | `your-gcp-project`     | `your-gcp-project`                             |
| GCP region                 | e.g. `us-east5`        | e.g. `us-east5`                                |
| GCP credentials file path  | `/path/to/sa-key.json` | *leave empty*                                  |
| Vertex OAuth client ID     | *leave empty*          | `1234567890-abc123.apps.googleusercontent.com` |
| Vertex OAuth client secret | *leave empty*          | `GOCSPX-xxxxxxxxxxxxxxxxxxxx`                  |
| Vertex OAuth scopes        | *leave empty*          | *leave empty for the default*                  |
| Vertex AI base URL         | *optional*             | *optional*                                     |

Under **Identity & models**, add at least one **Model list** entry using the Vertex publisher model ID, for example `claude-sonnet-4@20250514`.

Then click **Export** to produce a `.mobileconfig` (macOS) or `.reg` (Windows) file for your MDM. See [Installation and setup](/cowork/3p/installation) for the export and deployment workflow.

### Configuration keys

The full set of Vertex keys is below. Set `inferenceProvider` to `vertex`, supply a project and region, and provide exactly one credential source.

| Setting                                                            | Required                            | Description                                                                                                                                                                                                      |
| ------------------------------------------------------------------ | ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| GCP project ID<br />`inferenceVertexProjectId`                     | Yes                                 | Google Cloud project ID.                                                                                                                                                                                         |
| GCP region<br />`inferenceVertexRegion`                            | Yes                                 | Google Cloud region for the Vertex AI endpoint, for example `us-east5` or `europe-west4`. `global` is also accepted where the model supports it.                                                                 |
| GCP credentials file path<br />`inferenceVertexCredentialsFile`    | One credential source               | Absolute path to a service-account key, `authorized_user`, or `external_account` (Workforce Identity Federation) JSON file. No `~` or environment-variable expansion. If set, in-app Google sign-in is disabled. |
| Vertex OAuth client ID<br />`inferenceVertexOAuthClientId`         | One credential source (with secret) | Client ID of a Desktop-app OAuth client in your Google Cloud project. Enables in-app [Google sign-in](/cowork/3p/vertex-google-sign-in).                                                                         |
| Vertex OAuth client secret<br />`inferenceVertexOAuthClientSecret` | With OAuth client ID                | Client secret paired with the client ID above. Not treated as confidential for installed apps.                                                                                                                   |
| Vertex OAuth scopes<br />`inferenceVertexOAuthScopes`              | No                                  | Space-separated OAuth scopes for Google sign-in. Defaults to `openid email https://www.googleapis.com/auth/cloud-platform`.                                                                                      |
| Vertex AI base URL<br />`inferenceVertexBaseUrl`                   | No                                  | Override the public regional endpoint, for example with a Private Service Connect address. Must be `https://`.                                                                                                   |

If neither `inferenceVertexCredentialsFile` nor the OAuth client keys are set, the Google client library falls back to the standard Application Default Credentials search path on the device (`~/.config/gcloud/application_default_credentials.json`, then the environment's metadata server).

You must also set `inferenceModels` to a list of Vertex publisher model IDs, for example `claude-sonnet-4@20250514`. See the [Configuration reference](/cowork/3p/configuration#models).

## What users experience

The first-launch and re-authentication behavior depends on the authentication approach.

| Approach                               | First launch                                                                                                                                                         | Re-authentication                                                                                                                      |
| -------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Credentials file (service-account key) | Cowork opens directly; no user action.                                                                                                                               | Never, until you rotate the key file.                                                                                                  |
| In-app Google sign-in                  | The Cowork tab shows a **Sign in with Google** page. Clicking it opens Google's consent flow in the default browser. After approval, the app relaunches into Cowork. | When the refresh token is revoked, when you deploy a new OAuth client ID, or when your Google Cloud session-control policy expires it. |

For in-app Google sign-in, users can sign out by revoking the app from their Google Account's [third-party connections page](https://myaccount.google.com/connections); the app detects the revoked token at the next session start and shows the sign-in page again.

## Troubleshoot

To confirm which keys the app read and whether credentials validated, use **Help → Troubleshooting → Copy Managed Configuration Report**; see [Verifying the deployment](/cowork/3p/installation#verifying-the-deployment) for that workflow and the common causes when the app does not enter 3P mode. Application log locations are listed in [Data storage and residency](/cowork/3p/data-storage).