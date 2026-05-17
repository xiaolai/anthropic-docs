> ## Documentation Index
> Fetch the complete documentation index at: https://claude.com/docs/llms.txt
> Use this file to discover all available pages before exploring further.

# Monitoring

> Track Cowork usage and activity across your organization with OpenTelemetry

Track Cowork usage and activity across your organization by exporting events through [OpenTelemetry](https://opentelemetry.io/) (OTel). Cowork exports events via the OTel logs/events protocol, giving you visibility into user prompts, API requests, tool usage, and errors.

<Note>
  Monitoring is available for Team and Enterprise plans. OTel monitoring requires Claude desktop app version 1.1.4173 or later.
</Note>

## Setup

Configure monitoring from the Cowork admin settings:

1. Navigate to **Admin settings > Cowork**

2. Configure the following fields:

   | Field             | Description                               | Example                             |
   | ----------------- | ----------------------------------------- | ----------------------------------- |
   | **OTLP endpoint** | Your OpenTelemetry collector URL          | `http://collector.example.com:4318` |
   | **OTLP protocol** | Transport protocol                        | `http/json` or `http/protobuf`      |
   | **OTLP headers**  | Authentication headers for your collector | `Authorization=Bearer your-token`   |

3. Save your settings

4. Start a new Cowork session — settings are loaded at session start, so existing sessions won't pick up the new configuration

<Note>
  If your organization has network egress restrictions enabled, add your collector domain to the allowlist at **Admin settings > Capabilities > Network egress**. The OTel exporter runs inside the Cowork VM, and traffic to non-allowlisted domains is silently dropped.
</Note>

## Events

Cowork exports the following events to your OTel collector. User prompt content and tool details are always included in events.

### Event correlation

When a user submits a prompt, Cowork may make multiple API calls and run several tools. The `prompt.id` attribute links all events back to the single prompt that triggered them.

| Attribute   | Description                                                                          |
| ----------- | ------------------------------------------------------------------------------------ |
| `prompt.id` | UUID v4 identifier linking all events produced while processing a single user prompt |

To trace all activity triggered by a single prompt, filter your events by a specific `prompt.id` value.

### Standard attributes

All events include these attributes:

| Attribute              | Description                                                                                  |
| ---------------------- | -------------------------------------------------------------------------------------------- |
| `session.id`           | Unique session identifier                                                                    |
| `organization.id`      | Organization UUID                                                                            |
| `user.account_uuid`    | User's account UUID                                                                          |
| `user.account_id`      | Account ID in tagged format matching Anthropic admin APIs (for example, `user_01BWBeN28...`) |
| `user.id`              | Anonymous device/installation identifier                                                     |
| `user.email`           | User email                                                                                   |
| `workspace.host_paths` | Host workspace directories selected in the desktop app (string array)                        |
| `terminal.type`        | Terminal type (`non-interactive` for Cowork)                                                 |

### User prompt event

Logged when a user submits a prompt.

**Event name**: `user_prompt`

**Attributes**:

All [standard attributes](#standard-attributes), plus:

| Attribute         | Description                                                           |
| ----------------- | --------------------------------------------------------------------- |
| `event.timestamp` | ISO 8601 timestamp                                                    |
| `event.sequence`  | Monotonically increasing counter for ordering events within a session |
| `prompt_length`   | Length of the prompt                                                  |
| `prompt`          | Prompt content                                                        |

### Tool result event

Logged when a tool completes execution.

**Event name**: `tool_result`

**Attributes**:

All [standard attributes](#standard-attributes), plus:

| Attribute                | Description                                                                                                                                                               |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `event.timestamp`        | ISO 8601 timestamp                                                                                                                                                        |
| `event.sequence`         | Monotonically increasing counter for ordering events within a session                                                                                                     |
| `tool_name`              | Name of the tool                                                                                                                                                          |
| `success`                | `"true"` or `"false"`                                                                                                                                                     |
| `duration_ms`            | Execution time in milliseconds                                                                                                                                            |
| `error`                  | Error message (if failed)                                                                                                                                                 |
| `decision_type`          | Either `"accept"` or `"reject"`                                                                                                                                           |
| `decision_source`        | How the decision was made — `"config"`, `"hook"`, `"user_permanent"`, `"user_temporary"`, `"user_abort"`, or `"user_reject"`                                              |
| `tool_result_size_bytes` | Size of the tool result in bytes                                                                                                                                          |
| `mcp_server_scope`       | MCP server scope identifier (for MCP tools)                                                                                                                               |
| `tool_parameters`        | JSON string containing tool-specific parameters, including `mcp_server_name` and `mcp_tool_name` for MCP tools                                                            |
| `tool_input`             | JSON-serialized tool arguments. Individual strings over 512 characters are truncated; entire string limited to \~4K characters. Applies to all tools including MCP tools. |

### API request event

Logged for each API request to Claude.

**Event name**: `api_request`

**Attributes**:

All [standard attributes](#standard-attributes), plus:

| Attribute               | Description                                                           |
| ----------------------- | --------------------------------------------------------------------- |
| `event.timestamp`       | ISO 8601 timestamp                                                    |
| `event.sequence`        | Monotonically increasing counter for ordering events within a session |
| `model`                 | Model used (e.g., `claude-sonnet-4-6`)                                |
| `cost_usd`              | Estimated cost in USD                                                 |
| `duration_ms`           | Request duration in milliseconds                                      |
| `input_tokens`          | Number of input tokens                                                |
| `output_tokens`         | Number of output tokens                                               |
| `cache_read_tokens`     | Number of tokens read from cache                                      |
| `cache_creation_tokens` | Number of tokens used for cache creation                              |
| `speed`                 | `"fast"` or `"normal"`                                                |

### API error event

Logged when an API request to Claude fails.

**Event name**: `api_error`

**Attributes**:

All [standard attributes](#standard-attributes), plus:

| Attribute         | Description                                                           |
| ----------------- | --------------------------------------------------------------------- |
| `event.timestamp` | ISO 8601 timestamp                                                    |
| `event.sequence`  | Monotonically increasing counter for ordering events within a session |
| `model`           | Model used                                                            |
| `error`           | Error message                                                         |
| `status_code`     | HTTP status code as a string, or `"undefined"` for non-HTTP errors    |
| `duration_ms`     | Request duration in milliseconds                                      |
| `attempt`         | Attempt number (for retried requests)                                 |
| `speed`           | `"fast"` or `"normal"`                                                |

### Tool decision event

Logged when a tool permission decision is made.

**Event name**: `tool_decision`

**Attributes**:

All [standard attributes](#standard-attributes), plus:

| Attribute         | Description                                                                                                        |
| ----------------- | ------------------------------------------------------------------------------------------------------------------ |
| `event.timestamp` | ISO 8601 timestamp                                                                                                 |
| `event.sequence`  | Monotonically increasing counter for ordering events within a session                                              |
| `tool_name`       | Name of the tool                                                                                                   |
| `decision`        | Either `"accept"` or `"reject"`                                                                                    |
| `source`          | Decision source — `"config"`, `"hook"`, `"user_permanent"`, `"user_temporary"`, `"user_abort"`, or `"user_reject"` |

## Event analysis

The exported events support a range of analyses:

**Tool usage patterns** — Analyze tool result events to identify most frequently used tools, success rates, average execution times, and error patterns.

**Cost monitoring** — Track `cost_usd` from API request events to understand usage trends across users and teams. Group by `user.account_uuid` or `organization.id` for per-user or per-team breakdowns.

**Performance monitoring** — Track API request durations and tool execution times to identify performance bottlenecks.

<Note>
  Cost values from events are approximations. For official billing data, refer to your billing dashboard.
</Note>

## Backend considerations

Your choice of logs backend determines the types of analyses you can perform:

* **Log aggregation systems** (e.g., Elasticsearch, Loki): Full-text search and log analysis
* **Columnar stores** (e.g., ClickHouse): Structured event analysis and complex queries
* **Observability platforms** (e.g., Honeycomb, Datadog): Advanced querying, visualization, and alerting

## Service information

All events are exported with the following resource attributes:

| Attribute         | Description                            |
| ----------------- | -------------------------------------- |
| `service.name`    | `cowork`                               |
| `service.version` | Claude app version                     |
| `host.arch`       | Host architecture (e.g., `arm64`)      |
| `os.type`         | Operating system type (e.g., `darwin`) |
| `os.version`      | Operating system version string        |

## Security and privacy

* Events are only exported when an admin configures the OTLP endpoint
* User prompt content is included in events — configure your telemetry backend to filter or redact if needed
* Tool execution events include the `tool_input` attribute with file paths, URLs, search patterns, and other arguments — configure your telemetry backend to filter or redact `tool_input` if these may contain sensitive values
* `user.email` is included in event attributes — work with your telemetry backend to filter or redact if this is a concern