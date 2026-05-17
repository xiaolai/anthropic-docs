> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Deploy Cowork on 3P with Amazon Bedrock

> Set up AWS, choose an authentication path for your organization, and configure Cowork on 3P to use Claude models on Amazon Bedrock

This page walks an IT administrator through a complete Amazon Bedrock deployment: enabling Claude in your AWS account, choosing the authentication path that fits your organization, preparing devices, and pushing the managed configuration. If you only need the list of configuration keys, skip to [Configure the app](#configure-the-app).

## Choose an authentication approach

Bedrock supports several ways to authenticate, and the right one depends on whether your end users already work with AWS and whether you need per-user identity in CloudTrail. Use the table below to pick a path before doing any AWS or device setup.

| Scenario                                   | Use                                                                | Per-device prerequisite                 | Per-user CloudTrail identity | Notes                                                                                                               |
| ------------------------------------------ | ------------------------------------------------------------------ | --------------------------------------- | ---------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Proof of concept, single team              | [Bearer token](#bearer-token) (`inferenceBedrockBearerToken`)      | None                                    | No (shared key)              | A long-lived secret distributed in the managed profile. Simplest to start; not recommended for broad rollout.       |
| Broad rollout to users without AWS tooling | [In-app AWS sign-in](#in-app-aws-sign-in) (`inferenceBedrockSso*`) | None                                    | Yes                          | Users sign in through IAM Identity Center inside the app. No AWS CLI required. Requires app version 1.6.0 or later. |
| Developers who already use the AWS CLI     | [Named profile](#named-profile) (`inferenceBedrockProfile`)        | AWS CLI v2 and a pushed `~/.aws/config` | Yes                          | IT can distribute the AWS config file directly; users run `aws sso login` to refresh.                               |
| You already operate an LLM proxy           | [Gateway provider](/cowork/3p/gateway) instead of Bedrock          | None                                    | At your gateway              | The proxy holds the AWS credentials; the app authenticates only to the proxy.                                       |

If a static credential in the managed profile is acceptable but a Bedrock API key is not, you can also set [`inferenceCredentialHelper`](/cowork/3p/configuration#credential-helper) to an executable that prints a Bedrock bearer token to stdout at runtime.

When more than one credential is configured, the app uses the first one present in this order: bearer token, named profile, in-app AWS sign-in, credential helper.

## Set up AWS

These steps are performed once per AWS organization, regardless of which authentication approach you chose. You need an AWS account with permission to manage Bedrock model access and IAM Identity Center.

<Steps>
  <Step title="Enable Claude models in Bedrock">
    In the [Amazon Bedrock console](https://console.aws.amazon.com/bedrock/), open **Model access** and request access to the Claude models you intend to deploy. Access is granted per region, so enable the models in the same region you will set as `inferenceBedrockRegion`.
  </Step>

  <Step title="Create an IAM Identity Center permission set">
    Skip this step if you chose the bearer-token approach. The named-profile and in-app AWS sign-in approaches both use IAM Identity Center to issue per-user AWS credentials.

    In the [IAM Identity Center console](https://console.aws.amazon.com/singlesignon/), create a permission set with an inline policy that allows Bedrock inference. The minimal policy is:

    ```json theme={null}
    {
      "Version": "2012-10-17",
      "Statement": [{
        "Effect": "Allow",
        "Action": [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ],
        "Resource": "*"
      }]
    }
    ```

    Set the permission set's **Session duration** to between 8 and 12 hours. This value controls how long a user can run Cowork before needing to sign in to AWS again.
  </Step>

  <Step title="Federate Identity Center to your IdP (optional)">
    If your organization uses Microsoft Entra ID, Okta, or another SAML identity provider, you can configure it as the identity source for IAM Identity Center so users sign in with their existing corporate credentials. The per-device steps on this page are unchanged. See [Connect to an external identity provider](https://docs.aws.amazon.com/singlesignon/latest/userguide/manage-your-identity-source-idp.html) in the AWS documentation.
  </Step>

  <Step title="Assign users to the permission set">
    In IAM Identity Center, assign the permission set to the AWS account that hosts Bedrock, and add the users or groups who should have access.
  </Step>

  <Step title="Record the values you need for device configuration">
    From the IAM Identity Center **Settings** page, note:

    * **AWS access portal URL**: of the form `https://d-xxxxxxxxxx.awsapps.com/start` (or your custom subdomain)
    * **Identity Center region**: the region where Identity Center is enabled, which may differ from your Bedrock region
    * **AWS account ID**: the 12-digit ID of the account where you enabled Bedrock
    * **Permission set name**: the name you gave the permission set above
  </Step>
</Steps>

## Prepare devices

What each end-user device needs depends on the authentication approach you chose.

### In-app AWS sign-in

No per-device preparation is required. Distribute the four `inferenceBedrockSso*` keys in the managed configuration; the app shows a **Sign in with AWS** page on first launch, runs the IAM Identity Center device-authorization flow in the system browser, and stores the resulting token encrypted with the operating system's secure storage. See [Sign in with AWS for Amazon Bedrock](/cowork/3p/bedrock-aws-sign-in) for the full flow.

### Bearer token

No per-device preparation is required. In the [Amazon Bedrock console](https://console.aws.amazon.com/bedrock/home#/api-keys), generate an API key. The key's underlying IAM principal must be allowed the `bedrock:CallWithBearerToken` action; without it, requests return an authorization error even though the key was created. You will place the key in the managed configuration in the next section.

### Named profile

Each device needs AWS CLI v2 installed and an AWS config file that defines the named profile.

You do not need users to run `aws configure sso` interactively. That command is a wizard that writes a profile stanza to `~/.aws/config` (macOS) or `%USERPROFILE%\.aws\config` (Windows), and you can distribute that file directly through your device-management tooling instead. A profile that uses IAM Identity Center looks like:

```ini theme={null}
[profile claude-cowork]
sso_session = corp
sso_account_id = 123456789012
sso_role_name = ClaudeCoworkAccess
region = us-west-2

[sso-session corp]
sso_start_url = https://d-xxxxxxxxxx.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access
```

The recurring action for users is `aws sso login --profile claude-cowork`, which opens a browser for IAM Identity Center sign-in and caches a token under `~/.aws/sso/cache/`. To remove that manual step, some organizations deploy a launcher that runs `aws sts get-caller-identity` as a probe, falls back to `aws sso login` if it fails, and then opens Claude.

If your AWS configuration files are not at the default location, set `inferenceBedrockAwsDir` to the directory that contains them.

## Configure the app

With AWS set up and devices prepared, open the in-app configuration window (**Developer → Configure third-party inference**) on an evaluation device. In the **Connection** section, set **Inference provider** to **Bedrock** and fill in the **Bedrock credentials** card with the values for whichever authentication approach you chose:

| Field                | Bearer token         | In-app AWS sign-in                       | Named profile          |
| -------------------- | -------------------- | ---------------------------------------- | ---------------------- |
| AWS region           | e.g. `us-west-2`     | e.g. `us-west-2`                         | e.g. `us-west-2`       |
| AWS bearer token     | your Bedrock API key | *leave empty*                            | *leave empty*          |
| Bedrock base URL     | *optional*           | *optional*                               | *optional*             |
| AWS profile name     | *leave empty*        | *leave empty*                            | `claude-cowork`        |
| AWS config directory | *leave empty*        | *leave empty*                            | *only if not `~/.aws`* |
| AWS SSO start URL    | *leave empty*        | `https://d-xxxxxxxxxx.awsapps.com/start` | *leave empty*          |
| AWS SSO region       | *leave empty*        | e.g. `us-east-1`                         | *leave empty*          |
| AWS SSO account ID   | *leave empty*        | `123456789012`                           | *leave empty*          |
| AWS SSO role name    | *leave empty*        | `BedrockInference`                       | *leave empty*          |
| Bedrock service tier | *optional*           | *optional*                               | *optional*             |

Under **Identity & models**, add a **Model list** entry using the Bedrock inference-profile ID (required for profile or SSO auth; optional for bearer-token auth, which auto-discovers), for example `us.anthropic.claude-sonnet-4-20250514-v1:0`.

Then click **Export** to produce a `.mobileconfig` (macOS) or `.reg` (Windows) file for your MDM. See [Installation and setup](/cowork/3p/installation) for the export and deployment workflow.

### Configuration keys

The full set of Bedrock keys is below. Set `inferenceProvider` to `bedrock`, supply a region, and provide exactly one credential source.

| Setting                                                 | Required              | Description                                                                                                                                                                                                                                                                      |
| ------------------------------------------------------- | --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AWS region<br />`inferenceBedrockRegion`                | Yes                   | AWS region for the Bedrock runtime endpoint, for example `us-west-2` or `us-gov-west-1`.                                                                                                                                                                                         |
| AWS bearer token<br />`inferenceBedrockBearerToken`     | One credential source | Bedrock API key generated from the Amazon Bedrock console.                                                                                                                                                                                                                       |
| AWS profile name<br />`inferenceBedrockProfile`         | One credential source | AWS named profile from the device's AWS config and credentials files.                                                                                                                                                                                                            |
| AWS SSO start URL<br />`inferenceBedrockSsoStartUrl`    | One credential source | AWS access portal URL. Enables in-app [AWS sign-in](/cowork/3p/bedrock-aws-sign-in) (no AWS CLI needed). Set with the three SSO fields below. Ignored when a bearer token or profile is set.                                                                                     |
| AWS SSO region<br />`inferenceBedrockSsoRegion`         | One credential source | IAM Identity Center home region.                                                                                                                                                                                                                                                 |
| AWS SSO account ID<br />`inferenceBedrockSsoAccountId`  | One credential source | 12-digit AWS account ID assigned to users in IAM Identity Center.                                                                                                                                                                                                                |
| AWS SSO role name<br />`inferenceBedrockSsoRoleName`    | One credential source | IAM Identity Center permission-set name granting `bedrock:InvokeModel*` on the account above.                                                                                                                                                                                    |
| AWS config directory<br />`inferenceBedrockAwsDir`      | No                    | Absolute path to the directory containing the AWS `config` and `credentials` files, if not the default `~/.aws`.                                                                                                                                                                 |
| Bedrock base URL<br />`inferenceBedrockBaseUrl`         | No                    | Override the public regional endpoint, for example with a PrivateLink VPC interface endpoint. Must be `https://`.                                                                                                                                                                |
| Bedrock service tier<br />`inferenceBedrockServiceTier` | No                    | One of `flex` or `priority`. Sent as the `X-Amzn-Bedrock-Service-Tier` header on every inference request. Leave unset for the default on-demand tier. Tier availability varies by model and region; reserved capacity uses a provisioned-throughput ARN as the model ID instead. |

Set `inferenceModels` to a list of Bedrock inference-profile IDs, for example `us.anthropic.claude-sonnet-4-20250514-v1:0`. When using a bearer token, Cowork auto-discovers available Claude models from your account if this is unset; for profile or SSO authentication, the list is required. Application-inference-profile ARNs and provisioned-throughput ARNs are also accepted; pair them with a [`labelOverride`](/cowork/3p/configuration#setting-a-display-label) so the picker shows a readable name instead of the raw ARN. See the [Configuration reference](/cowork/3p/configuration#models).

## What users experience

The first-launch and re-authentication behavior depends on the authentication approach.

| Approach           | First launch                                                                                                                              | Re-authentication                                                                                                                                         |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Bearer token       | Cowork opens directly; no user action.                                                                                                    | Never, until you rotate the key in the managed profile.                                                                                                   |
| In-app AWS sign-in | Cowork shows a **Sign in with AWS** page; the user approves in the browser.                                                               | When the IAM Identity Center access portal session expires (defaults to 8 hours; configurable up to 90 days). The app prompts in-app; no terminal needed. |
| Named profile      | Cowork opens directly if the AWS SSO cache is fresh. If not, the first request fails and the user must run `aws sso login` in a terminal. | When the IAM Identity Center session expires (the permission set's session duration).                                                                     |

When a named-profile session has expired, requests fail with `ExpiredTokenException` from AWS, and the user runs `aws sso login` again.

## Troubleshoot

To confirm which keys the app read and whether credentials validated, use **Help → Troubleshooting → Copy Managed Configuration Report**; see [Verifying the deployment](/cowork/3p/installation#verifying-the-deployment) for that workflow and the common causes when the app does not enter 3P mode. Application log locations are listed in [Data storage and residency](/cowork/3p/data-storage).