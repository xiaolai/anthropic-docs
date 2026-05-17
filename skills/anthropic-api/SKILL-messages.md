# Anthropic Messages API — Reference

> **Auto-populated by the daily pipeline.** This file is a stub. After
> the first successful `daily.yml` run for the `anthropic-api` skill,
> it will be rewritten from the upstream docs at
> [platform.claude.com/docs/en/api/messages](https://platform.claude.com/docs/en/api/messages).

Covers:

- `POST /v1/messages` — request shape, response shape, streaming.
- Content blocks — `text`, `image`, `tool_use`, `tool_result`, `thinking`.
- System prompts and message roles.
- `tool_use` / `tool_result` round-trip with the API.
- `count_tokens` endpoint.
- Message batches (`POST /v1/messages/batches`).
- Streaming events (`message_start`, `content_block_delta`, etc.).
- Prompt caching at the API level (cache_control breakpoints).

## Status

- Stub created during scaffold. Next daily run populates from upstream.
- See `state.json.scaffoldComplete` — flips to `true` once populated.
