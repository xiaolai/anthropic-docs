import { query } from "@anthropic-ai/claude-agent-sdk";

/**
 * Basic Query Template
 *
 * Demonstrates:
 * - Simple query execution
 * - Message type handling
 * - Session ID capture
 */

async function basicQuery() {
  let sessionId: string | undefined;

  for await (const message of query({
    prompt: "Analyze the codebase and suggest improvements",
    options: {
      allowedTools: ["Read", "Grep", "Glob"],
      permissionMode: "bypassPermissions",
      allowDangerouslySkipPermissions: true,
    },
  })) {
    switch (message.type) {
      case "system":
        if (message.subtype === "init") {
          sessionId = message.session_id;
          console.log(`Session: ${sessionId}`);
          console.log(`Model: ${message.model}`);
          console.log(`Tools: ${message.tools.join(", ")}`);
        }
        break;

      case "assistant":
        // message.message is the full Anthropic API message object
        console.log("Assistant response received");
        break;

      case "result":
        if (message.subtype === "success") {
          console.log(`Result: ${message.result}`);
          console.log(`Cost: $${message.total_cost_usd.toFixed(4)}`);
          console.log(`Turns: ${message.num_turns}`);
        } else {
          console.error(`Error: ${message.subtype}`, message.errors);
        }
        break;
    }
  }
}

basicQuery().catch(console.error);
