> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Using Cowork on 3P with an LLM Gateway

> Configure Cowork on 3P to use Claude models on a self-hosted gateway that implements the Anthropic Messages API

To use a self-hosted LLM gateway (for example LiteLLM, Portkey, or an in-house proxy) as the inference provider, set `inferenceProvider` to `gateway` and supply the base URL and credentials described below.

The gateway must implement the Anthropic [Messages API](https://docs.claude.com/en/api/messages):

* `POST /v1/messages` with [streaming](https://docs.claude.com/en/api/streaming) and [tool use](https://docs.claude.com/en/docs/tool-use) is required.
* `GET /v1/models` is optional. If the gateway implements it, Cowork on 3P auto-discovers available models; if not, set `inferenceModels` explicitly.

<Note>
  The data-residency and "no conversation data sent to Anthropic" statements elsewhere in these pages apply to Vertex AI and Bedrock only. When you use a gateway, data handling is determined by the gateway you operate and the upstream provider it routes to.
</Note>

## Configuration keys

| Setting                                               | Required                                  | Description                                                                                                                                                                                                                                                                                                                                                               |
| ----------------------------------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Gateway base URL<br />`inferenceGatewayBaseUrl`       | Yes                                       | Gateway base URL. Must be `https://`.                                                                                                                                                                                                                                                                                                                                     |
| Gateway API key<br />`inferenceGatewayApiKey`         | Unless using `sso` or a credential helper | API key sent to the gateway. The field cannot be empty, so if your gateway authenticates by network identity and does not require a key, set a placeholder value.                                                                                                                                                                                                         |
| Gateway auth scheme<br />`inferenceGatewayAuthScheme` | No                                        | How the credential is sent. `bearer` (default) sends `Authorization: Bearer <key>`. `x-api-key` sends the `x-api-key` header instead. `sso` has each user sign in through your organization's identity provider and sends the resulting token as `Authorization: Bearer`; `inferenceGatewayApiKey` is not required. See [Gateway single sign-on](/cowork/3p/gateway-sso). |
| Gateway extra headers<br />`inferenceGatewayHeaders`  | No                                        | Additional HTTP headers sent on every inference request, as a JSON object mapping header name to value (e.g. `{"X-Org-Id":"team1"}`). A JSON array of `"Name: Value"` strings is also accepted for compatibility.                                                                                                                                                         |

As an alternative to a static `inferenceGatewayApiKey`, configure an [`inferenceCredentialHelper`](/cowork/3p/configuration#credential-helper) executable that prints the gateway credential to stdout, or set `inferenceGatewayAuthScheme` to `sso` for per-user [single sign-on](/cowork/3p/gateway-sso) through your identity provider.

## Models

When `inferenceModels` is unset, Cowork on 3P populates the model picker from your gateway's `GET /v1/models` response. Set [`inferenceModels`](/cowork/3p/configuration#models) to override discovery with an explicit list — the picker will show exactly the entries you provide. Use the model IDs your gateway expects (for example `bedrock/us.anthropic.claude-opus-4-7` for a LiteLLM-style routing prefix).

## Configure in the app

Open the in-app configuration window (**Developer → Configure third-party inference**). In the **Connection** section, set **Inference provider** to **Gateway**, then fill in the **Gateway credentials** card:

| Field                 | Value                                                                                |
| --------------------- | ------------------------------------------------------------------------------------ |
| Gateway base URL      | `https://llm-gateway.example.corp`                                                   |
| Gateway API key       | your gateway key (or a placeholder if your gateway has none)                         |
| Gateway auth scheme   | *leave empty for the default*, or `sso` for [single sign-on](/cowork/3p/gateway-sso) |
| Gateway extra headers | *optional*                                                                           |

Then click **Export** to produce a `.mobileconfig` (macOS) or `.reg` (Windows) file for your MDM. See [Installation and setup](/cowork/3p/installation) for the export and deployment workflow.