import { query, createSdkMcpServer, tool } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

/**
 * Custom MCP Server Template
 *
 * Demonstrates:
 * - Creating in-process MCP servers with createSdkMcpServer
 * - Defining tools with Zod schemas
 * - Using multiple MCP servers in one query
 */

const weatherServer = createSdkMcpServer({
  name: "weather-service",
  version: "1.0.0",
  tools: [
    tool(
      "get_weather",
      "Get current weather for a location",
      {
        location: z.string().describe("City name"),
        units: z.enum(["celsius", "fahrenheit"]).default("celsius"),
      },
      async (args) => {
        // Replace with real API call
        return {
          content: [
            {
              type: "text",
              text: `Weather in ${args.location}: 22° ${args.units}, sunny`,
            },
          ],
        };
      }
    ),
  ],
});

const mathServer = createSdkMcpServer({
  name: "math",
  version: "1.0.0",
  tools: [
    tool(
      "calculate",
      "Evaluate a math expression",
      { a: z.number(), b: z.number(), op: z.enum(["+", "-", "*", "/"]) },
      async ({ a, b, op }) => {
        const ops = { "+": a + b, "-": a - b, "*": a * b, "/": a / b };
        return {
          content: [{ type: "text", text: `${a} ${op} ${b} = ${ops[op]}` }],
        };
      }
    ),
  ],
});

async function useCustomTools() {
  for await (const message of query({
    prompt: "What's the weather in Tokyo? Also calculate 15% of 85.50",
    options: {
      mcpServers: {
        "weather-service": weatherServer,
        math: mathServer,
      },
      allowedTools: [
        "mcp__weather-service__get_weather",
        "mcp__math__calculate",
      ],
    },
  })) {
    if (message.type === "assistant") {
      for (const block of message.message.content) {
        if (block.type === "text") console.log(block.text);
      }
    } else if (message.type === "result" && message.subtype === "success") {
      console.log("Result:", message.result);
    }
  }
}

useCustomTools().catch(console.error);
