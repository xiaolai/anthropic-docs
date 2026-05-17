import { query } from "@anthropic-ai/claude-agent-sdk";
import type { HookInput, HookJSONOutput } from "@anthropic-ai/claude-agent-sdk";

/**
 * Hooks Template
 *
 * Demonstrates:
 * - PreToolUse: block, modify input, inject context
 * - PostToolUse: log results, modify MCP output
 * - Stop: cleanup on agent completion
 * - Matcher patterns for targeting specific tools
 */

// Log every tool call with timing
async function auditLogger(
  input: HookInput,
  toolUseID: string | undefined,
  { signal }: { signal: AbortSignal }
): Promise<HookJSONOutput> {
  const toolName = input.tool_name;
  console.log(`[audit] ${toolName} called (id: ${toolUseID})`);
  return {};
}

// Block writes to protected paths
async function protectSensitiveFiles(
  input: HookInput,
  toolUseID: string | undefined,
  { signal }: { signal: AbortSignal }
): Promise<HookJSONOutput> {
  const filePath: string = input.tool_input?.file_path ?? "";
  const protectedPaths = [".env", "credentials", "secrets", "id_rsa"];

  if (protectedPaths.some((p) => filePath.includes(p))) {
    return {
      hookSpecificOutput: {
        hookEventName: input.hook_event_name,
        permissionDecision: "allow",
        // Redirect to a safe echo instead of denying (avoids Known Issue #12)
        updatedInput: { command: `echo "BLOCKED: write to ${filePath}"` },
      },
    };
  }
  return {};
}

// Add context before every Bash execution
async function bashGuardrails(
  input: HookInput,
  toolUseID: string | undefined,
  { signal }: { signal: AbortSignal }
): Promise<HookJSONOutput> {
  return {
    hookSpecificOutput: {
      hookEventName: input.hook_event_name,
      additionalContext: "IMPORTANT: Do not modify files outside the project directory. Always use relative paths.",
    },
  };
}

// Log tool results in PostToolUse
async function resultLogger(
  input: HookInput,
  toolUseID: string | undefined,
  { signal }: { signal: AbortSignal }
): Promise<HookJSONOutput> {
  const toolName = (input as { tool_name: string }).tool_name;
  const output = (input as { tool_response: unknown }).tool_response;
  console.log(`[post] ${toolName} completed (id: ${toolUseID}), output length: ${JSON.stringify(output).length}`);
  return {};
}

// Cleanup on agent stop
async function onStop(
  input: HookInput,
  toolUseID: string | undefined,
  { signal }: { signal: AbortSignal }
): Promise<HookJSONOutput> {
  console.log("[stop] Agent finished, running cleanup...");
  return {};
}

async function main() {
  for await (const message of query({
    prompt: "Refactor the auth module to use bcrypt for password hashing",
    options: {
      hooks: {
        PreToolUse: [
          // Matcher is a regex on tool name
          { matcher: "Write|Edit", hooks: [protectSensitiveFiles] },
          { matcher: "Bash", hooks: [bashGuardrails] },
          { hooks: [auditLogger] }, // No matcher = all tools
        ],
        PostToolUse: [
          { hooks: [resultLogger] },
        ],
        Stop: [
          { hooks: [onStop] }, // Matchers are ignored for lifecycle hooks
        ],
      },
    },
  })) {
    if (message.type === "result") {
      if (message.subtype === "success") {
        console.log(`\nDone: ${message.result}`);
        console.log(`Cost: $${message.total_cost_usd.toFixed(4)}`);
      } else {
        console.error(message.subtype, message.errors);
      }
    }
  }
}

main().catch(console.error);
