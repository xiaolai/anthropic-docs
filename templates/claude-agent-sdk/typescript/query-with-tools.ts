import { query } from "@anthropic-ai/claude-agent-sdk";

/**
 * Query with Tool Control Template
 *
 * Demonstrates:
 * - allowedTools / disallowedTools
 * - System prompts
 * - Handling assistant messages with API message objects
 */

async function queryWithTools() {
  for await (const message of query({
    prompt: "Review the auth module for security issues and fix vulnerabilities",
    options: {
      workingDirectory: "/path/to/project",
      systemPrompt: `You are a security-focused code reviewer.
Analyze code for SQL injection, XSS, auth bypass, and OWASP issues.`,

      allowedTools: ["Read", "Grep", "Glob", "Write", "Edit"],
      disallowedTools: ["Bash"],
    },
  })) {
    switch (message.type) {
      case "assistant":
        // message.message is the full Anthropic API APIAssistantMessage
        for (const block of message.message.content) {
          if (block.type === "text") {
            console.log(block.text);
          } else if (block.type === "tool_use") {
            console.log(`Tool: ${block.name}`);
          }
        }
        break;

      case "result":
        if (message.subtype === "success") {
          console.log(`\nResult: ${message.result}`);
          console.log(`Cost: $${message.total_cost_usd.toFixed(4)}`);
        } else {
          console.error(`Error: ${message.subtype}`, message.errors);
        }
        break;
    }
  }
}

queryWithTools().catch(console.error);
