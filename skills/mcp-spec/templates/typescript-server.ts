// Minimal MCP server in TypeScript using @modelcontextprotocol/sdk.
// Exposes one tool (`echo`) and one resource (`hello://world`).
// See rules/mcp-server-impl.md for correctness rules.
//
// Run with: tsx typescript-server.ts
// Or compile + run as a stdio MCP server (Claude Desktop, Claude Code).

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ListResourcesRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const SERVER_NAME = "example-mcp-server";
const SERVER_VERSION = "1.0.0";
const PROTOCOL_VERSION = "2025-11-25"; // Rule 4: pin the protocol version we tested against.

const server = new Server(
  { name: SERVER_NAME, version: SERVER_VERSION },
  {
    // Rule 1: only declare what we actually handle.
    capabilities: {
      tools: {},
      resources: {},
    },
  }
);

// ─── Tools ──────────────────────────────────────────────────────────────────

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: "echo",
      description: "Echo the input message back to the caller.",
      inputSchema: {
        type: "object",
        properties: {
          message: { type: "string", description: "Text to echo" },
        },
        required: ["message"],
      },
      // Rule 3: explicit annotations help clients render permission prompts.
      annotations: {
        title: "Echo",
        readOnlyHint: true,
        destructiveHint: false,
        idempotentHint: true,
        openWorldHint: false,
      },
    },
  ],
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  if (name === "echo") {
    const message = (args as { message: string })?.message ?? "";
    return {
      content: [{ type: "text", text: `echo: ${message}` }],
    };
  }
  // Rule 7: tool-level error vs protocol-level error. Unknown-tool is a
  // protocol-level error — throw to let the SDK return -32602.
  throw new Error(`Unknown tool: ${name}`);
});

// ─── Resources ──────────────────────────────────────────────────────────────

server.setRequestHandler(ListResourcesRequestSchema, async () => ({
  resources: [
    {
      uri: "hello://world",        // Rule 6: absolute URI with a real scheme.
      name: "Hello, World",
      description: "A greeting resource.",
      mimeType: "text/plain",
    },
  ],
}));

server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  if (request.params.uri === "hello://world") {
    return {
      contents: [
        {
          uri: "hello://world",
          mimeType: "text/plain",
          text: "Hello, World!",
        },
      ],
    };
  }
  throw new Error(`Unknown resource: ${request.params.uri}`);
});

// ─── Boot ───────────────────────────────────────────────────────────────────

// Rule 5: stderr for logs (stdio servers use stdin/stdout for JSON-RPC ONLY).
console.error(`Starting ${SERVER_NAME} v${SERVER_VERSION} (MCP ${PROTOCOL_VERSION})`);

const transport = new StdioServerTransport();
await server.connect(transport);
