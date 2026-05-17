> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Sign in with AWS for Amazon Bedrock

> Configure per-user AWS IAM Identity Center authentication for Amazon Bedrock instead of distributing a bearer token or requiring the AWS CLI

By default, Cowork on 3P authenticates to Amazon Bedrock with either a shared bearer token (`inferenceBedrockBearerToken`) or a named profile that relies on the AWS CLI being installed on every device (`inferenceBedrockProfile`). As an alternative, you can configure an interactive AWS sign-in backed by IAM Identity Center. Each user authenticates once with their corporate credentials in the browser, and the app stores an encrypted AWS SSO token on the device. No AWS CLI is required.

Use AWS sign-in when you want:

* Per-user identity in AWS CloudTrail instead of a single shared key
* Access controlled through IAM Identity Center permission sets and group assignments
* To roll out to users who do not have, and should not need, the AWS CLI installed

The sign-in experience uses **your organization's AWS IAM Identity Center instance**. The app registers an OIDC client dynamically with your Identity Center at runtime, so you do not create or distribute a client ID.

## How it works

When all four `inferenceBedrockSso*` keys are set and neither `inferenceBedrockBearerToken` nor `inferenceBedrockProfile` is present, the app shows a **Sign in with AWS** page the first time a user opens the Cowork tab. Clicking the button starts an OAuth device-authorization flow with your IAM Identity Center's OIDC endpoint and opens the AWS access portal in the system browser. The app displays a short verification code so the user can confirm that the browser prompt matches the app that requested it. Identity Center redirects the user to whichever identity provider you have configured (Entra ID, Okta, Google Workspace, or the Identity Center built-in directory).

On success, the app stores the IAM Identity Center access token and refresh token encrypted with the operating system's secure storage (Keychain on macOS, DPAPI on Windows) and relaunches into Cowork.

At the start of each Cowork session, the app exchanges the stored token with IAM Identity Center for short-lived AWS credentials scoped to the configured account and permission set, and passes them into the session sandbox as `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_SESSION_TOKEN`. This is the same credential shape that `aws sso login` produces, obtained without the AWS CLI.

If the stored token expires or is revoked, or if you deploy a different `inferenceBedrockSsoStartUrl`, the app clears the stored token and shows the sign-in page again.

## Prerequisites

* An AWS organization with **IAM Identity Center** enabled
* A permission set that grants Bedrock inference, assigned to your Cowork users on the account where Bedrock is enabled
* Claude models enabled in Amazon Bedrock for the region you will set as `inferenceBedrockRegion`

