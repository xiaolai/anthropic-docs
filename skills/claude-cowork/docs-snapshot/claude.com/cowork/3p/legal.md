> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Legal and compliance

> Legal agreements, compliance, and security information for Cowork on 3P

## Legal agreements

### License

Your use of the Claude Desktop application, including in Cowork on third-party (3P) mode, is subject to Anthropic's [Commercial Terms of Service](https://www.anthropic.com/legal/commercial-terms).

### Commercial agreements

Cowork on 3P routes model inference through the provider you configure (Google Cloud's Vertex AI, Amazon Bedrock, Microsoft Foundry, or a compatible gateway). Inference usage is billed by, and subject to your agreement with, that provider. Your existing commercial agreement with Anthropic continues to apply to your use of the Claude Desktop application, unless we've mutually agreed otherwise.

## Compliance

When using Vertex AI or Bedrock, conversation content is sent only to your configured inference endpoint and stored on the local device; the compliance posture of your deployment is determined by your inference provider and the device environment you control. During the Microsoft Foundry preview, Claude models run on Anthropic's infrastructure and customers are subject to Anthropic's data use terms. See the [Overview](/cowork/3p/overview) for the architecture and the provider-specific data path.

For Anthropic's certifications and compliance reports, see the [Anthropic Trust Center](https://trust.anthropic.com).

For HIPAA, see [HIPAA](/cowork/3p/overview#hipaa) on the Overview page. When using Vertex AI or Bedrock, Anthropic does not interact with PHI; the BAA relationship is between you and your cloud service provider, and any remote MCP servers you connect should be reviewed for HIPAA compliance.

## Usage policy

Use of Claude models, including via Cowork on 3P, is subject to the [Anthropic Usage Policy](https://www.anthropic.com/legal/aup).

## Privacy and telemetry

The Claude Desktop application sends operational telemetry (crash reports and product analytics) to Anthropic by default. This telemetry contains no prompt or response content and can be fully disabled via managed configuration. See [Telemetry and egress](/cowork/3p/telemetry) for what each category contains and how to disable it.

Anthropic's [Privacy Policy](https://www.anthropic.com/legal/privacy) describes how Anthropic handles data it receives.

## Security and trust

Security architecture, threat-model, and data-flow documentation for Cowork and Cowork on 3P is available on the [Anthropic Trust Center](https://trust.anthropic.com).

### Security vulnerability reporting

Anthropic manages our security program through HackerOne. [Use this form to report vulnerabilities](https://hackerone.com/4f1f16ba-10d3-4d09-9ecc-c721aad90f24/embedded_submissions/new).

***

© Anthropic PBC. All rights reserved. Use is subject to applicable Anthropic Terms of Service.