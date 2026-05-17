> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Using Cowork on 3P with Microsoft Foundry

> Configure Cowork on 3P to use Claude models on Microsoft Foundry

To use Microsoft Foundry (Azure AI Foundry) as the inference provider, set `inferenceProvider` to `foundry` and supply the resource name and API key described below.

<Note>
  In this preview platform integration, Claude models on Microsoft Foundry run on Anthropic's infrastructure. This is a commercial integration for billing and access through Azure. The data-residency and "no conversation data sent to Anthropic" statements elsewhere in these pages do not apply when using Microsoft Foundry. See the [Overview](/cowork/3p/overview) for details.
</Note>

## Configuration keys

| Setting                                                         | Required | Description                                                                                                                                                               |
| --------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Microsoft Foundry resource name<br />`inferenceFoundryResource` | Yes      | Azure AI Foundry resource name used to construct the endpoint URL (`<resource>.services.ai.azure.com`). Two to sixty-four characters, lowercase alphanumeric and hyphens. |
| Microsoft Foundry API key<br />`inferenceFoundryApiKey`         | Yes      | API key for the Foundry resource. May be supplied dynamically by an [`inferenceCredentialHelper`](/cowork/3p/configuration#credential-helper) executable instead.         |

You must also set `inferenceModels` to a list of Foundry deployment names. See the [Configuration reference](/cowork/3p/configuration#models).

## Configure in the app

Open the in-app configuration window (**Developer → Configure third-party inference**). In the **Connection** section, set **Inference provider** to **Foundry**, then fill in the **Foundry credentials** card:

| Field                           | Value                   |
| ------------------------------- | ----------------------- |
| Microsoft Foundry resource name | `your-foundry-resource` |
| Microsoft Foundry API key       | your API key            |

Under **Identity & models**, add at least one **Model list** entry using the Foundry deployment name.

Then click **Export** to produce a `.mobileconfig` (macOS) or `.reg` (Windows) file for your MDM. See [Installation and setup](/cowork/3p/installation) for the export and deployment workflow.