The IAM Identity Center setup is identical to what the named-profile approach requires. If you have already completed the [Set up AWS](/cowork/3p/bedrock#set-up-aws) steps on the Bedrock deployment page, you can reuse that permission set and assignments here.

## Set up AWS sign-in

<Steps>
  <Step title="Create a permission set with Bedrock access">
    In the [IAM Identity Center console](https://console.aws.amazon.com/singlesignon/), create a permission set whose policy allows `bedrock:InvokeModel` and `bedrock:InvokeModelWithResponseStream`. The [Bedrock deployment page](/cowork/3p/bedrock#set-up-aws) shows the minimal inline policy.

    Set the permission set's **Session duration** to between 8 and 12 hours. The app mints AWS credentials once at the start of each Cowork session, and those credentials last for this duration. A session that runs past it fails with an expired-token error until the user starts a new session. See [Notes and limitations](#notes-and-limitations).
  </Step>

  <Step title="Assign users and record the values you need">
    Assign the permission set to the AWS account where you enabled Bedrock, and add the Identity Center users or groups who should have access.

    From the IAM Identity Center **Settings** page, note the four values you will deploy via MDM:

    * **AWS access portal URL**, of the form `https://d-xxxxxxxxxx.awsapps.com/start` or your custom subdomain
    * **Identity Center region**, the home region of your Identity Center instance, which is often different from your Bedrock region
    * **AWS account ID**, the 12-digit ID of the account where you enabled Bedrock
    * **Permission set name**, the name you gave the permission set above
  </Step>

  <Step title="Configure in the app">
    Open the in-app configuration window (**Developer → Configure third-party inference**) on an evaluation device. In the **Connection** section, set **Inference provider** to **Bedrock**, then fill in the **Bedrock credentials** card:

    | Field                | Value                                             |
    | -------------------- | ------------------------------------------------- |
    | AWS region           | Your Bedrock runtime region, e.g. `us-west-2`     |
    | AWS bearer token     | *leave empty*                                     |
    | Bedrock base URL     | *optional*                                        |
    | AWS profile name     | *leave empty*                                     |
    | AWS config directory | *leave empty*                                     |
    | AWS SSO start URL    | `https://d-1234567890.awsapps.com/start`          |
    | AWS SSO region       | Your IAM Identity Center region, e.g. `us-east-1` |
    | AWS SSO account ID   | `123456789012`                                    |
    | AWS SSO role name    | `BedrockInference`                                |
    | Bedrock service tier | *optional*                                        |

    Leave **AWS bearer token** and **AWS profile name** empty. If either is set, it takes precedence and the sign-in page is never shown.

    Under **Identity & models**, add at least one **Model list** entry using the Bedrock inference-profile ID, for example `us.anthropic.claude-sonnet-4-20250514-v1:0`.

    Then click **Export** to produce a `.mobileconfig` (macOS) or `.reg` (Windows) file for your MDM. See [Installation and setup](/cowork/3p/installation) for the export and deployment workflow, or the [Configuration keys](#configuration-keys) table below if you author policy by hand.
  </Step>

  <Step title="Allow network egress">
    The sign-in flow and token refresh reach the IAM Identity Center endpoints for the region you set as `inferenceBedrockSsoRegion`:

    * `oidc.<sso-region>.amazonaws.com`
    * `portal.sso.<sso-region>.amazonaws.com`

    These hosts are included automatically in the **Egress Requirements** section of the in-app configuration window when the SSO keys are set, so if you built your firewall allowlist from that output, no additional changes are needed. The browser step also reaches your AWS access portal (`*.awsapps.com`) and, if federated, your external identity provider.
  </Step>
</Steps>

## User experience

On first launch after the configuration is applied, the Cowork tab shows a **Sign in with AWS** page instead of the task composer. The user clicks the button, and the app opens the AWS access portal in the default browser with the authorization request prefilled. The app also displays a short verification code; the user confirms it matches the code shown on the AWS page and approves the request. The browser flow runs on the host, outside the Cowork sandbox, so it uses the user's existing identity-provider session and any security keys or passkeys configured on the device.

After approval, the app relaunches into Cowork automatically. Users stay signed in across app restarts for as long as the IAM Identity Center session remains valid. This is the **AWS access portal session duration** under **Authentication** in the Identity Center settings; it defaults to 8 hours and can be extended up to 90 days. When it expires, the app shows the sign-in page again on next launch. To force a user to sign in again sooner, delete their active session from the IAM Identity Center console.

## Configuration keys

| Setting                                                | Type   | Description                                                                                                        |
| ------------------------------------------------------ | ------ | ------------------------------------------------------------------------------------------------------------------ |
| AWS SSO start URL<br />`inferenceBedrockSsoStartUrl`   | string | AWS access portal URL from IAM Identity Center **Settings**, for example `https://d-1234567890.awsapps.com/start`. |
| AWS SSO region<br />`inferenceBedrockSsoRegion`        | string | Home region of the IAM Identity Center instance. Often different from `inferenceBedrockRegion`.                    |
| AWS SSO account ID<br />`inferenceBedrockSsoAccountId` | string | 12-digit AWS account ID where Bedrock is enabled and the permission set is assigned.                               |
| AWS SSO role name<br />`inferenceBedrockSsoRoleName`   | string | Name of the IAM Identity Center permission set that grants `bedrock:InvokeModel*`.                                 |

See [Deploy Cowork on 3P with Amazon Bedrock](/cowork/3p/bedrock) for the full list of Bedrock keys, including `inferenceBedrockRegion` and `inferenceModels`.

## Notes and limitations

* **Precedence.** If `inferenceBedrockBearerToken` or `inferenceBedrockProfile` is set, it is used and AWS sign-in is disabled. Remove those keys to switch an existing deployment to per-user sign-in. When AWS sign-in is configured, it takes precedence over `inferenceCredentialHelper`.
* **All four keys required.** If only some of the `inferenceBedrockSso*` keys are set, the app logs a warning and ignores the partial configuration.
* **One account and role per deployment.** Every user in a given managed configuration signs in to the same AWS account and assumes the same permission set. To give different groups different Bedrock permissions, deploy distinct configuration profiles with different `inferenceBedrockSsoRoleName` values.
* **No mid-session credential refresh.** AWS credentials are minted once when a Cowork session starts and are valid for the permission set's session duration. A session that outlives that duration fails until restarted. Set the session duration long enough to cover a working day.
* **Connection probe.** The in-app **Test connection** button reports that the connection cannot be verified in this mode, because the app cannot sign Bedrock requests outside the sandbox. This matches the behavior of named-profile mode and does not indicate a problem.
* **Configuration rotation.** If you change `inferenceBedrockSsoStartUrl` in the managed profile, existing users are automatically signed out and prompted to sign in again on next launch.