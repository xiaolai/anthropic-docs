# Claude Agent SDK — TypeScript Reference (v0.2.77)

**Package**: `@anthropic-ai/claude-agent-sdk@0.2.77`
**Docs**: https://platform.claude.com/docs/en/agent-sdk/overview
**Repo**: https://github.com/anthropics/claude-agent-sdk-typescript
**Migration**: Renamed from `@anthropic-ai/claude-code`. See [migration guide](https://platform.claude.com/docs/en/agent-sdk/migration-guide).

---

## Table of Contents

- [Breaking Changes](#breaking-changes-v010)
- [Core API](#core-api) — `query()`, `tool()`, `createSdkMcpServer()`, `listSessions()`, `getSessionMessages()`, `getSessionInfo()`, `renameSession()`, `forkSession()`, `tagSession()`
- [Options](#options) — Core, Tools & Permissions, Models & Output, Sessions, MCP & Agents, Advanced
- [Query Object Methods](#query-object-methods)
- [Message Types](#message-types) — All 23 SDKMessage types
- [Hooks](#hooks) — 22 hook events, matchers, return values, async hooks
- [Permissions](#permissions) — 5 modes, `canUseTool` callback
- [MCP Servers](#mcp-servers) — stdio, HTTP, SSE, SDK, claudeai-proxy
- [Subagents](#subagents) — AgentDefinition, tool enforcement workaround
- [Structured Outputs](#structured-outputs)
- [Sandbox](#sandbox)
- [Sessions](#sessions)
- [V2 Session API (Preview)](#v2-session-api-preview) — `unstable_v2_createSession`, `unstable_v2_prompt`
- [Debugging & Error Handling](#debugging--error-handling)
- [Known Issues](#known-issues)
- [Changelog Highlights](#changelog-highlights-v0212--v0272)

---

## Breaking Changes (v0.1.0)

1. **No default system prompt** — SDK uses minimal prompt. Use `systemPrompt: { type: 'preset', preset: 'claude_code' }` for old behavior.
2. **No filesystem settings loaded** — `settingSources` defaults to `[]`. Add `settingSources: ['project']` to load CLAUDE.md.
3. **`ClaudeCodeOptions` renamed** — Now `ClaudeAgentOptions` (Python).

---

## Core API

### `query()`

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

function query({
  prompt: string | AsyncIterable<SDKUserMessage>,
  options?: Options
}): Query  // extends AsyncGenerator<SDKMessage, void>
```

**Streaming input**: `prompt` accepts `AsyncIterable<SDKUserMessage>` for real-time, multi-message input:

```typescript
async function* promptStream(): AsyncIterable<SDKUserMessage> {
  yield { type: 'user', content: [{ type: 'text', text: 'First message' }] };
  // yield more messages as they arrive
}

const q = query({ prompt: promptStream() });
for await (const msg of q) { ... }
```

### `tool()`

Creates type-safe MCP tool definitions with Zod schemas.

```typescript
import { tool } from "@anthropic-ai/claude-agent-sdk";

function tool<Schema extends ZodRawShape>(
  name: string,
  description: string,
  inputSchema: Schema,
  handler: (args: z.infer<ZodObject<Schema>>, extra: unknown) => Promise<CallToolResult>,
  _extras?: { annotations?: ToolAnnotations }
): SdkMcpToolDefinition<Schema>
```

Handler returns: `{ content: [{ type: "text", text: "..." }], isError?: boolean }`

### `createSdkMcpServer()`

Creates an in-process MCP server.

```typescript
import { createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";

function createSdkMcpServer(options: {
  name: string;
  version?: string;
  tools?: Array<SdkMcpToolDefinition<any>>;
}): McpSdkServerConfigWithInstance
```

### `listSessions()`

Lists saved session metadata from `~/.claude/projects/`. Useful for building session pickers or resuming conversations by name.

```typescript
import { listSessions } from "@anthropic-ai/claude-agent-sdk";

function listSessions(options?: {
  dir?: string;             // Project directory — filters to sessions for that dir (and its worktrees)
  limit?: number;           // Max sessions to return
  offset?: number;          // Number of sessions to skip from the start (for pagination, default: 0)
  includeWorktrees?: boolean; // When dir is inside a git repo, include sessions from all worktree paths (default: true)
}): Promise<SDKSessionInfo[]>

type SDKSessionInfo = {
  sessionId: string;         // UUID — pass to options.resume
  summary: string;           // Display title (custom title, auto-summary, or first prompt)
  lastModified: number;      // Milliseconds since epoch
  fileSize?: number;         // Session file size in bytes (only populated for local JSONL storage)
  customTitle?: string;      // User-set title via /rename
  firstPrompt?: string;      // First meaningful user prompt
  gitBranch?: string;        // Git branch at end of session
  cwd?: string;              // Working directory for the session
  tag?: string;              // User-set session tag
  createdAt?: number;        // Creation time in milliseconds since epoch
};
```

Example:

```typescript
const sessions = await listSessions({ dir: process.cwd(), limit: 10 });
const latest = sessions[0];
// Resume the most recent session:
for await (const msg of query({ prompt: "Continue", options: { resume: latest.sessionId } })) { ... }
```

### `getSessionMessages()`

Reads a session's conversation messages from its JSONL transcript file. Returns user and assistant messages in chronological order. Useful for inspecting conversation history without resuming a session.

```typescript
import { getSessionMessages } from "@anthropic-ai/claude-agent-sdk";

function getSessionMessages(
  sessionId: string,
  options?: {
    dir?: string;    // Project directory to find the session in; searches all projects if omitted
    limit?: number;  // Maximum number of messages to return
    offset?: number; // Number of messages to skip from the start
  }
): Promise<SessionMessage[]>

type SessionMessage = {
  type: 'user' | 'assistant';
  uuid: string;
  session_id: string;
  message: unknown;           // Raw message content (MessageParam or BetaMessage shape)
  parent_tool_use_id: null;
};
```

Example:

```typescript
const messages = await getSessionMessages(sessionId, { limit: 20 });
for (const msg of messages) {
  console.log(`[${msg.type}]`, msg.uuid);
}
```

### `renameSession()`

Renames a session by appending a custom-title entry to the session's JSONL file. The new title appears in `listSessions()` results as `customTitle`.

```typescript
import { renameSession } from "@anthropic-ai/claude-agent-sdk";

function renameSession(
  sessionId: string,
  title: string,
  options?: { dir?: string }  // Project directory; searches all projects if omitted
): Promise<void>
```

Example:

```typescript
await renameSession(sessionId, "Authentication refactor session");
const sessions = await listSessions();
console.log(sessions[0].customTitle); // "Authentication refactor session"
```

### `getSessionInfo()`

Reads metadata for a single session by ID. Unlike `listSessions()`, only reads one session file. Returns `undefined` if the session is not found or has no extractable summary.

```typescript
import { getSessionInfo } from "@anthropic-ai/claude-agent-sdk";

function getSessionInfo(
  sessionId: string,
  options?: { dir?: string }  // Project directory; searches all projects if omitted
): Promise<SDKSessionInfo | undefined>
```

Example:

```typescript
const info = await getSessionInfo(sessionId);
if (info) console.log(info.summary, info.lastModified);
```

### `forkSession()`

Forks a session into a new branch with fresh UUIDs. Copies transcript messages from the source session, optionally up to a specific message. Forked sessions start without undo history.

```typescript
import { forkSession } from "@anthropic-ai/claude-agent-sdk";

function forkSession(
  sessionId: string,
  options?: {
    dir?: string;              // Project directory; searches all projects if omitted
    upToMessageId?: string;    // Fork up to this message UUID (inclusive); full copy if omitted
    title?: string;            // Custom title for the fork; derives from original + " (fork)" if omitted
  }
): Promise<{ sessionId: string }>  // UUID of the new forked session
```

Example:

```typescript
const { sessionId: forkId } = await forkSession(sessionId, {
  upToMessageId: checkpointMessageId,
  title: "GraphQL experiment"
});
// Resume the fork with a different approach
for await (const msg of query({ prompt: "Try GraphQL", options: { resume: forkId } })) { ... }
```

### `tagSession()`

Adds or clears a tag on a session. Tags appear in `listSessions()` results as `tag`. Pass `null` to clear the tag.

```typescript
import { tagSession } from "@anthropic-ai/claude-agent-sdk";

function tagSession(
  sessionId: string,
  tag: string | null,
  options?: { dir?: string }  // Project directory; searches all projects if omitted
): Promise<void>
```

Example:

```typescript
await tagSession(sessionId, "needs-review");
const sessions = await listSessions();
console.log(sessions[0].tag); // "needs-review"

// Clear the tag
await tagSession(sessionId, null);
```

---

## Options

### Core Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `model` | `string` | CLI default | Claude model to use |
| `cwd` | `string` | `process.cwd()` | Working directory |
| `systemPrompt` | `string \| { type: 'preset', preset: 'claude_code', append?: string }` | minimal | System prompt |
| `settingSources` | `SettingSource[]` | `[]` | `'user' \| 'project' \| 'local'` |
| `env` | `Dict<string>` | `process.env` | Environment variables (set `CLAUDE_AGENT_SDK_CLIENT_APP` to identify your app in User-Agent, e.g. `'my-app/1.0.0'`) |
| `abortController` | `AbortController` | — | Cancellation controller |

### Tools & Permissions

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `tools` | `string[] \| { type: 'preset', preset: 'claude_code' }` | — | Tool configuration |
| `allowedTools` | `string[]` | All tools | Allowed tool names |
| `disallowedTools` | `string[]` | `[]` | Blocked tool names |
| `permissionMode` | `PermissionMode` | `'default'` | `'default' \| 'acceptEdits' \| 'bypassPermissions' \| 'plan' \| 'dontAsk'` — see [Permissions](#permissions) |
| `canUseTool` | `CanUseTool` | — | Custom permission callback |
| `allowDangerouslySkipPermissions` | `boolean` | `false` | Required with `bypassPermissions` |
| `permissionPromptToolName` | `string` | — | Route permission prompts through a named MCP tool |

### Models & Output

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `outputFormat` | `{ type: 'json_schema', schema: JSONSchema }` | — | Structured output schema |
| `thinking` | `ThinkingConfig` | — | `{ type: 'enabled', budgetTokens?: number } \| { type: 'disabled' } \| { type: 'adaptive' }` |
| `effort` | `'low' \| 'medium' \| 'high' \| 'max'` | — | Controls response effort level |
| `maxThinkingTokens` | `number` | — | **Deprecated** — use `thinking` instead |
| `fallbackModel` | `string` | — | Fallback model on failure |
| `betas` | `SdkBeta[]` | `[]` | Beta features (e.g., `['context-1m-2025-08-07']`) |
| `includePartialMessages` | `boolean` | `false` | Include streaming partial messages |
| `promptSuggestions` | `boolean` | `false` | Emit `SDKPromptSuggestionMessage` after each turn with a predicted next user prompt (arrives after result; suppressed on first turn, after errors, in plan mode) |
| `agentProgressSummaries` | `boolean` | `false` | Enable periodic AI-generated progress summaries for running subagents. Every ~30s, forks the subagent's conversation to produce a short present-tense description emitted on `task_progress` events via the `summary` field. Applies to foreground and background subagents. |

### Sessions

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `resume` | `string` | — | Session ID to resume |
| `forkSession` | `boolean` | `false` | Fork when resuming |
| `continue` | `boolean` | `false` | Continue most recent conversation |
| `sessionId` | `string` | auto | Custom UUID for session (v0.2.33) |
| `resumeSessionAt` | `string` | — | Resume at specific message UUID |
| `persistSession` | `boolean` | `true` | When false, disables session persistence to disk |
| `maxTurns` | `number` | — | Max conversation turns (critical safety net — sessions never timeout) |
| `maxBudgetUsd` | `number` | — | Max budget in USD |
| `enableFileCheckpointing` | `boolean` | `false` | Enable file rollback |

### MCP & Agents

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `mcpServers` | `Record<string, McpServerConfig>` | `{}` | MCP server configs |
| `agents` | `Record<string, AgentDefinition>` | — | Subagent definitions |
| `agent` | `string` | — | Apply a named agent's config to main thread (like `--agent` CLI flag) |
| `plugins` | `SdkPluginConfig[]` | `[]` | `{ type: 'local', path: string }` |
| `strictMcpConfig` | `boolean` | `false` | Strict MCP validation |

### Advanced

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `onElicitation` | `OnElicitation` | — | Callback for MCP elicitation requests (form fields, URL auth); auto-declines if not provided |
| `sandbox` | `SandboxSettings` | — | Sandbox configuration |
| `hooks` | `Partial<Record<HookEvent, HookCallbackMatcher[]>>` | `{}` | Hook callbacks |
| `settings` | `string \| Settings` | — | Additional settings to apply (path to JSON file or inline object). Loaded into the highest-priority "flag settings" layer. Equivalent to `--settings` CLI flag. |
| `toolConfig` | `ToolConfig` | — | Per-tool configuration for built-in tools (e.g., `{ askUserQuestion: { previewFormat: 'html' } }`) |
| `additionalDirectories` | `string[]` | `[]` | Extra directories for Claude to access |
| `debug` | `boolean` | — | Enable debug logging (v0.2.30) |
| `debugFile` | `string` | — | Debug log file path (v0.2.30) |
| `stderr` | `(data: string) => void` | — | stderr callback |
| `executable` | `'bun' \| 'deno' \| 'node'` | auto | JS runtime |
| `executableArgs` | `string[]` | — | Additional arguments for the JS runtime |
| `extraArgs` | `Record<string, string \| null>` | — | Additional CLI arguments to pass to Claude Code |
| `pathToClaudeCodeExecutable` | `string` | auto | Explicit path to Claude Code CLI binary |
| `spawnClaudeCodeProcess` | `(options: SpawnOptions) => SpawnedProcess` | — | Custom spawn function for VMs/containers/remote execution |

---

## Query Object Methods

```typescript
const q = query({ prompt: "..." });

for await (const message of q) { ... }    // Primary: iterate messages

// Control
await q.interrupt();                        // Interrupt (streaming input mode)
q.close();                                  // Force terminate (v0.2.15)
await q.setModel("claude-opus-4-6");        // Change model
await q.setPermissionMode("acceptEdits");   // Change permissions
await q.setMaxThinkingTokens(4096);         // Change thinking budget (number | null)
await q.streamInput(stream);                // Stream user messages (AsyncIterable<SDKUserMessage>)
await q.stopTask(taskId);                   // Stop a running background task by ID

// Introspection
await q.supportedModels();                  // List available models
await q.supportedAgents();                  // List available subagents (AgentInfo[])
await q.supportedCommands();                // List slash commands
await q.mcpServerStatus();                  // MCP server status
await q.accountInfo();                      // Account info
await q.initializationResult();             // Full init response (commands, models, account, styles)
await q.applyFlagSettings(settings);        // Merge settings into flag layer mid-session (shallow-merge per top-level key)

// MCP management
await q.reconnectMcpServer("server-name");  // Reconnect MCP server (v0.2.21)
await q.toggleMcpServer("server-name", enabled); // Toggle MCP server (v0.2.21)
await q.setMcpServers(newServersConfig);    // Replace MCP servers mid-session

// File checkpointing (requires enableFileCheckpointing: true)
await q.rewindFiles(userMessageUuid, { dryRun?: boolean }); // Rewind to checkpoint
```

### Initialization Result Type

The `initializationResult()` method returns detailed session initialization data:

```typescript
type SDKControlInitializeResponse = {
  commands: SlashCommand[];              // Available skills/slash commands
  agents: AgentInfo[];                   // Available subagents
  output_style: string;                  // Current output style setting
  available_output_styles: string[];     // All available output style options
  models: ModelInfo[];                   // Available models
  account: AccountInfo;                  // User account information
  fast_mode_state?: FastModeState;       // 'off' | 'cooldown' | 'on' — rate-limit fast mode status
};

type SlashCommand = {
  name: string;           // Command name (without leading slash)
  description: string;    // What the command does
  argumentHint: string;   // Hint for arguments (e.g., "<file>")
};

type ModelInfo = {
  value: string;          // Model identifier for API calls
  displayName: string;    // Human-readable name
  description: string;    // Model capabilities description
  supportsEffort?: boolean;                              // Whether this model supports effort levels
  supportedEffortLevels?: ('low' | 'medium' | 'high' | 'max')[];  // Available effort levels
  supportsAdaptiveThinking?: boolean;                   // Whether this model supports adaptive thinking
  supportsFastMode?: boolean;                           // Whether this model supports fast mode (rate-limit speed optimization)
  supportsAutoMode?: boolean;                           // Whether this model supports auto mode
};

type AccountInfo = {
  email?: string;
  organization?: string;
  subscriptionType?: string;
  tokenSource?: string;
  apiKeySource?: string;
  apiProvider?: 'firstParty' | 'bedrock' | 'vertex' | 'foundry';  // Active API backend
};
```

---

## Message Types

The SDK emits 23 message types through the async generator:

```typescript
type SDKMessage =
  // Core messages
  | SDKAssistantMessage           // type: 'assistant' — agent responses
  | SDKUserMessage                // type: 'user' — user input
  | SDKUserMessageReplay          // type: 'user', isReplay: true — replayed messages on resume
  | SDKResultMessage              // type: 'result' — final result
  | SDKSystemMessage              // type: 'system', subtype: 'init' — session init
  | SDKPartialAssistantMessage    // type: 'stream_event' (includePartialMessages)
  | SDKCompactBoundaryMessage     // type: 'system', subtype: 'compact_boundary'
  // Status & progress
  | SDKStatusMessage              // type: 'system', subtype: 'status' — status updates (e.g., 'compacting')
  | SDKAPIRetryMessage            // type: 'system', subtype: 'api_retry' — transient API error being retried (v0.2.77)
  | SDKToolProgressMessage        // type: 'tool_progress' — tool execution progress with elapsed time
  | SDKToolUseSummaryMessage      // type: 'tool_use_summary' — summary of tool usage
  | SDKAuthStatusMessage          // type: 'auth_status' — authentication status
  | SDKLocalCommandOutputMessage  // type: 'system', subtype: 'local_command_output' — output from slash commands like /cost, /voice
  // Hook messages
  | SDKHookStartedMessage         // type: 'system', subtype: 'hook_started'
  | SDKHookProgressMessage        // type: 'system', subtype: 'hook_progress' — hook stdout/stderr
  | SDKHookResponseMessage        // type: 'system', subtype: 'hook_response' — hook outcome
  // Task & persistence
  | SDKTaskStartedMessage         // type: 'system', subtype: 'task_started' — emitted when background task begins
  | SDKTaskProgressMessage        // type: 'system', subtype: 'task_progress' — periodic progress updates for running tasks
  | SDKTaskNotificationMessage    // type: 'system', subtype: 'task_notification' — background task events
  | SDKFilesPersistedEvent        // type: 'system', subtype: 'files_persisted'
  // MCP Elicitation
  | SDKElicitationCompleteMessage // type: 'system', subtype: 'elicitation_complete' — MCP elicitation finished
  // Rate limiting & suggestions
  | SDKRateLimitEvent             // type: 'rate_limit_event' — rate limit status for claude.ai subscriptions
  | SDKPromptSuggestionMessage    // type: 'prompt_suggestion' — predicted next user prompt (requires promptSuggestions: true)
```

### SDKAPIRetryMessage (v0.2.77)

```typescript
{ type: 'system', subtype: 'api_retry', uuid, session_id,
  attempt: number,             // Current attempt number (1-based)
  max_retries: number,         // Maximum number of retries
  retry_delay_ms: number,      // Delay before next attempt in ms
  error_status: number | null, // HTTP status code, or null for connection errors (e.g. timeouts)
  error: SDKAssistantMessageError }
```

Emitted when a transient API error is automatically retried. Use to show retry indicators in UIs or log retry storms.

### SDKResultMessage

```typescript
// Success
{ type: 'result', subtype: 'success', session_id, duration_ms, duration_api_ms,
  is_error: false, num_turns, result: string, total_cost_usd,
  usage, modelUsage, permission_denials, structured_output?, stop_reason?,
  fast_mode_state?: FastModeState }

// Error variants
{ type: 'result', subtype: 'error_max_turns' | 'error_during_execution'
  | 'error_max_budget_usd' | 'error_max_structured_output_retries',
  session_id, is_error: true, errors: string[], ...,
  fast_mode_state?: FastModeState }

// Error codes (SDKAssistantMessageError)
'authentication_failed' | 'billing_error' | 'rate_limit' |
'invalid_request' | 'server_error' | 'unknown' | 'max_output_tokens'
```

### SDKSystemMessage (init)

```typescript
{ type: 'system', subtype: 'init', session_id, model, tools: string[],
  cwd, mcp_servers: { name, status }[], permissionMode, slash_commands,
  apiKeySource, output_style,
  agents?: string[],              // Available agent names
  betas?: string[],               // Active beta features
  claude_code_version: string,    // CLI version (e.g., "2.1.41")
  skills: string[],               // Loaded skills
  plugins: { name: string; path: string }[],  // Active plugins
  fast_mode_state?: FastModeState             // 'off' | 'cooldown' | 'on'
}
```

### SDKAssistantMessage

```typescript
{ type: 'assistant', uuid, session_id, message: APIAssistantMessage,
  parent_tool_use_id: string | null }
```

### SDKUserMessageReplay

```typescript
// Replayed user messages on session resume
{ type: 'user', ..., isReplay: true }
```

### Streaming Pattern

```typescript
let sessionId: string;
for await (const message of query({ prompt: "...", options })) {
  switch (message.type) {
    case 'system':
      if (message.subtype === 'init') sessionId = message.session_id;
      if (message.subtype === 'status') console.log('Status:', message.status, message.permissionMode);  // permissionMode?: PermissionMode
      if (message.subtype === 'api_retry') console.log(`Retrying (${message.attempt}/${message.max_retries}), delay ${message.retry_delay_ms}ms, http_status: ${message.error_status}`);
      if (message.subtype === 'hook_progress') console.log('Hook:', message.output);  // also: .stdout, .stderr, .hook_name, .hook_event
      if (message.subtype === 'local_command_output') console.log('Slash cmd output:', message.content);
      if (message.subtype === 'elicitation_complete') console.log('Elicitation done:', message.mcp_server_name, message.elicitation_id);
      if (message.subtype === 'task_started') console.log('Task started:', message.task_id, message.description, message.task_type, message.prompt);  // task_type?: string; prompt?: string
      if (message.subtype === 'task_progress') console.log('Task progress:', message.task_id, message.description, message.last_tool_name, message.usage, message.summary);  // usage: {total_tokens, tool_uses, duration_ms}; last_tool_name?: string; tool_use_id?: string; summary?: string (from agentProgressSummaries)
      if (message.subtype === 'task_notification') console.log('Task done:', message.task_id, message.status, message.tool_use_id, message.output_file, message.summary);  // output_file: string, summary: string, usage?: {total_tokens, tool_uses, duration_ms}
      break;
    case 'assistant':
      console.log(message.message);
      break;
    case 'tool_progress':
      console.log(`Tool running: ${message.tool_name} (${message.elapsed_time_seconds}s) task:${message.task_id}`);  // task_id?: string
      break;
    case 'result':
      if (message.subtype === 'success') {
        console.log(message.result);
        if (message.structured_output) console.log(message.structured_output);
      } else {
        console.error(message.errors);
      }
      break;
  }
}
```

---

## Hooks

Hooks use **callback matchers**: an optional regex `matcher` for tool names and an array of `hooks` callbacks.

### Hook Events

| Event | Fires When | TS | Py |
|-------|-----------|----|----|
| `Setup` | On init or maintenance trigger | Yes | No |
| `PreToolUse` | Before tool execution | Yes | Yes |
| `PostToolUse` | After tool execution | Yes | Yes |
| `PostToolUseFailure` | Tool execution failed | Yes | No |
| `UserPromptSubmit` | User prompt received | Yes | Yes |
| `Stop` | Agent stopping | Yes | Yes |
| `SubagentStart` | Subagent spawned | Yes | No |
| `SubagentStop` | Subagent completed | Yes | Yes |
| `PreCompact` | Before context compaction | Yes | Yes |
| `PostCompact` | After context compaction completes | Yes | No |
| `PermissionRequest` | Permission dialog would show | Yes | No |
| `SessionStart` | Session begins | Yes | No |
| `SessionEnd` | Session ends | Yes | No |
| `Notification` | Agent status message | Yes | No |
| `TeammateIdle` | Teammate agent is idle (v0.2.33) | Yes | No |
| `TaskCompleted` | Background task completed (v0.2.33) | Yes | No |
| `ConfigChange` | Settings file changed (user/project/local/policy/skills) | Yes | No |
| `WorktreeCreate` | Git worktree created | Yes | No |
| `WorktreeRemove` | Git worktree removed | Yes | No |
| `Elicitation` | MCP server requests user input (form or URL auth) | Yes | No |
| `ElicitationResult` | MCP elicitation completed (result available) | Yes | No |
| `InstructionsLoaded` | CLAUDE.md / instructions file loaded into context | Yes | No |

### Hook Callback Signature

```typescript
type HookCallback = (
  input: HookInput,              // Event-specific data
  toolUseID: string | undefined, // Correlate Pre/PostToolUse
  options: { signal: AbortSignal }
) => Promise<HookJSONOutput>;
```

### Hook Configuration

```typescript
// HookCallbackMatcher interface:
// { matcher?: string; hooks: HookCallback[]; timeout?: number }
// timeout is in seconds (default: 60). Use a large value for interactive hooks.
// See Known Issue #29 — there is no way to disable the timeout entirely.

const response = query({
  prompt: "...",
  options: {
    hooks: {
      Setup: [{ hooks: [initCallback] }],  // fires on init/maintenance
      PreToolUse: [
        { matcher: 'Write|Edit', hooks: [protectFiles], timeout: 30 },
        { matcher: '^mcp__', hooks: [logMcpCalls] },
        { hooks: [globalLogger] }  // no matcher = all tools
      ],
      Stop: [{ hooks: [cleanup] }],  // matchers ignored for lifecycle hooks
      Notification: [{ hooks: [notifySlack] }],
      TeammateIdle: [{ hooks: [coordinateTeam] }],
      TaskCompleted: [{ hooks: [onTaskDone] }]
    }
  }
});
```

### Hook Return Values

```typescript
// Allow (empty = allow)
return {};

// Block a tool (PreToolUse only)
// WARNING: permissionDecision: 'deny' causes API 400 error — see Known Issue #12
return {
  hookSpecificOutput: {
    hookEventName: input.hook_event_name,
    permissionDecision: 'allow',  // Use 'allow' with modified input instead of 'deny'
    updatedInput: { command: `echo "BLOCKED: ${reason}"` }
  }
};

// Modify tool input (PreToolUse only, requires permissionDecision: 'allow')
return {
  hookSpecificOutput: {
    hookEventName: input.hook_event_name,
    permissionDecision: 'allow',
    updatedInput: { ...input.tool_input, file_path: `/sandbox${path}` }
  }
};

// Modify MCP tool output (PostToolUse only)
return {
  hookSpecificOutput: {
    hookEventName: input.hook_event_name,
    updatedMCPToolOutput: { content: [{ type: 'text', text: 'filtered output' }] }
  }
};

// Inject context (PreToolUse, PostToolUse, UserPromptSubmit, SessionStart)
return {
  hookSpecificOutput: {
    hookEventName: input.hook_event_name,
    additionalContext: 'Extra instructions for Claude'
  }
};

// Decision-based response (reason is a top-level field, not nested)
return { decision: 'approve', reason: 'Looks safe' };   // or 'block'

// Stop agent
return { continue: false, stopReason: 'Budget exceeded' };

// Inject system message
return { systemMessage: 'Remember: /etc is protected' };

// Suppress hook output
return { suppressOutput: true };
```

### Async Hooks

Hooks can run asynchronously with a timeout:

```typescript
return { async: true, asyncTimeout: 30000 };  // 30s timeout
```

### Hook Input Fields

Common fields on all hooks: `session_id`, `transcript_path`, `cwd`, `permission_mode?`, `agent_id?` (set when hook fires from within a subagent), `agent_type?` (set when hook fires from within a subagent, or on the main thread of a session started with `--agent`)

| Field | Hooks |
|-------|-------|
| `tool_name`, `tool_input`, `tool_use_id` | PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest |
| `tool_response` | PostToolUse |
| `error`, `is_interrupt` | PostToolUseFailure |
| `prompt` | UserPromptSubmit |
| `stop_hook_active` | Stop, SubagentStop |
| `last_assistant_message` | Stop, SubagentStop (text of last assistant message, avoids parsing transcript) |
| `agent_id`, `agent_type` | SubagentStart |
| `agent_id`, `agent_type`, `agent_transcript_path` | SubagentStop |
| `trigger` (`'init' \| 'maintenance'`) | Setup |
| `trigger` (`'manual' \| 'auto'`), `custom_instructions` | PreCompact |
| `trigger` (`'manual' \| 'auto'`), `compact_summary` (the conversation summary produced by compaction) | PostCompact |
| `source` | SessionStart (`'startup' \| 'resume' \| 'clear' \| 'compact'`) |
| `agent_type`, `model` | SessionStart |
| `reason` | SessionEnd |
| `message`, `title`, `notification_type` | Notification |
| `permission_suggestions` | PermissionRequest |
| `teammate_name`, `team_name` | TeammateIdle |
| `task_id`, `task_subject`, `task_description`, `teammate_name`, `team_name` | TaskCompleted |
| `source` (`'user_settings' \| 'project_settings' \| 'local_settings' \| 'policy_settings' \| 'skills'`), `file_path?` | ConfigChange |
| `name` | WorktreeCreate (worktree name) |
| `worktree_path` | WorktreeRemove (path of removed worktree) |
| `mcp_server_name`, `message`, `mode?`, `url?`, `elicitation_id?`, `requested_schema?` | Elicitation |
| `mcp_server_name`, `elicitation_id?`, `mode?`, `action`, `content?` | ElicitationResult |
| `file_path`, `memory_type` (`'User' \| 'Project' \| 'Local' \| 'Managed'`), `load_reason` (`'session_start' \| 'nested_traversal' \| 'path_glob_match' \| 'include' \| 'compact'`), `globs?`, `trigger_file_path?`, `parent_file_path?` | InstructionsLoaded |

---

## Permissions

### PermissionMode

```typescript
type PermissionMode =
  | 'default'            // Prompt user for each action
  | 'acceptEdits'        // Auto-allow file edits, prompt for others
  | 'bypassPermissions'  // Skip all prompts (requires allowDangerouslySkipPermissions)
  | 'plan'               // Read-only planning mode — no writes/execution
  | 'dontAsk';           // Don't prompt — deny if not pre-approved
```

**Note**: `allowedTools` is ignored when `permissionMode: 'bypassPermissions'` — Claude can use any tool.

### canUseTool

```typescript
type CanUseTool = (
  toolName: string,
  input: Record<string, unknown>,
  options: {
    signal: AbortSignal;
    suggestions?: PermissionUpdate[];  // Permission suggestions from Claude
    blockedPath?: string;              // Path that triggered a permission check
    decisionReason?: string;           // Why this permission check was triggered
    title?: string;                    // Full permission prompt sentence (e.g. "Claude wants to read foo.txt")
    displayName?: string;              // Short noun phrase for the action (e.g. "Read file") — for button labels
    description?: string;              // Human-readable subtitle (e.g. "Claude will have read access to ~/Downloads")
    toolUseID: string;                 // ID of the tool use block
    agentID?: string;                  // Subagent ID (if called from a subagent)
  }
) => Promise<PermissionResult>;

type PermissionResult =
  | { behavior: 'allow'; updatedInput?: Record<string, unknown>; updatedPermissions?: PermissionUpdate[]; toolUseID?: string; }
  | { behavior: 'deny'; message: string; interrupt?: boolean; toolUseID?: string; };
```

Example:

```typescript
canUseTool: async (toolName, input, { signal, toolUseID, agentID }) => {
  if (['Read', 'Grep', 'Glob'].includes(toolName)) {
    return { behavior: 'allow', updatedInput: input };
  }
  if (toolName === 'Bash' && /rm -rf|dd if=|mkfs/.test(String(input.command ?? ''))) {
    return { behavior: 'deny', message: 'Destructive command blocked' };
  }
  return { behavior: 'allow', updatedInput: input };
}
```

---

## MCP Servers

### Config Types

```typescript
// stdio (type field optional, defaults to 'stdio')
{ command: "npx", args: ["@playwright/mcp@latest"], env?: Record<string, string> }

// HTTP (type required)
{ type: "http", url: "https://api.example.com/mcp", headers?: Record<string, string> }

// SSE (type required)
{ type: "sse", url: "https://api.example.com/mcp/sse", headers?: Record<string, string> }

// In-process SDK server
{ type: "sdk", name: "my-server", instance: mcpServerInstance }

// Claude AI Proxy (routes through Claude.ai)
{ type: "claudeai-proxy", url: "https://...", id: "server-id" }
```

**Tool naming**: `mcp__<server-name>__<tool-name>` (double underscores)

### In-Process MCP Server Example

```typescript
import { query, tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

const weatherTool = tool("get_weather", "Get weather for a city", {
  city: z.string().describe("City name")
}, async (args) => ({
  content: [{ type: "text", text: `Weather in ${args.city}: 72°F, sunny` }]
}));

const server = createSdkMcpServer({ name: "weather", tools: [weatherTool] });

for await (const msg of query({
  prompt: "What's the weather in Tokyo?",
  options: { mcpServers: { weather: server } }
})) {
  if (msg.type === 'result' && msg.subtype === 'success') console.log(msg.result);
}
```

### MCP Tool Annotations (v0.2.27)

```typescript
const myTool = tool("delete_record", "Delete a record", {
  id: z.string()
}, async (args) => { ... });
myTool.annotations = { destructiveHint: true, readOnlyHint: false };
```

### MCP Gotchas

- **URL-based servers require `type` field** — missing it causes opaque "exit code 1" (see [Known Issue #3](#3-mcp-config-missing-type-field))
- **SDK MCP servers don't support concurrent queries** — use stdio servers instead (see [Known Issue #7](#7-sdk-mcp-servers-fail-from-concurrent-query-calls))
- **In-process MCP servers don't work in subagents** since v0.2.23 ([#158](https://github.com/anthropics/claude-agent-sdk-typescript/issues/158))
- **HTTP MCP servers fail behind corporate proxies** — use SSE or stdio instead ([Known Issue #14](#14-http-mcp-servers-fail-behind-corporate-proxies))
- **Unicode U+2028/U+2029 in tool results breaks JSON** — sanitize all MCP responses (see [Known Issue #5](#5-unicode-line-separators-break-json))
- **5-minute hard timeout** on MCP tool calls — no workaround (see [Known Issue #10](#10-mcp-tool-calls-timeout-at-5-minutes-despite-mcp_tool_timeout))

---

## Subagents

### AgentDefinition

```typescript
type AgentDefinition = {
  description: string;        // When to use (used by main agent for delegation)
  prompt: string;             // System prompt
  tools?: string[];           // Allowed tools (inherits if omitted) — NOT enforced, see warning
  disallowedTools?: string[]; // Tools to block — NOT enforced, see warning
  model?: 'sonnet' | 'opus' | 'haiku' | 'inherit';
  mcpServers?: AgentMcpServerSpec[];  // Per-agent MCP servers
  skills?: string[];          // Skill names to preload
  maxTurns?: number;          // Max turns for this subagent
  criticalSystemReminder_EXPERIMENTAL?: string;  // Critical reminder added to system prompt
}
```

Include `Task` in parent's `allowedTools` — subagents are invoked via the Task tool.

```typescript
for await (const msg of query({
  prompt: "Use the reviewer to check this code",
  options: {
    allowedTools: ["Read", "Glob", "Grep", "Task"],
    agents: {
      "reviewer": {
        description: "Code review specialist",
        prompt: "Review code for bugs and best practices.",
        tools: ["Read", "Glob", "Grep"],
        model: "haiku",
        maxTurns: 10
      }
    }
  }
})) { ... }
```

### Tool Enforcement Warning

**`AgentDefinition.tools` and `disallowedTools` are NOT enforced at the API level** ([#172](https://github.com/anthropics/claude-agent-sdk-typescript/issues/172), [#163](https://github.com/anthropics/claude-agent-sdk-typescript/issues/163)). Subagents can call tools they shouldn't have access to, potentially causing infinite recursion.

Workaround — use `canUseTool` with session tracking:

```typescript
const activeSubagentSessions = new Map<string, string>();

const options = {
  hooks: {
    SubagentStart: [{ hooks: [async (input) => {
      activeSubagentSessions.set(input.session_id, input.agent_id);
      return {};
    }] }],
    SubagentStop: [{ hooks: [async (input) => {
      activeSubagentSessions.delete(input.session_id);
      return {};
    }] }]
  },
  canUseTool: async (toolName, input, { signal }) => {
    const sessionId = input.session_id;
    if (toolName === "Task" && activeSubagentSessions.has(sessionId)) {
      return { behavior: 'deny', message: 'Task tool blocked in subagents' };
    }
    return { behavior: 'allow', updatedInput: input };
  }
};
```

### Subagent Cleanup Warning

Subagents don't auto-stop when the parent stops ([#132](https://github.com/anthropics/claude-agent-sdk-typescript/issues/132), [#142](https://github.com/anthropics/claude-agent-sdk-typescript/issues/142)). This causes orphan processes and potential OOM.

Workaround — use a Stop hook:

```typescript
hooks: {
  Stop: [{ hooks: [async () => {
    console.log("Cleaning up subagents");
    // Track and terminate spawned processes
    return {};
  }] }]
}
```

---

## Structured Outputs

Define a JSON Schema and get validated data in `message.structured_output`.

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

const schema = z.object({
  summary: z.string(),
  sentiment: z.enum(['positive', 'neutral', 'negative']),
  confidence: z.number()
});

for await (const msg of query({
  prompt: "Analyze this feedback",
  options: {
    outputFormat: {
      type: "json_schema",
      schema: z.toJSONSchema(schema)  // Zod v3.24.1+ or v4+
    }
  }
})) {
  if (msg.type === 'result' && msg.subtype === 'success' && msg.structured_output) {
    const parsed = schema.safeParse(msg.structured_output);
    if (parsed.success) console.log(parsed.data);
  }
}
```

Error subtype `error_max_structured_output_retries` indicates validation failures after retries.

---

## Sandbox

```typescript
type SandboxSettings = {
  enabled?: boolean;
  autoAllowBashIfSandboxed?: boolean;
  excludedCommands?: string[];          // Always bypass sandbox
  allowUnsandboxedCommands?: boolean;   // Let model request unsandboxed execution
  network?: {
    allowLocalBinding?: boolean;
    allowUnixSockets?: string[];
    allowAllUnixSockets?: boolean;
    httpProxyPort?: number;
    socksProxyPort?: number;
    allowedDomains?: string[];          // Restrict network to specific domains
    allowManagedDomainsOnly?: boolean;  // Only allow managed domains
  };
  filesystem?: {
    allowWrite?: string[];               // Paths allowed for writing (glob patterns)
    denyWrite?: string[];                // Paths denied for writing (glob patterns)
    denyRead?: string[];                 // Paths denied for reading (glob patterns)
    allowRead?: string[];                // Re-allow reading within denyRead regions (takes precedence over denyRead)
    allowManagedReadPathsOnly?: boolean; // (managed settings) restrict reads to managed allowRead paths only
  };
  ignoreViolations?: Record<string, string[]>;  // Generic violation categories
  enableWeakerNestedSandbox?: boolean;
  enableWeakerNetworkIsolation?: boolean;
  ripgrep?: { command: string; args?: string[] };  // Custom ripgrep binary
};
```

`excludedCommands` = static allowlist (model has no control).
`allowUnsandboxedCommands` = model can set `dangerouslyDisableSandbox: true` in Bash input, which falls back to `canUseTool` for approval.

---

## Sessions

```typescript
// Capture session ID
let sessionId: string;
for await (const msg of query({ prompt: "Read auth module" })) {
  if (msg.type === 'system' && msg.subtype === 'init') sessionId = msg.session_id;
}

// Resume
for await (const msg of query({
  prompt: "Now find callers",
  options: { resume: sessionId }
})) { ... }

// Fork (creates new branch, original unchanged)
for await (const msg of query({
  prompt: "Try GraphQL instead",
  options: { resume: sessionId, forkSession: true }
})) { ... }

// Disable persistence (ephemeral sessions)
for await (const msg of query({
  prompt: "Quick analysis",
  options: { persistSession: false }
})) { ... }
```

**Session tips:**
- Use `maxTurns` as a safety net — sessions never timeout on their own
- Use `maxBudgetUsd` to limit costs per session
- Fork proactively before context gets too large ([Known Issue #2](#2-context-length-exceeded-session-breaking))
- `persistSession: false` disables writing session state to disk

---

## V2 Session API (Preview)

The V2 API simplifies multi-turn conversations by removing async generators. **Unstable** — APIs may change.

```typescript
import {
  unstable_v2_createSession,
  unstable_v2_resumeSession,
  unstable_v2_prompt
} from "@anthropic-ai/claude-agent-sdk";
```

### Create Session

```typescript
// Using 'await using' for automatic cleanup (TC39 Explicit Resource Management)
// Note: V2 does NOT support 'bypassPermissions' — use query() instead (see Known Issue #21)
await using session = unstable_v2_createSession({
  model: 'claude-sonnet-4-5-20250929',
  permissionMode: 'acceptEdits',
});

// Send a message
await session.send("Analyze this codebase");

// Stream responses
for await (const msg of session.stream()) {
  if (msg.type === 'result') console.log(msg.result);
}

// Multi-turn: send another message on the same session
await session.send("Now refactor the auth module");
for await (const msg of session.stream()) { ... }

// Session ID available for later resumption
console.log(session.sessionId);
```

### Resume Session

```typescript
await using session = unstable_v2_resumeSession(savedSessionId, {
  model: 'claude-sonnet-4-5-20250929'
});
await session.send("Continue where we left off");
for await (const msg of session.stream()) { ... }
```

### One-Shot Convenience

```typescript
const result = await unstable_v2_prompt("Explain this error", {
  model: 'claude-haiku-4-5-20251001'
});
console.log(result.result);
```

### SDKSession Interface

```typescript
interface SDKSession {
  readonly sessionId: string;
  send(message: string | SDKUserMessage): Promise<void>;
  stream(): AsyncGenerator<SDKMessage, void>;
  close(): void;
  [Symbol.asyncDispose](): Promise<void>;  // supports 'await using'
}
```

### V2 Limitations

`SDKSessionOptions` is a subset of `Options`. The V2 API **supports**: `permissionMode` (all modes except `bypassPermissions`), `allowedTools`, `disallowedTools`, `canUseTool`, `hooks`, `executable`, `env`.

The V2 API does **NOT** support:
- `bypassPermissions` mode — `allowDangerouslySkipPermissions` not in `SDKSessionOptions`
- `cwd` ([#176](https://github.com/anthropics/claude-agent-sdk-typescript/issues/176))
- `settingSources` ([#176](https://github.com/anthropics/claude-agent-sdk-typescript/issues/176))
- `plugins` ([#171](https://github.com/anthropics/claude-agent-sdk-typescript/issues/171))
- `systemPrompt` ([#160](https://github.com/anthropics/claude-agent-sdk-typescript/issues/160))
- `mcpServers` ([#154](https://github.com/anthropics/claude-agent-sdk-typescript/issues/154))
- `agents`, `outputFormat`, `sandbox`
- File checkpointing ([#133](https://github.com/anthropics/claude-agent-sdk-typescript/issues/133))

Use the standard `query()` API if you need these features.

---

## Debugging & Error Handling

### Debug Options

```typescript
// Enable debug logging
const q = query({
  prompt: "...",
  options: {
    debug: true,                    // Logs to stderr
    debugFile: '/tmp/agent.log'     // Also logs to file
  }
});
```

**Warning**: Do NOT use `ANTHROPIC_LOG=debug` — it corrupts the SDK JSON protocol ([Known Issue #15](#15-anthropic_logdebug-corrupts-sdk-protocol)). Use `debug: true` instead.

### Diagnostic Checklist for "process exited with code 1"

This opaque error ([#106](https://github.com/anthropics/claude-agent-sdk-typescript/issues/106)) has many causes:

1. **Missing `type` field on URL-based MCP config** — add `type: "http"` or `type: "sse"`
2. **Invalid model ID** — verify model string (e.g., `claude-sonnet-4-5-20250929`, not `claude-3.5-sonnet`)
3. **CLI not installed** — run `npm install -g @anthropic-ai/claude-code`
4. **`ANTHROPIC_LOG=debug` set** — unset it, use `debug: true` instead
5. **Bundled with esbuild/bun** — set `pathToClaudeCodeExecutable` explicitly
6. **`OTEL_*_EXPORTER=none`** — remove or change OpenTelemetry env vars ([#136](https://github.com/anthropics/claude-agent-sdk-typescript/issues/136))
7. **Enable debug mode** — add `debug: true` to see actual error

### Error Result Types

```typescript
// Check result subtypes for specific failures
switch (message.subtype) {
  case 'success':               // Normal completion
  case 'error_max_turns':       // Hit maxTurns limit
  case 'error_max_budget_usd':  // Hit maxBudgetUsd limit
  case 'error_during_execution': // Runtime error
  case 'error_max_structured_output_retries': // Schema validation failed
}
```

### Cost Monitoring

```typescript
for await (const msg of query({ prompt: "...", options: { maxBudgetUsd: 5.00 } })) {
  if (msg.type === 'result' && msg.subtype === 'success') {
    console.log(`Cost: $${msg.total_cost_usd}`);
    console.log(`Turns: ${msg.num_turns}`);
    // Per-model token usage (ModelUsage fields are camelCase)
    for (const [model, usage] of Object.entries(msg.modelUsage ?? {})) {
      console.log(`  ${model}: ${usage.inputTokens}in / ${usage.outputTokens}out ($${usage.costUSD})`);
    }
  }
}
```

---

## Known Issues

### #1: CLI Not Found
**Error**: `CLI_NOT_FOUND`
**Fix**: `npm install -g @anthropic-ai/claude-code`

### #2: Context Length Exceeded (Session-Breaking)
**Error**: "Prompt is too long" ([#138](https://github.com/anthropics/claude-agent-sdk-typescript/issues/138))
**Behavior**: Session permanently broken — cannot recover or compact.
**Prevention**: Monitor session age, fork proactively, use `maxTurns` / `maxBudgetUsd`.

### #3: MCP Config Missing `type` Field
**Error**: Cryptic "process exited with code 1" ([#131](https://github.com/anthropics/claude-agent-sdk-typescript/issues/131))
**Fix**: URL-based MCP servers require `type: "http"` or `type: "sse"`.

### #4: Orphan Subagents
Subagents don't stop when parent stops ([#132](https://github.com/anthropics/claude-agent-sdk-typescript/issues/132), [#142](https://github.com/anthropics/claude-agent-sdk-typescript/issues/142)).
**Fix**: Implement Stop hook cleanup (see Subagents section).

### #5: Unicode Line Separators Break JSON
U+2028/U+2029 in MCP tool results break parsing ([#137](https://github.com/anthropics/claude-agent-sdk-typescript/issues/137), [MCP Python SDK #1356](https://github.com/modelcontextprotocol/python-sdk/issues/1356)).
**Fix**: Sanitize: `content.replace(/[\u2028\u2029]/g, ' ')`

### #6: ANTHROPIC_BASE_URL via env option broken in v0.2.8+
**Error**: `error_during_execution` with 0 tokens when using custom base URL ([#144](https://github.com/anthropics/claude-agent-sdk-typescript/issues/144))
**Fix**: Downgrade to v0.2.7 or set `ANTHROPIC_BASE_URL` as environment variable before process start instead of via `options.env`.
**Additional bug**: If `ANTHROPIC_BASE_URL` contains query parameters (e.g., `https://proxy.example.com/api?token=abc`), the SDK mangles the URL by URL-encoding the API path into the query value instead of appending it to the path ([#195](https://github.com/anthropics/claude-agent-sdk-typescript/issues/195)). Use a base URL without query parameters; put auth tokens in a header via a proxy instead.

### #7: SDK MCP servers fail from concurrent query() calls
**Error**: Second+ concurrent queries timeout after 60s with "MCP error -32001: Request timed out" ([#122](https://github.com/anthropics/claude-agent-sdk-typescript/issues/122))
**Fix**: Use stdio MCP servers instead of `createSdkMcpServer()` for concurrent queries.

### #8: Missing @anthropic-ai/sdk dependency causes type loss
**Error**: TypeScript types resolve as `any` for SDK messages/events ([#121](https://github.com/anthropics/claude-agent-sdk-typescript/issues/121))
**Fix**: `npm install @anthropic-ai/sdk` as peer dependency.
**pnpm note**: pnpm's strict resolution doesn't auto-install undeclared peer deps ([#179](https://github.com/anthropics/claude-agent-sdk-typescript/issues/179)). Add to `package.json`:
```json
"pnpm": {
  "packageExtensions": {
    "@anthropic-ai/claude-agent-sdk": {
      "dependencies": { "@anthropic-ai/sdk": "*" }
    }
  }
}
```

### #9: Ripgrep binary lacks execute permission on VS Code Remote SSH
**Error**: Commands/agents from `.claude/commands/` and `.claude/agents/` silently not discovered on Linux remote ([#129](https://github.com/anthropics/claude-agent-sdk-typescript/issues/129))
**Fix**: VS Code extensions should `chmod +x` ripgrep binaries at activation:
```typescript
const rgPath = path.join(extensionPath, "node_modules/@anthropic-ai/claude-agent-sdk/vendor/ripgrep/x64-linux/rg");
await fs.promises.chmod(rgPath, 0o755);
```

### #10: MCP tool calls timeout at 5 minutes despite MCP_TOOL_TIMEOUT
**Error**: MCP tools timeout at exactly 300s with "fetch failed" even with `MCP_TOOL_TIMEOUT=1200000` ([#118](https://github.com/anthropics/claude-agent-sdk-typescript/issues/118))
**Cause**: Hardcoded undici `headersTimeout` overrides environment variable.
**Status**: No workaround available — long-running MCP tools (>5min) not currently supported.

### #11: Opaque "process exited with code 1" errors
**Error**: Cryptic crash without detail when input is too long, session expired, or other failures ([#106](https://github.com/anthropics/claude-agent-sdk-typescript/issues/106))
**Impact**: Difficult to debug production issues — all errors look identical.
**Workaround**: Enable `debug: true` or `debugFile: 'debug.log'` option to capture detailed logs. See [Debugging section](#debugging--error-handling).

### #12: permissionDecision: 'deny' causes missing tool_result, API 400 error
**Error**: `invalid_request_error` - "tool_use ids were found without tool_result blocks" ([#170](https://github.com/anthropics/claude-agent-sdk-typescript/issues/170))
**Cause**: PreToolUse hook with `permissionDecision: 'deny'` blocks tool execution but doesn't generate a corresponding `tool_result`, breaking conversation history.
**Fix**: Use `permissionDecision: 'allow'` with modified input instead:
```typescript
return {
  hookSpecificOutput: {
    hookEventName: 'PreToolUse',
    permissionDecision: 'allow',
    updatedInput: { command: `echo "BLOCKED: ${reason}"` }
  }
};
```

### #13: thinking: { type: 'adaptive' } silently disables thinking ✅ Fixed in v0.2.40
**Error**: Zero thinking blocks despite `thinking: { type: 'adaptive' }` configured ([#168](https://github.com/anthropics/claude-agent-sdk-typescript/issues/168))
**Cause**: SDK was setting `maxThinkingTokens = undefined` for adaptive mode, preventing `--max-thinking-tokens` CLI flag from being passed.
**Status**: Fixed in v0.2.40. `thinking: { type: 'adaptive' }` and `effort` options now work correctly.

### #14: HTTP MCP servers fail behind corporate proxies
**Error**: "The socket connection was closed unexpectedly" when HTTP MCP servers used behind corporate proxy with SSL inspection ([#169](https://github.com/anthropics/claude-agent-sdk-typescript/issues/169))
**Cause**: Bundled MCP transport doesn't propagate proxy configuration from environment variables (HTTP_PROXY, HTTPS_PROXY, NODE_EXTRA_CA_CERTS).
**Workaround**: Use SSE-type MCP servers or stdio MCP servers instead of HTTP type.

### #15: ANTHROPIC_LOG=debug corrupts SDK protocol
**Error**: `CLI output was not valid JSON` when `ANTHROPIC_LOG=debug` is set ([#157](https://github.com/anthropics/claude-agent-sdk-typescript/issues/157))
**Cause**: Debug logs written to stdout corrupt JSON protocol between SDK and CLI subprocess.
**Fix**: Don't use `ANTHROPIC_LOG=debug` with SDK. Use `debug: true` or `debugFile` option instead.

### #16: MCP server responses don't reset activity timer
**Error**: "Stream closed" errors or excessive query durations with SDK MCP servers ([#114](https://github.com/anthropics/claude-agent-sdk-typescript/issues/114))
**Cause**: `sendMcpServerMessageToCli()` resolves MCP responses but doesn't reset `lastActivityTime`, causing premature timeouts or unnecessary waits.
**Fix**: Increase `CLAUDE_CODE_STREAM_CLOSE_TIMEOUT` (e.g., 120000 for 120s) or apply [community patch](https://github.com/anthropics/claude-agent-sdk-typescript/issues/114#issuecomment-2693849829).

### #17: SDK fails to discover CLI when bundled with bun build
**Error**: `Claude Code executable not found at /$bunfs/root/cli.js` ([#150](https://github.com/anthropics/claude-agent-sdk-typescript/issues/150))
**Cause**: `import.meta.url` resolves to virtual filesystem path when bundled, where CLI binary doesn't physically exist.
**Workaround**: Set `pathToClaudeCodeExecutable` option explicitly to the physical CLI path, or avoid bundling the SDK.

### #18: unstable_v2_createSession() doesn't support plugins option
**Error**: Plugins silently ignored when using v2 session API ([#171](https://github.com/anthropics/claude-agent-sdk-typescript/issues/171))
**Cause**: `SDKSessionOptions` type doesn't include `plugins` field, so `--plugin-dir` CLI argument is never passed to Claude Code process.
**Workaround**: Use `query()` API instead of v2 sessions if you need plugin support. Plugins work correctly with the standard `query()` API.

### #19: AgentDefinition.tools and disallowedTools not enforced for subagents
**Error**: Subagents can call tools they shouldn't have access to, leading to infinite recursion ([#172](https://github.com/anthropics/claude-agent-sdk-typescript/issues/172), [#163](https://github.com/anthropics/claude-agent-sdk-typescript/issues/163))
**Cause**: CLI doesn't map `AgentDefinition.tools` to `--allowedTools` / `--disallowedTools` flags when spawning subagent child processes.
**Additional bug**: The `Task` tool is force-allowed for subagents even when `disallowedTools: ['Task']` is set ([#189](https://github.com/anthropics/claude-agent-sdk-typescript/issues/189)). The CLI unconditionally returns `true` for the Task tool in subagent contexts before evaluating `disallowedTools`, enabling subagents to recursively spawn other subagents.
**Workaround**: Use `canUseTool` callback to block disallowed tools (see [Subagents section](#tool-enforcement-warning)).

### #20: Structured output with Zod requires draft-07 target
**Error**: `structured_output` is `undefined` despite setting `outputFormat` with Zod schema ([#105](https://github.com/anthropics/claude-agent-sdk-typescript/issues/105))
**Cause**: Zod's `toJSONSchema()` generates draft-2020-12 by default, but Claude requires JSON Schema draft-07.
**Fix**: Specify `target: "draft-07"` when calling `toJSONSchema()`:
```typescript
const schema = z.toJSONSchema(MySchema, { target: "draft-07" });
// Or manually remove $schema field:
const schema = z.toJSONSchema(MySchema);
delete schema.$schema;
```

### #21: unstable_v2_createSession() has limited option support
**Error**: V2 session API silently ignores `cwd` and `settingSources`; `bypassPermissions` mode not supported ([#176](https://github.com/anthropics/claude-agent-sdk-typescript/issues/176))
**Status**: Partially resolved — `SDKSessionOptions` now includes `permissionMode`, `allowedTools`, `disallowedTools`, `canUseTool`, and `hooks`, so these options work. However `cwd`, `settingSources`, and `allowDangerouslySkipPermissions` remain absent from `SDKSessionOptions`.
**Impact**: V2 sessions cannot use `bypassPermissions` mode (requires `allowDangerouslySkipPermissions` which isn't exposed), custom working directories, or CLAUDE.md loading.
**Workaround**: Use `query()` API if you need `bypassPermissions`, `cwd`, or `settingSources`. For other permission control, the V2 API's built-in `permissionMode`, `allowedTools`, `canUseTool`, and `hooks` options now work.

### #22: Large MCP tool output forces filesystem tool dependency
**Error**: When MCP tools return ≥180KB output, SDK truncates response and saves full output to local file, then agent attempts to read file using `Bash`/filesystem tools ([#175](https://github.com/anthropics/claude-agent-sdk-typescript/issues/175), [#187](https://github.com/anthropics/claude-agent-sdk-typescript/issues/187))
**Impact**: Breaks security-hardened deployments where filesystem tools are intentionally disabled. No configuration to prevent this behavior.
**Current behavior**: Output message shows: `Output too large (182.9KB). Full output saved to: ~/.claude/projects/.../tool-results/<id>.json`
**Note**: Affects both `content` array and `structuredContent` responses; `structuredContent` produces single-line JSON that is harder for the model to navigate.
**Status**: No workaround available. Feature request for configuration option to disable file persistence or handle large outputs without filesystem tools.

### #23: Query.promptSuggestion() announced but missing from published package
**Error**: `q.promptSuggestion is not a function` ([#185](https://github.com/anthropics/claude-agent-sdk-typescript/issues/185))
**Cause**: The release notes describe a new `Query.promptSuggestion()` method to request prompt suggestions based on conversation context, but the published npm package's `sdk.d.ts` does not expose this method.
**Workaround**: Method is not available in the current package. Monitor future releases for the fix.

### #24: SDKRateLimitEvent and SDKPromptSuggestionMessage undefined cause SDKMessage to resolve to `any` ✅ Fixed in v0.2.63
**Error**: TypeScript reports no type errors on `SDKMessage` values; full type safety is lost ([#181](https://github.com/anthropics/claude-agent-sdk-typescript/issues/181), [#184](https://github.com/anthropics/claude-agent-sdk-typescript/issues/184), [#196](https://github.com/anthropics/claude-agent-sdk-typescript/issues/196), [#206](https://github.com/anthropics/claude-agent-sdk-typescript/issues/206))
**Cause**: Both `SDKRateLimitEvent` and `SDKPromptSuggestionMessage` were referenced in the `SDKMessage` union type in `sdk.d.ts` but were never declared or exported anywhere in the file. A union containing an undefined type resolves to `any` in TypeScript.
**Status**: Fixed in v0.2.63. Both `SDKRateLimitEvent` and `SDKPromptSuggestionMessage` are now exported in `sdk.d.ts`. Upgrade to v0.2.63+ to restore full type safety.

### #25: unstable_v2 close() breaks session persistence ✅ Fixed in v0.2.51
**Error**: Resuming a v2 session after `close()` starts a fresh session with no conversation context ([#177](https://github.com/anthropics/claude-agent-sdk-typescript/issues/177))
**Cause**: `session.close()` sent `SIGTERM` to the subprocess immediately, before it could flush session data to disk.
**Status**: Fixed in v0.2.51. Upgrade to v0.2.51+ to resolve. If still on an older version, use the v1 `query()` API as a workaround.

### #26: Slash command output lost since v0.2.45 ✅ Fixed
**Error**: `/context`, `/clear`, and other slash commands no longer emit output in the message stream since v0.2.45 ([#186](https://github.com/anthropics/claude-agent-sdk-typescript/issues/186))
**Behavior**: Previous behavior (v0.2.5): `system init → user (has output) → result success`. Current behavior (v0.2.45+): `rate_limit_event → system init → result success` (no output). Additionally, `/clear` is missing from `SDKSystemMessage.slash_commands` and returns `"Unknown skill: clear"`.
**Status**: Fixed (issue closed as completed 2026-02-26, fix merged to main). Upgrade to v0.2.63 or later if the issue persists.

### #27: Cloud MCP servers auto-discovered from claude.ai account with no way to disable
**Error**: SDK automatically connects to MCP servers from the user's Anthropic cloud account (Figma, Canva, Bright Data, etc.) in every session, with no option to disable ([#190](https://github.com/anthropics/claude-agent-sdk-typescript/issues/190))
**Cause**: A dead environment variable guard in `cli.js` (`if (rY(void 0))`) always evaluates to `false` because the env var name is compiled as `undefined` in the minified bundle. The guard never fires, so cloud MCP discovery cannot be suppressed.
**Impact**: Headless/automated pipelines see unwanted failed/auth-needed connections on every session. No SDK option or working env var to disable.
**Workaround**: No clean workaround. Some users patch the minified `sdk.mjs` in a `postinstall` script (fragile, breaks on updates). Setting `settingSources: []` does not affect cloud MCP discovery.

### #28: Model shorthands ('opus', 'sonnet', 'haiku') silently upgrade to latest model versions
**Error**: The `model` shorthands in `AgentDefinition.model` and `options.model` resolve to the current latest model, which can change across SDK releases without notice ([#182](https://github.com/anthropics/claude-agent-sdk-typescript/issues/182))
**Example**: In SDK v0.2.44, `model: 'opus'` silently upgraded from `claude-opus-4-5-20251101` to `claude-opus-4-6`. Opus 4.6 removes assistant prefilling support and uses adaptive thinking, breaking pipelines that relied on Opus 4.5 behavior.
**Impact**: Production pipelines using model shorthands may change behavior silently on SDK upgrade with no deprecation warning or changelog callout.
**Fix**: Pin to full model IDs (e.g., `'claude-opus-4-5-20251101'`) in `AgentDefinition.model` when specific model behavior is required. Use shorthands only when "latest" is acceptable.

### #29: HookCallbackMatcher timeout cannot be disabled — interactive hooks always time out at 60s
**Error**: Interactive hooks (e.g., `AskUserQuestion`, `ExitPlanMode`) time out after 60 seconds with no way to opt out ([#194](https://github.com/anthropics/claude-agent-sdk-typescript/issues/194))
**Cause**: The hook executor uses a truthy check (`timeout ? timeout * 1000 : default`), so `null`, `undefined`, and `0` all silently fall back to the 60-second default. The TypeScript type is `timeout?: number` with no `null` support.
**Workaround**: Set `timeout` to a very large value (e.g., `86400` for 24 hours) for hooks that need to wait for human input:
```typescript
hooks: {
  PreToolUse: [{ hooks: [interactiveApprovalHook], timeout: 86400 }]
}
```

### #30: pathToClaudeCodeExecutable rejects bare command names — must be an absolute path
**Error**: `Claude Code native binary not found at claude. Please ensure Claude Code is installed via native installer or specify a valid path with options.pathToClaudeCodeExecutable.` ([#205](https://github.com/anthropics/claude-agent-sdk-typescript/issues/205))
**Cause**: The SDK validates the binary path with `fs.existsSync(path)` before spawning. `existsSync` treats bare names as relative paths (checked against CWD), so `"claude"` fails even when `claude` is on `PATH`.
**Impact**: Affects integrations like the Zed editor that set `CLAUDE_CODE_EXECUTABLE=claude` portably.
**Fix**: Use the absolute path to the Claude Code binary:
```typescript
import { execFileSync } from 'child_process';
const claudePath = execFileSync('which', ['claude'], { encoding: 'utf8' }).trim();
const session = new ClaudeCodeSession({ pathToClaudeCodeExecutable: claudePath });
```

### #31: "write after end" race condition in single-turn queries with MCP tool calls
**Error**: `Error: write after end` / `Error: ProcessTransport is not ready for writing` in production ([#148](https://github.com/anthropics/claude-agent-sdk-typescript/issues/148))
**Cause**: For single-turn (string prompt) queries, the SDK calls `transport.endInput()` on the first `result` message. If async `handleControlRequest()` calls arrive after stdin is ended (e.g., MCP responses), they attempt to write to the ended stream. `handleControlRequest` is not awaited so there is no backpressure.
**Impact**: Production applications with MCP tools and single-turn queries see sporadic crashes (~77 Sentry errors per two weeks in one report).
**Workaround**: Catch these specific errors at the application level and treat them as non-fatal:
```typescript
process.on('uncaughtException', (err) => {
  if (err.message === 'write after end' || err.message === 'ProcessTransport is not ready for writing') {
    return; // non-fatal, query already completed
  }
  throw err;
});
```
Or use `AbortController` with the `abortController` option to cancel cleanly before stream end.

### #32: AsyncIterable prompt causes double AI turn per message, doubling token costs
**Symptom**: When using `query()` with an `AsyncIterable<SDKUserMessage>` prompt, the CLI executes two full AI thinking + response cycles for each message, roughly doubling token usage ([#207](https://github.com/anthropics/claude-agent-sdk-typescript/issues/207))
**Cause**: For `AsyncIterable` prompts, `isSingleUserTurn` is `false`, so `transport.endInput()` is never called after a result. The CLI sees stdin still open and runs a second agentic turn. The same issue affects `unstable_v2_createSession()` (which hardcodes `isSingleUserTurn = false`).
**Impact**: Tested on SDK versions v0.1.28 through v0.2.63 — same behaviour on all.
**Workaround**: Use a fresh one-shot query per message with the `resume` option to preserve conversation history:
```typescript
// Instead of a persistent AsyncIterable, spawn a new query() per message:
let sessionId: string | undefined;
for (const userMessage of messages) {
  const q = query({
    prompt: userMessage,           // string prompt, not AsyncIterable
    options: { resume: sessionId } // preserves history on 2nd+ message
  });
  for await (const msg of q) {
    if (msg.type === 'system' && msg.subtype === 'init') sessionId = msg.session_id;
    // handle messages...
  }
}
```
**Trade-off**: 3–12 second cold start per message (CLI process spawn + session load).

### #33: `env` option completely replaces subprocess environment — PATH required
**Error**: `Error: Failed to spawn Claude Code process: spawn node ENOENT` when `env` is provided without including `PATH` ([#208](https://github.com/anthropics/claude-agent-sdk-typescript/issues/208))
**Cause**: The SDK's `env` option replaces the subprocess environment entirely (it does not merge with `process.env`). If `PATH` is omitted, the subprocess cannot find the `node` executable.
**Fix**: Always spread `process.env` when building a custom env:
```typescript
const q = query({
  prompt: 'hello',
  options: {
    env: {
      ...process.env,                 // inherit PATH and all other vars
      ANTHROPIC_API_KEY: 'sk-...',
      ANTHROPIC_BASE_URL: 'https://example.com'
    }
  }
});
```

### #34: SDK v0.2.68+ silently injects `effort: "medium"` for all effort-capable models
**Error**: Multi-turn agentic workflows complete in a single turn with no tool use; AWS Bedrock users see `"output_config.effort: Extra inputs are not permitted"` for non-effort-capable models ([#214](https://github.com/anthropics/claude-agent-sdk-typescript/issues/214))
**Cause**: SDK v0.2.68 introduced a feature flag (`tengu_turtle_carbon`) that injects `output_config: { effort: "medium" }` into all requests for effort-capable models (Sonnet 4.6, Opus 4.6), even when no effort level is specified. A separate bug causes Bedrock ARN-format model IDs (e.g., `arn:aws:bedrock:us-east-1::foundation-model/...`) to incorrectly pass the effort-capable check, injecting an unsupported parameter.
**Impact**: Models given forced `medium` effort often skip tool use and return minimal single-turn responses. On Bedrock, Haiku 4.5 and Sonnet 4.5 inference profiles receive hard API validation errors on every call.
**Fix**: Explicitly set `effort: 'high'` to override the injected default:
```typescript
const q = query({ prompt, options: { effort: 'high' } });
```
Or set the environment variable before spawning: `CLAUDE_CODE_EFFORT_LEVEL=high`.
**Bedrock workaround**: Downgrade to v0.2.66 until the `supportsEffort` check correctly handles ARN-format model IDs.

### #35: `sdk-tools.d.ts` subpath unresolvable since v0.2.69 — missing from package exports map ✅ Fixed in v0.2.77
**Error**: TypeScript cannot resolve `"@anthropic-ai/claude-agent-sdk/sdk-tools"` in projects using `moduleResolution: bundler`, `node16`, or `nodenext` ([#218](https://github.com/anthropics/claude-agent-sdk-typescript/issues/218))
**Cause**: SDK v0.2.69 added a package.json `exports` field but omitted `"./sdk-tools"`. In strict ESM environments the exports map is authoritative, so the physical `sdk-tools.d.ts` file (which contains input schemas for all built-in tools: `BashInput`, `GlobInput`, `GrepInput`, etc.) is inaccessible via the subpath import.
**Status**: Fixed in v0.2.77 — the `./sdk-tools` entry has been added to `package.json`'s exports map ([#222](https://github.com/anthropics/claude-agent-sdk-typescript/issues/222)). Upgrade to v0.2.77+ to resolve.
**Workaround** (for older versions): Switch to `moduleResolution: node10` (legacy), which ignores the exports map and resolves directly from the file system. Alternatively, reference the types via a relative import from `node_modules` (non-portable):
```typescript
// Instead of (broken in bundler/node16/nodenext moduleResolution):
import type { GlobInput } from "@anthropic-ai/claude-agent-sdk/sdk-tools";

// Use legacy module resolution in tsconfig.json:
// "moduleResolution": "node10"
// Then the subpath import works again.
```
**Note**: This subpath is only needed when implementing custom MCP tool validators or SDK MCP servers that inspect built-in tool input schemas.

### #36: `env` in `~/.claude/settings.json` takes precedence over `options.env` — API keys not overridable
**Symptom**: Environment variables passed via `options.env` are silently ignored if the same variable is set in the `env` field of `~/.claude/settings.json`. The settings.json value wins regardless of `settingSources` configuration ([#217](https://github.com/anthropics/claude-agent-sdk-typescript/issues/217))
**Cause**: The SDK passes `options.env` as OS-level environment variables to the spawned CLI subprocess. However, the CLI's config system loads `settings.json` on startup and its `env` block takes precedence over OS environment variables. Because `options.env` was already downgraded to OS env by the time the CLI reads it, `settings.json` wins.
**Impact**: Developers who have an `ANTHROPIC_API_KEY` in `~/.claude/settings.json` cannot override it programmatically — a critical problem for multi-tenant apps, API key rotation, or using a different `ANTHROPIC_BASE_URL` for SDK apps vs interactive CLI.
**Workaround**: Remove the `env` field from `~/.claude/settings.json`, or set `settingSources: []` **and** clear the env block first. There is no pure programmatic workaround.
```typescript
// ⚠️ This does NOT work if ~/.claude/settings.json has an `env.ANTHROPIC_API_KEY`
const q = query({
  prompt: 'hello',
  options: {
    settingSources: [],          // Does not strip settings.json env block
    env: {
      ...process.env,
      ANTHROPIC_API_KEY: 'sk-your-key',  // Silently ignored
    }
  }
});

// Fix: remove the env block from ~/.claude/settings.json manually,
// or wait for the SDK fix to be released.
```
**Note**: A fix has been merged by Anthropic — check if your SDK version includes it.

### #37: Fast mode silently unavailable in Node.js — requires native Bun binary
**Error**: No error thrown — fast mode silently falls back to standard mode ([#216](https://github.com/anthropics/claude-agent-sdk-typescript/issues/216))
**Cause**: The SDK checks for the native streaming binary using `typeof Bun !== "undefined"`, which always returns `false` in Node.js. The server-side feature flag then rejects fast mode and silently falls back to standard Opus 4.6. Fast mode requires the native Bun-compiled CLI distribution that ships alongside Claude Code.
**Impact**: Affects claude.ai Pro subscribers who have fast mode available — `settings.fastMode` is silently ignored in Node.js environments despite TypeScript types suggesting it is available.
**Workaround**: Run your application with the Bun runtime (`bun run app.ts`), which enables the native binary required for fast mode. There is no workaround for Node.js-only environments.

### #38: MCP server processes remain as zombies after session ends
**Error**: `node.exe` / `python.exe` processes accumulate after multiple sessions ([#219](https://github.com/anthropics/claude-agent-sdk-typescript/issues/219))
**Cause**: The SDK does not guarantee cleanup of spawned MCP server child processes when sessions end — including timeouts, errors, and `close()` calls. No session-scoped process grouping is applied.
**Impact**: After 5–10 sessions, dozens of orphaned processes accumulate, consuming memory and causing port conflicts.
**Partial workaround**: Use externally-managed MCP servers (e.g., `stdio` servers you start and stop yourself) rather than relying on the SDK to spawn them. For SDK-managed servers, you can snapshot PIDs before and after a session and kill the difference — but this approach fails for concurrent sessions since processes from different sessions cannot be distinguished.
**Note**: Using `stdio` MCP servers launched and managed outside the SDK lifecycle avoids this issue entirely.

### #39: Sandbox cannot be locked down to the project directory — default allows full filesystem read access
**Error**: No error thrown — sandbox with `filesystem.denyRead` cannot be used to restrict reads to just the working directory ([#231](https://github.com/anthropics/claude-agent-sdk-typescript/issues/231))
**Cause**: There is no option to restrict reads to a specific subtree. `filesystem.denyRead: ['/']` (or `['//']`) also blocks the project directory itself because `allowWrite` rules cannot override a parent `denyRead`. The sandbox has no concept of "allow only CWD reads."
**Impact**: Multi-user or security-hardened deployments cannot use the sandbox to isolate file access to the working directory alone. The sandbox currently protects writes but not reads.
**Workaround**: Explicitly enumerate every top-level directory to deny (e.g., `/bin`, `/etc`, `/usr`, `/var`, `/home/other_user`, etc.), leaving only the path chain to your project directory visible. This is fragile — newly-created directories are not covered.
```typescript
sandbox: {
  enabled: true,
  filesystem: {
    // Deny-list everything except the path to your project:
    denyRead: ['/bin', '/boot', '/etc', '/lib', '/media', '/opt', '/proc', '/root', '/run', '/srv', '/sys', '/tmp', '/usr', '/var']
    // Note: /home and other user directories must also be added manually
  }
}
```
**Note**: There is no configuration option to invert this to "allow only CWD." A feature request for a `allowReadCwdOnly` or similar option is tracked in [#231](https://github.com/anthropics/claude-agent-sdk-typescript/issues/231).

### #40: `enableFileCheckpointing` has no effect in SDK (non-interactive) mode — `rewindFiles()` always returns `canRewind: false`
**Error**: `rewindFiles()` always returns `{ canRewind: false, error: "No file checkpoint found for this message." }` even with `enableFileCheckpointing: true` ([#236](https://github.com/anthropics/claude-agent-sdk-typescript/issues/236))
**Cause**: The snapshot creation function that tags file state to each user message UUID is only invoked from React/Ink interactive UI render code. In non-interactive SDK mode (`isInteractive = false`), those call sites are never reached. Without an initial snapshot, the file-tracking code silently bails (`FileHistory: Missing most recent snapshot`), so no file state is ever recorded.
**Impact**: The `enableFileCheckpointing` option and `Query.rewindFiles()` method are entirely non-functional when using the SDK programmatically. The option has no effect.
**Status**: No workaround available. This is a CLI-side bug; the SDK cannot compensate.

### #41: `bypassPermissions` mode not propagated to subagents — `allowDangerouslySkipPermissions` hardcoded to false
**Error**: Subagents spawned via the Task tool cannot use `bypassPermissions` mode even when the parent session has it enabled ([#117](https://github.com/anthropics/claude-agent-sdk-typescript/issues/117))
**Cause**: The SDK hardcodes `allowDangerouslySkipPermissions: false` when spawning subagent child processes, regardless of the parent session's configuration. Since `bypassPermissions` requires `allowDangerouslySkipPermissions: true` to function, subagents effectively cannot bypass permissions.
**Impact**: Automated pipelines that use `permissionMode: 'bypassPermissions'` with `allowDangerouslySkipPermissions: true` will have subagents block or prompt on permission checks, hanging in headless environments.
**Workaround**: Use `permissionMode: 'acceptEdits'` instead of `'bypassPermissions'` for workflows requiring subagents. `acceptEdits` automatically approves file edits without the safety flag requirement. For completely unrestricted tool use, set explicit permissions via `allowedTools` and a `canUseTool` callback that always allows.

---

## Changelog Highlights (v0.2.12 → v0.2.77)

| Version | Change |
|---------|--------|
| v0.2.77 | Added `SDKAPIRetryMessage` (`type: 'system', subtype: 'api_retry'`) — emitted when a transient API error is automatically retried; exposes attempt count, max retries, delay, and error status; fixed `SubagentStart`/`SubagentStop` hook `agent_type` always reporting `"general-purpose"` — now correctly reports the agent key from the `agents` map ([#226](https://github.com/anthropics/claude-agent-sdk-typescript/issues/226)); fixed missing `./sdk-tools` entry in `package.json` exports map ([#222](https://github.com/anthropics/claude-agent-sdk-typescript/issues/222)) |
| v0.2.71 | Fixed `Agent` tool returning `"Unknown tool: Agent"` in `query()` mode — subagent invocation via `tools: ['Agent']` + `agents` map now works ([#210](https://github.com/anthropics/claude-agent-sdk-typescript/issues/210)) |
| v0.2.63 | Fixed `SDKRateLimitEvent` and `SDKPromptSuggestionMessage` missing from `sdk.d.ts` — `SDKMessage` now has full type safety ([#196](https://github.com/anthropics/claude-agent-sdk-typescript/issues/196), [#206](https://github.com/anthropics/claude-agent-sdk-typescript/issues/206)) |
| v0.2.58 | Version bump |
| v0.2.57 | `getSessionMessages()` exported — reads transcript messages by session ID; `SessionMessage` type exported |
| v0.2.51 | Fixed `close()` breaking session persistence in v2 session API ([#177](https://github.com/anthropics/claude-agent-sdk-typescript/issues/177)) |
| v0.2.43 | Previous release (2026-02-14) |
| v0.2.33 | `TeammateIdle`/`TaskCompleted` hook events; custom `sessionId` option |
| v0.2.31 | `stop_reason` field on result messages |
| v0.2.30 | `debug`/`debugFile` options; PDF page reading |
| v0.2.27 | MCP tool `annotations` support |
| v0.2.23 | Structured output validation fix |
| v0.2.21 | `reconnectMcpServer()`, `toggleMcpServer()`, `disabled` MCP status |
| v0.2.15 | `close()` method on Query; notification hooks |

---

**Last verified**: 2026-03-18 | **SDK version**: 0.2.77
