import { query, createSdkMcpServer, tool } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

/**
 * Multi-Agent Workflow Template
 *
 * Demonstrates:
 * - Orchestrator with specialized subagents
 * - Custom MCP tools shared across agents
 * - canUseTool with { signal } parameter
 * - Task tool required for subagent invocation
 */

const appTools = createSdkMcpServer({
  name: "app-services",
  version: "1.0.0",
  tools: [
    tool(
      "send_notification",
      "Send notification to a team",
      {
        message: z.string(),
        priority: z.enum(["low", "medium", "high"]).default("medium"),
      },
      async (args) => ({
        content: [{ type: "text", text: `Sent (${args.priority}): ${args.message}` }],
      })
    ),
    tool(
      "check_health",
      "Check service health",
      { service: z.string() },
      async (args) => ({
        content: [{ type: "text", text: JSON.stringify({ service: args.service, status: "healthy" }) }],
      })
    ),
  ],
});

async function runWorkflow(task: string) {
  for await (const message of query({
    prompt: task,
    options: {
      systemPrompt: "You are a DevOps orchestrator. Coordinate agents to complete tasks safely.",
      mcpServers: { "app-services": appTools },

      agents: {
        "deployer": {
          description: "Handles deployments and rollbacks",
          prompt: "You deploy applications. Always verify health after deployment.",
          tools: ["Bash", "Read", "mcp__app-services__check_health", "mcp__app-services__send_notification"],
          model: "sonnet",
        },
        "security-checker": {
          description: "Security audits and vulnerability scanning",
          prompt: "Scan for exposed secrets, outdated deps, and OWASP issues.",
          tools: ["Read", "Grep", "Bash"],
          model: "sonnet",
        },
        "monitor": {
          description: "System monitoring and alerting",
          prompt: "Check metrics, error rates, and system health.",
          tools: ["Bash", "Read", "mcp__app-services__check_health"],
          model: "haiku",
        },
      },

      // Task is required for the orchestrator to invoke subagents
      allowedTools: [
        "Task", "Read", "Bash", "Grep",
        "mcp__app-services__send_notification",
        "mcp__app-services__check_health",
      ],

      canUseTool: async (toolName, input, { signal }) => {
        // Block destructive commands
        if (toolName === "Bash") {
          const dangerous = ["rm -rf", "dd if=", "mkfs", "shutdown"];
          if (dangerous.some((p) => input.command?.includes(p))) {
            return { behavior: "deny", message: `Blocked: ${input.command}` };
          }
        }
        return { behavior: "allow", updatedInput: input };
      },
    },
  })) {
    switch (message.type) {
      case "system":
        if (message.subtype === "init") {
          console.log(`Session: ${message.session_id}`);
        }
        break;
      case "assistant":
        for (const block of message.message.content) {
          if (block.type === "text") console.log(block.text);
        }
        break;
      case "result":
        if (message.subtype === "success") {
          console.log("\nDone:", message.result);
          console.log(`Cost: $${message.total_cost_usd.toFixed(4)}`);
        } else {
          console.error("Error:", message.subtype, message.errors);
        }
        break;
    }
  }
}

runWorkflow("Deploy v2.5.0 with security check and health monitoring").catch(console.error);
