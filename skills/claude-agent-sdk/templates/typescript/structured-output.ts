import { query } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";
import { toJSONSchema } from "zod/v4/core";

/**
 * Structured Output Template
 *
 * Demonstrates:
 * - JSON Schema output format
 * - Zod schema with draft-07 target
 * - Parsing structured_output from result
 * - Error handling for validation failures
 */

const ReviewSchema = z.object({
  summary: z.string(),
  issues: z.array(
    z.object({
      severity: z.enum(["critical", "warning", "info"]),
      file: z.string(),
      line: z.number().optional(),
      description: z.string(),
    })
  ),
  score: z.number().min(0).max(100),
  recommendation: z.enum(["approve", "request_changes", "needs_discussion"]),
});

async function structuredReview() {
  for await (const message of query({
    prompt: "Review the codebase for security issues and code quality",
    options: {
      allowedTools: ["Read", "Grep", "Glob"],
      permissionMode: "bypassPermissions",
      allowDangerouslySkipPermissions: true,
      outputFormat: {
        type: "json_schema",
        // IMPORTANT: Use target: "draft-07" — Claude requires draft-07, not draft-2020-12
        schema: toJSONSchema(ReviewSchema, { target: "draft-07" }),
      },
    },
  })) {
    switch (message.type) {
      case "result":
        if (message.subtype === "success" && message.structured_output) {
          const parsed = ReviewSchema.safeParse(message.structured_output);
          if (parsed.success) {
            console.log(`Score: ${parsed.data.score}/100`);
            console.log(`Recommendation: ${parsed.data.recommendation}`);
            console.log(`Issues found: ${parsed.data.issues.length}`);
            for (const issue of parsed.data.issues) {
              console.log(`  [${issue.severity}] ${issue.file}:${issue.line ?? "?"} — ${issue.description}`);
            }
          } else {
            console.error("Schema validation failed:", parsed.error);
          }
        } else if (message.subtype === "error_max_structured_output_retries") {
          console.error("Agent failed to produce valid structured output after retries");
        } else if (message.subtype !== "success") {
          console.error(`Error: ${message.subtype}`, message.errors);
        }
        break;
    }
  }
}

structuredReview().catch(console.error);
